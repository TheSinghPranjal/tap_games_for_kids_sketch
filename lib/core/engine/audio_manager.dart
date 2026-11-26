import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener, AppLifecycleState, Curves;

import 'app_settings.dart';

enum Sfx { tap, pop, collect, bonus, gem, chirp, splash, whoosh, cheer, soft }

/// Gentle synthesized sound effects (no loud or startling sounds), a soft
/// looping background tune and light haptics. Sound effects, music and
/// vibration each follow their own setting.
class AudioManager {
  AudioManager(this.settings);
  final AppSettings settings;

  static const _sfxVolume = 0.45;
  static const _musicVolume = 0.22;

  final _players = <AudioPlayer>[];
  final _clips = <Sfx, Uint8List>{};
  var _next = 0;
  var _broken = false;
  final _lastPlayed = <Sfx, int>{};

  AudioPlayer? _music;
  Future<Uint8List>? _tune;
  Timer? _fade;
  AppLifecycleListener? _lifecycle;
  bool _foreground = true;
  bool _started = false;

  /// Starts background music (if enabled) and follows the music setting and
  /// the app lifecycle from now on. Tests never call this, so no platform
  /// audio is touched there.
  void start() {
    if (_started) return;
    _started = true;
    try {
      // One shared, non-exclusive audio context: effects never steal focus
      // from the music, other apps keep playing, and on iOS the silent
      // switch is respected.
      AudioPlayer.global
          .setAudioContext(
            AudioContext(
              android: const AudioContextAndroid(
                usageType: AndroidUsageType.game,
                contentType: AndroidContentType.music,
                audioFocus: AndroidAudioFocus.none,
              ),
              iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
            ),
          )
          .catchError((Object e) => debugPrint('Audio context failed: $e'));
    } catch (e) {
      debugPrint('Audio context unavailable: $e');
    }
    settings.addListener(_syncMusic);
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _foreground = state == AppLifecycleState.resumed;
        _syncMusic();
      },
    );
    _syncMusic();
  }

  bool get _musicWanted => settings.musicOn && _foreground;

  void _syncMusic() {
    if (_musicWanted) {
      _startMusic();
    } else {
      _stopMusic();
    }
  }

  Future<void> _startMusic() async {
    try {
      final player = _music ??= AudioPlayer()..setReleaseMode(ReleaseMode.loop);
      if (player.state == PlayerState.playing) return _fadeTo(_musicVolume);
      _tune ??= compute(_synthTune, null);
      final bytes = await _tune!;
      if (!_musicWanted) return;
      await player.setVolume(0);
      await player.play(BytesSource(bytes, mimeType: 'audio/wav'), volume: 0);
      _fadeTo(_musicVolume);
    } catch (e) {
      debugPrint('Music failed: $e');
    }
  }

  void _stopMusic() {
    final player = _music;
    if (player == null || player.state != PlayerState.playing) return;
    _fadeTo(0, then: () => player.pause().catchError((Object e) => debugPrint('Music pause failed: $e')));
  }

  /// Smoothly ramps the music volume over ~0.6 s instead of cutting it.
  void _fadeTo(double target, {VoidCallback? then}) {
    final player = _music;
    if (player == null) return;
    _fade?.cancel();
    final from = player.volume;
    const steps = 12;
    var i = 0;
    _fade = Timer.periodic(const Duration(milliseconds: 50), (t) {
      i++;
      final v = from + (target - from) * Curves.easeInOut.transform(i / steps);
      player.setVolume(v).catchError((Object _) {});
      if (i >= steps) {
        t.cancel();
        then?.call();
      }
    });
  }

  void play(Sfx sfx) {
    // Rate-limit identical sounds during rapid tapping.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - (_lastPlayed[sfx] ?? 0) < 60) return;
    _lastPlayed[sfx] = now;
    _haptic(sfx);
    if (settings.muted) return;
    _ensure();
    if (_broken || _players.isEmpty) return;
    final bytes = _clips.putIfAbsent(sfx, () => _synth(sfx));
    final p = _players[_next++ % _players.length];
    p.play(BytesSource(bytes, mimeType: 'audio/wav'), volume: _sfxVolume).catchError((Object e) {
      _broken = true;
      debugPrint('Audio failed: $e');
    });
  }

  /// Feedback for pressing a menu button: a soft click and a haptic tick.
  void buttonTap() => play(Sfx.tap);

  void _haptic(Sfx sfx) {
    if (!settings.vibrationOn) return;
    switch (sfx) {
      case Sfx.tap || Sfx.pop || Sfx.collect:
        HapticFeedback.selectionClick();
      case Sfx.bonus || Sfx.gem || Sfx.cheer:
        HapticFeedback.lightImpact();
      case Sfx.chirp || Sfx.splash || Sfx.whoosh || Sfx.soft:
        break;
    }
  }

  void _ensure() {
    if (_players.isNotEmpty || _broken) return;
    try {
      for (var i = 0; i < 4; i++) {
        _players.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      }
    } catch (e) {
      _broken = true;
      debugPrint('Audio unavailable: $e');
    }
  }

  void dispose() {
    _fade?.cancel();
    _lifecycle?.dispose();
    if (_started) settings.removeListener(_syncMusic);
    _music?.dispose();
    for (final p in _players) {
      p.dispose();
    }
    _players.clear();
  }

  // ------------------------------------------------------------ synthesis

  static Uint8List _synth(Sfx sfx) {
    switch (sfx) {
      case Sfx.tap:
        return _tones([(880, 0.05)], vol: 0.25);
      case Sfx.pop:
        return _tones([(660, 0.04), (990, 0.06)], vol: 0.35);
      case Sfx.collect:
        return _tones([(784, 0.06), (1046, 0.09)], vol: 0.35);
      case Sfx.bonus:
        return _tones([(784, 0.06), (988, 0.06), (1318, 0.12)], vol: 0.35);
      case Sfx.gem:
        return _tones([(1046, 0.07), (1318, 0.07), (1568, 0.16)], vol: 0.3);
      case Sfx.chirp:
        return _sweep(1400, 2100, 0.09, vol: 0.25);
      case Sfx.splash:
        return _sweep(600, 300, 0.14, vol: 0.25);
      case Sfx.whoosh:
        return _sweep(300, 700, 0.18, vol: 0.18);
      case Sfx.cheer:
        return _tones([(523, 0.09), (659, 0.09), (784, 0.09), (1046, 0.2)], vol: 0.3);
      case Sfx.soft:
        return _tones([(392, 0.12)], vol: 0.2);
    }
  }

  static const _rate = 22050;

  static Uint8List _tones(List<(double, double)> notes, {double vol = 0.3}) {
    final samples = <double>[];
    for (final (f, d) in notes) {
      final n = (d * _rate).round();
      for (var i = 0; i < n; i++) {
        final t = i / _rate;
        final env = math.min(1.0, i / (_rate * 0.005)) * math.pow(1 - i / n, 1.6);
        samples.add(vol * env * (math.sin(2 * math.pi * f * t) + 0.25 * math.sin(4 * math.pi * f * t)));
      }
    }
    return _wav(samples);
  }

  static Uint8List _sweep(double f0, double f1, double d, {double vol = 0.3}) {
    final n = (d * _rate).round();
    final samples = <double>[];
    var phase = 0.0;
    for (var i = 0; i < n; i++) {
      final f = f0 + (f1 - f0) * i / n;
      phase += 2 * math.pi * f / _rate;
      final env = math.sin(math.pi * i / n);
      samples.add(vol * env * math.sin(phase));
    }
    return _wav(samples);
  }

  /// A calm 12-second music-box loop in C major pentatonic with a soft bass.
  /// Note tails wrap around the end so the loop is seamless.
  static Uint8List _synthTune(void _) {
    const beat = 0.375;
    // Semitones above C5; null is a rest.
    const melody = <int?>[
      4, 7, 9, 7, 4, 2, 0, 2, //
      4, 7, 9, 12, 9, 7, 4, null,
      2, 4, 7, 4, 2, 0, 2, 4,
      0, 2, 4, 7, 4, 2, 0, null,
    ];
    // One bass note per bar (semitones above C3): C, A, F, G.
    const bass = [0, -3, -7, -5, 0, -3, -7, -5];
    final total = (melody.length * beat * _rate).round();
    final buf = Float64List(total);

    void note(double start, double freq, double vol, double decay) {
      final s0 = (start * _rate).round();
      final n = (decay * 4 * _rate).round();
      for (var i = 0; i < n; i++) {
        final t = i / _rate;
        final env = math.min(1.0, i / (_rate * 0.008)) * math.exp(-t / decay);
        final v = vol * env * (math.sin(2 * math.pi * freq * t) + 0.18 * math.sin(4 * math.pi * freq * t));
        buf[(s0 + i) % total] += v;
      }
    }

    double hz(double base, int semis) => base * math.pow(2, semis / 12).toDouble();
    for (var i = 0; i < melody.length; i++) {
      final m = melody[i];
      if (m != null) note(i * beat, hz(523.25, m), 0.22, 0.35);
    }
    for (var b = 0; b < bass.length; b++) {
      note(b * 4 * beat, hz(130.81, bass[b]), 0.2, 0.9);
      note((b * 4 + 2) * beat, hz(130.81, bass[b] + 7), 0.12, 0.6);
    }
    return _wav(buf);
  }

  static Uint8List _wav(List<double> s) {
    final data = ByteData(44 + s.length * 2);
    void str(int o, String v) {
      for (var i = 0; i < v.length; i++) {
        data.setUint8(o + i, v.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    data.setUint32(4, 36 + s.length * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, _rate, Endian.little);
    data.setUint32(28, _rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    str(36, 'data');
    data.setUint32(40, s.length * 2, Endian.little);
    for (var i = 0; i < s.length; i++) {
      data.setInt16(44 + i * 2, (s[i].clamp(-1.0, 1.0) * 32767).round(), Endian.little);
    }
    return data.buffer.asUint8List();
  }
}
