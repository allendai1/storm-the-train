---
tags: [status]
updated: 2026-10-16
---
# Project Status

Read this at the start of every session. Keep it short and current.

## Overview
**Train Mayhem** (formerly Train Runner) — Roblox experience, built Studio-first with Claude Code via the
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

**M0, M1 (Sessions 1–5) and M2 Sessions 8–11 are built** in Studio (place `71855801375130`).
A run now plays like this:
- **Leg structure:** legs of 3 trains (the third is a Thief train), with leaps between
  trains, gap coins and a checkpoint train. The checkpoint heals everyone and holds a
  continue-or-cash-out vote.
- **Score:** a score and combo multiplier, coins, and a run-end screen with the squad score
  and callouts.
- **Agents:** Max Mayhem (built as Dash), plus Brick granted at the first checkpoint. Swap with Q/E, and change
  the squad at the Barracks.
- **Mayhem:** the meter fills from knockouts and deploys drones, the Heavyweight mech or an
  Air Strike.

M1 Session 6 (multi-client test and tuning) and M2 Session 7 (saving) are still open.
**Next steps ([decided 2026-10-16] roadmap):**
1. **[[Feel and Look (Slice)]]**, the next milestone. One Wild West train, Max and the 5
   built enemies at roughly launch quality:
   - F1 the look target,
   - F2 [[Combat Polish]],
   - F3 Max's feel,
   - F4 the map,
   - F5 the characters and enemies,
   - F6 sound,
   - F7 a phone test and a 2–4 player playtest.
2. **After the slice,** M2 resumes: Session 7 saving and Session 12 hub (both already
   drafted), then the Session 13 full-loop playtest.
3. **Then** M3 content and M4 meta. The economy and event decisions are recorded and wait.

**Before the slice, in Studio:** save the place. Finish verifying Session 11 (the
knockback fix, the Defender, key 1) as part of F2 and F7.

## In progress
- [[First Playable (M1)]]: Sessions 1–4 are done. Systems: [[ModeService]], [[Guard]],
  [[TrainService]], [[CharacterService]], [[InputController]], [[CameraController]],
  [[ParallaxController]], [[CombatService]], [[PickupService]], [[EffectsController]],
  [[EnemyService]], [[SpawnService]], [[RunStateService]], [[SquadService]] and
  [[HudController]]. Only Session 6 (measure, tune, playtest) is left.
- [[Loop (M2)]]: Sessions 8–11 are built: [[ScoreService]], [[AgentService]] and
  [[GadgetService]], plus multi-train runs in [[RunStateService]], [[TrainService]] and
  [[SpawnService]]. Sessions 7, 12 and 13 are left.

## Next up
- Technical architecture is settled. ADRs 0004–0010 are all accepted.
- Review the rest of [[Writing and Dialogue]] (the bark lines, missions and challenge
  chains). Its open questions were decided on 2026-10-16: text bubbles with a voiced
  grunt, a tutorial skippable from the start, and the Quartermaster kept.
- **Studio change:** set Big Bart's `ChargeSpeed` from 36 to **26.7** (2.5× walk, the
  original's rule; decided 2026-10-16, [[Wild West Enemies]]).
- **Rename in Studio:** change the experience name to **Train Mayhem**, and replace any
  "Train Runner" or placeholder names in GUI text: Dash → **Max Mayhem** (SquadGui and the
  HUD portrait label). Renaming the internal IDs (`DashDaring`) is optional.
- **[[Combat Polish]] (planned, reviewed 2026-10-16):** the next Studio work after saving.
  It makes Max a refined first agent, from the decompiled original:
  - enemy flinch with a cooldown, muzzle flashes, enemy attack jitter and telegraph rules,
  - perception, off-screen spawning, Dan's lobbed dynamite,
  - 0.3 s i-frames, the spin pop-up, revive grace, and the moving camera lead.

  The light and mid special mechanics are deferred until the first agent feels right.
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
- Tune in playtests:
  - enemy damage ([[Wild West Enemies]]),
  - Mayhem fill rates and mech armour ([[Gadgets and Mayhem]]),
  - score values and the combo window ([[Score and Combo]]),
  - prices and earn rates ([[Economy and Monetization]]).

