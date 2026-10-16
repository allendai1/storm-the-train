---
tags: [technique, studio, setup, checklist]
status: planned
updated: 2026-10-13
---
# Studio Setup Checklist

## When to use
Once, before **Session 1** of [[First Playable (M1)]], on the machine running Roblox Studio.
It covers the place settings that are painful to change after scripts exist, and the
local Claude Code connection. Settings move in Studio from time to time. If a menu
path below has changed, follow the current Studio UI and update this note.

## Steps
### 1. Local machine
1. Update Roblox Studio to the latest version.
2. Turn on Studio's MCP server and connect Claude Code (`CLAUDE.md` → Roblox Studio
   MCP → Setup). Check the green "connected" indicator in **Manage MCP Servers**.
3. In your local clone, **pull the merged vault** (after
   [allendai1/storm-the-train#1](https://github.com/allendai1/storm-the-train/pull/1) is
   merged), then start Claude Code in the repo root.
4. In Claude Code, run `list_roblox_studios` and check you're pointed at the right
   place before any edit.

### 2. Create and publish the place
1. **File → New → Baseplate.** Delete the `Baseplate` part later, once `Map.Run` has
   its staging platform.
2. **File → Publish to Roblox** as a new **private** experience, e.g. "Train Runner
   (dev)". Publishing gives version history, which is the code backup (`CLAUDE.md`).
3. Later, for M2 teleport tests, publish the **same place** to a second private
   experience, "Train Runner (test)". It's one place in two modes
   ([[0004-single-place-hub-and-run-modes]]), so there's no second place to build.

### 3. Game Settings (Home → Game Settings)
| Section | Setting | Value | Why |
|---|---|---|---|
| Basic Info | Name, description | **Train Mayhem** (decided 2026-10-16; the place may still say Train Runner) | [[Title Ideas]] |
| Basic Info | Devices | **Computer, Phone, Tablet**. No console | Decided: PC and mobile only (GDD) |
| Permissions | Playability | **Private** during development | |
| Security | **Enable Studio Access to API Services** | On, once saving starts (M2) | DataStores and MemoryStore in Studio. M1 can leave it off; ProfileStore uses its mock in Studio anyway |
| Security | Allow HTTP Requests | Off | Not needed |
| Security | Allow Third Party Teleports | Off | Teleports stay inside our experience |
| Avatar | Avatar type | **R15** | Agents and enemies are R15-compatible rigs ([[Art Direction]]) |
| Avatar | Scaling / body parts | Use fixed defaults; don't let player avatars set the scale | Players play as agents, not their own avatars. Keeps hitboxes consistent |
| Monetization | Private servers | **Allow, free** | Decided: free private servers ([[Economy and Monetization]]) |
| Communication | Voice chat | Off | All-ages co-op. Text chat uses Roblox's built-in filtering |

### 4. Place properties (Explorer → Properties)
| Instance | Property | Value | Why |
|---|---|---|---|
| `Workspace` | `StreamingEnabled` | **Off** for M1 | The train is small. Streaming complicates server-driven enemies and client parallax. Revisit if `Map.Hub` gets big |
| `Workspace` | `Gravity` | 196.2 (default) | Jump numbers in [[First Playable (M1)]] assume it |
| `Workspace` | `SignalBehavior` | Default (Deferred) | Write handlers that don't rely on immediate signals |
| `Lighting` | `Technology` | **ShadowMap** | [[Art Direction]] §8. Test Future later on a phone |
| `Lighting` | Add `Atmosphere`, mild `ColorCorrection` | — | [[Art Direction]] §8 |
| `StarterPlayer` | `DevComputerMovementMode`, `DevTouchMovementMode` | **Scriptable** | Custom side-on controls ([[0005-side-on-movement-and-camera]]). The setup script sets these |
| `StarterPlayer` | `AutoJumpEnabled` | Off | Jumps are deliberate |
| `StarterPlayer` | `EnableMouseLockOption` | Off | Fixed side-on camera |
| `StarterGui` ScreenGuis | `ResetOnSpawn` | **false** on every controller-held GUI | `CLAUDE.md` GUI rule |

### 5. Studio settings (File → Studio Settings)
- **Script Analysis:** on. Every script starts with `--!strict` (`CLAUDE.md`). Fix
  type warnings as you go.
- **Team Create:** leave it **off** while you work alone. With Team Create on, script
  edits go through drafts that have to be committed, which adds a step to every Claude
  edit.

### 6. Run the setup and bootstrap code
- Run the **setup script** and paste the **bootstrap modules** from
  [[M0 Bootstrap Code]]. That covers Session 1 of [[First Playable (M1)]].

### 7. Verify, then save
1. `start_stop_play` to start a playtest. `get_console_output` should show
   `[Server] Run mode` (from `ForceMode = "Run"`) and `[Client] Run mode`, with no
   errors or warnings.
2. `start_stop_play` to stop. Never leave Studio in play mode.
3. **File → Publish to Roblox** (or Save). Changes aren't saved until you do.
4. Tick the Session 1 boxes in [[First Playable (M1)]] that you verified. Add a
   devlog entry, and create the first `02 Systems/` notes (ModeService and Guard) from
   the [[Templates/System|System template]].

## Roblox export notes
- Nothing to export yet. The art pipeline (Blender → R15-compatible rigs) gets its
  own technique note before final art replaces greybox models.

## Example
- _Fill in after the first setup: the experience's place ID, and anything that
  differed from this checklist._

Related: [[Techniques]] · [[M0 Bootstrap Code]] · [[First Playable (M1)]] · [[0004-single-place-hub-and-run-modes]] · [[0005-side-on-movement-and-camera]]
