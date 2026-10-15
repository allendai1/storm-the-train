---
tags: [system, m2, gadgets, mayhem]
status: implemented
side: server, client
---
# GadgetService + MayhemService (+ MayhemController)

## Purpose
The Mayhem meter and gadgets ([[Gadgets and Mayhem]], [[Loop (M2)]] Session 11).
- **MayhemService** fills each player's meter.
- **GadgetService** validates deploys and runs the M2 gadgets: Turret, Melee and Defender
  Drones, the Heavyweight mech and the Air Strike.
- **MayhemController** (client) draws the ring and gadget fan.

## Code
- `ServerScriptService.Server.Services.MayhemService` and `…Services.GadgetService`
  (`Modes = { "Run" }`)
- `StarterPlayer.StarterPlayerScripts.Client.Controllers.MayhemController`

## Expects in the place
- **Agent template attribute `Gadgets`** (slot order): Dash
  `TurretDrone,MeleeDrone,AirStrike`; Brick `DefenderDrone,Heavyweight,AirStrike`. Brick also
  has `MayhemPerDamage` 0.5 (his perk).
- **Enemy template attribute `MayhemValue`:** lights 4, Bart 20.
- **`ReplicatedStorage.Assets.Drones`:** greybox models with pivot = `Body`.
  - `TurretDrone`: `Duration` 30, `Damage` 8, `FireInterval` 0.25, `Range` 25.
  - `MeleeDrone`: 30, 15, 0.6, 25, `Speed` 40, `Reach` 2.5.
  - `DefenderDrone`: `Duration` 51, plus a ForceField `Shield` part, thin along X, 7 tall.
- **`ReplicatedStorage.Assets.Mechs.Heavyweight`:** a purple suit with a gold belt, glass dome
  and yellow foam fingers. Attributes:
  - `Duration` 15, `Speed` 23, `Armour` 200,
  - `Damage` 12, `FireInterval` 0.1, `Reach` 4, `Knockback` 40,
  - `StompDamage` 200, `StompRadius` 6,
  - `SlamDamage` 40, `SlamRadius` 7,
  - `HitboxWidth` 4.4, `HitboxHeight` 8.5.
- **Effects:** `StrikeMarker` (a neon red bar) and `StrikePlane`.
- **HudGui:**
  - `MayhemRing` (TextButton circle: `Glow` UIStroke, `Fill` circle, `Percent`),
  - `GadgetFan` (`Slot1..3`: `KeyLabel`, `NameLabel`; minimum size 96 × 40),
  - `ActiveGadget`, `GadgetHint`,
  - `Teammates.Template.MayhemRing`.
- Remote `RequestGadget`.
- Runtime-generated content: `Workspace.Gadgets` (deployed drones), and the mech clone welded
  inside the character (`Mech`), both from templates.

## Public API
- `MayhemService.get`, `add`, `isFull` and `reset(player)`.
- `GadgetService.reset(player)`: removes the drone and ejects from the mech without the
  ring (run end, PLAY AGAIN).

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `RequestGadget` | client → server | `slot: 1 \| 2 \| 3` | `Guard.number(1, 3, integer)`, 2/s with burst 2, a strike on a bad payload |

**Refused when:**
- RunState isn't `InTrain` ("NOT BETWEEN TRAINS"),
- the player is downed,
- the meter isn't full ("MAYHEM NOT FULL"),
- the player is in a mech ("IN A MECH"),
- a drone is already up ("DRONE ALREADY ACTIVE"),
- an Air Strike is already incoming for the party ("STRIKE INCOMING").

Refusals set `GadgetMessage` and `GadgetMessageCount`.

## Data / state
- **Mayhem** (Player attribute, 0–`MAYHEM_MAX` 100):
  - a knockout gives the killer the enemy's `MayhemValue`, ×`MAYHEM_SPIN_SCALE` (1.5) for a
    spin knockout,
  - each other damager gets ×`MAYHEM_ASSIST_SCALE` (0.5),
  - `MayhemPerDamage` × raw damage taken (Brick),
  - it never decays, carries over swaps and trains, and is emptied on deploy.
- **Drones** (one per player, kept through swaps):
  - each hovers at `DRONE_OFFSET` behind and above its owner; the Defender hovers at
    `DEFENDER_OFFSET` in front,
  - positions update every Heartbeat, and attacks every `DRONE_STEP` (0.1 s),
  - the Turret hits the nearest enemy in range, with a tracer,
  - the Melee Drone flies to its target and punches within `Reach`,
  - the Defender's `Shield` is a `CombatService` blocker: [[EnemyService]] bullets and
    dynamite that cross it are removed,
  - Player attributes `DroneId` and `DroneEndsAt`.
