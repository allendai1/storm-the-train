---
tags: [design, feature, milestone, m1, spec, checklist]
status: planned
updated: 2026-10-16
---
# First Playable (M1) — spec and Studio build checklist

> **Status: planned.** This turns milestones **M0 (Bootstrap)** and **M1 (First
> playable)** from the [[Game Design Document]] into a checklist for the first local
> Studio sessions. Architecture follows ADRs [[0004-single-place-hub-and-run-modes]] to
> [[0010-third-party-packages]]. Numbers marked *first guess* are starting values to
> tune in playtests: the GDD treats the original's numbers as loose reference only.
> **Nothing here is built yet.** Tick items off only once they're verified in Studio.

## Summary
One Wild West hostile train, side-on, for 1–4 players. Each player is **Dash Daring**
with his two weapons, switched by walking into **weapon crates**. The squad fights from
the caboose to the engine against the first four Rattler Gang lights and **Big Bart**,
spawned by a budget timeline. Downed players can be revived by teammates. When the
timeline ends and the squad reaches the engine, the train is **cleared**. A wipe ends
the run. One **blueprint thief** drops a blueprint pickup that's counted but not saved.

M1 answers one question: **is the core fun?** Movement, shooting, readable enemies,
and co-op revives, on a side-on train.

## Scope
| In M1 | Not until later |
|---|---|
| Run mode only, entered with `ForceMode = "Run"` and a Ready countdown | Hub, party lobby, teleport (M2) |
| One 7-carriage Wild West train built from templates | Leaps, checkpoints, legs (M2) |
| Dash: Service Rifle + Pocket Rocket, **weapon crates**, jump, double-jump spin | Agent swap, other agents (M2/M3) |
| Bandana Bandit, Rodeo Kid, Six-Shooter, Dynamite Dan, **Big Bart** | Lasso Lucy, Saloon Door Sam, bosses, hostage (M3) |
| Budget spawning with co-op scaling; Bart's solo intro | Survival, boss events (M3) |
| 100 HP, toughness, downed → teammate revive, gap falls | Gem revives, Mayhem, gadgets (M2/M4) |
| **Blueprint thief stub**: a drop and pickup counted on the HUD, not saved | Blueprint banking and upgrades (M4) |
| HUD (HP, active weapon, teammates, train progress), touch controls, run-end screen | Score/combo, currencies, saving (M2+) |
| Ragdoll knock-outs (cap 12, 3 s fade), client parallax background | Final art. Greybox models are fine |

## Player experience (M1 loop)
1. Players join a Run-mode test server and land on a staging platform at the
   caboose. **READY** starts a 5 s countdown, or it starts automatically after 20 s.
2. "ALL ABOARD!" ([[Writing and Dialogue]]) The spawn timeline starts. Bandits pour onto the carriages
   ahead and behind.
3. Players move, jump between cars, spin-attack crowds, and grab weapon crates to
   flip between the rifle and the rocket.
4. At about 1:35, **Big Bart** arrives alone. Lights pause until he's knocked out.
5. If a player is downed, a teammate holds **Interact** for 2 s nearby to revive
   them.
6. When the timeline ends, "REACH THE ENGINE!" appears. Knocking out what's left and
   standing on the engine shows **TRAIN CLEARED**.
7. The run-end screen shows time, knockouts per player, revives and the blueprint
   counter, with **PLAY AGAIN**, which rebuilds the train.

## Rules & numbers
### Player (agent: Dash Daring)
| Value | M1 | Source |
|---|---|---|
| Health pool | 100 HP | Decided (GDD) |
| Toughness (damage taken) | 0.52 | Decided ([[Launch Agents]]) |
| WalkSpeed | 28.3 studs/s (425 px/s) | Decided |
| JumpHeight | 8 studs | First guess. Enough to climb from a flatbed onto a boxcar roof |
| Double jump | Spin attack: **6 damage** in a **5-stud radius**, +4 studs of lift, 0.6 s cooldown | First guess (spin level 4) |
| Hitbox | 1.3 × 5.5 studs | First guess (original agent box: 20×90 px) |
| Gap fall | Back on the nearest roof after 1 s, 15 raw damage | Decided ([[0005-side-on-movement-and-camera]]) |

