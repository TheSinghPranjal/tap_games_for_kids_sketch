import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../core/engine/app_settings.dart';
import '../core/sketch/ink.dart';
import '../l10n/l10n.dart';
import '../ui/sketch_widgets.dart';
import 'how_to_play_screen.dart';

Future<void> openSettings(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));

/// Every preference in one place: sound, music, vibration, theme, motion,
/// language, little-kid mode and the how-to-play guide. Changes apply (and
/// are saved) immediately.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return NotebookPage(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            final l = context.l10n;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: Row(
                    children: [
                      SketchButton(
                        semanticLabel: l.back,
                        padding: const EdgeInsets.all(10),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const DoodleIcon(Doodle.back),
                      ),
                      Expanded(
                        child: Center(
                          child: FittedBox(fit: BoxFit.scaleDown, child: ScribbleTitle(l.settings)),
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
                Expanded(
                  // A new language cross-fades in rather than snapping.
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey(settings.languageCode),
                      child: _SettingsList(settings: settings),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Section(
              title: l.settingsSoundSection,
              seed: 1,
              children: [
                _SwitchRow(
                  icon: Doodle.soundOn,
                  label: l.settingsSoundEffects,
                  value: settings.soundOn,
                  onChanged: settings.setSoundOn,
                ),
                _SwitchRow(
                  icon: Doodle.music,
                  label: l.settingsMusic,
                  value: settings.musicOn,
                  onChanged: settings.setMusicOn,
                ),
                _SwitchRow(
                  icon: Doodle.vibrate,
                  label: l.settingsVibration,
                  value: settings.vibrationOn,
                  onChanged: settings.setVibrationOn,
                ),
              ],
            ),
            _Section(
              title: l.settingsLookSection,
              seed: 2,
              children: [
                _RowLabel(icon: Doodle.sun, label: l.settingsTheme),
                const SizedBox(height: 8),
                _ChoiceGroup<ThemeMode>(
                  value: settings.themeMode,
                  onChanged: settings.setThemeMode,
                  options: [
                    (ThemeMode.light, Doodle.sun, l.themeLight),
                    (ThemeMode.dark, Doodle.moon, l.themeDark),
                    (ThemeMode.system, Doodle.auto, l.themeSystem),
                  ],
                ),
                const SizedBox(height: 6),
                _SwitchRow(
                  icon: Doodle.star,
                  label: l.settingsGentleMotion,
                  hint: l.settingsGentleMotionHint,
                  value: settings.reducedMotion,
                  onChanged: settings.setReducedMotion,
                ),
              ],
            ),
            _Section(
              title: l.settingsLanguage,
              seed: 3,
              children: [
                _ChoiceGroup<String>(
                  value: L10n.byCode(settings.languageCode).code,
                  onChanged: settings.setLanguage,
                  columns: 2,
                  options: [for (final lang in L10n.languages) (lang.code, null, lang.nativeName)],
                ),
              ],
            ),
            _Section(
              title: l.settingsPlaySection,
              seed: 4,
              children: [
                _SwitchRow(
                  icon: Doodle.heartFilled,
                  label: l.settingsLittleKid,
                  hint: l.settingsLittleKidHint,
                  value: settings.simpleMode,
                  onChanged: settings.setSimpleMode,
                ),
                _LinkRow(
                  icon: Doodle.book,
                  label: l.settingsHowToPlay,
                  hint: l.settingsHowToPlayHint,
                  onTap: () => openHowToPlay(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, required this.seed});
  final String title;
  final List<Widget> children;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Semantics(header: true, child: Text(title, style: Txt.heading)),
          ),
          SketchBox(
            fill: context.palette.surface,
            seed: seed + 20,
            radius: 20,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.icon, required this.label, this.hint});
  final Doodle icon;
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DoodleIcon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Txt.body.copyWith(fontSize: 17)),
              if (hint != null) Text(hint!, style: Txt.small.soft(context)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A whole-row toggle: tapping anywhere on the row flips it.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.icon, required this.label, required this.value, required this.onChanged, this.hint});
  final Doodle icon;
  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onChanged(!value);
            // After the change, so switching sound or vibration on confirms itself.
            AppScope.of(context).audio.buttonTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                Expanded(
                  child: _RowLabel(icon: icon, label: label, hint: hint),
                ),
                const SizedBox(width: 10),
                SketchSwitch(value: value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.onTap, this.hint});
  final Doodle icon;
  final String label;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppScope.of(context).audio.buttonTap();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Expanded(
                child: _RowLabel(icon: icon, label: label, hint: hint),
              ),
              const DoodleIcon(Doodle.forward, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hand-drawn on/off switch whose knob slides (and the track fills) smoothly.
class SketchSwitch extends StatelessWidget {
  const SketchSwitch({super.key, required this.value});
  final bool value;

  static const _duration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 64,
      height: 38,
      child: Stack(
        children: [
          // Two tracks cross-fade so the sketch outline never re-records per frame.
          for (final on in [false, true])
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: on == value ? 1 : 0,
                duration: _duration,
                curve: Curves.easeInOut,
                child: SketchBox(
                  fill: on ? p.tint(Ink.mint, 0.7) : p.surfaceWarm,
                  radius: 19,
                  seed: on ? 7 : 8,
                  padding: EdgeInsets.zero,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          AnimatedAlign(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            duration: _duration,
            curve: Curves.easeOutBack,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: SketchBox(
                fill: Ink.white,
                radius: 14,
                seed: 9,
                padding: EdgeInsets.zero,
                child: SizedBox.square(
                  dimension: 28,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: _duration,
                      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                      child: DoodleIcon(
                        value ? Doodle.check : Doodle.close,
                        key: ValueKey(value),
                        size: 14,
                        color: value ? Ink.leaf : Ink.navySoft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row (or grid) of chips where exactly one is selected.
class _ChoiceGroup<T> extends StatelessWidget {
  const _ChoiceGroup({required this.value, required this.onChanged, required this.options, this.columns = 3});
  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, Doodle?, String)> options;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rows = <Widget>[];
    for (var i = 0; i < options.length; i += columns) {
      final slice = options.sublist(i, (i + columns).clamp(0, options.length));
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
          child: Row(
            children: [
              for (final (j, (option, icon, label)) in slice.indexed) ...[
                if (j > 0) const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    selected: option == value,
                    inMutuallyExclusiveGroup: true,
                    child: AnimatedScale(
                      scale: option == value ? 1.0 : 0.96,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: SketchButton(
                        fill: option == value ? p.selected : p.surfaceWarm,
                        seed: i + j + 3,
                        radius: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        onTap: () => onChanged(option),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[DoodleIcon(icon, size: 22), const SizedBox(width: 6)],
                            Text(
                              label,
                              style: Txt.body.copyWith(
                                fontSize: 17,
                                fontWeight: option == value ? FontWeight.w900 : FontWeight.w700,
                              ),
                            ),
                            if (option == value) ...[
                              const SizedBox(width: 6),
                              const DoodleIcon(Doodle.check, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              // Keep a short last row aligned to the grid.
              for (var k = slice.length; k < columns; k++) ...[const SizedBox(width: 10), const Spacer()],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