## Open design decisions
After the 2026-10-16 pass ([[2026-10-16]]), these are still open:
- **Naming:** four agents are left (Brick, Turbo, Nana, Mimi), with shortlists in
  [[Title Ideas]]. Max Mayhem (ex-Dash) and Gleep (ex-Zorp) were decided on
  2026-10-16.
- **Before publishing:** check the agency name "ROBLOX Assault Team" against Roblox's
  Name and Logo Community Usage Guidelines. Using Roblox's name may not be allowed. Also
  search Roblox for other "Train Mayhem" experiences.
- **Left open on purpose** (still `[proposed]`):
  - no paid random items and honest pricing (GDD and [[Economy and Monetization]]),
  - the Premium Payouts focus,
  - Mayhem co-op balance ([[Gadgets and Mayhem]]),
  - run-end coins using boosted score ([[Score and Combo]]).
- **Review by hand:**
  - the rest of [[Writing and Dialogue]] (bark lines, missions, challenge chains),
  - the Figma mockups ([[Art Direction]] §10).
- **Needs a test first:**
  - ShadowMap vs Future,
  - enemy damage and cooldowns,
  - Mayhem fill and mech armour,
  - the combo window and score values,
  - the rocket's splash and range,
  - spawn distance,
  - Robux prices, the Coin Bonus pass and the login-streak amounts.
- **Studio housekeeping:** delete the template's `SpawnLocation` and `Baseplate`? Add a
  timeout to PLAY AGAIN?

## Known issues / open problems
- The place template's default `Workspace.SpawnLocation` (under the caboose) and the
  `Baseplate` are still there. Neither does anything now: agents spawn by script, and the
  Desert layer covers the baseplate. Deleting both is recommended, but it's your call.
- Open tuning questions from Session 3:
  - Does a direct rocket hit taking splash too (26 total) feel right?
  - The Pocket Rocket's `Range` 60 is a guess.
  - Mouse aim was removed and the rifle's 6° auto-aim is kept (decided 2026-10-13). Check
    in the playtest that enemies on lower or higher carriages are still hittable.
- Session 4 is not checked yet:
  - the Rodeo Kid leap by eye,
  - Dan's knockout blast hurting other enemies,
  - jumping over Six-Shooter bullets (needs a person playing),
  - picking up a dropped crate.
- **M2 Sessions 8–11 are not checked yet:**
  - **Session 11:** the Turret, the lock message, the Air Strike and the Heavyweight
    (stomp, armour, swap lock, eject) are verified. **Still to do:**
    - the knockback fix (PlatformStand stun),
    - the Defender blocking shots,
    - pressing key 1 by hand (Studio's virtual input can't send it).

    Studio's playtest start hangs intermittently after script edits; Stop/Play by hand, or
    a Studio restart, clears it.
  - Multiplayer-only: assists, the revive bonus, checkpoint votes and ties, the AFK
    safeguard, carrying downed players over a leap, and the teammate Mayhem rings.
  - A real running leap: is the engine → caboose gap comfortable for Dash and for Brick
    at 20 studs/s?
- **Controls changed to match the GDD:** Space = jump only, W/↑ = Interact (revive, the
  Barracks), Q/E = swap, 1/2/3 and F = gadgets.
- M2 simplifications:
  - the Mayhem ring fills from the centre (no arc yet),
  - the mech has no heavy gravity,
  - drones are server-moved,
  - later trains use a 60 s plateau (first guess),
  - coins and agents aren't saved until Session 7.
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
- **2026-10-14: M2 Sessions 8–11 need a save or publish** (File → Publish to Roblox).
  New:
  - **Services:** ScoreService, AgentService, MayhemService and GadgetService.
  - **Controllers:** CheckpointController, SquadController and MayhemController.
  - **Templates:** BrickBroadsley, Scattergun, CrowdPleaser, HubCheckpoint, the drones,
    the Heavyweight, Coin and the strike effects.
  - **GUIs:** CheckpointGui, SquadGui and the HUD additions.
  - **Remotes:** RequestCheckpointChoice, RequestSwap, EquipSquad and RequestGadget.

  Most other scripts were edited too.
