---
tags: [design, slice, art, animation, vfx, audio, spec, assets]
status: planned
updated: 2026-10-16
---
# Feel and Look — asset specs

> **Status: planned** (F3–F6 of [[Feel and Look (Slice)]]). These are the production specs
> for the slice's animations, models, environment, VFX and sound. They were written in a
> cloud session on 2026-10-16 from the vault notes only. **Studio wasn't checked.** Every number cites
> its note. A number the notes don't give is marked **(first guess)**. A value that has to
> be read off the built template is marked **[read in Studio]**. Design choices the vault
> hasn't made (hat shapes, shirt colours and so on) are marked **(proposal)**, and the
> developer has to confirm them. Nothing here overrides [[Art Direction]].
>
> **Slice scope** ([[Feel and Look (Slice)]]): one Wild West hostile train, Max Mayhem
> (Studio ID `DashDaring`) and the 5 built enemies: Bandana Bandit, Rodeo Kid,
> Six-Shooter, Dynamite Dan and Big Bart. Brick stays playable but isn't polished, so his
> weapons (Scattergun, Crowd Pleaser) are **nice-to-have** here.

**Labels:** **REQ** = required for the slice. **NTH** = nice-to-have. Animation frame counts
are at **30 fps**.

---

## 0. Five rules for every asset

1. **Skin it, don't replace it.** Every template the scripts read stays where it is, with
   the same name, PrimaryPart, pivot, tags, attributes and collision parts. New meshes go
   *onto* the template:
   - visual MeshParts welded or anchored onto the greybox,
   - the greybox colliders kept but made invisible (`Transparency = 1`).

   That keeps every height in [[TrainService]] and every hitbox in [[CharacterService]] and
   [[EnemyService]] exactly as verified.
2. **Visual meshes don't collide.** Set `CanCollide = false`, `CanQuery = false` and
   `CanTouch = false` on decorative MeshParts:
   - shots raycast against `workspace.Map` ([[CombatService]]),
   - enemy floor and wall probes raycast too ([[EnemyService]]),
   - gap-fall recovery looks for `WalkSurface` parts ([[CharacterService]]).

   A stray collider on a roof changes gameplay. The **Caboose roof overhang** that blocked
   jumps is the cautionary example ([[TrainService]] notes).
3. **Side-on first.** The camera looks along −Z from about 54 studs away, with FOV 40 and
   about 70 studs of view ([[CameraController]]). Motion along Z is invisible. Put every key
   pose, arc, flip and prop silhouette in the **X–Y plane**, and pass the black-silhouette
   test ([[Art Direction]] §1).
   - **Facing +X** (the main run direction), a character's **right side faces the camera**
     (Roblox RightVector = +Z).
   - **Facing −X**, the left side faces the camera.

   So the gun hand is visible when running right and hidden behind the body when running
   left. Check both facings for every asset.
4. **Drive animations by state, not by time.** Jump, fall and spin lengths depend on tuning
   that isn't settled (F3 has a jump tuning pass). Build
   rise/apex/fall and spin as **loops or holds** that the state machine enters and leaves,
   not as fixed-length clips.
5. **The budgets are hard limits** ([[Art Direction]] §11):
   - agent ≤ 6k triangles,
   - light enemy ≤ 2.5k, mid ≤ 4k, boss ≤ 10k,
   - carriage ≤ 8k,
   - background ≤ 20k per visible stretch,
   - about 40 animated characters, about 12 ragdolls and about 500 particles on screen.

---

## 1. Animation list

### 1.1 Conventions

