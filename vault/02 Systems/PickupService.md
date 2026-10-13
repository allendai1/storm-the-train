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
- `PickupService.dropCrate(position)`: a mid knockout. It makes a `DroppedCrateSpot`
  attachment tagged `WeaponCrateSpot` on the roof under `position`, with a `DroppedAt`
  attribute, so it's a personal crate for every player. It lasts `WEAPON_CRATE_RESPAWN`
  (20 s), then is removed. `WeaponCrates.spots()` sorts dropped spots **after** the train's
  own spots, so a drop never renumbers the `CrateReadyAt_<i>` attributes.
- `PickupService.dropBlueprint(position)`: clones `ReplicatedStorage.Assets.Pickups.Blueprint`
  (a blue `#2F6FD6` scroll with white bands) onto the roof under `position`. Each player
  collects it once by proximity (radius 6 from the HumanoidRootPart), which adds 1 to the
  Player attribute `Blueprints` (not saved in M1). It's removed once every current player
  has it.

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
  - the agent's one-line bark on pickup, which needs the HUD (Session 5).
  - resetting `CrateReadyAt_*` on PLAY AGAIN (Session 5).
- The blueprint is one shared model, so everyone sees it until the last player takes it.
  Make it per-player if that's confusing in co-op.
- Verified 2026-10-13 (Session 4): Bart's knockout made a dropped crate spot, and the
  thief's knockout dropped a blueprint that set `Blueprints = 1`. Picking up a dropped
  crate wasn't tried.
- Verified 2026-10-13: walking the roofs in a playtest picked up a crate and switched
  `ActiveWeapon` to `PocketRocket`. A crate showed on the boxcar roof in the screen
  capture.
