---
tags: [system, slice, f3, animation]
status: implemented
side: client
---
# AgentAnimationController

## Purpose
Plays the agents' state animations (F3, Max's feel) from the rig's `Animations` folder.
Today that is only the **spin**: the track plays and the gun is hidden while the player
attribute `Spinning` (set by [[CombatService]]) is true, and both revert when it goes false, for every player's
character, so teammates' spins show too. Cosmetic only; the spin's hits are server-side.

## Code
- Studio path: `StarterPlayer.StarterPlayerScripts.Client.Controllers.AgentAnimationController`
  (`Modes = { "Run" }`, `start()` only).

## Expects in the place
- On each agent template (`ReplicatedStorage.Assets.Agents.<AgentId>`), an **`Animations`
  folder** holding:
  - `SpinAnimation` (an `Animation`): the published spin clip's `AnimationId`,
  - `Spin` (a `KeyframeSequence`): the hand-editable clip itself, built from Blender
    ([[Blender to Roblox Animation]]).

  Built so far: **DashDaring only** (Max). Brick has no `Animations` folder yet, so he
  keeps the old pose.
- **`UpperTorso.SpinWeaponAttachment`** on the agent template: where the gun's `Handle`
  sits during the spin (hand-editable; Max's is `CFrame.new(0, -0.6, -0.7) *
  CFrame.Angles(100°, 0, 0)`, the barrel up along the curled spine).
- The rig's joints are **`AnimationConstraint`s** (not Motor6Ds), which the `Animator`
  drives the same way. The `Animator` lives under the Humanoid.
- Runtime-generated content: **`Character.SpinWeapon`**, a client-only clone of
  `Character.Weapon` shown while spinning (the real gun is welded to the root, which
  physics owns, so the clip can't turn it). The clone drops **only** the `WeldConstraint` to the
  character (the hand weld; was the root weld) (the weapon's parts hang on the Handle through their own
  WeldConstraints; stripping those too made the gun fall apart mid-air, fixed
  2026-10-17), is massless and non-colliding, and is `Weld`ed by its `Handle` to the UpperTorso at
  `SpinWeaponAttachment`; destroyed when the spin ends. It's a clone of a hand-built
  template, so nothing is styled in code. While `SpinAnimation.AnimationId` is empty, in Studio
  only, the controller registers the `Spin` KeyframeSequence with
  `KeyframeSequenceProvider` and plays it through the temporary id. **The live game needs
  the published id** (see Notes).

## Public API
- none (it only reacts to attributes).

## Remotes
- none.

## Data / state
- Per player: the current `AnimationTrack?`, dropped on `CharacterRemoving` and re-checked
  on `CharacterAdded` (a mid-air swap keeps `Spinning` true, so the new rig spins too).
- The track plays at **`SPIN_SPEED` 2.5×** (user request, 2026-10-17: the spin should read
  as a blur, not a body; the clip's one flip per 0.3 s becomes one per 0.12 s, about 8
  flips a second). Tune that constant, not the clip.
- The track plays at `Action2` with a 0.05 s fade in and out, so it wins over the
  `Animate` script's jump/fall tracks and blends back into them on landing.

## Depends on
- [[CombatService]] (the `Spinning` attribute), [[CharacterService]] (the rig and its
  `Animate` script).

## Notes
- **Verified 2026-10-17** in a playtest: a double jump sets `Spinning`, `SpinAnimation`
  plays (looping, 0.567 s per loop), stops when the attribute goes false, no console errors.
- **To publish the clip:** select `Animations.Spin`, open the Animation Editor, load it,
  Publish to Roblox under the place's owner, then paste the id into
  `Animations.SpinAnimation.AnimationId`.
- **The clip ends on the rig's own landing** (2026-10-17): `Spinning` stays true about
  0.3–0.5 s after touchdown (CombatService's landing raycast runs on the replicated root),
  so the controller also stops the track and unhides the gun on `Humanoid.StateChanged` →
  `Landed`/`Running`. The server's spin state is untouched. Verified in play: the track
  stops at `Running` while `Spinning` is still true.
- **The spin pivots on the body's centroid**, parked on the HumanoidRootPart centre: the
  Root pose carries a translation per frame ([[Blender to Roblox Animation]] step 6).
  Verified: the centroid stays within 0.06 studs through the spin.
- The clip is a **tight somersault tuck** (2026-10-17, tightened twice at the user's
  request): hips 145°, knees folded 150°, torso and head curled 45° over the knees, arms
  hugging the shins. The shirt front and bow tie are welded to the UpperTorso and follow the
  tuck; the tux tails hang off the LowerTorso and are hidden instead.
- **The gun spins with him** (user request, 2026-10-17): the real gun is hidden and the
  torso-welded `SpinWeapon` copy shows instead (above). Verified in play: the copy appears
  with the track and is destroyed on `Landed`.
- **The real gun and the tux tails are hidden while spinning** (user request, 2026-10-17):
  `setWeaponHidden` sets `LocalTransparencyModifier` 1 on every part of the character
  children in `HIDE_WHILE_SPINNING` (`Weapon`, `TuxTails`) when `Spinning` goes true and 0
  when it goes false. Add a name to that list to hide another root-welded piece. Client-side only; the hand-set `Transparency` is untouched
  and the server's muzzle keeps working. Verified in play (modifier 1 during the spin, 0
  after).
