import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';

enum Sfx { tap, pop, collect, bonus, gem, chirp, splash, whoosh, cheer, soft }

/// Gentle synthesized sound effects (no loud or startling sounds) plus a
/// light haptic tick. Respects the global mute setting.
class AudioManager {
  AudioManager(this.settings);
  final AppSettings settings;

  final _players = <AudioPlayer>[];
  final _clips = <Sfx, Uint8List>{};
  var _next = 0;
  var _broken = false;
  final _lastPlayed = <Sfx, int>{};

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

  void play(Sfx sfx) {
    if (settings.muted) return;
    // Rate-limit identical sounds during rapid tapping.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - (_lastPlayed[sfx] ?? 0) < 60) return;
    _lastPlayed[sfx] = now;
    if (sfx == Sfx.tap || sfx == Sfx.pop || sfx == Sfx.collect) HapticFeedback.selectionClick();
    _ensure();
    if (_broken || _players.isEmpty) return;
    final bytes = _clips.putIfAbsent(sfx, () => _synth(sfx));
    final p = _players[_next++ % _players.length];
    p.play(BytesSource(bytes, mimeType: 'audio/wav'), volume: 0.45).catchError((Object e) {
      _broken = true;
      debugPrint('Audio failed: $e');
    });
  }

  void dispose() {
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
