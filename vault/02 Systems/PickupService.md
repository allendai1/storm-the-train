---
tags: [system, m1, pickups]
status: implemented
side: server, client
---
# PickupService (+ PickupController)

## Purpose
**Personal weapon crates** ([[First Playable (M1)]] → Weapons and weapon crates): every
`WeaponCrateSpot` on the train holds one crate **per player**. Walking into your own crate
flips you to your agent's other weapon. It comes back for you after `WEAPON_CRATE_RESPAWN`
(20 s). The server decides every pickup; the client only draws your own crates.

## Code
- Server: `ServerScriptService.Server.Services.PickupService` (`Modes = { "Run" }`)
- Client: `StarterPlayer.StarterPlayerScripts.Client.Controllers.PickupController`
- Shared: `ReplicatedStorage.Shared.WeaponCrates`. It defines the spot order (the
  `WeaponCrateSpot` attachments in `workspace`, sorted by world X) and the attribute name,
  so both sides agree.

## Expects in the place
- Attachments tagged `WeaponCrateSpot` on carriage roofs (Boxcar and CattleCar, see
  [[TrainService]]).
- Template `ReplicatedStorage.Assets.Pickups.WeaponCrate`: a wooden crate with gold bands
  and a neon star. Its pivot is the bottom centre, and it has no collision or queries.
- Runtime-generated content: the client clones one crate per ready spot into `workspace`
  (local only) and bobs and spins it.

## Public API
None yet.

## Remotes
None. The state is the **Player attribute `CrateReadyAt_<index>`**: the server time
(`GetServerTimeNow`) when that spot's crate is back. Missing means ready.

## Data / state
- **Server, every `PICKUP_CHECK_INTERVAL` (0.1 s):** for each living player and each spot
  that's ready for them, if the HumanoidRootPart is within `CRATE_PICKUP_RADIUS` (3) of
  the spot + `CRATE_PICKUP_HEIGHT` (3), it sets the attribute to now + 20 and calls
  `CombatService.toggleWeapon`.
- **Client, every frame:** it shows a crate for each ready spot. When a spot goes from
  ready to taken, it removes the crate with a spark pop (`EffectsController.spark`).

## Depends on
- [[CombatService]] (`toggleWeapon`), [[EffectsController]] (client pop), `Shared.Constants`

## Notes
- The crate rules are built as proposed in the M1 spec: personal crates, a 20 s respawn,
  and every train starting on the primary weapon (CharacterService equips it on spawn).
- **Not yet done:**
  - a crate drop on a **mid knockout**. It arrives with Big Bart in Session 4: drop a crate
    for each player at the knockout position.
  - the agent's one-line bark on pickup, which needs the HUD (Session 5).
  - resetting `CrateReadyAt_*` on PLAY AGAIN (Session 5).
- Verified 2026-10-13: walking the roofs in a playtest picked up a crate and switched
  `ActiveWeapon` to `PocketRocket`. A crate showed on the boxcar roof in the screen
  capture.
