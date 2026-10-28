import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../core/sketch/ink.dart';
import '../ui/sketch_widgets.dart';

Future<void> showSettingsDialog(BuildContext context) {
  final settings = AppScope.of(context).settings;
  return showSketchDialog(
    context,
    builder: (ctx) {
      return ListenableBuilder(
        listenable: settings,
        builder: (ctx, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ScribbleTitle('Settings', style: Txt.heading),
            const SizedBox(height: 16),
            _Toggle(
              icon: DoodleIcon(settings.muted ? Doodle.soundOff : Doodle.soundOn),
              label: 'Sounds',
              value: !settings.muted,
              onChanged: (v) => settings.setMuted(!v),
            ),
            _Toggle(
              icon: const DoodleIcon(Doodle.star),
              label: 'Gentle motion',
              value: settings.reducedMotion,
              onChanged: settings.setReducedMotion,
            ),
            _Toggle(
              icon: const DoodleIcon(Doodle.heartFilled),
              label: 'Little-kid mode',
              hint: 'slower, bigger, longer rounds',
              value: settings.simpleMode,
              onChanged: settings.setSimpleMode,
            ),
            const SizedBox(height: 12),
            SketchButton(
              fill: Ink.blushPink,
              onTap: () => Navigator.of(ctx).pop(),
              child: const Text('Done', style: Txt.heading),
            ),
          ],
        ),
      );
    },
  );
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.icon, required this.label, required this.value, required this.onChanged, this.hint});
  final Widget icon;
  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Txt.body),
                if (hint != null) Text(hint!, style: Txt.small),
              ],
            ),
          ),
          SketchButton(
            semanticLabel: '$label ${value ? 'on' : 'off'}',
            fill: value ? Ink.tint(Ink.mint, 0.3) : Ink.white,
            padding: const EdgeInsets.all(10),
            onTap: () => onChanged(!value),
            child: DoodleIcon(value ? Doodle.check : Doodle.close, size: 24),
          ),
        ],
      ),
    );
  }
}
