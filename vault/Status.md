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

**M0 Bootstrap is built** in Studio (place `71855801375130`), apart from packages.
**Next step: Session 2** of [[First Playable (M1)]] (train, movement, camera), from a
local Claude Code session with the Studio MCP connected.

## In progress
- [[First Playable (M1)]]: Session 1 is done. Systems: [[ModeService]], [[Guard]].

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
- **Session 2**: carriage templates, `Map.Run` staging, TrainService, CharacterService,
  and the Input, Camera and Parallax controllers. Movement is Scriptable now, so the
  character can't move until InputController exists.
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
- _(none yet)_

## Unsaved work in Studio
- **2026-10-13: the M0 bootstrap needs a save or publish** (File → Publish to Roblox),
  unless you've saved since this session.
