---
tags: [moc]
---
# Train Mayhem — Home

Map of content for the project. Start here, then read [[Status]].
The title is **Train Mayhem** (decided 2026-10-16; the working title was Train Runner).
The repo is still named `storm-the-train` after the
2016 game it's inspired by (see [[Original Game]]).

## Design
- [[Game Design Document]] — pitch, core loop, pillars, open questions
- [[Art Direction]] — visual style, palettes, readability rules, budgets; consult before any modeling (planned)
- [[Loop (M2)]] — M2 spec and Studio checklist, sessions 7–13 (planned)
- [[Queue Pads]] — physical party lobby in the hub: step on a pad, countdown, the pad's squad teleports together; replaces the party menu (planned, M2)
- [[Feel and Look (Slice)]] — **the next milestone**: one train, Max and the built enemies at launch quality (planned)
- [[Original Mechanics Match]] — **the game plays like the original, keeping co-op**: the converted values, co-op adaptations and the Studio change list (planned, decided 2026-10-16)
- [[Background Kit]] — the standard six background slots, tile rules and the plugin workflow for every theme's scenery (planned)
- [[Feel and Look Asset Specs]] — the slice's animations, models, environment, lighting, VFX and sound specs, with 16 open questions (planned)
- [[Combat Polish]] — the accepted feel and AI polish for a refined first agent (planned, next Studio session)
- [[Writing and Dialogue]] — voice rules, barks, announcements, tutorial, missions, challenge chains (proposed)
- [[First Playable (M1)]] — M0+M1 spec and Studio build checklist, in session order (planned)
- [[Wild West Enemies]] — the Cowboys roster for the first-playable theme (planned)
- [[Gadgets and Mayhem]] — Mayhem meter, 6 drones, 3 mech suits, Air Strike (planned)
- [[Score and Combo]] — knockout points, combo multiplier, bonuses, squad and individual boards (planned)
- [[Economy and Monetization]] — currencies, earn rates, prices, boosters, Robux products (planned)
- [[Launch Agents]] — the 6 launch agents: loadouts, speed/toughness, theme matchups (planned; names are placeholders)
- Feature specs: create from [[Templates/Feature|Feature template]]

## Systems
One note per code system in Studio (path, API, remotes). Create from [[Templates/System|System template]].
- [[ModeService]] — Hub vs Run mode, plus the server/client bootstraps (implemented)
- [[Guard]] — remote validation and rate limiting (implemented)
- [[TrainService]] — builds the 7-car train from carriage templates (implemented)
- [[CharacterService]] — side-on character setup, plane lock, gap falls, movement validation (implemented)
- [[InputController]] — keyboard movement, facing, jump, double-jump spin (implemented)
- [[CameraController]] — side-on Scriptable camera (implemented)
- [[ParallaxController]] — client-side scrolling background strips (implemented)
- [[CombatService]] — server fire loop, hitscan + rockets, spin, damage, Effects (implemented)
- [[PickupService]] — personal weapon crates, plus PickupController (implemented)
- [[EffectsController]] — tracers, rockets, explosions, sparks, KO pops (implemented)
- [[AgentAnimationController]] — plays the agents' clips from the rig's `Animations` folder; the spin on `Spinning` (implemented)
- [[EnemyService]] — enemy spawning, AI archetypes, enemy projectiles, ragdoll knockouts (implemented)
- [[SpawnService]] — plays the spawn timeline: budget waves, solo mids, blueprint thief (implemented)
- [[RunStateService]] — the run loop: lobby/ready, start, cleared/wiped, results, PLAY AGAIN (implemented)
- [[SquadService]] — downed, revive, bleed-out, wipe, player colour slots (implemented)
- [[HudController]] — HUD, touch controls and run-end screen controllers (implemented)
- [[ScoreService]] — score, combo multiplier, assists, flat bonuses (implemented)
- [[AgentService]] — owned agents, squad, swap, Barracks squad select (implemented)
- [[GadgetService]] — Mayhem meter, drones, Heavyweight mech, Air Strike, ring and fan HUD (implemented)

## Decisions
Architecture decision records. Create from [[Templates/Decision|Decision template]].
- [[0001-studio-first-with-studio-mcp]]
- [[0002-build-in-place-script-behavior]]
- [[0003-2.5d-side-scroller]]
- [[0004-single-place-hub-and-run-modes]] — one place; Hub vs Run mode via reserved servers (accepted)
- [[0005-side-on-movement-and-camera]] — Z = 0 plane lock, scriptable controls and camera (accepted)
- [[0006-humanoid-enemies-and-combat]] — Humanoid enemies, server hitbox queries, ragdolls (accepted)
- [[0007-networking-and-remotes]] — remotes list, input state, validation and rate limits (accepted)
- [[0008-player-data-profilestore]] — ProfileStore, schema v1, receipts, leaderboards (accepted)
- [[0009-static-trains-scrolling-world]] — anchored trains, client parallax, carriage templates (accepted)
- [[0010-third-party-packages]] — ProfileStore, Signal, Trove, Promise; no framework (accepted)
- [[0012-match-the-original]] — match the original's mechanics; keep co-op, final knockouts, no ads (accepted)
- [[0011-background-kit]] — standard background slots, variant tiles, in-place editing with a plugin (proposed)

## Devlog
Dated session notes live in `04 Devlog/` (Obsidian daily notes are configured to put them there).
- [[2026-10-13]] — first design session: GDD, design notes, art direction, ADRs, M1/M2 specs
- [[2026-10-14]] — M2 Sessions 8–11 built: score/coins, multi-train runs and checkpoints, Brick and swapping, Mayhem and gadgets
- [[2026-10-17]] — F3's spin clip built in Blender and wired in Studio (AgentAnimationController); the Blender→Roblox animation technique
- [[2026-10-16]] — Design open questions decided: vote and pad rules, crates, tutorial, barks, the Invisible Bow, run-end coins, the login streak
- New entries use the [[Templates/Devlog|Devlog template]].

## Inbox
Unsorted and proposed ideas go in `00 Inbox/` (`status: proposed`) until they're triaged.
- [[Title Ideas]] — candidate titles and names for the new IP
- [[From the Original - Proposals]] — proposals from the full decompile, plus 3 decisions to revisit
- [[Hit Feedback]] — proposed hit reactions, knockback, muzzle flashes and shakes, based on the original's code

## Assets & packages
- [[Packages]] — third-party Luau libraries in `ReplicatedStorage.Packages`
- [[References]] — reference images for art and modeling
- [[Original Game]] — data from the 2016 Storm the Train Android APK: enemies, spawning, economy, assets (reference, not canon)

## Techniques
- [[Techniques]] — reusable Blender modeling and other how-tos
