---
tags: [technique, blender, animation]
status: implemented
---
# Blender to Roblox Animation

## When to use
Authoring an R15 clip in Blender (the spin, and later the F3 set in [[Feel and Look Asset
Specs]] §1) and getting it into the place without the Animation Editor's FBX importer.
First used for `Max_Spin` ([[2026-10-17]]). Source files live in `05 Assets/Animations/`
(`Max_Spin.blend`, `Max_Spin.fbx`).

## Steps
1. **Build a bone per R15 part, named exactly like the part** (`HumanoidRootPart` →
   `LowerTorso` → `UpperTorso` → `Head`, the arms off `UpperTorso`, the legs off
   `LowerTorso`). Put each bone's head at the joint and point **every bone straight up
   (+Z) with roll 0**. With Blender's Z-up/−Y-front and Roblox's Y-up/−Z-front, that makes
   each bone's local axes equal the Roblox joint axes, so a pose bone's `matrix_basis`
   rotation *is* the Roblox `Pose.CFrame` rotation. No axis conversion anywhere.
2. Parent a box per part (R15 sizes, in studs = metres) to its bone so `look` shows the
   character. Animate at **30 fps** with `rotation_mode = 'XYZ'`; rotate about local X for
   anything in the screen plane (+X tips the top back / swings the bottom forward).
3. Key the whole-body spin on **`LowerTorso`** (the Root joint): the HumanoidRootPart is
   physics-driven and can't be animated. Key every frame for rotations over 90° so Roblox's
   shortest-path interpolation can't go the wrong way.
4. **Export the poses**: for each frame, each bone's `matrix_basis` 3×3 → JSON. A small
   Python script turns that into a Luau script that builds a `KeyframeSequence` (Keyframe →
   nested `Pose`s named after the parts, `CFrame.new(0,0,0, r00..r22)`, Linear easing) under
   the rig's `Animations` folder. Run it with `execute_luau` in the Edit datamodel. Bones
   that don't change are keyed only on the first and last frame.
5. Also export an FBX (`object_types ARMATURE+MESH`, `bake_anim`, `-Z forward / Y up`) and
   save the `.blend` next to it, as the editable source.

6. **Pivot a whole-body spin on the body, not the hip.** The Root joint sits at the hip, so
   a rotation-only Root pose orbits the body around the hip. At export, give the Root pose
   a translation: `T = CFrame.new(target) * R * CFrame.new(-c)`, where `c` is the posed
   body's volume centroid in the hip frame and `target` is where that centroid should sit
   (the HumanoidRootPart centre is `(0, 1, 0)` in the hip frame). Measure `c` on a posed
   copy (step 7) with the same part list you'll judge it by; for `Max_Spin` it is
   `(0, 0.72, -0.81)`. Verified: the centroid then stays within 0.06 studs over the spin.
7. **Preview or measure a pose in Edit mode** without the Animation Editor: clone the rig
   into `Workspace`, anchor it, and walk its `AnimationConstraint`s setting
   `child.CFrame = parent.CFrame * Attachment0.CFrame * Pose.CFrame * Attachment1.CFrame:Inverse()`,
   then `screen_capture` from +X (the template faces −Z, so +X is the side view). Delete
   the clone afterwards. Welded cosmetics (tails, gun) don't follow joints.

8. **Upper-body clips and the gun** (`Max_Rifle.blend`, Hold and Shoot): build the rig from
   the **real** joint positions (read `AnimationConstraint` attachments off the template; the
   R15 upper arm sits 0.53 studs outboard of the shoulder joint, so FK/IK with a straight
   "down" offset is wrong) and parent a rifle stand-in to the RightHand bone at the grip
   convention. Pose the right arm by FK and solve the left arm with a two-bone IK onto the
   rifle (Blender's IK needs limb-aligned bones, which this rig doesn't have). Export only
   the upper-body bones; the builder gives the structural parents Weight 0. Mind that the
   rig faces +Y in Blender, so `look`'s "front" view is its back.

## Roblox export notes
- The scripts build **`KeyframeSequence`s**, not published assets. To publish: select the
  KeyframeSequence, open the Animation Editor, load it, Publish to Roblox under the place's
  owner, and paste the id into the sibling `Animation` instance's `AnimationId`.
- In Studio playtests, `KeyframeSequenceProvider:RegisterKeyframeSequence` gives a temporary
  id, which is what the client uses while `AnimationId` is empty. **That only works in
  Studio**: the live game needs the published id.
- Blender 5 actions are layered: f-curves are under `action.layers[].strips[].channelbags[]`.
- A looping clip: make the last keyframe the pose *before* returning to the start (frames
  0–17 for an 18 f loop); Roblox wraps to time 0 after the last keyframe.

## Example
- `Max_Rifle.blend`: `Max_Hold` (30 f, two hands, barrel ~12° down with a 3° bob) and
  `Max_Shoot` (5 f: aim level, 1 f kick with the muzzle up 6° and the shoulders back, 3 f
  recover). Actions export as separate FBX takes.
- `Max_Spin`: 18 f at 30 fps, two front flips (one per 9 f, 0.3 s) in a tight somersault tuck
  (hips 145°, knees −150°, torso −45°, head −45°, arms 85° forward with the elbows bent
  −95° to hug the shins; about 2.7 studs across). Verified in a playtest on 2026-10-17 (the rig's joints are
  `AnimationConstraint`s; the Animator drives them like Motor6Ds). Played by
  [[AgentAnimationController]].

Related: [[Techniques]] · [[Art Direction]] · [[Feel and Look Asset Specs]]