### Weapons and weapon crates
- **[decided] Weapon crates switch weapons.** Each agent's two weapons are switched by
  walking into a **weapon crate** on the train, as in the original ("weapon crates",
  `GiveRandomWeapon`). A crate flips you to your agent's **other** weapon. There's no
  secondary fire button and no weapon-swap button.
- **[proposed] Crate rules:**
  - Crates are **personal pickups**: each player sees and takes their own.
  - **Boxcars and cattle cars** each have one crate spot.
  - A crate you've taken **comes back for you after 20 s**.
  - Every **mid knockout** also drops a crate.
  - You always **start a train on your primary weapon**.
  - A crate pickup gets a pop and the agent says one line.
  - **[decided 2026-10-16]** A crate **only** switches the weapon. It doesn't refill, heal or
    reset any cooldown.

| Weapon | Type | Damage | Interval | Other (first guesses) |
|---|---|---|---|---|
| **Service Rifle** (primary) | Hitscan | 12 | 0.175 s | Range 45 studs; slight auto-aim cone of 6° |
| **Pocket Rocket** (secondary, from crates) | Server-simulated projectile | 13 direct + 13 splash | 0.5 s | 70 studs/s, 4-stud splash radius, no friendly fire |

Fire rate is enforced **on the server** while the trigger is held
([[0007-networking-and-remotes]]).

### Enemies
Stats and behaviours come from [[Wild West Enemies]]. All are first guesses there.

| Enemy | Slot | HP | Speed | Cost | Attack | M1 note |
|---|---|---|---|---|---|---|
| Bandana Bandit | 0 | 25 | 9.3 | 2 | Melee 3 / 0.75 s | First type introduced |
| Rodeo Kid | 1 | 30 | 10.7 | 3 | Melee 3; cartwheels over the player every ~2.8 s | |
| Six-Shooter | 2 | 35 | 8.7 | 3 | Bullet 5, 0.5 s tell, jumpable, every 2.5–4 s | |
| Dynamite Dan | 3 | 30 | 10 | 3 | Dynamite 10 in a 4-stud radius, 1.5 s fuse; explodes on knockout | |
| **Big Bart** | 5 | 160 | 10.7 walk / **36 charge** | 15 | Melee 6; a 1 s wind-up, then a charge with knockback. **30 damage during the wind-up staggers him** | The only mid in M1 |

- **Blueprint thief (stub):** at about 60 s, one Bandana Bandit spawns with
  `CarriesBlueprint = true` and a saddlebag accessory. Knocking it out drops a
  **Blueprint** pickup for each player. The HUD counts "1 BLUEPRINT (not saved)".

### Spawn timeline (M1, first guess)
The alive cap is measured in **total spawn cost alive**. It's multiplied by the co-op
factor: **×1.0 / 1.6 / 2.2 / 2.8** for 1 / 2 / 3 / 4 players.

