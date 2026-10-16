---
tags: [inbox, combat, vfx, game-feel, proposal]
status: proposed
updated: 2026-10-16
---
# Hit Feedback — proposals from the original's code

> **Status: proposed, not approved.** These are Claude's suggestions, based on how the
> original handles combat feel ([[Original Game - Combat Feel (Native Code)]]). Each one
> needs the developer's OK before it goes into a design note or into Studio. The numbers
> are converted at 15 px ≈ 1 stud and are first guesses.

## Biggest gap: enemies react to hits
Our enemies get a white spark and keep coming. The original makes every hit read.
1. **A flinch on hit, with a cooldown.**
   - A short hit-react (a 0.15–0.25 s lean-back, or an animation) on a gun hit,
   - **skipped mid-attack** (so the telegraph stays honest),
   - then no new flinch for a random 0.8–1.2 × a per-enemy `FlinchCooldown` attribute
     (lights about 0.75 s, mids longer, bosses rarely),
   - no blood, per [[Art Direction]]. Add a brief white `Highlight` flash on every hit,
     even when the flinch is on cooldown.
2. **Per-weapon knockback on every hit**, ÷ a per-enemy `Weight` attribute (1 lights, 2
   mids, 2.8 bosses).
   - The original's scale is rifle 1.6, Scattergun about 10 (and a close blast about
     53), rockets about 17 studs/s.
   - Ours would go through the existing `CombatService.knockback` and `StunnedUntil`,
     with a tiny stun on small pushes.
3. **A weapon pop on knockout:** the enemy's weapon (revolver, lasso…) flies off the
   ragdoll. It's cheap, readable and funny, and it's the original's gib idea without the
   gore.

## Firing
4. **Muzzle flashes**, one template per weapon type in `Assets.Effects`: a rifle flash, a
   Scattergun cone and a twin flash for dual weapons. Spawn it at the `Muzzle` attachment.
5. **±30% fire-rate jitter for slow weapons only** (interval > 0.2 s: the Pocket Rocket,
   Scattergun, Crowd Pleaser…). Fast guns stay steady. That's one line in CombatService's
   timer reset.
6. **Rethink the Scattergun as a "shot plus close blast"** instead of 5 pellets? The
   original's shotgun is one long ray plus a short (about 12 studs) piercing blast with a
   big push. It reads more clearly side-on than a 10° fan. *(This changes a built weapon,
   so the developer must decide.)*
7. **Lobbed throws** (Dynamite Dan, future sticky weapons) should aim at the target's
   distance: speed about 1.6 × max(7, distance × 0.45) studs/s, a 42° arc, plus 20% of
   the thrower's velocity.
8. **Camera shake tiers:**
   - light about 0.75 studs for 0.3–0.6 s (rocket impacts),
   - heavy about 2 studs for 0.4–0.8 s (mech stomp, Air Strike, boss slams),
   - long event shakes of 1.3–2 studs for about 1 s.

   Today we have one 0.5-stud explosion shake.

## Player side
9. **0.3 s of invulnerability after each hit**, so crowds can't shred you in one frame.
   The system notes don't mention one; check [[CombatService]] in Studio before adding it.
10. **A Mayhem gain penalty while a gadget is active** (the original uses × 0.2). It
   stops gadget chaining and fits [[Gadgets and Mayhem]].

## Worth knowing, not proposing
- **The original's combo window is about 1 s**: 2 kills to start, then 1 kill per second.
  Ours is a deliberate 2.5 s ([[Score and Combo]]); leave it.
- **The original pays score and Mayhem per point of damage**, not per KO (Mayhem 0.035 per
  damage plus 0.035 × max HP on the kill). Ours pays per KO, and per damage only for
  bosses. Per-damage rewards suit bosses and assists, but switching is a design change to
  weigh during Mayhem tuning.
- **Achievements:** 9 themes × 3 tiers (Good Student, Skippy, Mutiny, Massacre, Completist,
  Globe Trotter, Metamorph, Seasoned, Techie). That's a possible model for Roblox badges
  later.

Related: [[Original Game - Combat Feel (Native Code)]] · [[CombatService]] · [[EffectsController]] · [[Art Direction]] · [[Gadgets and Mayhem]]
