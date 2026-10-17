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
- The rig's joints are **`AnimationConstraint`s** (not Motor6Ds), which the `Animator`
  drives the same way. The `Animator` lives under the Humanoid.
- Runtime-generated content: _none_. While `SpinAnimation.AnimationId` is empty, in Studio
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
- **Seen in the test:** `Spinning` stays true about 0.4–0.5 s after the Humanoid's `Landed`
  state, so the spin loops on the ground for a few frames. That's CombatService's landing
  check (a raycast from the replicated root), not this controller; the F3 landing clip
  (`Max_Land`) should probably cut the spin on the client's own `Landed`.
- The clip is a **tight somersault tuck** (2026-10-17, tightened twice at the user's
  request): hips 145°, knees folded 150°, torso and head curled 45° over the knees, arms
  hugging the shins. The shirt front and bow tie are welded to the UpperTorso and follow the
  tuck; the tux tails hang off the LowerTorso and are hidden instead.
- **The gun and the tux tails are hidden while spinning** (user request, 2026-10-17):
  `setWeaponHidden` sets `LocalTransparencyModifier` 1 on every part of the character
  children in `HIDE_WHILE_SPINNING` (`Weapon`, `TuxTails`) when `Spinning` goes true and 0
  when it goes false. Add a name to that list to hide another root-welded piece. Client-side only; the hand-set `Transparency` is untouched
  and the server's muzzle keeps working. Verified in play (modifier 1 during the spin, 0
  after).
