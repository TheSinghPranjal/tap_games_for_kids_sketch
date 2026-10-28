# TinyThink — Tap & Drag Games

17 hand-drawn, notebook-doodle 2D mini-games for kids, built with Flutter
`CustomPainter` (no image assets, no 3D).

## Layout

| Path | What |
|---|---|
| `lib/core/rewards/` | `RewardService` — the single source of truth for gems, daily free plays and history. `RewardStore` is the storage boundary (`PrefsRewardStore` today; swap in a server-backed store to make a backend authoritative). |
| `lib/core/engine/` | `GameScene` base class (+ fx, flights), `GameDefinition`/`GameRegistry`, `GameSessionManager` + `ScoreManager`, `GameCanvas` (renderer + input), `AudioManager` (synthesized gentle sfx), `AppSettings` (mute, gentle motion, little-kid mode, favorites). |
| `lib/core/sketch/` | Sketch toolkit: roughened outlines, colored-pencil hatching, graph paper, sprite picture cache. |
| `lib/art/` | Procedural doodle sprites (critters, nature, props). |
| `lib/games/` | One file per game; `catalog.dart` registers them. |
| `lib/screens/` | Hub, intro (start validation + gem confirmation), play (HUD, pause, results). |

## Reward rules

- 1 gem per 20 points, granted at each 20-point milestone (`floor(score / 20)`).
- 3 free rounds per game per local day; then 1 gem per round, charged only after the
  child confirms and the round is persisted. Start requests are idempotent.
- Score events are idempotent per event id; completion is idempotent per round.
- The day never moves backwards, so winding the clock back can't unlock free plays.

## Adding a game

Create a `GameScene` subclass and a `GameDefinition`, then add it to `allGames` in
`lib/games/catalog.dart`. Games never compute gems or play limits themselves.
Drag games override `onDragStart / onDragMove / onDragEnd / cancelDrag`
(see `clean_room.dart`).

## Tests

`flutter test` — reward rules (`reward_service_test.dart`), all scenes simulate/paint and
stop scoring when the round ends (`scene_snapshot_test.dart`; set `SNAPSHOT_DIR` to dump
PNGs), and the hub → intro → play → results flow (`app_flow_test.dart`).