| Topic | Spec |
|---|---|
| Frame rate | Author at **30 fps**. Lengths are given as frames (f) and seconds |
| Rig | Standard R15 proportions on an R15-compatible skeleton ([[Art Direction]] Core choices). Animations made on the Max rig retarget directly to the enemies, which are the same rig reskinned ([[EnemyService]]). **Big Bart is scaled 1.15:** check any **root-translation keys** on him, because rotations transfer and translations may not |
| Tools | The Studio Animation Editor, or Moon Animator, on a copy of the rig in `Workspace`. Or animate in Blender on the matching R15 armature and import through the 3D Importer's animation import |
| Ownership | **Publish every animation under the place's owner** (the user or the group that owns the experience). Animations owned by anyone else don't play in the live game |
| Priorities (Roblox `AnimationPriority`) | `Idle` < `Movement` < `Action` < `Action2` < `Action3` < `Action4` (with `Core` below all of them). Below, "Movement" = locomotion, "Action" = attacks and specials, "Action2+" = reactions that must win over attacks |
| Layering | A track only overrides the joints it keys. **Shoot overlays key the upper body only:** UpperTorso, Head and both arms, *not* LowerTorso or the legs. The run keeps going underneath, as in the original ([[Original Game - Player and Camera (Native Code)]] §3) |
| Markers | Add `KeyframeMarker`s that code and sound can hook into: `Footstep` (each foot contact in walk and run cycles), `Release` (Dan's throw), `Gulp` (Bart's swig), `Impact` (melee contact frame) |
| Agent movement slots | Max's rig includes the default `Animate` script ([[CharacterService]]). Put the new idle, walk, run, jump and fall IDs into its `StringValue`/`Animation` children. The **idle has two weighted variants**, used for the personality fidget (below). Everything else plays from a client controller (new code) |
| Enemy slots | Each enemy template has an `Animations` folder holding `Walk` and `Idle` (default R15 IDs) ([[EnemyService]]). **Add Animation instances with the names below** (`Attack`, `Flinch`, `WindUp`…), so the IDs stay hand-editable. EnemyService needs code to play them (part of F2/F5) |
| Weapon hold | The weapon is **welded to the HumanoidRootPart** at `Constants.WEAPON_HOLD_OFFSET`, not to the hand ([[CombatService]]). Shots start at the `Muzzle` projected onto Z = 0. **Arm animations don't move the gun.** Shooting and holding poses must bring the hands *to* the fixed gun position **[read in Studio: `WEAPON_HOLD_OFFSET`]**. See Q4 |
| Speeds | Max runs at **28.3 studs/s** ([[AgentService]]), about 5.6 body heights per second: a cartoon sprint. The `Animate` script scales the run track's playback with WalkSpeed, so **check foot slide in a playtest** and adjust the authored cycle length or the track speed |
| Must-feel, everywhere | Anticipation → action → overshoot → settle ([[Art Direction]] §5). Suggest squash and stretch in the poses (R15 parts don't deform): crouch low and tuck, then extend fully. Hold the key pose 2–3 frames longer than feels natural so it reads at 70 studs wide |

**Movement physics that set the timings** (from the built numbers):
- **Jump:** `JumpHeight` 8 at gravity 196.2 ([[CharacterService]], [[Studio Setup Checklist]] §4).
  - Take-off speed is about 56 studs/s, the apex comes about 0.29 s in (9 f), and a flat
    jump lasts about 0.57 s (17 f).
  - A running jump covers about 16 studs, which matches [[Loop (M2)]].
- **Spin:** a 4-stud `SPIN_LIFT` ([[InputController]]). The measured rise for a jump plus a
  spin is 10.8, so a spin is airborne for about 0.45–0.55 s (14–16 f).
- **Combat Polish:** the spin **lasts until landing**, capped at 1.5 s (`SPIN_MAX_TIME`,
  [[Combat Polish Code]]), so `Max_Spin` loops and never needs more than about 45 f.

### 1.2 Max Mayhem (template `ReplicatedStorage.Assets.Agents.DashDaring`)

Max's personality ([[Launch Agents]], [[Writing and Dialogue]] §3): square-jawed, smug, he
narrates his own heroics, and **his hair never moves, even in an explosion**. Every pose
should be a little too pleased with itself.

| # | Animation (asset name) | Slice | Trigger (game event / state) | Loop | Length | Priority | Key poses | Must-feel notes (side-on) |
|---|---|---|---|---|---|---|---|---|
| M1 | `Max_Idle` | **REQ** | Humanoid idle (Animate `idle`, variant 1, weight ~9) | Loop | 60–90 f (2–3 s) | Idle | Weight on the back foot, chest out, chin up. A small breathing bob. One hand near the gun | The chest-out S-curve must read in silhouette. Keep the arms off the torso outline |
| M2 | `Max_IdleHairCheck` | **REQ** | Animate `idle`, variant 2 (weight ~1), so it plays about every 6–10 s of idling | One-shot inside the idle loop | 45–60 f | Idle | Glances at the camera, smooths the hair swoop with his palm, a tiny satisfied nod | **The signature personality beat.** The hand travels in a big arc above the head so it reads side-on. The hair itself never moves |
| M3 | `Max_Run` | **REQ** | Animate `run` (Running state, speed > 0) | Loop | 8–10 f per cycle (2 steps) (first guess) | Movement | Contact → down (low crouch) → passing → up (airborne, both feet off). Lean forward about 15°, elbows pumping | A cartoon sprint, not a jog. Exaggerate the down/up bob. `Footstep` markers on both contacts. Arms stay *beside* the body so the gun's outline stays clean |
| M4 | `Max_Jump` | **REQ** | Animate `jump` (Jumping state) | One-shot → holds its last frame | 6–8 f | Movement | 2 f crouch (anticipation, if the input allows it) → launch stretch: arms up, legs trailing | The stretch pose sells the 8-stud height. Don't delay the physics take-off; the "crouch" lives in the first 2 frames of the clip |
| M5 | `Max_Fall` | **REQ** | Animate `fall` (Freefall) | Loop | 12–16 f | Movement | Knees up, arms out for balance, coat tails flaring up | Readable apex: a 1–2 frame "hang" pose at the top |
| M6 | `Max_Land` | **REQ** | `Humanoid.StateChanged` → `Landed` (new client code) | One-shot | 5–7 f | Action | Squash: deep knee bend, arms down → overshoot up → settle | **The overshoot on landing** that §5 asks for. Play over the run when moving, so it must not stop locomotion. Blend out in 0.1 s |
| M7 | `Max_Spin` (double-jump spin) | **REQ** | The second jump press while airborne (`InputController.jump()` → spin) | **Loops until landing** ([[Combat Polish]]) | One full rotation every 8–10 f | Action2 | A tucked **front flip, rotating about the camera axis (Z)**: knees to chest, gun tucked in | A rotation about Z reads as a spin side-on; a pirouette about Y reads as a wobble. 1 f of anticipation (arms whip down) before the first rotation. On landing, go into `Max_Land` |
| M8 | `Max_ShootRifle` | **REQ** | `SetInput fire = true` with the Service Rifle (client knows its own input; teammates via `ActiveWeapon` + a fire-state attribute or the effect records) | Loop while firing | Hold pose + a 4 f recoil cycle that repeats every shot (0.175 s ≈ 5 f) | Action (upper body only) | Rifle shouldered, head down to the sight, elbows tight. Recoil: shoulder back 1 f, recover 3 f | The recoil must fit inside the 0.175 s interval. Upper body only, so it layers over idle, run and fall (**standing, running and airborne are one overlay**) |
| M9 | `Max_ShootRocket` | **REQ** | Fire held with the Pocket Rocket | Loop while firing | Hold + an 8–10 f kick per shot (0.5 s = 15 f interval) | Action (upper body only) | The tube on the shoulder, his other hand bracing it. The kick: the torso is shoved back about 10°, then settles with an overshoot | A heavier kick than the rifle so the two weapons feel different. Optional 1 f knee dip when standing |
| M10 | `Max_ShootAir` | NTH | Firing while airborne | Loop | As M8/M9 | Action (upper body) | Legs tucked, a slight backward lean from the recoil | The original has a dedicated air-fire animation (anim 6). Only needed if M8/M9 over `Max_Fall` looks wrong |
| M11 | `Max_HitReact` | **REQ** | The Player attribute `Health` decreases (or `onPlayerDamaged`) | One-shot | 6–8 f (≤ 0.3 s, inside the 0.3 s i-frames from [[Combat Polish]]) | Action2 (upper body + head) | 1 f snap: the head and torso thrown back, arms flung up → recover. Swap to the **hurt face** | Must not stop movement or firing. Pair it with a white flash on the hit spot and a `NOT THE HAIR!` bark on big hits ([[Writing and Dialogue]] §3) |
| M12 | `Max_DownedEnter` | **REQ** | Player attribute `Downed` = true ([[SquadService]]) | One-shot | 18–24 f | Action3 | A spin-around stagger → knees → a comic flop | Comic, never painful. See Q5 about `PlatformStand`, which currently tips the body over physically |
| M13 | `Max_DownedLoop` | **REQ** | While `Downed` (and while `BledOut`) | Loop | 45–60 f | Action3 | Slumped, one arm weakly waving for help, little stars over his head (VFX), **downed face** | Must read as "revive me" from 35 studs away. The waving arm is the beacon |
| M14 | `Max_BeingRevived` | **REQ** | `ReviveProgress` > 0 while `Downed` | Loop | 20–30 f | Action3 | He reaches up toward the reviver; the pose rises a little as progress grows (or 2 poses blended) | Shows the 2 s hold is working ([[SquadService]] `REVIVE_HOLD`) |
| M15 | `Max_Revived` | **REQ** | `Downed` goes true → false | One-shot | 15–20 f | Action3 | A kip-up or spring to his feet, overshoot, a brush-off of the lapels | Also where the 3 s revive grace and its radial push begin ([[Combat Polish]]). Bark "I HAD IT, BUT THANKS." |
| M16 | `Max_Celebrate` | **REQ** | Train cleared ("TRAIN CLEARED!", [[RunStateService]]) and the `Win` bark | One-shot → idle | 45–60 f | Action | A finger-gun at the camera, a gun twirl, or a hair-flick and a smirk | Hold the final pose for 10+ frames. Bark "NAILED IT." |
| M17 | `Max_SwapIn` | **REQ** | The character arrives through `CharacterService.swapTo` (a new rig with `AgentId`) | One-shot | 15–20 f (≤ 0.67 s) | Action (cancel on movement input) | Lands in frame, straightens his bow tie, a cocky nod | It must not hold up control. Cancel it with a 0.1 s fade on any move or fire. A `SwapPuff` VFX. Bark "THE STAR HAS ARRIVED." |
| M18 | `Max_Leap` | **REQ** | `RunState = Leap` and the player jumps past the engine's `FrontX` (new client code) | One-shot take-off → held flying pose → normal landing | 6 f take-off + a held pose | Action | A superhero long-jump: the lead arm forward, legs split, coat tails streaming | The 10-stud leap gap ([[TrainService]] `LEAP_GAP`) should feel heroic. Land into `Max_Land` with a bigger squash |
| M19 | `Max_GapFlail` | NTH | Root Y below `GAP_FALL_Y` (5) before the recovery ([[CharacterService]]) | Loop | 10–12 f | Action | Arms windmilling, legs cycling | A cartoon "uh-oh" beat before the 1 s recovery |
| M20 | `Max_CratePickup` | NTH | Weapon switch from a crate ([[PickupService]]) | One-shot | 10 f | Action (upper body) | A quick weapon toss-and-catch | Bark "UPGRADE ACCEPTED." |
| M21 | `Max_Walk` | NTH | Animate `walk` (low speed, which is rare because input is digital) | Loop | 16 f | Movement | A swagger | Barely seen. Reuse the run if time is short |

**Faces** ([[Art Direction]] §4): swap face textures per state, with no facial rig.
- **REQ:** `Normal`, `Hurt`, `Downed`, `Celebrate`.
- **NTH:** `Smug` (for the idle hair check).

### 1.3 Enemies: the shared light-enemy set (all 4 lights, and Bart where it fits)

The enemies run on the server with server network ownership ([[EnemyService]]), so these
tracks play from EnemyService on the server and replicate. Add each as an `Animation` child
of the template's `Animations` folder.

| # | Animation (folder name) | Slice | Trigger | Loop | Length | Priority | Key poses | Must-feel notes |
|---|---|---|---|---|---|---|---|---|
| E1 | `Idle` (exists, default ID) | **REQ** | Standing (Shooter tell, Lobber holding distance) | Loop | 45–60 f | Idle | A shifty, hunched outlaw stance, the bandana up | Hunched versus Max's chest-out: villains read by posture |
| E2 | `Walk` (exists, default ID) | **REQ** | `Humanoid:Move` ≠ 0. Lights walk at 8.7–10.7 studs/s ([[Wild West Enemies]]) | Loop | 14–16 f per cycle (first guess) | Movement | A scurrying, sneaky jog, knees high, arms pumping low | `Footstep` markers. Per-slot speed differs, so scale the track speed by `Speed` / authored speed |
| E3 | `Attack` (melee punch) | **REQ** | A Walker melee hit, every `AttackInterval`, within `ENEMY_MELEE_REACH` 1.5 ([[EnemyService]]) | One-shot | 8–10 f; `Impact` on f 3 | Action | A 2 f wind-back of the fist → a big haymaker → hold → recover | **The built melee lands instantly** (as in the original). Art Direction §5 wants anticipation before *every* attack, so see Q6 about a 0.2 s melee wind-up. Without one, keep the anticipation to 2 frames |
| E4 | `Flinch` | **REQ** | A gun hit, not during a wind-up or attack, outside the `FlinchCooldown` ([[Combat Polish]]: lights 0.75 s, Bart 1.5 s) | One-shot | **5–7 f (0.15–0.25 s)** | Action2 | 1 f snap: the head back, the hat bouncing up (still attached), arms out → recover | Exactly the "hit reaction" the GDD lists. It must recover fast so crowds keep flowing. Explosions use the pop-up knockback, not this |
| E5 | `KnockoutPose` | NTH | `Health` ≤ 0, just before the ragdoll | One-shot, 3 f, then ragdoll | 3 f (0.1 s) | Action4 | A starfish launch: limbs flung wide, the head back | **Today the ragdoll starts on the knockout frame**, so the last pose is whatever was playing ([[EnemyService]]). A 0.1 s pose before the ragdoll (Q7) makes the "exaggerated impulse" read. Otherwise the feel comes from `RAGDOLL_IMPULSE`, the hat pop and the stars |
| E6 | `Celebrate` | **REQ** | A player near this enemy goes `Downed` (original state 6 `CELEBRATE_A`) | One-shot | 30–40 f | Action | Hat waved overhead, a little jig, "YEEHAW!" | One celebration per downed event per enemy (first guess), then back to the AI. It mustn't freeze the enemy for long in co-op |
| E7 | `Spot` | NTH | First target acquisition (the perception rules in [[Combat Polish]]) | One-shot | 8–10 f | Action | A double-take, then pointing at the player | Pairs with the "GET 'EM!" bark ([[Writing and Dialogue]] §4) |
| E8 | `Flee` | NTH (M3) | Boss intro / revive flee (deferred) | Loop | 8 f | Movement | Arms flailing overhead | Not needed for the slice |

### 1.4 Enemy specials

| # | Enemy / animation | Slice | Trigger | Loop | Length | Priority | Key poses | Must-feel notes |
|---|---|---|---|---|---|---|---|---|
| R1 | **Rodeo Kid** `Spin` (the leap) | **REQ** | Leaper: within `LeapTrigger` 8 it jumps and keeps going for `LeapTime` 1.1 s, landing behind the player ([[EnemyService]]) | **Loop while airborne** | One rotation every 10–12 f (about 2–3 flips per leap) | Action | 2–3 f crouch with a hat grab (anticipation) → a **tucked forward flip about the Z axis** → a splayed landing, then a "ta-da" | The design says "cartwheels" ([[Wild West Enemies]]). **A true cartwheel rotates about the facing axis and reads edge-on from the side.** Animate it as a front flip or roundoff in the screen plane (Q11). The special *mechanic* changes are deferred ([[Combat Polish]] "Not adopted"), but this animation covers the built leap |
| R2 | Rodeo Kid `Land` | NTH | Landing after the spin | One-shot | 6 f | Action | Arms up, "ta-da" | The 1/7 flinch-escape from the original isn't built; no animation needed |
| S1 | **Six-Shooter** `Aim` (the tell) | **REQ** | Shooter in range: stops, "!" `Alert`, faces the player for `TellTime` **0.5 s**; Combat Polish moves the shot to **0.5–0.6 s into the wind-up** | One-shot (holds) | **15–18 f** | Action | 3 f: hand to holster → a quick draw up to arm's length → **hold the aim**, the other hand ready to fan the hammer | **This is the telegraph.** Hold the aim pose clearly (≥ 6 f). The barrel should sit at about root + 1 stud (`ENEMY_SHOT_HEIGHT`, chest height) so the bullet visibly leaves it. Bark "DRAW!" |
| S2 | Six-Shooter `Fire` | **REQ** | The bullet fires | One-shot | 6–8 f | Action | The gun kicks up 30°, smoke puffs → a twirl back into the holster (NTH) | Recoil overshoot. The orange-red muzzle flash comes from the revolver's `Muzzle` (§4) |
| D1 | **Dynamite Dan** `Throw` | **REQ** | Lobber throws (every `ThrowIntervalMin`–`Max` 2.5–4 s); the dynamite reaches the target in 0.9 s ([[EnemyService]]) | One-shot | **24–27 f**; `Release` at f 16–18 (0.53–0.6 s, matching the ranged telegraph rule) | Action | Strikes a match on his boot (f 0–6) → lights the fuse, sparkle (6–10) → **wind-back, the arm far behind the head** (10–16) → release → follow-through, a hop | A big overhand arc fully in the X–Y plane. At `Release`, hide the held dynamite prop and the `Dynamite` effect takes over. Bark "FIRE IN THE HOLE!" |
| D2 | Dan `Backpedal` | NTH | Holding `KeepDistance` 15 ± 3 and backing away ([[EnemyService]]) | Loop | 14 f | Movement | Walking backwards, glancing back, a nervous hunch | Dan's coward personality. Only if he faces the player while backing off **[read in Studio: does he turn or backpedal?]** |
| B1 | **Big Bart** `Walk` | **REQ** | Walking (10.7 studs/s at 1.15 scale) | Loop | 16–18 f | Movement | A heavy stomp, belly first, the jug swinging | Weight: a long down pose, a short up. `Footstep` markers for heavy thuds |
| B2 | Bart `Attack` (mid melee) | **REQ** | Melee in reach | One-shot | 12 f; `Impact` f 5 | Action | A big belly-bump or a jug swing | Slower and heavier than the lights |
| B3 | Bart `WindUp` (jug swig) | **REQ** | Charger ready, within `ChargeTrigger` 20: "!" and stands still for **`WindUp` 1 s** ([[EnemyService]]) | One-shot | **30 f exactly** (it must match `WindUp`); `Gulp` markers at f 8 and 16 | Action | Jug up and tipped back (f 0–6) → two big gulps, the belly swelling (6–20) → wipe the mouth, toss the jug over his shoulder or hook it back → head down, hoof-scrape the ground (20–30) | **This is the stagger window**: 30 damage in this second cancels the charge ([[Wild West Enemies]]). The pose must say "hit me now": a wide-open stance, the head tilted back. Bark "*glug glug*… HERE I COME!" |
| B4 | Bart `Charge` | **REQ** | Charging at `ChargeSpeed` for `ChargeDistance` 30 (**26.7 studs/s after the F2 fix**, about 1.1 s) | Loop | 8–10 f cycle | Movement + Action (upper body) | Head down like a bull, fists back, legs pounding | `ChargeDust` VFX on each `Footstep`. It reads as unstoppable. Retime it if `ChargeSpeed` changes |
| B5 | Bart `ChargeStop` | NTH | The charge ends (at its distance, a gap or a wall) | One-shot | 8–10 f | Action | A heel-skid, windmilling arms, a teeter at the edge | The "stops at a gap" behaviour becomes a gag |
| B6 | Bart `Stagger` | **REQ** | ≥ `StaggerDamage` during the wind-up → staggers for **`StaggerTime` 1.5 s** | Loop (or one-shot of 45 f) | 45 f | Action2 | Wobbly legs, eyes spinning, a hiccup bounce, `StaggerStars` VFX | **The co-op payoff moment** ("focus fire!"). A big read. Bark "WHOA, WHOA, WHOA!" |
| B7 | Bart `Celebrate` | NTH | A player near him goes down | One-shot | 40 f | Action | A big belly laugh, a swig | Reuse E6 timing |

---

## 2. Model specs

### 2.1 The pipeline (shared by every model)

**Blender → FBX → Studio** (Roblox's 3D Importer):

1. **Units.** Model at **1 Blender unit = 1 stud**. Check the 3D Importer's file-unit or scale
   option on the first import with a 1 × 1 × 1 test cube, and record the setting in
   [[Techniques]].
2. **Axes.** Roblox is Y-up, and carriages run along +X. Export the FBX with *Apply
   Transform* (or *FBX All* scalings) and a forward and up axis the importer maps to −Z
   and +Y. Verify it with the test cube.
3. **Origins.** Set the Blender origin to the pivot named in each block, for example a
   carriage's `RearCoupling` point, so the imported pivot lines up.
4. **Import.** Use Studio's Import 3D. Import as a Model of MeshParts, check the preview,
   and keep it anchored.
5. **After import:**
   - `CollisionFidelity = Box` (or `Hull`) on anything that collides. Decorative meshes get
     `CanCollide/CanQuery/CanTouch = false` (rule 2).
   - `RenderFidelity = Automatic`, except background strips: `Performance`.
   - `CastShadow = false` on small trim and on everything in the background.
   - Material: `SmoothPlastic` plus the theme `MaterialVariant`s, wood, metal and fabric
     ([[Art Direction]] §7). `SurfaceAppearance` (hand-painted gradients) only on Max
     (and future bosses).
6. **Textures.** 256–512 px for most things, 1024 px for agents and bosses (§7). Use **one
   Wild West train atlas** (1024 px, first guess) shared by the whole kit.
7. **Restyle and scan.** Run a `search_game_tree` scan for `Script`/`LocalScript`/
   `ModuleScript` inside any Creator Store asset ([[Art Direction]] §12, `CLAUDE.md`). Then
   restyle it to the palette and the toon finish.
8. **Naming.** `PascalCase` everywhere. No default `Part`, `MeshPart` or `Union` names.
   Visual meshes go under a `Visual` Model inside each template (first guess) so they're
   easy to toggle against the greybox.

**Characters: rig rules** (Max and every enemy):
- **Keep the R15 hierarchy.** That means the 15 body parts with their exact names
  (`Head`, `UpperTorso`, `LowerTorso`, `LeftUpperArm`…`RightFoot`), the
  `HumanoidRootPart` and every rig attachment (`RootRigAttachment`,
  `NeckRigAttachment`…).
- **Keep the joint type the built rig uses.** The enemies use **`AnimationConstraint`
  joints (the new avatar joints)**, with **`BallSocketConstraint`s disabled** until
  knockout ([[EnemyService]]). The ragdoll code toggles exactly those.
  - **An imported FBX rig usually comes in with `Motor6D`s,** and the ragdoll would then
    break.
  - The safest path: **model each body-part mesh to the standard R15 part sizes and
    attachment positions, and put it onto the existing body parts** (by setting each body
    MeshPart's mesh in Studio, or with the Avatar Setup tool), leaving the joints alone.
  - If you import a new rig instead, have a local Claude session transplant the Humanoid,
    joints, `Hitbox`, attributes, tag, `Animations` folder and scripts, and then re-run the
    knockout test.
- **Segmented (rigid) meshes, not skinned.** §5 assumes R15 parts don't deform, and
  segmented parts are cheapest for crowds.
- **Hats and props:** each is an `Accessory` (with a `Handle` and a matching attachment) or
  a part welded to the right body part. They're `Massless`, with `CanCollide`, `CanQuery`
  and `CanTouch` false.

### 2.2 The train kit (`ServerStorage.Assets.Carriages.WildWest`)

**What every carriage keeps** ([[TrainService]], [[CharacterService]], [[PickupService]]):

| Must keep | Value |
|---|---|
| The template Model and its name | `Caboose`, `Boxcar`, `Flatbed`, `CattleCar`, `WaterTanker`, `Engine` |
| `PrimaryPart` | `RearCoupling` at **local X 0, Y 3** (the rear end). The geometry runs along **+X from 0 to `Length`** |
| Attributes | `Length`, `CarriageType`, `Theme` (`"WildWest"`) |
| Tag | `Carriage` |
| `Roof` | Tagged **`WalkSurface`**, at the exact heights below. Keep it as the invisible collider |
| Engine | The cab `Roof` is also tagged **`TrainGoal`**. **`BoilerWalk`** is a second `WalkSurface` |
| Attachments on the roof | `EnemySpawn` (2–3 per car); `WeaponCrateSpot` on the Boxcar and CattleCar |
| Heights (greybox) | Rail top Y 1, **deck top Y 4**. The highest deck-to-roof step is about **7.6 studs, under the 8-stud jump** |
| Collision | Colliders stay in the `Default` group, so shots stop at train walls (the `Projectiles` group collides with `Default` and `Hitboxes`). Anchored |
| The play plane | Characters walk at **Z = 0** (`PLANE_Z`). The camera is on the **+Z side**, so detail goes on the +Z face. Pods on the checkpoint sit at Z −3 ([[TrainService]]). **Body width in Z: [read in Studio]** (first guess 8 studs, centred on Z 0) |

**Lengths and pivots** (verified layout: pivots at X 0, 20, 56, 76, 112, 148 and 168, with
`CARRIAGE_GAP` 3 and a 201-stud train) ([[TrainService]], [[First Playable (M1)]]):

| Car | `Length` | Roof / deck top (Y) | Layout slot |
|---|---|---|---|
| Caboose | **17** | 10.6 (cupola 13.6) | 1 |
| Boxcar | **33** | 11 | 2 and 5 |
| Flatbed (the "flatcar") | **17** | 4.4 (deck) | 3 |
| CattleCar | **33** | 11 | 4 |
| WaterTanker | **17** | 11.9 | 6 |
| Engine | **33** | cab roof 12.1, boiler walk 11.15 | 7 (front, +X) |
| `HubCheckpoint` (`ServerStorage.Assets.Trains`) | **60** | deck 4.4 | Checkpoint train |

**Shared palette** ([[Art Direction]] §2): freight red `#B04A33`, wood `#7C5A3A`, iron and
trim `#3B3B42`. The cars sit "a little brighter than the world". **No brass or gold as a
main colour on hostile cars:** navy, gold and brass are the Agency's "our side" look (§6).
Extra trim swatches are (first guess) a light wood `#A57A50`, lettering cream `#EBD9B4` and
grime `#4A3A2E`.

**Roof rules** (everything that can stand on or touch a roof):
- The visual roof top sits **exactly flush** with the collider top. Feet float or sink if
  it's off by 0.1.
- **Nothing collides above the roof line inside |Z| < 1.5** (first guess) except deliberate
  obstacles. Enemies jump at a wall found by the knee-height probe 3 studs ahead
  (`ENEMY_WALL_PROBE`), and player shots stop at map geometry.
- Brake wheels, lamps, vents and roof-walk planks are visual only. Put tall ones off the
  plane (|Z| > 1.5) or below roof height.
- **No overhang** past the car body at the ends: the Caboose lesson ([[TrainService]] notes).

#### Shared sub-meshes (build them once and reuse them across every car)
| Asset | Spec |
|---|---|
| `Truck` (bogie) | 2 axles, side frames and springs. About 4.5 long × 2.6 high (first guess), sitting on the rail top at Y 1. **≤ 800 tris** (first guess). One mesh asset with 2 instances per car (the engine uses its own drivers) |
| `Wheel` | Radius about 1.2 (first guess), a spoked toon wheel. A separate MeshPart so a client controller can spin it. Tag **`TrainWheel`** and Attribute `Radius` (first guess, NTH: wheel and rod animation isn't built, [[ParallaxController]] notes). At 50 studs/s, a 1.2-radius wheel turns about 6.6 rev/s, which strobes at 60 fps, so **paint a motion-blur spoke texture or spin it slower than true** |
| `Coupler` (the gap piece) | A link-and-pin coupler on a buffer beam at Y about 3 (the `RearCoupling` height). Each car's coupler sticks out **≤ 1.4 studs** past its end, so two meet across the 3-stud `CARRIAGE_GAP`. **`CanCollide`, `CanQuery` and `CanTouch` = false**, because a colliding coupler at Y 3 would let a player stand in the gap with the root above `GAP_FALL_Y` 5 and skip the gap-fall rule, and would fool the enemy floor probe. ≤ 150 tris |
| `EndLadder` | A ladder at the car end (visual, Z +3.5, off the plane). It reads as "climb up here" even though you jump |
| `RoofWalk` | Running-board planks along the roof centre, `#A57A50`. Visual only, flush with the collider |

#### `Caboose` (17) **REQ**
- **Parts:** cabin (deck 4 → roof 10.6); **cupola** (top 13.6) with windows; a rear and a
  front porch with railings (enemies jump from the porches onto the roof, so **keep the
  porch rails non-colliding or below the jump arc**); a stove pipe; marker lamps; 2 trucks
  and 2 couplers.
- **Palette:** freight red `#B04A33` body, iron `#3B3B42` roof and trim, cream lettering,
  warm yellow window glow `#FFD9A0` (first guess, Neon is fine at a small size).
- **Budget:** ≤ 8k tris (aim for 5k).
- **The scripts depend on:** `Roof` 11 studs long, flush with the cabin (trimmed in
  Session 4); the cupola's collider if it has one **[read in Studio]**; `EnemySpawn` ×2–3.
- It's the first car players see, standing behind the `Map.Run.Staging` platform. Make it
  charming.

#### `Boxcar` (33) **REQ: the highest priority car** (2 of the 7 slots)
- **Parts:** the box body (deck 4 → roof 11) with vertical board seams; a **sliding door**
  on the +Z face; corner ladders; a roof walk; a brake wheel at one end (**visual and off
  the plane**); stencilled lettering (proposal: a cartoon railroad name, for example
  "ACME & WESTERN", checked so it isn't a real company); 2 trucks and 2 couplers.
- **Palette:** red `#B04A33` boards with wood `#7C5A3A` framing, iron `#3B3B42` roof edge,
  lettering `#EBD9B4`.
- **Budget:** ≤ 8k (aim for 4–5k). Use a train-atlas texture with soft board lines.
- **The scripts depend on:** `Roof` at 11 tagged `WalkSurface`; `EnemySpawn` ×2–3;
  **`WeaponCrateSpot`** (the crate stands on the roof, so leave space around it).

#### `Flatbed` (17), the flatcar **REQ**
- **Parts:** the deck (top 4.4) with plank texture; stake pockets with short stakes; an
  optional low cargo (proposal: lashed hay bales or crates) **only off the plane at Z < −2,
  below 1.5 studs high**; 2 trucks and 2 couplers.
- **Palette:** wood `#7C5A3A` deck, iron `#3B3B42` sill.
- **Budget:** ≤ 4k (first guess).
- **The scripts depend on:** the deck `Roof` at 4.4 tagged `WalkSurface`; `EnemySpawn`.
  It's the low car: players drop to it from Y 11 and climb back up the 7.6-stud step, so
  no cargo should block the climb line.
- Note: the boss arena (M3) wants about 67 studs ([[Wild West Enemies]]); this 17-stud
  flatbed isn't it. That's out of the slice's scope.

#### `CattleCar` (33) **REQ**
- **Parts:** a **slatted** body (deck 4 → roof 11), with gaps between slats that let the
  sky and background show through (it adds depth); a roof walk; a door; 2 trucks and 2
  couplers. Proposal (NTH): **cartoon cow heads** poking out of the slats with a blink
  animation. They're background-band decoration, so keep them desaturated (`#C9B8A0`)
  so they never read as actors.
- **Palette:** wood `#7C5A3A` slats over red `#B04A33` frame posts.
- **Budget:** ≤ 8k (the slats cost triangles: use a texture with alpha cut-outs **or**
  real slats, but not both).
- **The scripts depend on:** `Roof` at 11; `EnemySpawn`; **`WeaponCrateSpot`**.
- If you go for slat see-through, keep the collider walls solid: shots stop at walls, and
  "shooting through the gaps" isn't designed.

#### `WaterTanker` (17) **REQ**
- **Parts:** a horizontal tank on a frame, iron bands, a filler hatch, a **flat catwalk on
  the tank top** (the visual walkway over the flat collider `Roof` at 11.9), end ladders,
  2 trucks and 2 couplers.
- **Palette:** iron `#3B3B42` tank with red `#B04A33` bands (or the reverse), wood
  catwalk.
- **Budget:** ≤ 6k (first guess).
- **The scripts depend on:** `Roof` at 11.9 tagged `WalkSurface`; `EnemySpawn`.
- See Q2: this slot sits right behind the engine, where a real train has its **coal
  tender**.

#### `Tender` (coal tender) **NTH / decide first** (Q2)
- [[Feel and Look (Slice)]] F4 lists a coal tender, but **no `Tender` template exists** and
  `LAYOUT` has none ([[TrainService]]).
- **Option A (recommended, no code):** restyle the `WaterTanker` slot as a combined tender
  (a coal bunker at the front, the water tank behind), keeping `CarriageType`
  `"WaterTanker"`, `Length` 17 and `Roof` 11.9.
- **Option B:** a new 17-stud `Tender` template plus a `LAYOUT` change. That changes the
  201-stud train length and the pivot list, so it needs a local session to re-verify.
- **Parts (either way):** a coal heap (chunky toon lumps, `#2B2B30` with `#4A4A55`
  highlights), the bunker walls, a water hatch and 2 trucks. The walkable `Roof` stays flat
  over the coal. Budget ≤ 6k.

#### `Engine` (33) **REQ: the hero piece and the goal**
- **Orientation:** `RearCoupling` at X 0 is the cab end; the **cowcatcher points at +X**
  into the 10-stud leap gap (`LEAP_GAP`), so nothing may extend past `Length` 33.
- **Parts** (an 1870s "American" type 4-4-0, cartoon proportions):
  - the **cab** at the rear (its roof at 12.1 is the **`TrainGoal`**: give it a readable
    "goal" identity such as a bright flag or bell, proposal),
  - the boiler with bands, the **`BoilerWalk`** running board (11.15),
  - a steam dome, a sand dome and a bell,
  - a **balloon (diamond) smokestack** (its top is the smoke VFX source, `SmokeStack`
    attachment),
  - a big headlamp,
  - the **cowcatcher (pilot)**,
  - 2 big driving wheels a side + a 2-axle leading truck,
  - side rods and pistons (separate MeshParts if the rods will animate, NTH),
  - a whistle (a `Whistle` attachment for sound).
- **Palette:** iron `#3B3B42` boiler and smokebox, red `#B04A33` cab, cowcatcher and wheel
  centres, wood `#7C5A3A` cab trim. A dull, small bell, not the Agency's polished brass.
  The headlamp is warm white `#FFF2B3` (first guess).
- **Budget:** ≤ 8k. The drivers and rods are the expensive part. If it doesn't fit, ask
  the developer for a carriage exception (≤ 10k, first guess) rather than cutting the
  silhouette.
- **The scripts depend on:** the cab `Roof` (`WalkSurface` + `TrainGoal`) at 12.1;
  `BoilerWalk` (`WalkSurface`) at 11.15; `EnemySpawn`. The step between the boiler walk and
  the cab is about 1 stud, so keep it climbable.

#### `HubCheckpoint` (60) **NTH for the slice** (the checkpoint shows after 3 trains)
- **Keep:** the `Roof` deck at 4.4 tagged `WalkSurface`, with the gold trim; the
  **pods at Z −3** (`MedbayPod`, `BarracksPod`, `ArmoryPod`, `SurplusPod` and
  `MissionsPod`), each with its SurfaceGui `Sign` facing the camera and `Closed = true` on
  the closed ones; Attributes `Length` 60, `CarriageType` "HubCheckpoint", `Theme`
  "Agency"; tag `Carriage`. **No `EnemySpawn`, no `TrainGoal`** ([[TrainService]]).
  `BarracksPod`'s X span drives the squad prompt ([[AgentService]]).
- **Look:** the Falcon-8 style, navy `#1F2A44` and gold `#F2C14E` with polished brass
  (§6), so it is clearly "our side".
- **Budget:** ≤ 8k for the car + ≤ 1.5k per pod (first guess).

### 2.3 Characters

#### Max Mayhem: template `ReplicatedStorage.Assets.Agents.DashDaring` **REQ**
| Item | Spec |
|---|---|
| Size | Standard R15 at scale 1, about **5 studs** tall ([[Art Direction]] §6). Don't scale the Humanoid. (If a scaled version is ever needed, set `AutomaticScalingEnabled = false`: the Brick and Bart lesson, [[AgentService]] and [[EnemyService]]) |
| **Hitbox (keep)** | The invisible **`Hitbox` part 1.3 × 5.5 × 2**, welded to the root, in collision group **`Hitboxes`** ([[CharacterService]]). Every other part goes into `Players` at spawn, so new parts can stay in `Default` |
| Look ([[Launch Agents]], §3) | A **navy tux `#1F2A44`** with **tails**, a white shirt front, a **gold bow tie `#F2C14E`**, a **perfect hair swoop** and a square jaw. The silhouette hooks are the tux tails and the hair swoop |
| Palette | Navy `#1F2A44`, gold `#F2C14E`, shirt white `#F4F1EA` (first guess), hair dark brown `#3A2A1E` (first guess), shoes `#1A1A1F` (first guess), skin tone **(developer's choice)** |
| Parts to model | The 15 R15 body meshes (the tux jacket is built into the UpperTorso and arm meshes); `HairSwoop` (an accessory on the Head, **rigid: it never moves**); `TuxTails` (on the LowerTorso, a rigid mesh angled back so it flares in silhouette; NTH: a 2-bone tail swing); `BowTie`; a `Face` (see below). Optional: cufflinks, a lapel pin |
| Hair from both sides | The swoop must read from **both facings** (rule 3). Make it symmetrical enough or a big forward pompadour |
| Faces | 4 textures, 256–512 px: Normal, Hurt, Downed, Celebrate ([[Art Direction]] §4). Either a `Decal` on the `Head` or a thin `Face` MeshPart welded to the Head, whose `TextureID` gets swapped. **Recommended: the `Face` mesh**, because decals project unpredictably on a curved toon head (Q12) |
| Costume damage | 3 stages (§4): full / torn (hat or sleeve gone, smudges) / comedy long johns. **NTH** for the slice ("if in reach", F3). The stages swap pieces and don't add triangles. See Q10 about the long-johns red |
| Budget | **≤ 6k tris, 1 × 1024 texture**, `SurfaceAppearance` with a hand-painted gradient (§7, §11) |
| **Keep (the scripts read these)** | Name `DashDaring` until the rename session; tag **`Agent`**; Attributes `Speed` 28.3, `Toughness` 0.52, `SpinLevel` 4, `SpinDamage` 6, `SpinRadius` 5, `PrimaryWeapon` "ServiceRifle", `SecondaryWeapon` "PocketRocket", `DisplayName`, `Role` ([[AgentService]], [[CharacterService]]); the **`Animate` script**; the Humanoid (code sets `UseJumpPower`, `JumpHeight`, `WalkSpeed` and `AutoRotate = false`); the R15 joints and attachments. **Runtime-added, don't build these:** `PlaneLockAttachment`, `PlaneLock`, `Character.Weapon` |
| Pivot / facing | The template faces **+X** at spawn (agents spawn facing +X on `StagingSpawn`) |
| Import | Model each body mesh around the standard R15 part bounds; apply them to the existing body MeshParts (§2.1). Then: Play → spawn → the hitbox is still 1.3 × 5.5, the swap works, the plane lock holds, and the parts are in `Players` |

#### The light-enemy base body (shared by all 4 lights) **REQ**
| Item | Spec |
|---|---|
| Size | The R15 rig at scale 1 (Dash's rig, reskinned) ([[EnemyService]]) |
| **Hitbox (keep)** | `Hitbox` part in group **`Hitboxes`**. **Spawning resizes it from the attributes `HitboxWidth` × `HitboxHeight`**: lights **1.3 × 5** ([[Wild West Enemies]]) |
| **Keep** | Tag **`Enemy`**; body parts in group **`Enemies`**; **`AnimationConstraint` joints, with the `BallSocketConstraint`s present but disabled**; Humanoid `BreakJointsOnDeath` off, `RequiresNeck` off, name and health bar hidden; the **`Animations`** folder; every tunable attribute (`Slot`, `Archetype`, `MaxHealth`, `Speed`, `SpawnCost`, `Damage`, `AttackInterval`, `HitboxWidth`, `HitboxHeight`, `FreezeScalar`, `Points`, `CoinChance`, `CoinMin`, `CoinMax`, plus the archetype ones) |
| Shared pieces | A base body with a **red bandana `#D7322F`** (on every bandit, so "enemy" reads instantly), snakeskin tan `#C9A15A` trim (a belt, a vest edge), a dark stubbly face texture, boots |
| Budget | **≤ 2.5k tris each, 1 × 512 texture** (§11). Body ~1.6k + hat ~300 + prop ~400 (first guess). Crowds of 15–30 |
| Slot identity | §4 / [[Wild West Enemies]] "Art & audio needs": **hat shape** and **shirt colour** tell the slots apart. **The built slot shirt colours aren't in the notes: [read in Studio]**. Below are proposals only. They avoid the player colours (blue, green, yellow, pink), the danger orange and the agents' signature colours |
| Saddlebag | `ServerStorage.Assets.Enemies.Props.Saddlebag` (the blueprint thief's bag): pivot at the LowerTorso, welded on at spawn. Restyle it with blueprint-blue `#2F6FD6` scrolls sticking out ([[Art Direction]] §1). ≤ 300 tris |

| Enemy | Template | Silhouette hook **(proposal)** | Shirt / trim **(proposal)** | Prop |
|---|---|---|---|---|
| **Bandana Bandit** (slot 0, Walker) | `BandanaBandit` | A classic dented cowboy hat, bandana over the nose, a scrawny build | Faded brown `#8B5E3C`, tan vest | Bare fists (oversized gloves, NTH) |
| **Rodeo Kid** (slot 1, Leaper) | `RodeoKid` | A tall ten-gallon hat with a **chin strap** (it stays on through the flips, then pops on KO), chaps with fringe, spurs | Checked maroon `#8E2C48` | A rope coil on the hip (visual) |
| **Six-Shooter** (slot 2, Shooter) | `SixShooter` | A flat-brim black gambler hat, a **long duster coat** (a strong side silhouette), a gun belt | Charcoal `#2E2E34` with tan | **Revolver** (§2.4) |
| **Dynamite Dan** (slot 3, Lobber) | `DynamiteDan` | A **miner's helmet with a lamp**, or a bowler (proposal), a **bandolier of dynamite sticks** across his chest, singed eyebrows | Dusty olive `#6E6A3A` | **Dynamite** in his hand (§2.4) |

#### Big Bart (slot 5, mid, Charger): template `BigBart` **REQ**
| Item | Spec |
|---|---|
| Size | The R15 rig **scaled 1.15** (about 5.75 studs tall) ([[EnemyService]]). **Humanoid `AutomaticScalingEnabled = false`** (the fix from 2026-10-14) |
| **Hitbox (keep)** | **2.4 × 6.5** as spawned (built, [[EnemyService]]); the design note says about 2.4 × 5.7 ([[Wild West Enemies]]). Driven by `HitboxWidth`/`HitboxHeight` |
| **Keep** | Everything in the light base, plus the Charger attributes `ChargeSpeed` (36 now, **→ 26.7** in F2), `StaggerDamage` 30, `WindUp` 1, `ChargeDistance` 30, `ChargeInterval` 5, `ChargeTrigger` 20, `StaggerTime` 1.5, `Knockback` 45 |
| Look ([[Wild West Enemies]]) | A huge barrel belly, small head (proposal: a **tiny bowler hat on a big head** is the comic read), overalls, the red bandana, a scruffy beard. He **swigs from a jug** |
| Palette | Bandana `#D7322F`, overalls in an olive-brown `#5E5A3A` (proposal: avoid denim blue, which could read as P1 blue or as Max's navy), shirt tan `#C9A15A` |
| Parts | The R15 body meshes with a belly built into the UpperTorso and LowerTorso; a hat; the **jug** (§2.4) |
| Budget | **≤ 4k tris (mid), 1 × 512** (§11). "Mids get more detail and bigger props" (§4) |

### 2.4 Props

| Prop | Slice | Where it lives / what's kept | Size (studs) | Parts | Palette | Budget | Notes |
|---|---|---|---|---|---|---|---|
| **Pop-off hats** (one per enemy slot) | **REQ** | An `Accessory` named **`Hat`** (proposal) on each enemy template, with a `Handle` | Fits the head; brim about 1.6–2.0 across (first guess) | A crown and a brim | Per the slot table | ≤ 300 each (within the 2.5k) | **The hat pop isn't built** ([[EffectsController]] "Not yet done"). Recommended: on a `K` record, the client hides the real hat (`LocalTransparencyModifier`) and flings a **client-side clone** that spins up and away, then fades with the ragdoll (Q8). A consistent name lets the code find it |
| **Service Rifle** | **REQ** | `ReplicatedStorage.Assets.Weapons.ServiceRifle`: a Model, **`PrimaryPart` = `Handle` (the grip = the pivot)**, parts **pre-welded to the Handle**, the **barrel along −Z**, a **`Muzzle` Attachment at the tip** ([[CombatService]]) | About 3.2 long (first guess), oversized-toon | Stock, body, a chunky scope, barrel, magazine | Agency gunmetal `#3A3F4A` with gold `#F2C14E` accents (first guess, matches Max) | ≤ 800 tris (first guess); shares Max's texture or a 256 one | **Keep the attributes:** `Damage` 12, `FireInterval` 0.175, `Range` 45, `AutoAimAngle` 6. **Add** `MuzzleFlash` = "MuzzleFlashRifle" ([[Combat Polish]]). Visual parts are `Massless`, with `CanCollide/CanQuery/CanTouch` false |
| **Pocket Rocket** | **REQ** | `…Weapons.PocketRocket`, same rules (`Handle`, −Z, `Muzzle`) | About 3.0 long, 0.8 across (first guess). The gag: "pocket"-sized but chunky | A tube, sight, grip, a fin-shaped tail | Gunmetal with a red-orange rocket nose visible in the tube (the player tint is `#FFF2B3`, so keep the nose warm white, not danger orange) | ≤ 700 | Keep `Damage` 13, `FireInterval` 0.5, `Range` 60, `ProjectileSpeed` 70, `SplashRadius` 4, `SplashDamage` 13. `MuzzleFlash` = "MuzzleFlashRocket". The **in-flight rocket** is the `Rocket` effect (§4) |
| **Scattergun** (Brick) | NTH | `…Weapons.Scattergun`, same rules | About 3.0 long (first guess) | A double barrel, pump | Purple `#6B3FA0` and gold (Brick, §3) | ≤ 800 | Keep `Pellets` 5, `Spread` 10, `Damage` 12, `CloseDamage` 16, `CloseRange` 6, `Range` 14, `FireInterval` 0.45. `MuzzleFlash` = "MuzzleFlashScattergun" (a cone) |
| **Crowd Pleaser** (Brick) | NTH | `…Weapons.CrowdPleaser`, same rules | About 3.5 long, barrel cluster about 1.0 across (first guess) | A 6-barrel cluster as a **separate `Barrels` part** (it spins client-side during `SpinUp`, NTH), the body, a handle | Purple and gold | ≤ 1.2k | Keep `Damage` 6, `FireInterval` 0.07, `Range` 40, `AutoAimAngle` 4, `SpinUp` 0.6. There's no decided flash template: reuse `MuzzleFlashRifle` (first guess) |
| **Revolver** (Six-Shooter) | **REQ** | A prop on the `SixShooter` template, welded to `RightHand` (it's held in the `Aim` pose; enemies don't use weapon templates) | About 1.2 long (first guess) | Barrel, cylinder, grip | Dark iron `#3B3B42`, a pearl grip `#EBD9B4` | ≤ 300 | **Add a `Muzzle` Attachment** (new, proposal) for the orange-red revolver flash. The bullet itself spawns at root + `ENEMY_SHOT_HEIGHT` 1, not at the muzzle ([[EnemyService]]), so the `Aim` pose has to line the barrel up with that height |
| **Dynamite, held** (Dan) | **REQ** | A prop welded to Dan's `RightHand` | A stick about 0.3 across × 1.0 long (first guess) | A stick with a fuse | Red `#C8322A` (matches the effect), a cream label | ≤ 150 | Hidden at the `Release` marker (code). A `Fuse` Attachment at the fuse tip carries `FuseSparkle` |
| **Dynamite, thrown** | **REQ** | `ReplicatedStorage.Assets.Effects.Dynamite` (today a red `#C8322A` cylinder, [[EffectsController]]) | **Keep the built size [read in Studio]** | The same stick + a `Fuse` attachment + a blink part | Red `#C8322A`, the blink in telegraph orange `#FF4A1C` | ≤ 150 | Fuse blink: period = remaining fuse × 0.2 s, at least 0.02 s ([[Combat Polish]]). Fuse 1.5 s (`Fuse`) |
| **Bandolier** (Dan) | NTH | Welded to the UpperTorso | — | 4–6 sticks on a strap | Red/tan | ≤ 300 | Silhouette only |
| **The jug** (Bart) | **REQ** | A prop welded to Bart's `RightHand` (or his hip during walks: one prop that the `WindUp` animation carries; one weld, first guess) | About 1.0 tall × 0.8 across (first guess, at Bart's scale) | A stoneware jug, a cork, a "XXX" label | Brown `#8A5A3C`, cream top `#E9DCC0`, black "XXX" | ≤ 300 | Read in the `WindUp` swig; the jug's mouth is the source for a small `Gulp` splash (NTH, amber `#E0A040`, first guess; it mustn't read as orange-red danger) |
| `Pickups.Coin` | **REQ** (it exists) | `ReplicatedStorage.Assets.Pickups.Coin` ([[Loop (M2)]]) | **Keep the built size [read in Studio]** | A round coin with a star stamp | Gold `#FFC83D` (§1) | ≤ 200 | "Round and spinning" (§1). PickupController spins it. Add the `CoinSparkle` emitter |
| `Pickups.WeaponCrate` | NTH | Exists: a wooden crate with gold bands ([[PickupService]]) | Keep | — | Wood `#7C5A3A`, gold bands | ≤ 500 | Restyle only |
| `Pickups.Blueprint` | NTH | Exists ([[PickupService]]) | Keep | A rolled scroll | Blueprint blue `#2F6FD6` with white lines (§1) | ≤ 200 | Restyle only |

---

## 3. Environment spec

### 3.1 How the parallax works (it constrains every layer)
> **Update 2026-10-16:** the [[Background Kit]] now standardises this: six slots with fixed
> Z bands (Foreground, Track, Ground, Near, Mid, Far), variant tiles, set-pieces and a
> Studio plugin. Where it differs from this section, the Background Kit wins.

- Every layer is a Model in **`ReplicatedStorage.Assets.Backgrounds.WildWest`**, with
  Attributes **`TileLength`** and **`Tiles`**. Each has **one `Tile` Model** whose pivot is
  at its **left end**, with its parts spanning **X 0 → `TileLength`**. Every part is
  **anchored**, with **no collision, query, touch or shadows** ([[ParallaxController]]).
- **There are no per-layer scroll factors in code.** Every layer moves at `TRAIN_SPEED`
  **50 studs/s in −X**. The perspective camera does the parallax.
- The *apparent* factor is about **D / (D + d)**, where D ≈ 54 (the camera distance at
  16:9, [[CameraController]]) and d is the depth behind the train plane. The visible width
  at depth d is about **70 × (D + d) / D**.

| Layer (built greybox) | Z range | Depth d | Apparent speed vs the train plane | Visible width | `TileLength` × `Tiles` | Final contents | Budget (of the 20k visible) |
|---|---|---|---|---|---|---|---|
| **1_Foreground** | +22 | −22 (in front) | **≈ 1.7×** (crosses the screen in about 0.8 s) | ≈ 41 | 140 × 2 | **Rare, dark, low-detail** silhouettes: telegraph poles (with wires sagging between tiles), a saguaro, a rock. `#4A3A2E`-dark, no texture. They never cover the gameplay plane for more than a moment (§1) | ≤ 1k |
| **2_Track** | ≈ 0 (under the train) | 0 | 1.0 | 70 | 30 × 5 | **10 ties (3-stud spacing) and 2 rails** under the train; ballast. The moving ties sell the speed. Ties `#5A4632`, rails `#3B3B42`, ballast `#CDB48E` (first guesses) | ≤ 2k |
| **3_Ground** (was Desert) | +60 → −640 (a ground slab) | 0 → 640 | 1.0 → 0.08 | — | 200 × 8 | Sand floor `#E8CBA2`, scattered rocks, scrub tufts `#A9B38A`, tyre-free dirt road (proposal), a faint dune undulation. Keep the near strip low-contrast so it doesn't compete with the train | ≤ 5k |
| **4_Near** (was Scrub) | −35 → −110 | 35–110 | ≈ 0.6 → 0.33 | ≈ 115–213 | 120 × 4 | Saguaros, bushes, fence lines, the occasional windmill or water tower. Muted sage `#A9B38A`; slightly lower saturation than the train | ≤ 6k |
| **6_Far** (was Mesas) | −380 → −520 | 380–520 | ≈ 0.12 → 0.09 | ≈ 560–745 | 500 × 4 | Mesas and buttes in **desaturated terracotta `#D9A27C`**, flat-shaded with 2–3 strata bands, fading with Atmosphere | ≤ 6k |

- Check the **coverage**: `TileLength × Tiles` must exceed the visible width plus one tile
  (2000 vs about 745 for the mesas, 480 vs about 213 for scrub, 280 vs about 41 for the
  foreground: all fine). Raise `Tiles` if gaps show ([[ParallaxController]]).
- **Seams:** each `Tile`'s contents must tile seamlessly at X 0 and `TileLength`. Nothing
  can straddle the ends unless it's mirrored in the next copy.
- Background colours stay **lighter, desaturated and lower contrast**, getting paler with
  distance (§1). Only the gameplay plane is fully saturated.

### 3.2 Sky
- `Lighting.Sky` plus `Atmosphere`; not a strip ([[ParallaxController]] notes).
- The gradient is **`#8EC3E6` (top) → `#F6DDB4` (horizon)** (§2), and it still needs setting
  by hand ([[Studio Setup Checklist]] §4).
- **A custom 6-face skybox** (512 px a face, first guess), hand-painted with that gradient
  and a few soft toon clouds, is cheap and exact.
- `Clouds` (under Terrain) is an optional extra (first guess: `Cover` 0.35, `Density` 0.5,
  `Color` `#FFF6EA`). Check it doesn't fight the toon finish.
- Set `CelestialBodiesShown` so the sun disc doesn't sit in the middle of the play area
  (first guess: hide it, or keep it small).

### 3.3 Lighting: starting values (all first guesses; [[Art Direction]] §8 gives only the intent)
§8: **one strong warm key (the sun) slightly in front of the gameplay plane**, so faces
toward the camera are lit; a cool ambient; Atmosphere for distance fade; a little Bloom; a
gentle saturation and contrast boost; **a light depth of field on the background only**
(changed 2026-10-16; it was "none").

| Instance | Property | Starting value |
|---|---|---|
| `Lighting` | `Technology` | **ShadowMap** (the default decision). **Future** only if a mid-range phone holds frame rate (the open item in §8; the F1 test plan) |
| | `ClockTime` / `GeographicLatitude` | 14.5 / tune until the sun is **behind the camera (+Z side), high, a little to one side**. Check faces on both facings |
| | `Brightness` | 2.5–3 |
| | `Ambient` | `#5E6B80` (cool) |
| | `OutdoorAmbient` | `#8E9BB0` |
| | `ColorShift_Top` | `#FFE6C2` (a warm key) |
| | `EnvironmentDiffuseScale` / `EnvironmentSpecularScale` | 0.4 / 0.1 (toon: no shiny plastic) |
| | `ShadowSoftness` | 0.25 |
| | `GlobalShadows` | true. `CastShadow` off on small trim, VFX and backgrounds |
| `Atmosphere` | `Density` | 0.28 (the train at about 54 studs must stay crisp; the mesas fade) |
| | `Offset` | 0.25 |
| | `Color` | `#F6DDB4` (the horizon) |
| | `Decay` | `#D9A27C` (the mesa tone) |
| | `Glare` / `Haze` | 0.15 / 1.2 |
| `ColorCorrectionEffect` | `Saturation` / `Contrast` / `Brightness` | +0.10 / +0.08 / +0.02 |
| | `TintColor` | `#FFF6EC` |
| `BloomEffect` | `Intensity` / `Size` / `Threshold` | 0.35 / 20 / **1.4** (high enough that sand and white shirts don't bloom, but Neon tracers, muzzle flashes and coins do) |
| `SunRaysEffect` | `Intensity` / `Spread` | 0.02 / 0.6 (optional) |
| `DepthOfFieldEffect` (`Lighting.DepthOfField`) | `Enabled` / `FocusDistance` / `InFocusRadius` / `FarIntensity` / `NearIntensity` | true / **55** / **25** / **0.25** / **0.2**. Set in Studio 2026-10-16. The camera sits 40–72 studs from the plane depending on aspect (48 at the Studio viewport), so focus 55 ± 25 keeps the train sharp on every screen while `4_Near` softens a little and `6_Far` more. Off at low graphics quality |

**Test**: capture the same frame on PC and a phone under ShadowMap and Future, and record
the frame rate with 4 agents, a 20-enemy crowd and 12 ragdolls (F7).

### 3.4 Set-pieces (§6: canyon, bridge, ghost town, cactus field)
**Today's ParallaxController recycles exactly one `Tile` per layer**, so set-pieces need a
small code change. **Now drafted** in the [[Background Kit]]: variant tiles
(`Tile_GhostTown`…) with a `Weight` (random) or `Every` (every Nth tile) attribute (Q14).

| Set-piece | Layer | Slice | Contents | Notes |
|---|---|---|---|---|
| **Cactus field** | 4_Near | **REQ** (easiest) | A dense stand of saguaros and prickly pear, one or two comic cactus "poses" (arms up as if held up by a bandit) | Fits the existing 120-stud scrub tile |
| **Ghost town** | 4_Near (or a new 5_Mid layer at about Z −150) | NTH | A false-front saloon, a bank, a water tower and tumbleweeds; desaturated wood `#B89A7A` (first guess) | A one-tile variant |
| **Canyon** | 6_Far + 3_Ground | NTH | Canyon walls rising close behind the train (a new layer at about Z −60, first guess), in a slightly darker terracotta | Gives the strongest depth change |
| **Bridge (trestle)** | 2_Track + 3_Ground | NTH (later) | The track tile becomes a timber trestle and the desert floor drops away into a gorge | The hardest: it swaps the ground under the train. Remember the gap-fall rule uses absolute Y |

---

## 4. VFX list

**Conventions:**
- Templates live in **`ReplicatedStorage.Assets.Effects`** and are built by hand in Studio.
  Code clones them and calls `ParticleEmitter:Emit(n)` or tweens them, which is allowed
  for effects ([[EffectsController]], `CLAUDE.md`).
- Emitters are kept `Enabled = false`, except looping ones on live props.
- Smoke and dust use **flipbook** textures (§9): a 512 px sheet in a 4 × 4 grid, OneShot.
- **The total is at most about 500 particles alive on mobile** (§11). The caps below add up
  to about 450 in the worst case.
- Draw remote players' effects at reduced counts (first guess: half).

**Colours** ([[Art Direction]] §1 and §9, [[EffectsController]]):
- player shots warm white-yellow `#FFF2B3`,
- hits white,
- explosion core `#FFC24A`, then grey smoke,
- enemy projectiles orange-red `#FF5A2A` with a dark outline,
- the telegraph `#FF4A1C`,
- coins `#FFC83D`,
- healing mint `#5BE38A`,
- **no blood, ever**.

| Event | Template | Slice | Build | Colours | Lifetime | Max particles alive (budget) |
|---|---|---|---|---|---|---|
| Rifle shot | **`MuzzleFlashRifle`** (decided name, [[Combat Polish]]) | **REQ** | At the weapon's `Muzzle`: a star-shaped flash billboard (or a Neon part) + 2–3 sparks | Core white, edges `#FFF2B3` | **0.05–0.08 s** | 3 per shot; about 40 total for 4 players |
| Rocket launch | **`MuzzleFlashRocket`** | **REQ** | A back-blast puff from the tube rear + a front flash | `#FFF2B3` → light grey smoke | 0.08 s flash; 0.4 s smoke | 6 per shot |
| Scattergun | **`MuzzleFlashScattergun`** (a cone) | NTH | A cone flash along the barrel | `#FFF2B3` | 0.06 s | 4 |
| Crowd Pleaser | `MuzzleFlashRifle` reused (first guess) | NTH | — | — | — | — |
| Revolver (enemy) | `MuzzleFlashRevolver` (first guess name) | **REQ** | At the revolver's `Muzzle` | **Orange-red `#FF5A2A`** (enemy fire) + a dark smoke wisp | 0.08 s | 3 |
| Player tracer | `Tracer` (exists) | **REQ** (keep) | The neon bar; fades over 0.08 s | `#FFF2B3`, no outline | 0.08 s | — (a part) |
| Rocket in flight | `Rocket` (exists, a neon capsule) | **REQ** (restyle) | A toon rocket mesh + a `Trail` of light smoke | `#FFF2B3` body glow, light-grey trail | Until `X` (or 3 s) | Trail only |
| Enemy bullet | `EnemyBullet` (exists) | **REQ** (upgrade) | Add the **dark outline** (a dark shell 1.2× behind the core) and a **smoky `Trail`** (§1) | `#FF5A2A` core, dark `#2A1A14` outline, grey trail | Until `P` (or 3 s) | Trail only |
| Hit on an enemy | `HitSpark` (exists, a white neon ball) | **REQ** (upgrade) | Keep the 1.6-stud flash; add a **comic star burst** (4–6 white streaks) | White | 0.12–0.2 s | 6 per hit; rate-capped to about 60 total |
| Hit on Max | `HitFlashPlayer` (first guess) | **REQ** | A white flash on Max's body (a short `Highlight` fill, or a white burst at the hit point). Only the local player's own hits get the body flash | White | 0.1 s | 4 |
| Run dust | **`DustRun`** (first guess) | **REQ** | A small puff at the foot on each `Footstep` marker (Max and the enemies close to the camera) | Sand `#E8CBA2`, slightly darker `#D9B98C` so it reads on the roof (first guess) | 0.35 s | 2 per step. Cap at 40; skip it for enemies over the cap |
| Land dust | **`DustLand`** | **REQ** | A flat ring of 6–8 puffs on `Landed`; bigger on a leap landing | Sand, as above | 0.4 s | 8 |
| Jump dust | `DustJump` | NTH | 3 puffs at take-off | Sand | 0.3 s | 3 |
| Spin | **`SpinTrail`** (new) + `SpinRing` (exists) | **REQ** | A `Trail` between 2 attachments on Max's hands or feet during `Max_Spin`, plus the existing ring growing to the spin radius over 0.25 s | **The player's colour** (P1 `#3D8BFF`…) so co-op players can see whose spin it is (proposal), fading to `#FFF2B3` | Trail 0.2 s | Trail only |
| Explosion (rocket splash, Dan) | `ExplosionCore` + `ExplosionSmoke` (exist) | **REQ** (upgrade) | Keep the round toon balls (the core grows to 2× radius over 0.35 s; the smoke to 2.6× over 0.8 s) and add: **chunky smoke-ball flipbook particles**, 4–6 wood **splinters** when it's on the roof, and the existing `CameraController.shake(EXPLOSION_SHAKE)` (0.5) | Core `#FFC24A` → `#FFF2B3` centre; smoke greys `#8A8A92` → `#C9C9CF` (first guess) | 0.8–1.2 s | 25 |
| Engine smoke | **`SmokeStack`** (on the engine's stack attachment) | **REQ** | Continuous puffs, streaming toward −X (the train "moves" +X, so the smoke streams back over the train) | White-grey `#E6E6EA` → transparent | 2.5 s | 30 (Rate 12/s) |
| Knockout stars | **`KnockoutStars`** | **REQ** | 3–4 cartoon stars circling over the ragdoll's head (an attachment to the ragdoll's `Head`, or a client part following it) | Warm white `#FFF2B3` stars with a dark outline (not coin gold, which would read as pickups) | Until the ragdoll fades (`RAGDOLL_FADE` 3 s + fade) | 4 per ragdoll × 12 ragdolls = 48 |
| Knockout pop | `KnockoutPop` (exists; "+points" label) | **REQ** (keep) | Rises 3 studs and fades over 0.8 s ([[EffectsController]], [[ScoreService]]) | Luckiest Guy text | 0.8 s | — |
| Knockout dust | **`KnockoutDust`** (§9) | **REQ** | A puff burst where the body lands, plus 3–4 wood splinters | Sand dust; splinters `#A57A50` | 0.5 s | 10 |
| Hat pop | **`HatPop`** (a client clone of the enemy's `Hat`, §2.4) | **REQ** | Flung up (about 20–25 studs/s, first guess) and away from the hit, spinning in the X–Y plane, a small "pop" puff where it leaves | — | Lands and fades with the ragdoll (about 3.8 s) | 1 part + 3 puff particles |
| Telegraph "!" | `Alert` (exists, a "!" in `#FF4A1C`, 4 studs above, fades over 0.6 s) | **REQ** (upgrade) | Add a **punch-in scale** (0 → 1.3 → 1.0 over 0.12 s) and a faint `#FF4A1C` glow ring | `#FF4A1C` | 0.6 s | 1 |
| Bart's charge | **`ChargeDust`** | **REQ** | Big dust clouds behind each `Footstep` during the charge + speed lines | Sand; speed lines white at 50% | 0.5 s | 20 |
| Bart's stagger | `StaggerStars` | **REQ** | `KnockoutStars` reused at Bart's size | As KO stars | 1.5 s (`StaggerTime`) | 4 |
| Dynamite fuse | **`FuseSparkle`** (at the `Fuse` attachment on the held and thrown dynamite) | **REQ** | Continuous sparks + a tiny smoke wisp. The **blink** (a Neon part toggled) speeds up as the fuse burns (period = remaining × 0.2 s, ≥ 0.02 s) | Sparks `#FFF2B3` → `#FF4A1C`; the blink in `#FF4A1C` (it's a danger telegraph) | The fuse (1.5 s) | 10 per stick (Rate 20/s, 0.25 s each) |
| Coins | **`CoinSparkle`** (on the `Coin` template) | **REQ** | 1–2 twinkles while the coin spins; a pickup burst of 6 gold sparkles | Gold `#FFC83D` + white | Twinkle 0.4 s; burst 0.3 s | 2 per coin while idle; the gap-coin arc is 20 coins, so 40 + bursts |
| Swap-in | `SwapPuff` | **REQ** | A puff ring + a gold sparkle (the original has "a puff effect" on swaps) | White + Max gold `#F2C14E` | 0.4 s | 12 |
| Revive | `ReviveBurst` | **REQ** | A ring pushing out (it visualises the radial push from [[Combat Polish]]) + mint plus-signs | Healing mint `#5BE38A` (§1) | 0.5 s; plus-signs 1 s | 15 |
| Leap | `LeapWhoosh` | NTH | Speed lines behind the leaper + a big `DustLand` on landing | White | 0.5 s | 10 |
| Checkpoint heal | `HealBurst` | NTH | Mint plus-signs rising from each player (the medbay's free heal) | `#5BE38A` | 1.0 s | 8 per player |
| Downed | `DownedStars` | **REQ** | `KnockoutStars` reused over a downed agent | As KO stars | While `Downed` | 4 per downed player |

**Budget check (worst case, 4 players, 30 enemies, 12 ragdolls):** muzzle 40 + hits 60 +
dust 70 + KO stars 48 + explosions 2 × 25 + smoke 30 + coins 60 + fuses 30 + misc 60 ≈
**450**, under the about-500 cap. Add a client-side particle governor (NTH): above about 400
alive, skip `DustRun` and halve the bursts.

---

## 5. Sound list

**Conventions** (all first guesses; there's no audio note in the vault yet):
- **SoundGroups** under `SoundService`: `Music`, `SFX`, `Voice`, `UI`.
  - Starting volumes: Music 0.3, SFX 0.6, Voice 0.7, UI 0.5.
  - **Duck the music** under barks and big stingers (a `CompressorSoundEffect` side-chained
    to `Voice`, or a short tween).
- **Positional SFX:** parent sounds to a part or attachment. The listener is the camera,
  which sits about 54 studs from the play plane; an on-screen sound is at most about 64
  studs away. Set `RollOffMode = InverseTapered`, **`RollOffMinDistance` ≈ 65** (so
  everything on screen plays at full volume) and `RollOffMaxDistance` ≈ 160.
- **Variation:**
  - pick a random variant,
  - randomise `PlaybackSpeed` 0.94–1.06 (pitch ±6%),
  - randomise volume ±10%,
  - never play the same variant twice in a row.
- **Concurrency caps** (client): at most 6 gunshot sounds and 4 hit sounds at once. The
  local player's sounds play at full volume and teammates' at 0.5 (otherwise 4 rifles at
  0.175 s each make about 23 shots a second).
- **Sourcing:**
  - **Library** = the Roblox Creator Store audio (free, including Roblox's licensed SFX and
    music for use in Roblox experiences).
  - **Pack** = a licensed royalty-free pack whose licence allows re-uploading inside a game.
  - **Custom** = recorded or designed by the developer, or commissioned.
  - Upload under the **place's owner** (user or group), or the sounds won't play.
- **Barks** are **text bubbles plus a voiced grunt** (decided, [[Writing and Dialogue]] §1).
  There's a cooldown per agent of about 4 s, and important barks skip it. For enemies, a
  global bark limit of at most 1 every 1.5 s (first guess), so crowds don't babble.

**Priority:** **P1** = required for the slice and the biggest feel gain. **P2** = required
for the slice. **P3** = nice-to-have.

| Event | Sound | Pri | Length | Variants | Volume / pitch notes | Source |
|---|---|---|---|---|---|---|
| Service Rifle shot | A punchy, compact "pew-crack" with a fast decay (toon, not realistic) | P1 | 0.15–0.25 s (must decay inside 0.175 s) | 4 | Local 0.6, teammates 0.3; pitch ±6% | Library / pack, layered |
| Pocket Rocket launch | A "fwoomp" + hiss | P1 | 0.4 s | 3 | 0.7 | Library / pack |
| Rocket in flight | A hiss/whistle loop | P3 | 0.5 s loop | 1 | 0.3, positional | Library |
| Explosion (rocket splash, dynamite) | A round, cartoony "boom" with low end + debris tinkles | P1 | 1.2–1.8 s | 3 | 0.8; pitch ±8%; ducks the music | Pack |
| Scattergun shot / rack | A "ka-BLAM" + a pump rack | P3 | 0.35 s / 0.3 s | 3 / 1 | 0.7 | Library |
| Crowd Pleaser spin-up / fire loop / spin-down | A motor whine rising over **0.6 s** (`SpinUp`) → a buzz-saw loop → a wind-down | P3 | 0.6 s / a 0.5 s loop / 0.5 s | 1 each | 0.6 | Library / pack |
| Revolver shot (enemy) | A cartoon "bang" with a ricochet tail | P1 | 0.3–0.4 s | 3 | 0.6; positional | Library |
| Revolver cock (the tell) | A hammer click at the start of `Aim` | P1 | 0.15 s | 2 | 0.6. **An audio telegraph** | Library |
| Alert "!" | A bright "ting" with the `Alert` pop | P1 | 0.15 s | 1 | 0.5. **Accessibility: a non-visual telegraph** | Custom / library |
| Hit on an enemy | A cartoony "thwack"/"bonk" | P1 | 0.08–0.15 s | 4–5 | 0.5; pitch ±8%; at most 8 a second | Pack |
| Hit on Max | A soft "oof" grunt + a cloth thump | P1 | 0.2–0.3 s | 3 | 0.6 | Custom (Max's voice) |
| Enemy flinch grunt | "Hup!"/"Ack!" | P2 | 0.2–0.4 s | 3 per voice | 0.5 | Custom |
| Enemy spot bark | Grunts behind "YEEHAW!"/"GET 'EM!" bubbles | P2 | 0.4–0.8 s | 3 per light voice | 0.6 | Custom |
| Enemy knockout | A **"boing" + a falling slide whistle + a bonk**, plus a grunt "OOF!"/"MY HAT!" | P1 | 0.6–1.0 s | 4 + 3 grunts | 0.7; pitch ±10% | Pack + custom |
| Hat pop | A cork "thwip"/pop | P1 | 0.15 s | 2 | 0.6 | Library |
| Knockout stars | A tweety twinkle loop | P3 | 0.8 s loop | 1 | 0.25 | Library |
| Six-Shooter "DRAW!" | A voiced bark | P2 | 0.5 s | 2 | 0.7 | Custom |
| Dan: match strike + fuse hiss | "Scritch" + a hiss loop for the 1.5 s fuse | P1 | 0.3 s + a 0.5 s loop | 2 + 1 | 0.6; the hiss rises in pitch as the fuse runs out (+20%, first guess) | Library |
| Dan "FIRE IN THE HOLE!" | A voiced bark | P2 | 0.8 s | 2 | 0.7 | Custom |
| Bart's swig | **"Glug glug"**, timed to the `Gulp` markers in the 1 s `WindUp` | P1 | 1.0 s | 1–2 | 0.7. **It's the stagger telegraph** | Custom |
| Bart "HERE I COME!" / "WHOA, WHOA, WHOA!" | Voiced barks | P2 | 0.8 s / 1.2 s | 1–2 each | 0.8 | Custom |
| Bart's charge | Thundering stomps on each `Footstep` + a snort | P1 | Per step 0.2 s | 3 | 0.7; positional | Pack |
| Bart's charge hit | A big "BONK" + a whoosh (the knockback) | P1 | 0.4 s | 2 | 0.8 | Pack |
| Bart's stagger | A slide whistle wobble + a dizzy bird tweet | P2 | 1.5 s | 1 | 0.6 | Library |
| Footsteps (Max) | Wooden-roof "tok"s on `Footstep` markers; iron "tink"s on the tanker and engine (a `Surface` attribute on the roof parts, first guess) | P2 | 0.08 s | 4 per surface | 0.35 local only; teammates 0.15 | Pack |
| Jump | A short whoosh | P1 | 0.2 s | 3 | 0.5 | Library |
| Double-jump spin | A whirl "fwip-fwip" | P1 | 0.35 s | 2 | 0.55 | Library / custom |
| Land | A wood thud (heavier after a big fall or a leap) | P1 | 0.15–0.25 s | 3 + 1 heavy | 0.5 | Pack |
| Max's barks | Grunts and one-word lines behind the bubbles (Start, Swap, Crate, Hit, Down, Thanks, Help, Mayhem, Win; [[Writing and Dialogue]] §3) | P2 | 0.5–1.5 s | 1–2 per category | 0.7 | Custom (a voice actor or the developer) |
| Swap | A whoosh + a "ta-da" sparkle | P2 | 0.4 s | 1 | 0.5 | Library |
| Downed | A comic "wah-wah" trombone | P2 | 1.2 s | 1 | 0.6 | Library |
| Revive hold | A rising tone over the **2 s** `REVIVE_HOLD` | P2 | 2.0 s | 1 | 0.4 | Custom / library |
| Revived | A short heroic sting | P2 | 0.8 s | 1 | 0.6 | Library |
| Coin pickup | A bright chime, **rising a semitone for each coin collected within 0.5 s** (first guess), so the 20-coin gap arc plays a scale | P1 | 0.2 s | 1 (pitch-stepped) | 0.45; local only (coins are personal) | Library / custom |
| Coin drop | A soft clink | P3 | 0.15 s | 2 | 0.35 | Library |
| Crate pickup | A wooden "clunk" + a weapon rack | P2 | 0.4 s | 1 | 0.5 | Library |
| Train start | **A steam whistle** at the engine's `Whistle` + "ALL ABOARD!" | P2 | 2–3 s | 1–2 | 0.6 | Library |
| Train ambience | A **clickety-clack** loop (about 1.7 clacks a second, matching a 30-stud track tile at 50 studs/s), a soft steam-chuff loop and wind | P1 | 4–8 s loops | 1 each | 0.25 / 0.2 / 0.15. Never ducks to silence | Pack / library |
| Train cleared / leap call | "TRAIN CLEARED!" sting → "NEXT TRAIN — LEAP!" sting ([[Loop (M2)]]) | P2 | 1.5 s each | 1 | 0.7 | Custom / library |
| Leap | A big whoosh at take-off + a crowd "whoa" (NTH) + a heavy land | P2 | 0.6 s | 1 | 0.6 | Library |
| Checkpoint arrival | "HUB TRAIN ALONGSIDE!" sting + an Agency jingle | P2 | 2 s | 1 | 0.7 | Custom |
| Medbay heal | A soft magical chime | P3 | 1.0 s | 1 | 0.5 | Library |
| UI click / hover / back | Chunky toon clicks | P2 | 0.05–0.1 s | 2 / 1 / 1 | 0.4 | Library |
| UI ready-up / countdown tick / GO | "Ding", tick, a horn | P2 | 0.1–0.6 s | 1 each | 0.5 | Library |
| UI combo tier, Mayhem ready, results tally | Pops, a power chord, a coin-counter rattle | P2 | 0.2–1.0 s | 1 each | 0.5 | Library |
| **Music: Wild West hostile train** | A cartoon-western chase loop: banjo, harmonica, whip-cracks, a galloping beat, about 130–150 BPM (first guess). Saturday-morning cartoon, not spaghetti-western grit | P1 | A 90–120 s seamless loop | 1 (+ an intensity layer for the Bart fight, NTH) | 0.3; ducks under barks | Library (Roblox licensed music), or commissioned (Q15) |
| **Music: checkpoint / hub** | Spy-fi lounge (vibes, a walking bass, brass stabs): the Agency's sound | P2 | A 60–90 s loop | 1 | 0.3 | Library or commissioned |
| Music: results / wipe stingers | A win flourish / a comic fail | P3 | 3–5 s | 1 each | 0.5 | Library |

---

## 6. Build order, checklist and open questions

### 6.1 Build order (the biggest feel gain first)
1. **Lighting pass (half a day).** Sky gradient, ShadowMap, Atmosphere, ColorCorrection,
   Bloom (§3.3). It changes every screenshot at once. Do the ShadowMap/Future phone test
   now (F1).
2. **Combat Polish code (F2), with the cheap VFX it needs:** `MuzzleFlashRifle` and
   `MuzzleFlashRocket`, the upgraded `HitSpark`, the `Alert` punch-in, and the enemy
   `Flinch` (even a tween first, then the animation). Also Bart's `ChargeSpeed` → 26.7.
3. **The P1 sounds:** rifle, rocket, explosion, hits, KO boing, hat pop, jump/spin/land,
   coin chime, the Alert ting, the revolver cock, Bart's glug and stomps, the train
   ambience and the music loop. **Sound is the cheapest big gain.**
4. **Max's core animations** on the greybox rig: `Max_Run`, `Max_Idle` + `Max_IdleHairCheck`,
   `Max_Jump`/`Max_Fall`, `Max_Land`, `Max_Spin`, `Max_ShootRifle`, `Max_ShootRocket`,
   `Max_HitReact`. Animations don't depend on the final mesh, so start them before the
   model.
5. **The knockout package:** `Hat` accessories, `HatPop`, `KnockoutStars`, `KnockoutDust`.
   (This is the comedy payoff in every fight.)
6. **The enemy telegraph animations:** Six-Shooter `Aim`/`Fire`, Dan `Throw`, Bart
   `WindUp`/`Charge`/`Stagger`, Rodeo Kid `Spin`, plus the shared `Walk`, `Attack` and
   `Celebrate`.
7. **The train kit:** `Boxcar` (2 of 7 slots) → `Engine` (the goal and the hero) → `Caboose`
   (the first impression) → `CattleCar` → `WaterTanker`/tender → `Flatbed` → couplers. Use
   the shared `Truck`/`Wheel`/`Coupler` meshes from the first car on.
8. **Max's toon model + faces**, then the remaining Max animations (downed, revive,
   celebrate, swap-in, leap).
9. **The light-enemy base body**, then the per-slot hats and props, then **Big Bart**.
10. **Final parallax layers** (2_Track → 4_Near → 6_Far → 3_Ground → 1_Foreground), the skybox and
    the cactus-field set-piece.
11. **VFX pass 2:** dust, `SpinTrail`, `ChargeDust`, `FuseSparkle`, `CoinSparkle`,
    `SmokeStack`, swap and revive bursts. Then the P2 sounds and barks.
12. **Prove it (F7):** the phone test against §11, then 2–4 players, then tuning. Repeat.

### 6.2 Checklist
**Before you start (in a local Studio session; the values aren't in the vault):**
- [ ] The carriage **body width in Z** and the exact `Roof` sizes of each greybox.
- [ ] `Constants.WEAPON_HOLD_OFFSET`, `RAGDOLL_IMPULSE` and the enemies' `JumpHeight`.
- [ ] Which **joint type** Max's rig uses (Motor6D or AnimationConstraint), and the
  enemies' `AnimationConstraint` and `BallSocketConstraint` layout.
- [ ] The built **slot shirt colours** and hats on the 5 enemy templates.
- [ ] The sizes of `Pickups.Coin`, `Effects.Dynamite`, `Effects.Rocket` and `EnemyBullet`.
- [ ] Whether Dan turns or backpedals when he backs off.
- [ ] Who owns the place (user or group), which is where the animations and audio must be
  published.
- [ ] Import a 1 × 1 × 1 test cube and record the importer unit and axis settings in
  [[Techniques]].

**Animations:**
- [ ] Max REQ set: M1–M9, M11–M18 (17 clips) + 4 face textures.
- [ ] Shared enemy set E1–E4 and E6; specials R1, S1, S2, D1, B1–B4 and B6.
- [ ] `Footstep`, `Release`, `Gulp` and `Impact` markers.
- [ ] Every ID in `Animate` (Max) or in the template `Animations` folders (enemies),
  published under the place owner.

**Models:**
- [ ] The 6 carriages (+ the tender decision) on the greybox, colliders kept, visuals
  non-colliding, ≤ 8k each.
- [ ] Max ≤ 6k / 1024; hitbox 1.3 × 5.5 kept; the tag and attributes kept.
- [ ] 4 lights ≤ 2.5k / 512; Bart ≤ 4k / 512; hitboxes from the attributes; joints and
  groups kept.
- [ ] Hats as `Accessory` named `Hat`; revolver (+ `Muzzle`), dynamite (+ `Fuse`), the jug.
- [ ] Service Rifle and Pocket Rocket: `Handle` pivot, −Z barrel, `Muzzle`, attributes
  kept, plus `MuzzleFlash`.

**Environment:**
- [ ] 5 parallax layers at final quality, tiling seamlessly, with no collision, query or
  shadows.
- [ ] The skybox gradient; the lighting values (§3.3); the ShadowMap/Future decision.
- [ ] The cactus field (needs the parallax variant code if it's a variant tile).

**VFX and sound:**
- [ ] The REQ rows of §4, built as templates in `Assets.Effects`, under the particle budget.
- [ ] The P1 and P2 rows of §5, with SoundGroups, roll-off and the concurrency caps.

**Verify** (`CLAUDE.md` → Verifying changes):
- [ ] A playtest console with no errors.
- [ ] The heights, hitboxes, gap-fall, crate pickup and enemy jumps unchanged.
- [ ] The ragdoll still works with the new meshes.
- [ ] The phone frame rate.

**Vault:** update [[TrainService]], [[EffectsController]], [[EnemyService]] and
[[CharacterService]] with every new template, tag, attribute and marker; add an
`05 Assets/` audio list with each sound's source and licence.

### 6.3 Open questions for the developer
1. ~~**Jump height.**~~ **Answered:** the jump stays at the built 8 studs. The original's
   14-stud jump was turned down on 2026-10-16 ([[Combat Polish]] "Not adopted"). The F3
   tuning pass may still adjust it.
2. **The coal tender.** Restyle the `WaterTanker` slot as a combined tender (no code; the
   recommendation), or add a new `Tender` template and change `LAYOUT` (which changes the
   201-stud train)?
3. **Rename `DashDaring` → `MaxMayhem`** in Studio? It's optional ([[Status]]); only the
   display name has to change. If yes, do it before the model swap. (The rename touches the attributes `Squad`/`OwnedAgents`, `STARTER_AGENT` and
   `Weapon_<AgentId>`.)
4. **The weapon weld.** Keep the gun welded to the root (a stable muzzle on the server;
   the poses must match it, the recommendation), or move it to `RightHand` (natural poses,
   but the shot height would move with the animation)?
5. **The downed pose.** Keep the `PlatformStand` physics flop, or keep the root upright and
   use an animated slump (`Max_DownedLoop`), which reads better as "revive me"?
6. **Melee wind-up.** §5 wants anticipation before *every* enemy attack, but the built
   melee hits instantly. Add a short `MeleeWindUp` (about 0.2 s, first guess) to
   EnemyService?
7. **A knockout launch pose.** Delay the ragdoll by about 0.1 s for a 3-frame starfish
   pose, or rely on the impulse alone?
8. **Hat pop:** a client-side cosmetic copy (recommended: no physics on the server), or a
   real server-side unweld?
9. **Enemy hats and shirt colours:** confirm or replace the proposals in §2.3 (Dan's miner
   helmet or bowler, Bart's tiny bowler, the shirt colours).
10. **The long-johns colour.** §4 says red long johns, but red means danger and gang red is
    `#D7322F`. Use a pink-red or a cream-and-red stripe so Max never reads as an enemy?
11. **The Rodeo Kid's "cartwheel":** OK to animate it as a forward flip or roundoff in the
    screen plane, so it reads side-on?
12. **Faces:** a `Decal` on the Head, or a separate `Face` mesh with a texture swap (the
    recommendation)?
13. **Is the Engine allowed ≤ 10k triangles** if the drivers and rods don't fit in 8k?
14. **Set-pieces need ParallaxController support** (variant tiles). In the slice (the
    cactus field) or later? Wheel and rod animation (a `TrainWheel` tag): in the slice or
    later?
15. **Music and voices.** Roblox library music, or a commissioned loop? Who voices Max and
    the Cowboys' grunts?
16. **Brick's weapons (Scattergun, Crowd Pleaser):** do they get flashes and sounds in the
    slice even though Brick isn't polished?

Related: [[Feel and Look (Slice)]] · [[References]] · [[Combat Polish Code]] · [[Art Direction]] · [[Combat Polish]] · [[TrainService]] · [[CharacterService]] · [[AgentService]] · [[EnemyService]] · [[CombatService]] · [[EffectsController]] · [[ParallaxController]] · [[HudController]] · [[Wild West Enemies]] · [[Launch Agents]] · [[Writing and Dialogue]]
