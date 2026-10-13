---
tags: [system, m1, run-loop]
status: implemented
side: server
---
# RunStateService

## Purpose
The M1 run loop ([[First Playable (M1)]]):

**Lobby → InTrain → Cleared or Wiped → Results → PLAY AGAIN → Lobby.**

It decides when a train starts and ends, sends the results, and resets everything for PLAY
AGAIN. It's deliberately not named `RunService`, which is Roblox's own service.

## Code
- Studio path: `ServerScriptService.Server.Services.RunStateService` (`Modes = { "Run" }`)

## Expects in the place
- A part tagged `TrainGoal` (the engine cab roof, [[TrainService]]).
- Remotes `RequestReady`, `Announce` and `RunEnded`.

## Public API
None. Other systems read the workspace attribute `RunState`.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `RequestReady` | client → server | none | 2/s, burst 2. Only acts in `Lobby` (READY) and `Results` (PLAY AGAIN): it sets Player attribute `Ready = true` |
| `Announce` | server → all clients | `text: string` | — |
| `RunEnded` | server → all clients | `Types.RunResult`: `{ outcome, time, players = { { name, knockouts, revives, blueprints } } }` | — |

## Data / state
- **Workspace attributes:**
  - `RunState` (`Types.RunState`),
  - `StartsAt`: the server time the train starts, while in the Lobby.
- **Player attributes:** `Ready`, and `Knockouts` (counted by [[CombatService]]).
- It ticks every `RUN_CHECK_INTERVAL` (0.25 s).
- **Lobby:**
  - the auto-start is `LOBBY_AUTO_START` (20 s) after a player is present,
  - once everyone is `Ready`, the start is `READY_COUNTDOWN` (5 s) away, if that's sooner,
  - at the start: everyone's `Ready` is cleared, it announces **ALL ABOARD!** and calls
    `SpawnService.begin()`.
- **InTrain:**
  - **Wiped** when `SquadService.allDown()`,
  - **Cleared** when `TimelineDone`, `EnemyService.aliveCost() == 0` and an up player's
    root is over a `TrainGoal` part's X span and above its top,
  - either way it calls `SpawnService.stop()` and announces **TRAIN CLEARED!** or **SQUAD
    WIPED!**. After `RUN_END_DELAY` (3 s) it moves to `Results` and fires `RunEnded`.
- **Results:** once everyone has pressed PLAY AGAIN (`Ready`), it resets:
  - `SpawnService.stop`, `EnemyService.clear`, `TrainService.build`, `PickupService.reset`,
  - for each player: `SquadService.reset`, `Knockouts = 0`, `Ready = true` and
    `CharacterService.spawn`.

  Then it's back to `Lobby`. Everyone is already Ready, so the 5 s countdown starts
  straight away.

## Depends on
- [[SpawnService]], [[EnemyService]], [[TrainService]], [[CharacterService]],
  [[PickupService]], [[SquadService]], [[Guard]], `Shared.Constants`, `Shared.Types`

## Notes
- Verified 2026-10-13 in a one-player playtest:
  - clicking READY → `StartsAt` 5 s → `InTrain`, with no errors,
  - Health 0 → `Wiped` → `Results` after 3 s, and RunEndGui showed SQUAD WIPED, 0:31 and
    1 KO,
  - PLAY AGAIN → Lobby with Health 100, KOs 0, no enemies, a respawn at staging and
    `Ready` → `InTrain`,
  - standing on the engine roof with the timeline forced done and the enemies cleared →
    `Cleared` → `Results`.
- PLAY AGAIN needs **everyone**. A player who joins during Results, or never presses it,
  blocks the reset. Add a timeout if that bites in co-op tests.
- Players who join mid-run spawn at staging and join in. There's no late-join rule yet.
