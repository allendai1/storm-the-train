---
tags: [inbox, proposal, original-game, enemies, gadgets, movement, economy]
status: proposed
updated: 2026-10-16
---
# From the Original — proposals

> **Status: proposed, not approved.** These are ideas taken from the full decompile of the
> original (2026-10-16). Each one needs the developer's OK before it goes into a design note
> or into Studio. The combat-feel ideas (flinch, knockback, muzzle flashes, shakes) are in
> [[Hit Feedback]]. Sources:
> - [[Original Game - Enemy AI (Native Code)]]
> - [[Original Game - Weapons and Gadgets (Native Code)]]
> - [[Original Game - Player and Camera (Native Code)]]
> - [[Original Game - Run Structure and Meta (Native Code)]]

## Decisions to revisit — **resolved 2026-10-16**
- **Charge speed → 2.5× walk** (Bart about 26.7 studs/s).
- **`BERSERK_HEALTH` → keep our wind-up stagger** (a deliberate departure).
- **Boosters → until the next checkpoint** (a whole leg).

They're recorded in [[Wild West Enemies]], the GDD and [[Economy and Monetization]]. What
was asked:

Three of today's decisions were made before the code showed what the original really does:
1. **Charge speed.** We decided "original speeds", which set Big Bart's charge to 10.7 studs/s
   because no charge speed had been recovered. **The original charges at 2.5× walk speed:
   Bart about 26.7 studs/s for 34 studs, a boss about 41.7.** That's between Brick (20) and
   Max (28.3), so fast agents can outrun it and the tank can't. The planned Studio change
   (`ChargeSpeed` 36 → 10.7) is on hold until this is answered.
2. **`BERSERK_HEALTH`.** We decided it's a wind-up *stagger threshold*. **In the original it
   *triggers* the charge:** every ~30 damage Bart takes, he charges, 4–5 times over his
   life, and nothing staggers him. (Our built stagger works and was verified. Keeping it is
   a valid choice, but it isn't the original's.)
3. **Booster duration.** We decided "one train, as in the original". The original actually
   clears boosters **at every checkpoint**, and it has a checkpoint after every train. In
   our 3-train legs, the faithful rule ("until the next checkpoint") is **a whole leg**.

## Enemies ([[Wild West Enemies]])
- **Perception:** enemies notice you only in front of them or after being hit, lose you
  while you jump over them, and back off inside their minimum range.
- **Ranged telegraph:** a shot lands 0.5–0.6 s into the wind-up, 4 s ± 30% apart, and never
  in the first 4 s after spawning.
- **Rodeo Kid:** the spin is a reposition (2.5× speed, about 8 studs high and 19 long) with
  no damage of its own.
- **Saloon Door Sam:**
  - the doors are a real collider,
  - the guard drops while he flinches,
  - he takes 0.2–0.5 s to turn (jumping over him pays off),
  - ×1.6 speed once the doors break.
- **Dynamite Dan:** backs off while reloading. The dynamite has a fuse blink, a radius of
  about 5 studs with no falloff, and it **hurts other bandits**.
- **McGraw:**
  - charges every 4.8–7.2 s,
  - leaps every 4–6 s when you're more than 20 studs away,
  - 2–3 s cross-cooldowns between attacks,
  - **enrages below 15% HP** (charge at least every 2.5 s),
  - never flinches.
- **Ma Rattler (summoner):** bursts into 6–8 minions at 66% and 33% HP and stays
  invulnerable until they're dead, or throws a volley of 3–4 minions every 3–7 s.
- **Boss arena:** a barrier-locked arena of about 67 studs. Lights flee, and a 2 s intro
  taunt plays while the boss is invulnerable.
- **Emergent pacing:** if spawn groups count unclaimed alive cost, lights stall until a mid
  dies, with no scripted "wait for the mid".

## Gadgets and weapons ([[Gadgets and Mayhem]], [[Launch Agents]])
- **Freeze** as a hard stop scaled per enemy (1 / 0.6 / 0.3). Burn refreshes instead of
  stacking, and burning lights flee.
- **Explosion knockback** is radial, with ×1.3 vertical for the "pop-up". Bullets push
  horizontally only.
- **Defender Drone** eats projectiles, and each block costs it duration. **Healer** works on
  charges, not a timer.
- **Turret targeting:** pick the least turn, at 200°/s, and fire when within 1°.
- **Mech:** hits drain the timer (0.65 s per HP) instead of armour, with a 2.5 s
  invulnerable entry and an exit blast. *(Ours uses an armour bar, which is decided. This
  is an alternative.)*
- **Air Strike** as a 14-shell diagonal curtain that lands as a sweep.
- **Mimi's Invisible Bow:** the original's charge curve is EaseInCubic over 1.1 s, with 3
  visual tiers. *(We decided a fixed 70 after a 0.8 s draw; this is only for reference.)*

## Player, movement and camera ([[CharacterService]], [[CameraController]])
- **Jump:** our `JUMP_HEIGHT` 8 is low next to the original's **14 studs**, reached with **2×
  gravity** and about 0.9 s of airtime. Higher gravity plus a higher jump gives a snappier
  feel.
- **Double jump = spin:** pressing while rising adds velocity, and pressing at or after the
  apex resets to a small hop. The spin lasts until landing, guns pause during it, and its
  knockback pops enemies up.
- **Camera:** lead about **17 studs** in the move direction only while moving, ease the flip
  over about 2 s, and recentre when stopped. Ours leads 8 studs by facing.
- **Revive:** 3 s of invulnerability, a radial push, and **every enemy flees** for a moment.
- **Train leap** (scripted): auto-run 22 → 45 studs/s, the jump unlocks about 28 studs
  before the edge, the spin is locked for 0.2 s after landing, then a forward push.

## Run structure and economy ([[Loop (M2)]], [[Economy and Monetization]], [[Score and Combo]])
- **Event strength tied to run score** (every 40k: more bosses and adds, more waves), which
  gives catch-up for weaker squads.
- **Spawn just off-screen ahead** (about 3 studs past the edge). Spawn behind only on a
  1-in-3 roll when the squad isn't advancing.
- **Event payouts:** the original pays 125–500 coins and 5k–20k score per event, by tier.
  Our train-clear bonus (500 + 100 per train) is small next to that.
- **Magnet booster:** 24-stud radius, pull ramping from 0 to 60 studs/s over 1.2 s, 5 s
  linger.
- **Daily challenge baseline:** 300 / 600 / 1,200 / 2,400 coins, then 20 gems.
- **Missions can introduce events** (`PushEventFirst`). That's a clean way to teach events.

Related: [[Hit Feedback]] · [[Original Game]] · [[Wild West Enemies]] · [[Gadgets and Mayhem]] · [[Loop (M2)]]
