---
tags: [decision, enemies, combat, performance, physics]
status: accepted
date: 2026-10-13
---
# 0006 — Humanoid enemies with physics, server-side hit detection

## Context
Up to 4 players fight crowds of 15–30 enemies ([[Wild West Enemies]]). Knock-outs are
ragdolls that stay on the train, and knockback can push living enemies off the train
(GDD → Tone). The developer chose **Humanoid NPCs with Roblox physics** over a custom
2D simulation.

## Decision
- **Rigs:**
  - Enemies are R15-compatible **Humanoid** rigs, using the same skeleton as agents.
  - Templates live in `ServerStorage.Assets.Enemies.<Theme>.<Name>`.
  - Each template carries its design numbers as **Attributes**: `Slot`, `Archetype`,
    `MaxHealth`, `Speed`, `SpawnCost`, `HitboxWidth`, `HitboxHeight`,
    `FreezeScalar`, `Damage`.
  - They're tagged `Enemy` with CollectionService.
- **Server-owned:** every enemy part gets `SetNetworkOwner(nil)`. Enemies use the same
  Z = 0 plane lock as players ([[0005-side-on-movement-and-camera]]).
- **AI:**
  - One `EnemyService` loop runs on `Heartbeat` at about **10–15 Hz** for decisions;
    Humanoid movement fills in between. There are no per-enemy scripts.
  - Each archetype is a behaviour module (Walker, Shooter, Leaper, Lobber, Grappler,
    Charger, Shielded, SummonerBoss, ChargerBoss).
  - Enemies move with `Humanoid:Move` along X. They don't use `PathfindingService`,
    because the track is one-dimensional.
  - At a gap between cars, a downward ray detects the edge and the enemy jumps.
- **Keeping Humanoids cheap:**
  - Disable unused `HumanoidStateType`s: Climbing, Swimming, Seated, Flying,
    StrafingNoPhysics and RunningNoPhysics.
  - Set `BreakJointsOnDeath = false` and `RequiresNeck = false`.
  - **Health lives in our own `Health` Attribute,** not `Humanoid.Health`, so Roblox's
    death handling never fires.
  - Spawning respects the design's **alive cap**.
- **Hitboxes:**
  - Each player character and enemy has an invisible, non-colliding **`Hitbox` part**,
    welded to the root and sized from the design hitbox, in collision group
    `Hitboxes`.
  - Combat queries only ever hit `Hitboxes`. Bodies, props and ragdolls are ignored.
- **Weapons and hit detection are server-side:**
  - The client sends **input state**, not shots: trigger held or released, plus aim
    ([[0007-networking-and-remotes]]).
  - The server fires at the weapon's own interval from the character's muzzle, in the
    facing direction.
    - **Hitscan weapons** (rifle, SMGs, pistols, minigun, lightning) use
      `workspace:Raycast` or `Spherecast` along the plane against `Hitboxes`.
    - **Projectiles** (rockets, sticky bombs, plasma, enemy dynamite and bullets) are
      **simulated by the server as data**: position and velocity, stepped each
      Heartbeat with a raycast per step. They're not physical parts.
  - Clients draw tracers, projectiles and impacts as **client-side visuals**, from
    replicated events.
  - There's no lag compensation at first. Enemies are slow and players outrun them.
    Revisit this if hits feel unfair in playtests.
- **Knock-outs:**
  - On a knockout, the server switches the enemy to ragdoll:
    - Humanoid state set to `Physics`,
    - the template's pre-built `BallSocketConstraint`s enabled and its `Motor6D`s
      disabled,
    - an impulse applied.
  - The ragdoll's network ownership goes to the **nearest player**, to spread the
    physics load.
  - Ragdolls are in collision group `Ragdolls`, which doesn't collide with players or
    `Hitboxes`. They fade after about **3 s**, with **at most 12** at once; the oldest
    fade first.
- **Knocked off the train:** knockback is a real physical impulse on living enemies. An
  enemy that falls below the track's Y threshold counts as **knocked out** and is
  removed.
- **Performance budget:**
  - Target **≤ 30 live Humanoid enemies + 4 players + 12 ragdolls** per run server.
  - Measure in M1 with the MicroProfiler and the server stats.
  - If the budget fails, write a new ADR that **supersedes this one**. The fallback is
    a server-side 2D simulation with lightweight, non-Humanoid models.

## Alternatives considered
- **Server-side 2D simulation with non-Humanoid models and client-side ragdolls:**
  cheaper and more cheat-proof, and it fits the original's hitbox data directly. It
  was rejected for now in favour of standard Roblox Humanoids and real physics, and
  it's kept as the fallback.
- **Client-side hit detection with server checks:** feels snappier, but it's open to
  hit spoofing. That conflicts with `CLAUDE.md`'s rule that the server is
  authoritative.

## Consequences
- Standard Roblox animation, ragdoll and knockback physics, with less custom maths.
- Humanoid cost is the main performance risk. The alive cap and the disabled states
  are mandatory, not optional.
- Players can't be hit by physical enemy parts, only through the server's hitbox
  queries, so damage stays authoritative.
- Ragdolls owned by players can be messed with by those players, but they're cosmetic
  only: they deal no damage and give no score.

Related: [[0005-side-on-movement-and-camera]] · [[0007-networking-and-remotes]] · [[Wild West Enemies]] · [[Home]]
