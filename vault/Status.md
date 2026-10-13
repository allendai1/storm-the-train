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

**M0 Bootstrap and M1 Session 2 are built** in Studio (place `71855801375130`). You can
walk, jump and spin along a greybox 7-car train with a side-on camera and scrolling desert.
**Next step: Session 3** of [[First Playable (M1)]] (Dash agent rig, weapons, crates,
combat), from a local Claude Code session with the Studio MCP connected.

## In progress
- [[First Playable (M1)]]: Sessions 1 and 2 are done. Systems: [[ModeService]], [[Guard]],
  [[TrainService]], [[CharacterService]], [[InputController]], [[CameraController]] and
  [[ParallaxController]].

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
- **Session 3**: the Dash Daring agent template (with `Hitbox`), weapons, PickupService,
  CombatService and EffectsController. Its loose ends from Session 2:
  - gap-fall damage,
  - sending `RequestSpin` from InputController,
  - reading `Speed` from the agent instead of `FALLBACK_AGENT_SPEED`.
- **Review the greybox carriages and background layers** in Studio
  (`ServerStorage.Assets.Carriages.WildWest`, `ReplicatedStorage.Assets.Backgrounds.WildWest`).
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
  `Baseplate` are still there:
  - players spawn on `StagingSpawn` through `RespawnLocation`,
  - the Desert background layer covers the baseplate,
  - deleting both is recommended, but it's your call.
- On the caboose, the roof overhangs the rear porch by 1 stud, so jump from the porch's
  outer edge to reach the roof. Check how this feels in the Session 6 playtest.

## Unsaved work in Studio
- **2026-10-13: the M0 bootstrap and the Session 2 build need a save or publish**
  (File → Publish to Roblox), unless you've saved since.