| Time | Pool | Wave every | Wave cost | Alive-cost cap |
|---|---|---|---|---|
| 0:00–0:20 | Bandit | 4 s | 2–4 | 8 |
| 0:20–0:45 | + Rodeo Kid | 4 s | 3–5 | 10 |
| 0:45–1:10 | + Six-Shooter | 3.5 s | 3–6 | 12 |
| 1:10–1:35 | + Dynamite Dan | 3.5 s | 4–7 | 14 |
| ~1:35 | **Big Bart alone** (lights paused until he's knocked out) | — | 15 | — |
| +15 s | Light breather | 5 s | 2–3 | 8 |
| next 40 s | Ramp, with Bart recurring once | 3 s | 4–8 | 30 |
| end (~2:45) | **"REACH THE ENGINE!"**: spawning stops | — | — | — |

- Enemies spawn at the `EnemySpawn` attachments of carriages **within 1 carriage**
  of a living player, never on screen, at least 20 studs from every player.

### Co-op, downed and revive (decided rules; M1 has no gems)
- At 0 HP a player is downed and bleeds out over 15 s. A teammate holds **Interact for
  2 s** within about 5 studs to revive them at 40% HP. Unlimited.
- Taking damage interrupts a revive.
- If a downed player bleeds out with teammates still up, they **spectate** until
  **PLAY AGAIN**, because M1 has no checkpoint.
- If everyone is down, the run ends ("SQUAD WIPED"). There's no gem prompt in M1.

### Train (M1)
- 7 carriages, caboose to engine, along +X: **Caboose (17) → Boxcar (33) → Flatbed
  (17) → Cattle car (33) → Boxcar (33) → Water tanker (17) → Engine (33)**. The numbers
  are lengths in studs.
- Gaps between carriages are about 3 studs (`Constants.CARRIAGE_GAP`). The whole train
  is about 200 studs long.
- **Cleared:** the timeline has ended, no enemies are alive, and at least one living
  player is on the engine roof.

## Studio build list (in build order)
_Each session ends with a playtest (`start_stop_play`, `get_console_output`) and a
save or publish reminder, per `CLAUDE.md`._

### Session 1 — M0 Bootstrap
_Do the [[Studio Setup Checklist]] first. The setup script and module sources are in [[M0 Bootstrap Code]]._
- [x] **Folders:**
  - `ServerScriptService.Server` (Script) with an Attribute `ForceMode = "Run"`, plus
    `Services`, `Util`
  - `StarterPlayer.StarterPlayerScripts.Client` (LocalScript) plus `Controllers`
  - `ReplicatedStorage.Shared` (`Constants`, `Types`), `ReplicatedStorage.Assets`,
    `ReplicatedStorage.Packages`, `ReplicatedStorage.Remotes`
  - `ServerStorage.Assets`, `ServerStorage.Packages`
- [x] **Bootstraps** with the `init` → `start` pattern and mode filtering
  ([[0004-single-place-hub-and-run-modes]]). The mode service reads `ForceMode` in
  Studio.
- [ ] **Packages:** Signal and Trove from their official releases. Record them in
  [[Packages]]. ProfileStore isn't needed until saving arrives in M2.
- [x] **`Shared.Constants`:** every global number in this spec (plane Z, gap, revive
  timings, co-op factors, ragdoll cap and fade, jump, spin, crate respawn).
  **`Shared.Types`:** `InputState`, `WeaponStats`, `EnemyStats`, `AgentStats`.
- [x] **Remotes for M1:**
  - `SetInput` (UnreliableRemoteEvent),
  - `RequestSpin`, `RequestInteract`, `RequestReady`,
  - `Effects` (UnreliableRemoteEvent), `Announce`, `RunEnded`.
- [x] **`Server.Util.Guard`**, the shared validator and token bucket
  ([[0007-networking-and-remotes]]).
- [x] **Collision groups:** `Players`, `Enemies`, `Hitboxes` (no physical collision),
  `Ragdolls` (no collision with `Players` or `Hitboxes`), `Pickups`.
- [x] **StarterPlayer:** `DevComputerMovementMode` and `DevTouchMovementMode` set to
  `Scriptable`. Default jump and controls are off.

### Session 2 — Train, movement, camera
- [x] **Carriage templates** in `ServerStorage.Assets.Carriages.WildWest`: Caboose,
  Boxcar, Flatbed, CattleCar, WaterTanker, Engine. Greybox is fine.
  - Each is a Model, with its `PrimaryPart` at the rear coupling.
  - Attributes: `Length`, `CarriageType`, `Theme`.
  - Tag `Carriage`. The `Roof` part is tagged `WalkSurface`.
  - Attachments tagged `EnemySpawn` (2–3 each) and `WeaponCrateSpot` (Boxcar and
    CattleCar).
  - The Engine's roof also has the tag `TrainGoal`.
- [x] **`Workspace.Map.Run`:** a staging platform behind the caboose spot, with a
  SpawnLocation.
- [x] **`TrainService`:** assembles the 7-car train from the templates
  ([[0009-static-trains-scrolling-world]]), and rebuilds it on PLAY AGAIN.
- [x] **`CharacterService`:** puts each player in the agent rig and adds the Z = 0
  plane lock. It sets WalkSpeed and JumpHeight from the agent's Attributes, adds the
  Hitbox part, and validates movement ([[0005-side-on-movement-and-camera]]).
- [x] **Client controllers:**
  - `InputController`: keyboard, mouse and touch → `Humanoid:Move`, facing, jump and
    double-jump.
  - `CameraController`: side-on, FOV about 40°, about 70 studs wide, leads in the
    facing direction.
  - `ParallaxController`: the Wild West background strips.
- [x] **Background:** `ReplicatedStorage.Assets.Backgrounds.WildWest`, with sky, mesa
  and desert strips ([[Art Direction]] §2).

### Session 3 — Dash, weapons, crates, combat
- [x] **Agent template** `ReplicatedStorage.Assets.Agents.DashDaring`: an R15 rig with
  Attributes `Speed = 28.3`, `Toughness = 0.52`, `SpinLevel = 4`,
  `PrimaryWeapon = "ServiceRifle"`, `SecondaryWeapon = "PocketRocket"`. It has an
  invisible `Hitbox` part.
- [x] **Weapon templates** in `ReplicatedStorage.Assets.Weapons`: `ServiceRifle`
  and `PocketRocket`, each with a `Muzzle` attachment and Attributes `Damage`,
  `FireInterval`, `Range`, `ProjectileSpeed`, `SplashRadius`, `SplashDamage`.
- [x] **`CombatService`:**
  - `SetInput` drives the server's fire loop at each weapon's interval.
  - Hitscan uses `workspace:Raycast` against `Hitboxes`.
  - Rockets are server-simulated, with splash.
  - Spin attack via `RequestSpin`.
  - Damage is scaled by toughness, and health lives in Attributes.
  - Visuals go out on the batched `Effects` event.
- [x] **`PickupService`:** _(the mid-knockout drop was added in Session 4)_
  - Spawns `WeaponCrate` per player at `WeaponCrateSpot`s, from the template
    `ReplicatedStorage.Assets.Pickups.WeaponCrate`.
  - Toggles the active weapon on touch (checked by server proximity).
  - Respawns crates after 20 s, and drops one on a mid knockout.
- [x] **`EffectsController`:** tracers, the rocket visual, explosions, hit sparks
  and knockout number pops. Effect templates go in `ReplicatedStorage.Assets.Effects`.
  Particles and flashes are generated in code; that's allowed for effects
  (`CLAUDE.md`). Note it in the system's note.

### Session 4 — Enemies and spawning
- [x] **Enemy templates** in `ServerStorage.Assets.Enemies.WildWest`: BandanaBandit,
  RodeoKid, SixShooter, DynamiteDan, BigBart. Each is an R15 Humanoid, tagged `Enemy`,
  and has:
  - Attributes `Slot`, `Archetype`, `MaxHealth`, `Speed`, `SpawnCost`, `Damage`,
    `HitboxWidth`, `HitboxHeight`, `FreezeScalar` (plus `ChargeSpeed` and
    `StaggerDamage` on Bart),
  - a `Hitbox` part,
  - **pre-built ragdoll `BallSocketConstraint`s, disabled**,
  - a red bandana ([[Art Direction]]).
- [x] **A saddlebag accessory** for the blueprint thief, and a Blueprint pickup template.
- [x] **`EnemyService`:**
  - the AI loop at 10–15 Hz, with behaviours Walker, Leaper, Shooter, Lobber and
    Charger,
  - disabled Humanoid states,
  - knockout → ragdoll (ownership to the nearest player, cap 12, 3 s fade),
  - below the track = knockout,
  - all per [[0006-humanoid-enemies-and-combat]].
- [x] **`SpawnService`**, or part of EnemyService: the timeline table above, read from a
  `Shared.Config.SpawnTimeline` ModuleScript (data only). It handles co-op scaling, the
  spawn-location rules, and Bart's solo intro.

### Session 5 — Co-op flow, HUD, run end
- [x] **`RunStateService`:** Lobby (Ready and countdown) → InTrain → Cleared or Wiped
  → Results → PLAY AGAIN. The state is the Attribute `RunState`. **Don't name it
  `RunService`**, which clashes with Roblox's own service.
- [x] **`SquadService`:** downed and bleed-out, revives through `RequestInteract`
  (the server picks the nearest downed teammate), interruption by damage, spectating
  and wipe detection.
- [x] **GUIs** built by hand in `StarterGui` with `ResetOnSpawn = false`, following the
  [Figma mockups](https://www.figma.com/design/dYELw7ZfOV3nZAh34vtCtL):
  - `HudGui`: the player panel (portrait, HP, **active weapon icon**), teammate cards,
    train progress ("TRAIN 1 · CABOOSE → ENGINE"), the revive prompt template, the
    "REACH THE ENGINE!" banner and the blueprint counter,
  - `TouchControlsGui`: ◀ ▶, JUMP, SHOOT, and a context button for Revive (≥ 48 pt),
  - `RunEndGui`: TRAIN CLEARED or SQUAD WIPED, with a per-player row template and
    PLAY AGAIN.

  The Mayhem ring and gadget fan come in M2.
- [x] **Controllers:** `HudController`, `TouchControlsController`, `RunEndController`.
  They only connect events and set text and visibility.

### Session 6 — Measure, tune, playtest
- [ ] Do a **multi-client test** (Studio → Test → Clients and Servers, 2–4 players)
  with the full timeline.
- [ ] Check the **performance budget**: ≤ 30 live enemies + 4 players + 12 ragdolls.
  Use the MicroProfiler and server stats. Record the results in this note and in
  [[0006-humanoid-enemies-and-combat]].
  - *First pass done (Studio, 1 client).* Server Heartbeat 1.6 ms and physics 2.75 ms on
    average with ~30 enemies, and the client held 60 fps. Server send is about 10 kbps per
    enemy (330 kbps at 31), which is the item to watch. Details are in
    [[0006-humanoid-enemies-and-combat]]. Re-check on a live server with 4 clients and a
    phone.
  - Ragdolls: the 12-body cap is enforced, but bodies already fading (0.4 s) and burst
    knockouts (Dan chains) briefly showed up to 19 bodies. That's fine for now.
- [ ] Do a **tuning pass** on the first-guess numbers. Record what changed and why.

## Systems involved (notes to create in `02 Systems/` as each is built)
- **Server:** ModeService, TrainService, CharacterService, CombatService,
  PickupService, EnemyService, SpawnService, RunStateService, SquadService, and
  Util.Guard.
- **Client:** InputController, CameraController, ParallaxController,
  EffectsController, HudController, TouchControlsController and RunEndController.

## Playtest questions (what M1 must answer)
1. Does side-on movement at 28 studs/s, with jumping between cars, feel good on PC and
   on touch?
2. Can you read every threat? Telegraphs, Six-Shooter bullets, dynamite, Bart's
   wind-up.
3. Do weapon crates create a good rhythm, or are they annoying? Should crates respawn
   faster or slower?
4. Is the damage scale right? The roster predicts about 48 s for one bandit to down
   Dash alone.
5. Is reviving fun and readable in 2–4 player co-op?
6. Does the Humanoid enemy budget hold? If not, the fallback in
   [[0006-humanoid-enemies-and-combat]] applies.

## Open questions
- ~~Should a crate also refill or reset anything (e.g. the rocket's cooldown)?~~
  **[decided 2026-10-16] No**, it only switches weapons.
- How should a downed player's camera spectate? Proposed: it follows the nearest
  living teammate. *(Built that way in Session 5; confirm it in the co-op playtest.)*

## Implementation notes
- **Session 1 (M0), 2026-10-13: done except Packages.** Built in place 71855801375130
  from [[M0 Bootstrap Code]]. A playtest prints `[Server] Run mode, 1 service(s)` and
  `[Client] Run mode, 0 controller(s)` with no errors. Collision groups, `StreamingEnabled
  = false` and Scriptable movement were checked in the Server datamodel. Signal and Trove
  aren't installed yet (nothing uses them). `Shared.Types` has no `InputState`, since
  `SetInput` sends scalars (ADR 0007). Systems: [[ModeService]], [[Guard]].
- **Session 2, 2026-10-13: done.** Greybox carriage templates, `Map.Run.Staging`
  (platform, `StagingSpawn`, buffer stop) and the `TrainStart` marker, plus five greybox
  Wild West background layers. Systems: [[TrainService]], [[CharacterService]],
  [[InputController]], [[CameraController]] and [[ParallaxController]]. A playtest checked
  the train build, speed, jump, spin, gap-fall recovery, teleport set-back, the Z lock, the
  camera and scrolling, with no script errors. Deferred, because they need later sessions:
  - the agent rig and the `Hitbox` part move to the Session 3 agent template, and so do
    gap-fall damage and sending `RequestSpin`,
  - touch input comes with `TouchControlsGui` (Session 5).
- **Session 3, 2026-10-13: done, except the mid-knockout crate drop** (no mids exist until
  Session 4).
  - Built: the Dash Daring R15 agent template with a Hitbox, both weapon templates, the
    WeaponCrate template, the effect templates and a query-only `Projectiles` collision
    group.
  - Systems: [[CombatService]], [[PickupService]] (+ PickupController and
    `Shared.WeaponCrates`) and [[EffectsController]]. [[CharacterService]],
    [[InputController]] and [[CameraController]] were extended.
  - The crate rules are built as proposed (personal crates, a 20 s respawn, and each train
    starting on the primary weapon).
  - A playtest against a temporary dummy enemy checked the rocket and rifle damage and
    cadence, release, the spin, gap-fall damage and a crate pickup, with no script
    errors.
- **Session 4, 2026-10-13: done.**
  - Built: five enemy templates (the Dash R15 rig reskinned, with ball sockets disabled and
    tunables as attributes), the Saddlebag prop, the Blueprint pickup, and the `EnemyBullet`,
    `Dynamite` and `Alert` effect templates.
  - Systems: [[EnemyService]] and [[SpawnService]], with `Shared.Config.SpawnTimeline`.
    Hooks were added to [[CombatService]] (`effect`, `newProjectileId`, `distanceTo`),
    [[CharacterService]] (`lockToPlane`), [[PickupService]] (`dropCrate`, `dropBlueprint`),
    `WeaponCrates` (dropped spots sort last) and [[EffectsController]] (`R` with a template,
    `P`, `A`, `N`).
  - Decisions made while building:
    - a charge stops at gaps and walls instead of jumping,
    - the off-train check uses feet height,
    - the "!" pop is the only telegraph for now,
    - Dan's thrown dynamite hurts only players, while his knockout blast also hurts
      enemies,
    - Bart's hitbox is 2.4 × 6.5 (not 5.7), to cover the 1.15× rig,
    - lights have `FreezeScalar` 1,
    - the Caboose roof was trimmed flush (it had a 1-stud overhang).
  - SpawnService starts itself 5 s after the first spawn, until RunStateService arrives
    (Session 5).
  - Playtests checked melee, bullets, dynamite, Bart's wind-up, charge, stagger and
    knockback, the ragdoll and its fade, the crate and blueprint drops, and a full timeline
    to `TimelineDone`. The console was clean. Details are in [[EnemyService]].
- **Session 5, 2026-10-13: done.**
  - Built: `HudGui`, `TouchControlsGui` and `RunEndGui` in `StarterGui`. The Figma file
    couldn't be read (Starter plan limit), so they follow [[Art Direction]] §10 as written.
  - Systems: [[RunStateService]], [[SquadService]] and [[HudController]] (+
    TouchControlsController and RunEndController).
  - Hooks:
    - `SpawnService.stop` (it no longer starts itself),
    - `EnemyService.clear`,
    - `PickupService.reset`,
    - knockout credit in `CombatService.damageEnemy`,
    - the touch, Interact (E) and downed handling in [[InputController]],
    - spectating in [[CameraController]].
  - Decisions made while building:
    - PLAY AGAIN needs every player and returns to a Lobby where everyone is already
      Ready (a 5 s countdown),
    - revives are a held Interact that resends `RequestInteract` every 0.3 s,
    - downed players lie down (PlatformStand),
    - the revive prompt is on screen, not a billboard,
    - the weapon shows as text.
  - A one-player playtest checked:
    - READY → countdown → ALL ABOARD,
    - live HUD health, weapon and progress,
    - a KO credited,
    - Health 0 → downed → SQUAD WIPED → the results screen,
    - PLAY AGAIN → a full reset → a new run,
    - the engine roof with the timeline done → TRAIN CLEARED → results,
    - a clean console.
  - Revives, bleed-out, spectating, the teammate cards and the touch controls are left for
    the Session 6 multi-client and device tests.

Related: [[Game Design Document]] · [[Wild West Enemies]] · [[Launch Agents]] · [[Art Direction]] · [[0004-single-place-hub-and-run-modes]] · [[0005-side-on-movement-and-camera]] · [[0006-humanoid-enemies-and-combat]] · [[0007-networking-and-remotes]] · [[0009-static-trains-scrolling-world]] · [[Home]]