- **Mech** (Heavyweight):
  - **on deploy:** the agent's parts are hidden, the suit is welded to the root, and the
    Hitbox grows to 4.4 × 8.5. WalkSpeed becomes 23. The character's spin attributes become
    the body slam (`SpinDamage` 40, `SpinRadius` 7, `SpinKnockback` 40). The **entry stomp**
    does 200 within 6 studs,
  - **while suited:**
    - hits drain `MechArmour` instead of Health, through the `CombatService` damage
      filter,
    - holding the trigger punches everything in reach in front (12 every 0.1 s) with
      knockback,
    - `CombatService` skips its normal firing, and swaps are refused,
  - **eject** on the timer or at 0 armour: everything is restored, with 1 s of
    invulnerability and a knockback ring,
  - Player attributes `InMech`, `MechEndsAt`, `MechArmour` and `MechArmourMax`.
- **Air Strike** (one per party):
  - the span is the carriage under the player plus half of each neighbour,
  - the `Effects` record `Z` (x1, x2, y, seconds) draws a blinking marker, and a plane that
    crosses as it lands,
  - "3… 2… 1… INCOMING!",
  - after 3 s, 200 to every enemy in the span (attributed to the player, as source
    "Gadget"), plus 8 explosion records,
  - workspace attribute `AirStrikeAt`.
- **MayhemController:**
  - the ring's `Fill` grows with the meter, and `Glow` turns gold when full,
  - "MAYHEM READY!" appears when it fills,
  - the fan shows the active agent's gadgets while full and in a train,
  - keys 1/2/3, F repeats `LastGadget`, and the slots can be tapped,
  - `ActiveGadget` shows the drone or mech timers and armour, and the strike countdown,
  - it fills the teammate cards' small rings,
  - it **disables the Backpack CoreGui**, because the hotbar was claiming the number keys.

## Depends on
- [[CombatService]] (`onKnockout`, `onPlayerDamaged`, `setDamageFilter`, `addBlocker`,
  `isFiring`, `SpinKnockback`), [[TrainService]] (carriages for the strike),
  [[RunStateService]] (resets), [[Guard]], `Shared.Constants`

## Notes
- **Verified 2026-10-14 (one player, Mayhem set by hand):**
  - the full ring glowed and the fan listed TURRET DRONE / MELEE DRONE / AIR STRIKE,
  - key 2 deployed the Melee Drone and emptied the meter; the drone flew out and its
    knockouts refilled Mayhem (28 = 7 lights × 4).
- **Found:** key 1 was swallowed by Roblox's Backpack hotbar, so the Backpack CoreGui is now
  disabled. Studio's virtual input still refuses to send key 1 ("bound to a CoreGUI core
  action"), so **press 1 by hand** to confirm it. The fan's Slot1 button and key 2 both
  work.
- **Verified 2026-10-15:**
  - **Turret Drone:** 4 knockouts in 6 s, and its kills refilled Mayhem.
  - **Lock:** Slot2 with a drone up → "DRONE ALREADY ACTIVE", and the meter stays full.
  - **Air Strike:**
    - the countdown banner, marker and readout,
    - 200 to a bandit inside the span (caboose + half the boxcar),
    - the meter emptied and `AirStrikeAt` cleared.
  - **Heavyweight:**
    - the entry stomp knocked out 3,
    - armour 200, WalkSpeed 23, hitbox 4.4 × 8.5, the agent hidden, the slam spin values
      set,
    - hits drained armour (3 per light punch) and **Health didn't drop**,
    - **E was refused** while suited,
    - it **ejected at 15 s** with everything restored (speed 20, hitbox 2 × 6.3, visible,
      spin 9).
- **Fixed 2026-10-15: knockback didn't carry.** The enemy AI's `Humanoid:Move` and the
  Humanoid's own braking cancelled pushes (the peak was 11–17 studs/s against a 40 push).
  Now `CombatService.knockback(enemy, velocity)` sets `StunnedUntil` (`KNOCKBACK_STUN`
  0.6 s) and `PlatformStand`. EnemyService stops steering while stunned, then stands the
  enemy back up. The mech punches, body slam and eject ring use it. **Re-verify** (the
  playtest start hung again).
- **Not verified yet:**
  - the Defender blocking bullets and dynamite (it needs Six-Shooters or Dans in range),
  - the knockback fix,
  - the teammate rings (2+ players),
  - the touch fan.
- **Simplifications:**
  - the ring fills from the centre, not as a clockwise arc (art pass),
  - the mech has no heavy gravity (3.5), which would need client-side physics,
  - drones are server-moved anchored models, so they may look a little steppy on clients.
    Move them to client-side visuals if it shows.
