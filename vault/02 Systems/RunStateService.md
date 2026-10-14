---
tags: [system, m1, m2, run-loop, checkpoint]
status: implemented
side: server
---
# RunStateService

## Purpose
The run loop ([[First Playable (M1)]], [[Loop (M2)]] Session 9). It handles:
- the lobby,
- the train-by-train flow with leaps,
- legs of `LEG_TRAINS` (3) trains ending in a Thief train,
- checkpoints with a continue-or-cash-out vote,
- the wipe and cash-out endings,
- results and PLAY AGAIN.

The M2 spec's planned `CheckpointService` is folded in here; the checkpoint is just one state
of the loop. It's not named `RunService`, which is Roblox's own service.

## Code
- Studio path: `ServerScriptService.Server.Services.RunStateService` (`Modes = { "Run" }`)

## Expects in the place
- A part tagged `TrainGoal` on each hostile train (the engine cab roof, [[TrainService]]).
- `ServerStorage.Assets.Trains.HubCheckpoint` (via TrainService).
- Remotes `RequestReady`, `RequestCheckpointChoice`, `Announce` and `RunEnded`.
- `StarterGui.CheckpointGui` (CheckpointController, see [[HudController]]).

## Public API
None. Other systems read the workspace attributes.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `RequestReady` | client → server | none | 2/s, burst 2. Only in `Lobby` (READY) and `Results` (PLAY AGAIN): it sets Player `Ready = true` |
| `RequestCheckpointChoice` | client → server | `"Continue" \| "CashOut"` | `Guard.oneOf`, 1/s with burst 2, a strike on a bad payload. Ignored outside `Checkpoint`. You can change your vote until everyone has voted |
| `Announce` | server → all clients | `text` | — |
| `RunEnded` | server → all clients | `Types.RunResult` `{ outcome = "Wiped" \| "CashedOut", time, squadScore, trains, players }` | — |

## Data / state
- **Workspace attributes:**
  - `RunState`: `Lobby`, `InTrain`, `Leap`, `Checkpoint`, `Wiped`, `CashedOut` or `Results`,
  - `StartsAt` (in the lobby),
  - `Leg`, `TrainInLeg`, `TrainNumber`, and `NextEvent` (`TRAIN`, `THIEF TRAIN` or
    `CHECKPOINT`).
- **Player attributes:** `Ready`, `Knockouts`, `CheckpointVote` and `CheckpointAway`.
- It ticks every `RUN_CHECK_INTERVAL` (0.25 s).
- **Lobby:** everyone READY starts a 5 s countdown; otherwise it starts 20 s after the
  lobby fills. The start announces **ALL ABOARD!**.
- **Each train** (`startTrain`):
  - Untouchable tracking resets, every crate is ready again, and everyone goes back to
    their primary weapon,
  - `SpawnService.begin(trainNumber, thief)`; train `LEG_TRAINS` of each leg is the Thief
    train.
- **Cleared:** when `TimelineDone`, no enemies are alive and an up player is on the
  *current* train's `TrainGoal`:
  - the clear bonus ([[ScoreService]]),
  - **TRAIN CLEARED!**, then **NEXT TRAIN — LEAP!**,
  - `TrainService.buildNext` ("Checkpoint" after a Thief train),
  - `GAP_COINS` (20) coins in an arc over the gap,
  - every combo ends.
- **Leap:**
  - a player has crossed once their root is past the new train's `RearX` + 1 and above
    `GAP_FALL_Y`. Each up player who crosses gets +50 LEAP,
  - once every up player is across, the rest (downed, bled out) are placed on the new
    train (`CharacterService.placeNear`) and the old train is dropped,
  - after a checkpoint, the counters move to the next leg.
- **Checkpoint:**
  - everyone is fully healed (`SquadService.heal`, so downed and bled-out players get up
    too),
  - **HUB TRAIN ALONGSIDE!**, then **CONTINUE OR CASH OUT?**,
  - there's no timer; it waits for every vote,
  - a player who hasn't moved for `CHECKPOINT_AFK` (90 s) and hasn't voted counts as
    Continue (`CheckpointAway`),
  - more CashOut than Continue → `CashedOut`; otherwise (a tie included) it leaps to the
    next leg.
- **End:**
  - nobody is up (in a train or a leap) → `Wiped`, or a cash-out → `CashedOut`,
  - announcement → after `RUN_END_DELAY` (3 s), `Results` and `RunEnded` with each
    player's score, KOs, revives, coins (with the run-end bonus of 1 per 25 points),
    blueprints and callouts.
- **PLAY AGAIN** (everyone): stops the spawns, clears enemies, rebuilds the first train
  and resets pickups, squad, score and votes. Everyone respawns already Ready.

## Depends on
- [[TrainService]], [[SpawnService]], [[EnemyService]], [[CharacterService]],
  [[CombatService]], [[PickupService]], [[SquadService]], [[ScoreService]], [[Guard]],
  `Shared.Constants`, `Shared.Types`

## Notes
- **Verified 2026-10-14 (one player).** The timelines were forced done and Dash was walked
  across in steps.
  - The whole of Leg 1 played through: train 1 cleared (+600), a 20-coin arc, the leap
    (+50 LEAP, old train dropped, primary weapon back), train 2, then the Thief train
    (2 thieves at about 20 s and 40 s).
  - At the checkpoint, Health went from 30 to 100, the HUD read "LEG 1 · CHECKPOINT",
    and CheckpointGui appeared.
  - Clicking CONTINUE → leap → Leg 2 Train 1 (train 4). The console was clean.
- **Verified 2026-10-13 (M1):** READY → countdown → run, a wipe → results, PLAY AGAIN.
- **Not verified:**
  - **cash-out** (it shares `finish()` with the wipe path),
  - the AFK safeguard,
  - multi-player votes and ties,
  - carrying downed players over a leap,
  - a real running leap.
- Saving commits at checkpoints and at run end come with Session 7 (saving). The
  first-checkpoint Brick grant is in Session 10.
- PLAY AGAIN needs every player. A player who joins mid-run spawns at the staging
  platform; Session 12 locks run servers to the party.
