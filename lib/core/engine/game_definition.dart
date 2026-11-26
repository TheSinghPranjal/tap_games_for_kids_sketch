import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../l10n/l10n.dart';
import 'game_scene.dart';

/// A piece of text looked up in the player's language.
typedef LocalizedText = String Function(AppLocalizations l);

enum Interaction { tap, drag, tapDrag }

extension InteractionX on Interaction {
  bool get isTap => this != Interaction.drag;
  bool get isDrag => this != Interaction.tap;
  String label(AppLocalizations l) => switch (this) {
    Interaction.tap => l.interactionTap,
    Interaction.drag => l.interactionDrag,
    Interaction.tapDrag => l.interactionTapDrag,
  };
}

class ScoreConfig {
  const ScoreConfig({this.base = 2, this.bonus = 6});

  /// Points for an ordinary successful action.
  final int base;

  /// Points for special (golden) objects or completed cycles.
  final int bonus;
}

class GameDefinition {
  const GameDefinition({
    required this.gameId,
    required this.name,
    required this.objective,
    required this.instructions,
    required this.interactionType,
    required this.accent,
    required this.create,
    required this.thumbnail,
    this.scoreConfig = const ScoreConfig(),
    this.roundSeconds = 60,
    this.assetManifest = const [],
    this.isEnabled = true,
  });

  final String gameId;
  final LocalizedText name;

  /// Short line for the hub card.
  final LocalizedText objective;

  /// One sentence for the intro screen.
  final LocalizedText instructions;
  final Interaction interactionType;
  final Color accent;
  final ScoreConfig scoreConfig;

  /// objectiveConfig: rounds are timed; scenes report their own progress.
  final int roundSeconds;

  /// Procedural sprite keys this game draws (all art is generated in code).
  final List<String> assetManifest;
  final bool isEnabled;
  final GameScene Function(ScoreConfig config) create;

  /// Paints the hand-drawn hub thumbnail into [size].
  final void Function(Canvas c, Size size) thumbnail;
}

/// Registers every game. Games can be disabled remotely or for testing.
class GameRegistry extends ChangeNotifier {
  final _games = <String, GameDefinition>{};
  final _disabled = <String>{};

  void register(GameDefinition def) {
    assert(!_games.containsKey(def.gameId), 'Duplicate gameId ${def.gameId}');
    _games[def.gameId] = def;
    if (!def.isEnabled) _disabled.add(def.gameId);
  }

  List<GameDefinition> get all => _games.values.toList(growable: false);
  GameDefinition? byId(String id) => _games[id];
  bool isEnabled(String id) => _games.containsKey(id) && !_disabled.contains(id);

  void setEnabled(String id, bool enabled) {
    enabled ? _disabled.remove(id) : _disabled.add(id);
    notifyListeners();
  }
}
