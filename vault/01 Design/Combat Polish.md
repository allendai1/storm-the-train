---
tags: [design, feature, combat, game-feel, polish, m2]
status: planned
updated: 2026-10-16
---
# Combat Polish — a refined first agent

> **Status: planned.** The developer accepted these on 2026-10-16, from [[Hit Feedback]]
> and [[From the Original - Proposals]]. **The priority is a playable, refined first agent
> (Max Mayhem)** before the other agents' and enemies' special mechanics. Everything here
> applies to what's already built (M1/M2). The numbers come from the decompiled original
> (converted at 15 px ≈ 1 stud) and are first guesses to tune. Nothing here is built yet;
> each item names the system note it changes. **The code is drafted in [[Combat Polish Code]].**

## Enemy hit reactions
- [ ] **A flinch with a cooldown** ([[EnemyService]], [[CombatService]]). From the original's
  `Enemy::HandleDamageAnim`.
  - **On a gun hit,** the enemy plays a short hit-react (0.15–0.25 s: a lean-back tween or
    an animation) and pauses its movement for that time.
  - **Never during an attack.** No flinch during a wind-up or an attack, so telegraphs
    stay honest.
  - **Then a cooldown:** no new flinch for a random **0.8–1.2 × `FlinchCooldown`** (a new
    template attribute: lights 0.75 s, Big Bart 1.5 s). **Bosses never flinch.**
  - **Explosions don't use the flinch.** They use the pop-up knockback below.
- [ ] **Explosion pop-up knockback** ([[CombatService]], from [[Gadgets and Mayhem]]).
  Explosions push radially, with **×1.3 on the upward part**, so enemies pop up and away.
  Bullets don't push (no change).

## Firing
- [ ] **Muzzle flashes** ([[EffectsController]], [[CombatService]]).
  - One template per weapon type in `ReplicatedStorage.Assets.Effects`:
    `MuzzleFlashRifle`, `MuzzleFlashScattergun` (a cone) and `MuzzleFlashRocket`, plus a
    twin version for dual weapons later.
  - A weapon attribute `MuzzleFlash` names its template.
  - It's spawned client-side at the weapon's `Muzzle` attachment, from the existing tracer
    or rocket records, and lasts about 0.05–0.08 s.
- [ ] **The Scattergun stays at 5 pellets** (decided 2026-10-16; the original's "shot plus
  close blast" was considered and turned down).

## Enemy attacks and AI
- [ ] **Attack-cadence jitter** ([[EnemyService]]): each ranged enemy's cooldown is
  × random(0.7, 1.3) after every shot. Player guns stay steady.
- [ ] **Ranged telegraph rules** ([[EnemyService]]):
  - the shot fires **0.5–0.6 s into the wind-up** (the "!" alert stays),
  - **no enemy fires in its first 4 s after spawning.**
- [ ] **Perception rules** ([[EnemyService]]):
  - an enemy only notices a player **in front of it**, or one who **has hit it**,
  - it **loses its target while that player is jumping over it** (the player is above
    and behind), and walks on past,
  - it **backs off when closer than its weapon's minimum range** (a `MinRange` attribute
    on ranged enemies).
- [ ] **Spawn just off-screen, ahead** ([[SpawnService]]). This fixes the known issue that
  the 20-stud minimum is inside the ~35-stud half-width of the camera.
  - Spawn at **the camera edge + about 3 studs, on the side the squad is heading**, with
    3–10 studs between extra enemies in a wave.
  - Spawn behind only on a **1-in-3 roll, and only when the squad isn't advancing**.
- [ ] **Lobbed throws: Dynamite Dan** ([[EnemyService]], [[Wild West Enemies]]).
  - **Aim at the target's distance:** horizontal speed = 1.6 × max(6.7, distance × 0.45)
    studs/s, on a low arc (about 25–30°), plus 20% of Dan's own velocity.
  - **A fuse blink** that speeds up: the blink period is the remaining fuse × 0.2 s, at
    least 0.02 s.
  - **The blast hurts other bandits too,** as in the original. *(Open: who gets the score
    and Mayhem credit for a dynamite knockout? First guess: nobody.)*

## Max and the squad
- [ ] **0.3 s of invulnerability after any hit** ([[CombatService]], [[SquadService]]).
  Further damage in that window is ignored, so a crowd can't shred you in one frame.
- [ ] **The spin as a pop-up** ([[CombatService]], [[InputController]]):
  - **the spin lasts until you land,**
  - **your gun pauses during the spin** and resumes on landing (fire input is remembered),
  - **its knockback pops enemies up and away:** equal sideways and upward push
    F = 6.7 × spin level studs/s (Max at level 4 is about 27; Brick at 6 is about 40).
- [ ] **Revive grace** ([[SquadService]]): on any revive (by a teammate, or with gems
  later), **3 s of invulnerability** and a radial push of nearby enemies (about 100 studs/s,
  ÷ their weight later).

## Camera
- [ ] **A bigger lead, only while moving** ([[CameraController]]):
  - lead **about 17 studs** in the direction you're moving, but only while you're moving,
  - when you turn, the lead eases across at about 7 studs/s (about 2 s to flip fully),
  - when you stop, it recentres,
  - this replaces today's fixed 8-stud lead by facing. Tune it against the 70-stud view.

## Not adopted (2026-10-16)
- **Turned down:** a white flash on every hit, per-weapon knockback ÷ weight on every hit,
  the weapon pop on knockout, camera-shake tiers, and Mayhem ×0.2 while a gadget is active.
- **Turned down, so movement stays as built** (the 8-stud jump and so on): the original's
  higher 14-stud jump, the original's double-jump
  velocity rule, the scripted train leap, and emergent "wait for the mid" spawn pacing.
- **Deferred:** the light and mid special mechanics (the Rodeo Kid spin, Saloon Door Sam's
  doors, Dan backing off, enemies fleeing on revive). They wait until the first agent is
  refined.

Related: [[Hit Feedback]] · [[From the Original - Proposals]] · [[First Playable (M1)]] · [[Loop (M2)]] · [[CombatService]] · [[EnemyService]]
