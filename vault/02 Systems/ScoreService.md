---
tags: [system, m2, score, combo]
status: implemented
side: server
---
# ScoreService

## Purpose
Personal score and combo ([[Score and Combo]], [[Loop (M2)]] Session 8). It's server-side
only; the client just shows the attributes. Coins are in [[PickupService]], and the run-end
coin bonus is in [[RunStateService]].

## Code
- Studio path: `ServerScriptService.Server.Services.ScoreService` (`Modes = { "Run" }`)

## Expects in the place
- Enemy template attribute **`Points`**: 10 for lights, 100 for Big Bart. Edit it on
  `ServerStorage.Assets.Enemies.WildWest.*`.
- `ReplicatedStorage.Assets.Effects.KnockoutPop`: its `Label` shows "+points".

## Public API
- `ScoreService.addBonus(player, points, label)`: flat points (not multiplied) and a HUD
  pop.
- `ScoreService.startTrain()`: resets Untouchable tracking.
- `ScoreService.trainCleared(trainNumber)`: every player not bled out gets
  `SCORE_TRAIN_CLEARED + SCORE_TRAIN_CLEARED_PER_TRAIN × n` (500 + 100n). Players who took no
  damage on that train also get Untouchable (`SCORE_UNTOUCHABLE`, 1,000).
- `ScoreService.endCombos()`: called at a leap.
- `ScoreService.reset(player)`: PLAY AGAIN.

## Remotes
None. Knockout pops go out as `Effects` record `K` with a third field, `points`.

## Data / state
- **Player attributes:** `Score`, `Combo` (count), `ComboMultiplier`, `ComboEndsAt`
  (server time), plus `LastBonus` (text) and `BonusCount` (it ticks on every bonus, so
  repeats still pop).
- **Knockout** (`CombatService.onKnockout` with a `by` player):
  - the count goes +1 if your combo is still active, otherwise it restarts at 1,
  - the multiplier comes from `COMBO_TIERS`: 5 → ×2, 10 → ×3, 20 → ×4, 35 → ×6,
  - points = `Points` × multiplier, and `ComboEndsAt` = now + `COMBO_WINDOW` (2.5 s),
  - **assists:** every other damager whose combo is active has their timer refreshed,
    with no count added,
  - **thief caught:** a knockout of a `CarriesBlueprint` enemy is +500.
- **The combo ends** when its timer runs out, when you're `Downed` (checked every 0.25 s),
  or at `endCombos()`.
- **Revives:** it watches the `Revives` attribute from [[SquadService]]; each new revive is
  +250.
- **Untouchable:** any `CombatService.onPlayerDamaged` hit marks you for the current
  train.

## Depends on
- [[CombatService]] (`onKnockout`, `onPlayerDamaged`, `effect`), `Shared.Constants`

## Notes
- Verified 2026-10-14 in a playtest:
  - 1 knockout scored 10,
  - a spin that knocked out 6 at once gave combo 6, ×2 and +80 (10 + 4×10 + 2×20 = 90
    total),
  - the combo expired after 2.5 s,
  - the HUD showed the score, coins and combo badge,
  - the results showed the squad score, score and coins (with the run-end bonus) and TOP
    SCORE.
- **Not verified:** assists and the revive bonus (they need 2+ players), and Untouchable
  and train-clear bonuses on a real clear.
- Bosses (1,000 to the finisher + 500 per helper) and boosters come in M3/M4.
