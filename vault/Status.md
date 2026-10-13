---
tags: [status]
updated: 2026-10-13
---
# Project Status

Read this at the start of every session. Keep it short and current.

## Overview
**Train Runner** (working title) — Roblox experience, built Studio-first with Claude Code via the
Roblox Studio MCP server. See [[Game Design Document]] and [[Art Direction]].

## Current phase
Pre-production. **The gameplay design is settled.** The [[Game Design Document]] and all its
feature notes are `planned`:
- [[Wild West Enemies]],
- [[Launch Agents]],
- [[Gadgets and Mayhem]],
- [[Score and Combo]],
- [[Economy and Monetization]].

Three things are not settled yet:
- **naming**: the title, agency, hub train, agents and gang,
- **[[Art Direction]]**: now `planned`. The only open item is ShadowMap vs Future
  lighting, which waits for a mobile test. No reference images yet,
- **number tuning**, which needs playtests. The original's numbers are loose reference only.

**M0 and M1 Sessions 2–5 are built** in Studio (place `71855801375130`). **The full M1 loop
plays:**
1. Ready up in the lobby → ALL ABOARD.
2. As greybox Dash Daring (rifle, crate rocket, spin), fight the Rattler Gang's budget
   timeline across a 7-car train.
3. Get downed and revived.
4. TRAIN CLEARED on the engine roof, or SQUAD WIPED.
5. The results screen, then PLAY AGAIN.

It has a hand-built HUD, touch controls and a run-end screen.

**Next step: Session 6** of [[First Playable (M1)]]: a multi-client test (Studio → Test →
Clients and Servers, 2–4 players), the performance budget and a tuning pass. Do it from a
local Claude Code session with the Studio MCP connected; the multi-client test needs you at
the keyboard.

## In progress
- [[First Playable (M1)]]: Sessions 1–4 are done. Systems: [[ModeService]], [[Guard]],
  [[TrainService]], [[CharacterService]], [[InputController]], [[CameraController]],
  [[ParallaxController]], [[CombatService]], [[PickupService]], [[EffectsController]],
  [[EnemyService]], [[SpawnService]], [[RunStateService]], [[SquadService]] and
  [[HudController]]. Only Session 6 (measure, tune, playtest) is left.

## Next up
- Technical architecture is settled. ADRs 0004–0010 are all accepted.
- Review [[Writing and Dialogue]] (barks, tutorial, missions, challenge chains) and the
  open points in [[Loop (M2)]] (tie = continue, 90 s AFK safeguard).
- **Manual [[Studio Setup Checklist]] items still to do in Studio:**
  - **Game Settings** (§3): devices, R15, free private servers, voice off.
  - **`Lighting.Technology` = ShadowMap** (§4). Scripts can't set it.
  - Atmosphere and ColorCorrection.
  - Studio settings (§5).
- **Install Signal and Trove** into `ReplicatedStorage.Packages` and record them in
  [[Packages]]. This is the last Session 1 item; nothing needs them yet.
- **Session 6:**
  - a multi-client test,
  - check the unverified Session 4–5 items (below),
  - the perf budget (≤ 30 enemies + 4 players + 12 ragdolls),
  - tuning.
- **Compare the Session 5 GUIs with the Figma mockups** by hand. The Figma MCP was
  blocked by the Starter plan limit, so they follow [[Art Direction]] §10 as written.
- **Review the greybox carriages, background layers, Dash, enemies, weapons and effects** in
  Studio (`ServerStorage.Assets.Carriages.WildWest`, `ServerStorage.Assets.Enemies`,
  `ReplicatedStorage.Assets.Backgrounds.WildWest`, `ReplicatedStorage.Assets.Agents`,
  `.Weapons`, `.Pickups` and `.Effects`).
  Adjust them by hand if you like; the scripts only read their tags and attributes.
- Figma UI mockups (linked in [[Art Direction]] §10). These are done: PC HUD, mobile
  HUD, run end, Party Lobby, Squad Select and Armory. The Figma Starter plan's
  tool-call limit was hit, so these are still to do:
  - swap both HUDs to the decided Mayhem ring (left edge, gadget fan; teammate rings
    glow when ready),
  - Boosters, Checkpoint (continue or cash out), Surplus Shop, Missions and daily
    challenge, Store and Exchange, Downed and Squad Wiped, and Leaderboards screens.
- Add reference images to `05 Assets/References/` (the list is in [[Art Direction]] §13)
  before modelling starts in M1.
- Name the agency, hub train, agents and gang ([[Title Ideas]]).
- Design leftovers:
  - Mimi's Invisible Bow charge formula ([[Launch Agents]]).
  - The exact knock-out ragdoll limits (GDD → Tone).
- Tune in playtests:
  - enemy damage ([[Wild West Enemies]]),
  - Mayhem fill rates and mech armour ([[Gadgets and Mayhem]]),
  - score values and the combo window ([[Score and Combo]]),
  - prices and earn rates ([[Economy and Monetization]]).

## Known issues / open problems
- The place template's default `Workspace.SpawnLocation` (under the caboose) and the
  `Baseplate` are still there. Neither does anything now: agents spawn by script, and the
  Desert layer covers the baseplate. Deleting both is recommended, but it's your call.
- Open tuning questions from Session 3:
  - Does a direct rocket hit taking splash too (26 total) feel right?
  - The Pocket Rocket's `Range` 60 is a guess.
  - `AIM_MAX_ANGLE` 30° is a guess.
- Session 4 is not checked yet:
  - the Rodeo Kid leap by eye,
  - Dan's knockout blast hurting other enemies,
  - jumping over Six-Shooter bullets (needs a person playing),
  - picking up a dropped crate.
- Session 5 is not checked yet. These need 2+ players or a touch device:
  - revives, and a revive interrupted by damage,
  - bleed-out → spectating,
  - the teammate cards and the revive prompt,
  - the touch controls (a finger sliding off a button may stick).
- PLAY AGAIN waits for **every** player. Someone who joins during Results or never
  presses it blocks the reset (no timeout yet).
- Enemy spawns can be on screen: the 20-stud minimum is less than the ~35-stud half-width
  of the camera. Tune this in Session 6.

## Unsaved work in Studio
- **2026-10-13: Session 5 needs a save or publish** (File → Publish to Roblox). It added:
  - the three GUIs,
  - RunStateService and SquadService,
  - three controllers,
  - edits to Constants, Types, CombatService, SpawnService, EnemyService, PickupService,
    InputController and CameraController.
