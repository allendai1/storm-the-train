---
tags: [system, m2, agents, squad]
status: implemented
side: server, client
---
# AgentService (+ SquadController)

> **Planned change (2026-10-16):** a squad is **2 agents**, and a swap toggles between them with no cooldown ([[Original Mechanics Match]] §3.4). The built version uses 3 and a 1.5 s cooldown.

> **Display names (decided 2026-10-16):** Dash Daring is now **Max Mayhem** ([[Launch Agents]]).
> The Studio IDs (`DashDaring`, `Dash`) are unchanged until a local session renames
> them, so this note keeps the old names where it describes what's built.

## Purpose
Agents and squads ([[Launch Agents]], [[Loop (M2)]] Session 10): which agents a player owns,
which 3 they bring, and swapping between them mid-run.

The M2 spec calls this "SquadService", but that name was already taken by the co-op
downed/revive service ([[SquadService]]), so it's **AgentService**.

## Code
- Server: `ServerScriptService.Server.Services.AgentService` (`Modes = { "Run" }`)
- Client: `StarterPlayer.StarterPlayerScripts.Client.Controllers.SquadController` (the
  Barracks)

## Expects in the place
- **Agent templates** in `ReplicatedStorage.Assets.Agents`:
  - `DashDaring`,
  - `BrickBroadsley`: Dash's rig reskinned in purple `#6B3FA0` and gold, with mask, cape,
    belt and tiny briefcase, scaled 1.15. **Humanoid `AutomaticScalingEnabled = false`**, or
    the spawn re-scales the already-scaled parts and the Hitbox.
- **Attributes on each template:** `Speed`, `Toughness`, `SpinLevel`, `SpinDamage`,
  `SpinRadius`, `PrimaryWeapon`, `SecondaryWeapon`, `DisplayName` and `Role`.
  - Dash: 28.3 speed, 0.52 toughness, spin 6 damage / 5 studs.
  - Brick: 20, 0.2, 9 / 6 studs, Scattergun / CrowdPleaser, hitbox 2 × 6.3 (a first guess).
- **Weapon templates** `Scattergun` and `CrowdPleaser` in `ReplicatedStorage.Assets.Weapons`
  (see [[CombatService]]).
- `StarterGui.SquadGui`: a `Prompt` ("PRESS W: CHANGE SQUAD") and a `Panel` with `Title`,
  `Hint`, `Cards` (a horizontal list, `Template` card: `Initial`, `NameLabel`, `RoleLabel`,
  `SlotLabel`) and `DoneButton`.
- The `BarracksPod` part on the checkpoint train ([[TrainService]]).
- `HudGui.SquadStrip` (+ `Template` portrait), `HudGui.TutorialHint`, and
  `TouchControlsGui.SwapButton` (see [[HudController]]).
- Remotes `RequestSwap` and `EquipSquad`.

## Public API
- `AgentService.owns(player, agent)`, `AgentService.grant(player, agent)`: grant adds the agent
  to `OwnedAgents`, and to `Squad` if there's room.
- `AgentService.onCheckpoint(player)`: called by [[RunStateService]] on every checkpoint
  arrival. The first one ever grants `FIRST_CHECKPOINT_AGENT` (Brick) and sets
  `TutorialHint`.
- Client: `SquadController.nearBarracks()` and `SquadController.open()` (used by the touch
  context button).

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `RequestSwap` | client → server | `direction: 1 \| -1` | `Guard.number(-1, 1, integer)`, not 0, 2/s with burst 2. Refused during the `SWAP_COOLDOWN` (1.5 s), while `Downed`/`BledOut`, while `InMech`, or with a squad of 1 |
| `EquipSquad` | client → server | `{ agentId }`, 1–3 entries | Only in `Lobby` or `Checkpoint`. A table of at most `SQUAD_SIZE`, each id a string ≤ 40 characters, owned and unique. A bad payload is a strike |

## Data / state
- **Player attributes:**
  - `OwnedAgents` and `Squad` (comma-separated ids, first = spawn agent),
  - `ActiveAgent` (set by [[CharacterService]]),
  - `SwapReadyAt` (server time), `FirstCheckpointDone`, `TutorialHint`,
  - `Weapon_<AgentId>`: each agent's remembered weapon, set by `CombatService.setWeapon`
    and cleared at every train start.
- **On join:** `OwnedAgents` = `Squad` = `STARTER_AGENT` (Dash). With the Studio-only dev flag
  (the `DevGrantAllAgents` attribute on `ServerScriptService.Server`), every agent template is
  granted.
- **Swap:** the next or previous agent in `Squad` → `CharacterService.swapTo`, which
  replaces the rig where you stand (feet level, same facing). Health, Mayhem, score and
  combo are Player attributes, so they carry over. The new rig re-applies WalkSpeed,
  Toughness, the hitbox and the spin. The first swap clears `TutorialHint`.
- **EquipSquad:** sets `Squad`. If the active agent was removed, it swaps to the new first
  agent.
- **SquadController** (client): at a checkpoint, when the root is within the `BarracksPod`'s
  X span, it shows the `Prompt`. W / ↑ (or the touch SQUAD button) opens the `Panel`, with one
  card per owned agent. Clicking a card toggles it in the selection (order = slot number,
  1–3, at least 1). DONE sends `EquipSquad`.

## Depends on
- [[CharacterService]] (`swapTo`, `spawn` uses `Squad[1]`), [[Guard]], `Shared.Constants`

## Notes
- **Verified 2026-10-14 (one player):**
  - the first checkpoint granted Brick and showed the hint,
  - E swapped to Brick: toughness 0.2, Scattergun, WalkSpeed 20, HP kept, hint cleared,
  - the HUD showed BRICK BROADSLEY with the D/B strip,
  - W at the Barracks opened SquadGui; deselecting Dash → DONE → `Squad = BrickBroadsley`,
  - PLAY AGAIN spawned Brick,
  - Brick's hitbox is 2 × 6.3 in play, after the scaling fix.
- **Not verified:**
  - the touch SWAP and SQUAD buttons,
  - the Q (previous) direction,
  - swapping while airborne,
  - 3-agent squads (only 2 agents exist).
- Without saving (Session 7), `OwnedAgents` and `FirstCheckpointDone` last only for the
  server session.
- Squad-strip portraits only display. Tap-to-swap on mobile isn't built; SWAP cycles.
- Swap-in barks and animations come with art.
