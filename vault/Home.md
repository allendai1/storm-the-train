---
tags: [moc]
---
# Train Runner — Home

Map of content for the project. Start here, then read [[Status]].
The working title is **Train Runner**; the repo is still named `storm-the-train` after the
2016 game it's inspired by (see [[Original Game]]).

## Design
- [[Game Design Document]] — pitch, core loop, pillars, open questions
- [[Art Direction]] — visual style, palettes, readability rules, budgets; consult before any modeling (planned)
- [[Loop (M2)]] — M2 spec and Studio checklist, sessions 7–13 (planned)
- [[Writing and Dialogue]] — voice rules, barks, announcements, tutorial, missions, challenge chains (proposed)
- [[First Playable (M1)]] — M0+M1 spec and Studio build checklist, in session order (planned)
- [[Wild West Enemies]] — the Rattler Gang roster for the first-playable theme (planned)
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

## Devlog
Dated session notes live in `04 Devlog/` (Obsidian daily notes are configured to put them there).
- [[2026-10-13]] — first design session: GDD, design notes, art direction, ADRs, M1/M2 specs
- New entries use the [[Templates/Devlog|Devlog template]].

## Inbox
Unsorted and proposed ideas go in `00 Inbox/` (`status: proposed`) until they're triaged.
- [[Title Ideas]] — candidate titles and names for the new IP

## Assets & packages
- [[Packages]] — third-party Luau libraries in `ReplicatedStorage.Packages`
- [[References]] — reference images for art and modeling
- [[Original Game]] — data from the 2016 Storm the Train Android APK: enemies, spawning, economy, assets (reference, not canon)

## Techniques
- [[Techniques]] — reusable Blender modeling and other how-tos
