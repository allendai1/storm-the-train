---
tags: [reference, original-game]
status: reference
source: /Users/allen/re/storm-drain/unpacked (Storm the Train v1.7.4 Android APK, Games Faction 2016)
---
> Reference only: describes the **original 2016 mobile game**, not this Roblox project. Not design canon. See [[Original Game]].

# Storm the Train (2016, com.gamesfaction.stormthetrain): enemies, spawning and environments

Source: `assets/scripts/{environments,oriental,horror,future}.lua`, `assets/scripts/Enemies/*.lua`,
`assets/Locales/en-GB.locale`, file names in `assets/Models`, `assets/Music`, `assets/Sounds`,
`assets/Atlases/env_oriental_shared_hres.atlas`. `scripts/DB/` was **not** read (per brief).
Everything was read as data only; nothing from the APK was executed.

Confidence tags used below:
- **[data]**: read directly from a script/file.
- **[inferred]**: my interpretation of names and numbers. Treat it as a hypothesis.
- **[unknown]**: not in these files (most likely in `scripts/DB/` or native code).

---

## 0. TL;DR of the engine model

- **It's a 2D side-scroller.** The virtual screen is 1024x768 px. Parallax layer Y positions go up to 768, and the track layer sits at Y=683 **[data]**. Light enemies have 20x76 px hitboxes. The oriental engine sprite is 750x194 px, and a "250" flatbed sprite is 251x45 px **[data, atlas]**. So **carriage lengths 250 and 500 are pixel widths** (short and long cars).
- **There are three themes**, mapped as `oriental=1, horror=2, future=3` **[data]**. Each theme has exactly 10 enemy slots (`<prefix>_1.._10`), plus one shared hostage NPC (`npc_1`). Spawn tables never name an enemy directly. They use **slot indices 0-9**, which the loader maps to `ninja_N` / `horror_N` / `future_N` for the current environment **[data, spawnLoader]**. **One spawn script drives all three themes.**
- **Slot roles are fixed across themes [data + inferred from spawnGroups]:**

| Slot (ENEMY_ID) | File | Role |
|---|---|---|
| 0-3 | `_1`..`_4` | Light grunts (cost ~1.7-3). Make up the normal waves. |
| 4-6 | `_5`..`_7` | "Mid" enemies (cost 15). Also the **key holders** for hostage events, introduced one at a time. |
| 7-8 | `_8`, `_9` | **Bosses** (cost 40). |
| 9 | `_10` | **Boss-spawned minion** (`SPAWN_GROUP_BOSSSPAWN`). |
| — | `npc_1` | Hostage (`HOSTAGE_NEUTRAL`). |

- **Spawning works on a budget.** Each active spawn group spends a cost budget per wave and has a cap on the total cost of its enemies alive on the train. Both budget and cap interpolate from START to END values over the group's active time. Groups chain in sequence (`NEXT`). A group can also run sibling (child) groups in parallel, each with its own timer, budget and cap **[data]**.

---

## 1. Environments / themes

### 1.1 Overview

| Theme (env id) | Enemy prefix | Enemy family | HUD banner on approach **[locale]** | Music **[data, Music/]** | Sky regions **[data]** |
|---|---|---|---|---|---|
| Oriental (1) | `ninja_` | Ninjas/samurai | "NINJA HORDE!" | `theme_oriental.mp3` | `SKY_ORIENTAL` (rural), `SKY_ORIENTAL_NEW` (city) |
| Horror (2) | `horror_` | Zombies, skeletons, vampires, wolfman | "THE UNDEAD!" | `theme_horror.mp3` | `SKY_HORROR`, `SKY_HORROR_NEW` |
| Future (3) | `future_` | Robots | "EVIL ROBOTS!" | `theme_future.mp3` | `SKY_FUTURE`, `SKY_FUTURE_NEW` |

There is also `theme_main.mp3` (menus / home train, **[inferred]**). Boss SFX exist per theme in `Sounds/`: `{oriental,horror,future}_boss_{1,2}_{attack,die,taunt}.raw`.

The tutorial starts on the **horror** theme ("...ANOTHER PESKY ZOMBIE! SHOOT IT QUICK!"). Mission strings "REACH THE FUTURE TRAIN" and "REACH THE ORIENTAL TRAIN" mean you **progress through themes by jumping from train to train** **[locale]**.

`LOCKED_REASON_ENV_CHANGING = "ENVIRONMENT CHANGING"` means the environment switches mid-run during a transition. Gadgets are locked while that happens.

There are also seasonal reskins: commented-out **Christmas** regions (`SKY_XMAS1/2/3`, `christmas_*`, `christmas2_*` art) and **Halloween** hats on horror mids (`vampire_middle_hat_*`, `wolfman_middle_hat_1`, commented out) **[data]**.

### 1.2 Parallax/background construction (environment scripts)

The theme scripts only define **scenery**, not the train. Each theme has **2 regions** (visual variants). Each region has a sky and **7 parallax layers**:

| Layer | Meaning | Typical Y (px, 768-high screen) |
|---|---|---|
| B4 | Far background (mountains / city skyline) | 552-620 |
| B3 | Mid-far (rice fields / lantern sets / hills) | 325-621 |
| B2 | Mid (rail-side props, city). `nil` in horror 1 and future 1. | 600-768 |
| B1 | Near background strip (crops, fence, rail) | 600-621 |
| T | **Tracks** | 683 |
| F1 | Foreground 1 (fields, graves, signs) | 768 |
| F2 | Foreground 2 (big occluding props) | 400-768 |

Each layer is a weighted random pool of sprites. Each sprite has optional `scale`, `weight` (default 1) and a `min`/`max` gap in px between repeats. For example, oriental 2 F2 signs use `min=7000, max=10000` px gaps, so a foreground sign appears rarely. Oriental 1 B2 rail props use 1200-2048 px gaps with weight 3 **[data]**. `environments.lua` registers every sprite with `TerrainManager:SetFurniture(...)` and every region with `SetRegionSky` / `SetRegionLayerEntry` / `SetRegionLayerPos` **[data]**.

Scenery content per region **[data]**:

| Theme | Region 1 | Region 2 |
|---|---|---|
| Oriental | mountains, rice fields, rail props, crops, fields | city skyline, lantern sets, city, rail, signs |
| Horror | hills, fence, graves (no B2) | `horror_2_*` hills/trees/etc. (8 B4, 3 B3, 5 B2, 8 B1, 3 F1, 7 F2) |
| Future | city (11 B4, 13 B3), rail, signs (no B2) | `future_2_*` city, rail, signs |

**Scrolling speed is not in these files [unknown]**. The train's speed and scroll rate are presumably native code or DB.

### 1.3 How a train is assembled: carriage pieces (from `assets/Models`)

The same 37-piece kit exists for each theme (prefix `oriental_` / `horror_` / `future_`). **The assembly rules (order, count, lengths) are not in these scripts [unknown, probably DB/native].** The piece list:

| Category | Pieces | Notes **[inferred unless stated]** |
|---|---|---|
| Locomotive | `engine_1`, `engine_coal_1` | Engine plus coal tender. These form the front of every hostile train. The engine sprite is 750x194 px **[atlas]**. |
| Passenger coach | `coach_250_1`, `coach_250_rear_1`, `coach_500_1` | Short or long. `_rear` = variant used as the last car of the train. |
| Coach with crates | `coach_500_boxes_front_1`, `coach_500_boxes_rear_1/2` | Roof boxes, probably cover/platforms. Front and rear variants. |
| Closed coach | `coach_closed_500_1..6`, `coach_closed_500_rear_1..4` | Enterable interiors. The atlas has `coach_doors`, `coach_windows`, `bench`, `loo`. The mission "DIE INSIDE A CARRIAGE ON THE ORIENT EXPRESS" confirms you can go inside. |
| Weapons coach | `coach_weapons_500_front_1`, `coach_weapons_500_rear_1/2` | Atlas has `deco_weapon_1..4`. Probably where weapon crates spawn (mission "COMPLETE A TRAIN WITHOUT COLLECTING A WEAPON CRATE"). |
| Flatbed | `flatbed_250_1`, `flatbed_500_1/2` | Open platforms. |
| Freight | `freight_250_1/2`, `freight_500_1/2/3`, `freight_half_250_1`, `freight_half_500_1` | Boxcars with roofs (`freight_roof_250/500`, `freight_boxes_*` in atlas). "half" = half-height wall/cover. |
| Cannon freight | `freight_cannon_500_1/2` | Has a mounted cannon (`freight_cannon_1/2` sprites). Could be a hazard or a usable weapon **[unknown]**. |
| Prison (hostage) | `prison_1`, `prison_2`, `prison_2_rear_1`, `prison_3` | Atlas: `prison`, `prison_door`, `prison_backing`, `prison_flatbed_a/b/c`, `prison_rope_left/right`, `key_box_green`. The hostage event happens here. |
| Misc. (atlas only) | `pressure_pad` (+ clamps), `go_sign`, `stop_sign`, `ornament`, `lantern`, `tree`, wheels | The pressure pad is probably the "JUMP FROM HERE" take-off point to the next train (`EVENT_NTE_JUMP_INDI_ON`). Go/stop signs probably mark train start and end. |

**Player / home train ("EAGLE-7")**: `player_engine_1`, `player_engine_coal_1`, `player_flatbed_250_1`, `player_flatbed_500_1`, `player_freight_250_1`, `player_freight_half_250_1`. Checkpoint cars are `player_checkpoint_bank`, `_barracks`, `_health`, `_missions` and `_surplus` (Vault shop, agent recruiting/upgrades, healing station, missions board, and the "specials" store that needs no blueprints) **[data + locale]**.

**Other vehicles:**
- `helicopter_player`
- `challenge_chopper` (daily challenge chains)
- `vehicle_ball`: probably the **CDW = "Cylindrical Death Weapon"**, a rolling-ball minigame where you "TAP ANYWHERE TO JUMP. AVOID MISSILES AND OBSTACLES" **[locale]**
- Jetpack minigame ("TAP ANYWHERE TO BOOST")

`assets/Patterns/` holds `cdw_{missile,obstacle}_levelN_M.tga` and `jp_{missile,obstacle}_levelN_M.tga` (levels 0-5). These are **bitmap-encoded obstacle/missile layouts** for those two minigames **[inferred]**.

### 1.4 Run structure (from locale)

This is the per-run event flow. Event keys come from the locale **[locale]**; the ordering is **[inferred]**.

1. **Hostile train.** You fight along the carriages. Events that can occur on a train:
   - `EVENT_BOSS`: "KILL THE BOSS"
   - `EVENT_HOSTAGE`: "FREE THE HOSTAGE" / "FIND THE KEYS"
   - Blueprint thief: an enemy wears a blueprint mesh, and "THE ENEMIES STOLE OUR BLUEPRINTS... THERE'S ONE. GET HIM!"
2. **Next-train event (`NTE`).** "NEXT TRAIN" → "JUMP FROM HERE" to the next train. The next train can be a different theme; the banner announces it. There's a mission "COLLECT ALL COINS BETWEEN TWO TRAINS" and a lock reason "BETWEEN TRAINS".
3. **Checkpoint.** "LEAP TO EAGLE-7" takes you to the home train: shop, heal, upgrade, hand in blueprints, equip up to 3 boosters "FOR THE DURATION OF THE NEXT TRAIN".
4. **Alternate segments.** CDW ride ("RIDE THE CYLINDRICAL DEATH WEAPON", "SPEEDING UP") and jetpack. Both are distance-based ("TRAVEL %s METERS").
5. **Survival / ESE (Endless Survival Event).** "SURVIVAL MODE - ONE HIT DEATH", "SURVIVE %i WAVES", "WAVE %i/%i". Uses `SPAWN_GROUP_SURVIVAL` (section 3.5).

---

## 2. Enemies

### 2.1 Field glossary (EnemySetup keys)

| Key | Meaning |
|---|---|
| `ENEMY_HEALTH` | Hit points **[data]**. |
| `ENEMY_MOVESPEED` | px/s **[inferred]**. Many have a `-- was N` comment: everything was slowed in a balance pass, typically 225 → 140-170 for lights. |
| `ENEMY_WEIGHT` | Mass. Probably knockback / launch resistance **[inferred]**. |
| `ENEMY_BOUNDINGBOX_X/Y` | Hitbox in px. |
| `ENEMY_SPAWN_COST` | **Budget cost used by the spawner** (section 3). |
| `ENEMY_FREEZE_SCALAR` | Multiplier on freeze effects: 1 = light, 0.6 = mid, 0.3 = boss. |
| `ENEMY_FLEE_ON_FIRE` | Lights run around in panic when set on fire (`ON_FIRE` anim `n_run_fire`). |
| `ENEMY_DAMAGE_TIMER` | Probably attack cooldown / hit interval in seconds **[inferred]**. Values: 0.05 (exploding minion), 0.3, 0.5, 0.75, 1. |
| `AGILE_SPINJUMPTIME` | For `AGILE_ENEMY`: interval between spin-jump attacks in seconds **[inferred]** (1.5-3). |
| `UNDEAD_REVIVE_PROBABILITY` / `UNDEAD_DEAD_TIME` | % chance a "dead" undead gets back up, and seconds it lies down first. The player must gib/smash the corpse to stop it (mission: "SMASH %s CORPSES USING SPIN ATTACKS OR A CORPSE SMASHER DRONE"). |
| `BERSERK_HEALTH`, `BERSERK_DIST`, `BERSERK_OFFSET_X/Y`, `BERSERK_SIZE_W/H`, `BERSERK_EFFECT` | Berserkers. `BERSERK_DIST=512` px is probably the trigger range for the charge. `BERSERK_HEALTH` (30 mid / 100 boss) plus an offset/size box looks like a **separate berserk meter or weak-point box drawn above the head** **[unclear]**. Effect `EFFECT_FRENZY_1`. |
| `SHIELD_HEALTH`, `SHIELD_OFFSET`, `SHIELD_SIZE_W/H`, `SHIELD_GIB_TYPE` | A breakable frontal shield with its own HP and hitbox (10 px wide). Once broken, the enemy switches to its "without shield" archetypes. Gib type: 0 = wood, 1 = metal, 2 = heavy **[inferred]**. |
| `TELEPORT_INTERVAL_MIN/MAX`, `TELEPORT_TIME`, `TELEPORT_RECOVER_TIME`, `HOVER_INTERVAL_MIN/MAX` | Teleporters (vampires) blink every 3-7 s. The vampire boss also hovers and throws from the air every 5-8 s. |
| `ENEMY_BEAM_LEAP_MIN/MAX` | 0.5-1.5 s. Bosses that leap. Probably a reaction delay before leaping when hit by sustained beam fire **[inferred]**. |
| `ENEMY_BLIND_DISTANCE` | 400 px on all bosses (was 250 before v1.2). Probably the range at which the boss notices / engages the player **[inferred]**. |
| `ENEMY_TAUNT`, `ENEMY_BOSS_SOUND_*` | Boss speech bubbles (locale) and SFX. |
| `ENEMY_MISSION_HANDLE` | Mission counter tag: `EMH_YELLOW_NINJA`, `EMH_ZOMBIE`, `EMH_HOVERING_ROBOT`, `EMH_WOLFMAN`. |

**Weapon IDs** (`ENEMY_PRIMARY/SECONDARY/DEATH/LEAP_WEAPON`) name weapon definitions. **Damage numbers are not in these files [unknown → DB]**. Score and coin rewards per enemy are **not present either [unknown]**.

**Archetypes.** An enemy can have several visual/behaviour archetypes:
- Melee vs ranged variants
- With or without shield
- Calm vs berserk run anims

The loader also auto-clones every base archetype into two extra variants:
- **`blueprint`**: the enemy wears a stolen-blueprint mesh. Killing it drops a blueprint.
- **`keyBox`**: the enemy carries a key box (`graham_char_oriental_key_box.png` / `*_key_box_green`). This is the hostage-event key holder.

Blueprint carriers are lights and mids. Key boxes exist only on **mids** (`_5`..`_7`) **[data]**.

**Behaviour types (`EnemyType`, AI class) [data names, inferred behaviour]:**

| Type | Behaviour |
|---|---|
| `NORMAL_ENEMY` | Walks up and attacks. Uses its secondary (ranged) weapon if it has one. |
| `AGILE_ENEMY` | Melee plus periodic **spin-jump** attack (`SPIN` anim) that crosses gaps and flips over the player. |
| `COWARD_ENEMY` | Keeps distance and fires ranged (fireworks). |
| `UNDEAD_ENEMY` | Can revive after "death" unless gibbed. |
| `BERSERKER_ENEMY` / `BERSERKER_BOSS` | Normal approach, then a `BEHAVIOUR` wind-up anim, then a fast berserk charge (`n_run_berserker_1`, frenzy effect). |
| `SHIELD_ENEMY` / `SHIELD_BOSS` | Frontal shield blocks shots until broken. Melee up close, ranged otherwise. |
| `TELEPORT_ENEMY` / `TELEPORT_BOSS` | Blinks around the carriage. The boss also hovers and throws stakes. |
| `HOVER_ENEMY` | Floats, so it's probably unaffected by gaps or ground hazards. |
| `SUICIDE_ENEMY` | Runs up and does a **suicide leap** (`r_suicide_1/2`) that explodes. Also explodes on death, which can kill other enemies (mission "KILL %s ENEMIES BY TRIGGERING THE EXPLODING ROBOT"). |
| `SPAWN_BOSS` / `FUTURE_SPAWN_BOSS` | Summons slot-9 minions (`_10`). |
| `HOSTAGE_NEUTRAL` | Hostage NPC. |

Every humanoid also has `CELEBRATE_A/B` (when the player dies), `DEATH_A/B`, and `DAMAGE_BEAM` / `DAMAGE_GUN` hit-react anims. Bosses add `TAUNT`, `LEAP` and `LEAP_ATTACK`.

### 2.2 Oriental: ninjas

| Slot | File | Name **[inferred from art]** | Type | HP | Speed (was) | Weight | Hitbox | Cost | Weapons | Special |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | ninja_1 | **Yellow ninja**, twin sai | NORMAL | 25 | 140 (225) | 1 | 20x76 | 3 | LIGHT_MELEE | flees on fire; mission tag `EMH_YELLOW_NINJA` |
| 1 | ninja_2 | Kama ninja | AGILE | 30 | 160 (225) | 1 | 20x76 | 3 | LIGHT_MELEE | spin-jump every 2.8 s (was 2) |
| 2 | ninja_3 | Katana ninja | AGILE | 40 | 170 (225) | 1 | 20x76 | 3 | LIGHT_MELEE | spin-jump 3 s; 2 archetypes: katana melee / sword stowed + **ranged throw** (`n_attack_range_1`) |
| 3 | ninja_4 | **Firework ninja** (rockets on back) | COWARD | 30 | 160 (205) | 1 | 20x76 | 3 | FIREWORK; death: FIREWORK_DEATH | keeps distance; **explodes on death** |
| 4 | ninja_5 | Balisong mid ninja | AGILE | 160 | 170 (210) | 1.6 | 25x80 | 15 | MEDIUM_MELEE | spin-jump 2.8 s; dmg timer 0.75; freeze 0.6; **key holder** |
| 5 | ninja_6 | Butterfly-sword berserker | BERSERKER | 160 | 160 (200) | 2 | 36x85 | 15 | MEDIUM_MELEE | berserk HP 30 (was 50), dist 512; **key holder** |
| 6 | ninja_7 | Shield samurai (big katana) | SHIELD | 160 | 180 (220) | 2 | 36x85 | 15 | MEDIUM_MELEE + MEDIUM_FIREBALL | shield 90 HP (was 125), 10x64, gib type 0; 4 archetypes (shield × melee/ranged); **key holder** |
| 7 | ninja_8 | **Boss: twin-katana berserker** | BERSERKER_BOSS | **600** (800 pre-1.2) | 250 | 2.5 | 35x140 | 40 | ORIENTAL_BOSS_MELEE + leap: BOSS_LEAP_ATTACK | berserk HP 100, dist 512; blind dist 400; freeze 0.3; taunt NINJA_TAUNT; SFX oriental_2 |
| 8 | ninja_9 | **Boss: dao + great shield** | SHIELD_BOSS | **550** (650) | 180 | 2.8 | 40x140 | 40 | ORIENTAL_BOSS_MELEE + NINJA_BOMB + leap: BOSS_LEAP_ATTACK | shield **250** (was 400), 10x90, gib type 2; beam-leap 0.5-1.5 s; 4 archetypes; SFX oriental_1 |
| 9 | ninja_10 | Fast kama ninja (minion) | AGILE | 30 | **225** | 1 | 20x76 | 3 | LIGHT_MELEE | spin-jump 1.5 s; dmg timer 0.75. The oriental bosses aren't spawn-type, so it's **unclear when this is used**. |

Models: `ninja_light.cm` (slots 0-3 and 9), `ninja_medium.cm` (4-6), `ninja_heavy.cm` (bosses).

Ninja boss taunts: "NOW YOU DIE!", "YOU'RE NO MATCH FOR ME", "THE SAMURAI WILL WIN!"

### 2.3 Horror: undead

| Slot | File | Name **[inferred]** | Type | HP | Speed (was) | Weight | Hitbox | Cost | Weapons | Special |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | horror_1 | **Zombie** (head 1) | UNDEAD | 20 | 90 (120) | 1 | 20x76 | 1.7 | LIGHT_MELEE | **revive 33 %**, 1.5 s down; green blood FX; tag `EMH_ZOMBIE` |
| 1 | horror_2 | Zombie (head 2, tougher) | UNDEAD | 40 | 110 (200) | 1.4 | 20x76 | 1.7 | LIGHT_MELEE | **revive 75 %**, 1.5 s; dmg timer 1; tag `EMH_ZOMBIE` |
| 2 | horror_3 | Skeleton swordsman | UNDEAD | 35 | 90 (160) | 1 | 20x76 | 2 | LIGHT_MELEE | revive 70 %, 2 s; dmg timer 0.5; bone-hit FX |
| 3 | horror_4 | Helmeted skeleton, skull thrower | NORMAL | 45 | 110 (205) | 2 | 20x76 | 2.5 | LIGHT_MELEE + **SKULL** (ranged) | dmg timer 0.3; has revive fields/anim but type is NORMAL (`UNDEAD_REVIVE_PROBABILITY=60` probably ignored) |
| 4 | horror_5 | **Vampire** (teleporter) | TELEPORT | 160 | 170 (200) | 2 | 25x80 | 15 | MEDIUM_MELEE | teleports every 3-6 s, 0.8 s blink, 0.4 s recover; **key holder** |
| 5 | horror_6 | **Wolfman** berserker | BERSERKER | 160 | 160 (200) | 2 | 36x95 | 15 | MEDIUM_MELEE | berserk HP 30, dist 512; tag `EMH_WOLFMAN`; **key holder** |
| 6 | horror_7 | Vampire stake-thrower | NORMAL | 160 | 180 (190) | 2 | 36x85 | 15 | MEDIUM_MELEE + **MEDIUM_STAKE** | shield fields present but commented "this isn't used!"; **key holder** |
| 7 | horror_8 | **Boss: vampire lord** | TELEPORT_BOSS | **600** (800) | 155 | 2.8 | 35x140 | 40 | HORROR_BOSS_MELEE + **BOSS_STAKE** | teleport 4-7 s (0.8 s / 0.3 s recover); **hovers** every 5-8 s and throws stakes from the air (`hover_throw_1`); blind 400; SFX horror_2 |
| 8 | horror_9 | **Boss: skeleton king** | SPAWN_BOSS | **600** (800) | 250 | 2.8 | 40x140 | 40 | HORROR_BOSS_MELEE + leap: BOSS_LEAP_ATTACK | **summons slot-9 skeletons**; beam-leap 0.5-1.5 s; SFX horror_1 |
| 9 | horror_10 | Summoned skeleton | UNDEAD | 25 | 160 | 1 | 20x76 | 2 | LIGHT_MELEE | revive 60 %, 2 s; dmg timer 0.75 |

Models:
- `zombie_light.cm` (slots 0-1)
- `skeleton_light.cm` (2, 3, 9)
- `vampire_medium.cm` (4, 6)
- `wolfman_medium.cm` (5)
- `vampire_heavy.cm` (7)
- `skeleton_heavy.cm` (8)

Taunts:
- Vampire: "BLOOD! BLOOD!", "YOU CAN'T KILL THE DEAD!"
- Skeleton: "YOU WILL SUFFER!", "YOU WILL NEVER DESTROY ME!"

### 2.4 Future: robots

| Slot | File | Name **[inferred]** | Type | HP | Speed (was) | Weight | Hitbox | Cost | Weapons | Special |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | future_1 | Walker robot | NORMAL | 20 | 110 (200) | 1 | 30x86 | 1.7 | LIGHT_MELEE | spark-hit and explode FX |
| 1 | future_2 | **Hover robot** (melee) | HOVER | 30 | 150 (225) | 1 | 20x84 | 3 | LIGHT_MELEE | tag `EMH_HOVERING_ROBOT` |
| 2 | future_3 | Hover robot (beam) | HOVER | 40 | 150 (225) | 1 | 20x84 | 3 | LIGHT_MELEE + **LIGHT_BEAM** | 2 archetypes melee/ranged; tag `EMH_HOVERING_ROBOT` |
| 3 | future_4 | **Bomb robot** | SUICIDE | 18 | 130 (200) | 1 | 30x86 | 3 | SUICIDE (primary and death) | suicide leap; explodes when killed (chain kills) |
| 4 | future_5 | Agile mid robot | AGILE | 160 | 170 (210) | 2 | 30x112 | 15 | MEDIUM_MELEE | spin 2.8 s; **key holder** |
| 5 | future_6 | Berserker mid robot | BERSERKER | 160 | 160 (200) | 2 | 36x100 | 15 | MEDIUM_MELEE | berserk HP 30, dist 512; **key holder** |
| 6 | future_7 | Shield mid robot | SHIELD | 160 | 180 (220) | 2 | 40x112 | 15 | MEDIUM_MELEE + **MEDIUM_BEAM** | shield 90, 10x74, gib type 1 (metal); 4 archetypes; **key holder** |
| 7 | future_8 | **Boss: heavy mech, minion-thrower** | FUTURE_SPAWN_BOSS | **700** (1300) | 225 | 2.8 | 50x185 | 40 | FUTURE_BOSS_MELEE + leap: FUTURE_LEAP_ATTACK | `BEHAVIOUR` = `r_throw_1/2`, i.e. **throws slot-9 mini-robots** (its gib set includes 3× `gibs_robot_10_head`); beam-leap 0.5-1.5; SFX future_2 |
| 8 | future_9 | **Boss: berserker with mega-gun** | BERSERKER_BOSS | **700** (1100) | 250 | 2.8 | 40x180 | 40 | FUTURE_BOSS_MELEE + **FUTURE_BOSS_MEGAGUN** | berserk HP 100 (box 90x45), dist 512; archetype 2 = berserk run + ranged; SFX future_1 |
| 9 | future_10 | Thrown mini-robot | NORMAL | 20 | **250** | 1.5 | 20x76 | 2 | LIGHT_MELEE; death: **SUICIDE** | dmg timer 0.05; explodes on death |

Models:
- `robot_1.cm` (slots 0 and 9)
- `robot_2.cm` … `robot_9.cm` (one per remaining slot)
- `robot_7.cm` is the shield robot

Robot taunts: "ACTIVATING KILL ALGORITHMS", "BIDDY BIDDY BIDDY", "KILL ALL HUMANS"

### 2.5 Cross-theme stat bands (design takeaway)

| Tier | HP | Speed px/s | Spawn cost | Freeze scalar | Notes |
|---|---|---|---|---|---|
| Light | 18-45 | 90-170 (themes differ: horror slow 90-110, ninja fast 140-170) | 1.7-3 | 1.0 | flee when burning; die in a few hits |
| Mid / key holder | 160 (all) | 160-180 | 15 | 0.6 | one gimmick each: agile/teleport, berserk, shield/ranged |
| Boss | 550-700 (+ shield 250 or berserk 100) | 155-250 | 40 | 0.3 | leap attack, taunts, special DOT FX, 400 px aggro |
| Boss minion | 20-30 | 160-250 | 2-3 | 1.0 | fast, often explosive or reviving |

There's a **v1.2 balance pass**: boss HP was cut about 25-45 %, shields were nerfed, and lights were slowed by about 30-40 %. The original numbers felt too hard.

### 2.6 Gibs

Each enemy defines:
- `genericGibs`: scattered chunks with a repeat count.
- `uniqueGibs`: specific parts, each with a launch `offset` (height in px where it spawns) and a `force` multiplier.

Examples:
- Ninja light: 2× each of 3 flesh chunks, 1 heart, 3 bones, plus skull (offset 40, force 2), brain, body, 2× limbs and **its own weapon** (2× sai/kama).
- Bosses: heavy skull at force 4, and the future boss body at **force 12**.

Theme FX:
- Ninjas: red blood.
- Zombies: green blood (`EFFECT_DAMAGE_GREEN_BLOOD`, `EFFECT_GIB_GREEN_BALL`).
- Skeletons: bone hit (`EFFECT_SKELETON_HIT`).
- Robots: sparks / explosion (`EFFECT_ROBOT_HIT_V1`, `EFFECT_ROBOT_EXPLOSION_V1`, `EFFECT_ROBOT_BLOOD_SPLAT` for mids and bosses).

`EE_BALL_GIB` is the gib effect used when killed by the **ball (CDW / `vehicle_ball`)**. Gibbing is a core feedback loop:
- Undead must be gibbed to stay dead.
- Key holders must be **smashed** after death to release the key ("DEAD KEY HOLDER — SMASH HIS BODY").
- There are spin-attack corpse-smash missions.

### 2.7 NPC / hostage and other actors

- **`npc_1`, the hostage**: `HOSTAGE_NEUTRAL`, 25 HP, speed 200, cost 0.1, model `hostage_1.cm`. Anims are idle/run/jump only. Speech: "HELP!!!" and, when freed, "YAY! I'M FREE".
  - **Hostage event flow [locale]**: "FREE THE HOSTAGE" → "FIND THE KEYS" → a **KEY HOLDER** mid (slots 4-6 via `SPAWN_GROUP_KEYHOLDER = {4,5,6}`, keyBox archetype) → kill it → "DEAD KEY HOLDER: SMASH HIS BODY" → "KEY: GRAB THIS" → "HOSTAGE: RELEASE THIS GUY" at the prison carriage.
  - It's unclear whether the hostage can be killed by enemies or the player. It has 25 HP and a gib sound, so probably yes.
- **Blueprint thieves**: any light or mid can spawn in its `blueprint` variant (tutorial taunt "FINDERS KEEPERS!"). Blueprints are dropped off at Eagle-7 to unlock shop items.
- **Player-side actors (models)**: 13 agents:
  - Graham, Dino Graham, Mason, Kitty Mason, Carrera, Carrera Bear, Razor/Rogue, Dead Zed, Wonder/Cowgirl, Wei, Hal, Bingo Bango, Bob
  - All equipped agents **share one health pool**, and you swipe to switch between them.

  Player gadgets (filled by the **Mayhem** meter):
  - 3 mech suits: `chr_mechDamage`, `chr_mechDefence`, `chr_mechHeal`
  - Drones: turret, defender, smasher, melee, freeze, healer
  - Airstrike

---

## 3. Spawning system (spawnGroups.lua / spawnLoader.lua)

### 3.1 Data model **[data, from the header comment]**

| Field | Meaning |
|---|---|
| `SPAWN_ENABLE_TIME` | Seconds this group stays active before handing over to the next group. |
| `SPAWN_WAVE_TIME` | Seconds between waves. In survival, enemies spawn **one at a time at this rate**. |
| `SPAWN_WAVE_START_MIN/MAX` → `SPAWN_WAVE_END_MIN/MAX` | **Cost** to spend per wave, a random value in [min, max]. Lerps from START to END over the group's lifetime. |
| `SPAWN_CAP_START` → `SPAWN_CAP_END` | Max total **cost** of this group's enemies alive on the train. Lerps over the lifetime. |
| `ENEMY_ID` | Pool of slot IDs (0-9). The spawner picks from the pool **[inferred: random with replacement]**. |
| `SIBLING_NODE` | A child group that runs **in parallel** with its own wave timer, budget and cap. Can be nested (survival groups 31 and 37 have 3 parallel layers). |
| `SPAWN_FLAG_SINGLE_MID = n` | Overrides `ENEMY_ID`: spawn only the n-th mid. The 3 mids (slots 4-6) are **shuffled into a random order per run** (`SpawnData::Reset()`). |
| `SPAWN_FLAG_PREV_MID = n` | Overrides `ENEMY_ID`: any of mids 1..n (those already introduced). |
| `SPAWN_FLAG_BOSS = 1` | Survival only: boss group, a single wave. |
| `SPAWN_FLAG_ESE_DIFFICULTY = d` | Survival only: "any difficulty above this number will skip this node". This lets one table serve 3 difficulty tiers (0-2). |

Group lists:
- `SPAWN_GROUP_NORMAL`: the main hostile-train ramp
- `SPAWN_GROUP_BOSS = {7,8}`
- `SPAWN_GROUP_BOSS_EXTRA`: adds that run during a boss fight
- `SPAWN_GROUP_KEYHOLDER = {4,5,6}`
- `SPAWN_GROUP_BOSSSPAWN = {9}`
- `SPAWN_GROUP_SURVIVAL` (ESE)
- `SPAWN_GROUP_TIME_CHALLENGE`

**Worked example of cost math.** Ninja lights cost 3, so the intro's cap of 3 means **exactly one ninja on the train at a time**, rising to 2 by 15 s (cap 6). Zombies cost 1.7, so horror's intro also gets one zombie at a time (3.4 > 3), then 3 zombies at cap 6. **Cheaper horror lights mean bigger crowds of slow enemies; ninjas are fewer and faster.** Each mid costs 15, so "wave 16 / cap 17-18" means **exactly one mid alive**, "cap 36-40" means 2 mids, and cap 60 means 4.

### 3.2 SPAWN_GROUP_NORMAL (difficulty curve, theme-agnostic)

The group labels and comments are the designers' own. "Start" is the elapsed time noted in the file's comments. The actual sum of enable times differs (see notes).

| # | Start (s, per comment) | Enable s | Root: wave every s, cost start→end, cap start→end, pool | Sibling (parallel) | Designer comment |
|---|---|---|---|---|---|
| Intro | 0 | 15 | 0.6 s; 3→4; cap 3→6; {0} | — | intro |
| 1 | 15 | 30 | 2.6 s; 3→4; cap 4→5; {0} | 3 s; 3; cap 3; {1} | "Introduction of second mob, groups split for even distribution" |
| 2 | 45 | 30 | 2.5 s; 4→4-5; cap 5→6; {0,1} | 2.8 s; 4; cap 5; {2} | "combine first two... introduction of the third enemy" |
| 3 | 75 | 45 | 2.5 s; 4-5→6-8; cap 6→8; {0,1,2} | 2.4 s; 4; cap 4; {3} | "Introduction of the fourth enemy, ramp slows down drastically" |
| 4 | 120 | 1 | 0.1 s; 16; cap 17; **SINGLE_MID 1** | — | "Introduction to medium enemies, light enemies stop spawning" |
| 5 | 130 | 15 | 1.8 s; 3-7; cap 9; {0-3} | — | "Single wave after 1st mid kill" |
| 6 | 145 | 40 | 5 s; 16; cap 17; **PREV_MID 1** | 0.8 s; 2-4→5-8; cap 5→8; {0-3} | "Gradual ramp of light enemies with irregular spawning of mids" |
| 8 | 185 | 1 | 0.1 s; 16; cap 18; **SINGLE_MID 2** | — | new mid; lights stop |
| 9 | 200 | 15 | 1.5 s; 5-8; cap 6→10; {0-3} | — | after mid kill |
| 10 | 215 | 40 | 8 s; 16; cap 18; PREV_MID 2 | 0.7 s; 6-9→9-13; cap 10→15; {0-3} | ramp |
| 11 | 255 | 1 | 0.1 s; 16; cap 18; **SINGLE_MID 3** | — | third mid |
| 12 | 270 | 60 | 5 s; 16→16-40; cap 36→40 (2 mids); PREV_MID 3 | 1.7 s; 2-4→3-6; cap 6→8; {0-3} | ramp |
| 13 | 330 | 20 | 0.8 s; 4-8→8-16; cap 12→22; {0-3} | — | "Tons of light enemies for a short burst" |
| 14 | 350 | 150 | 3.25 s; 16; cap 25→40; PREV_MID 3 | 1 s; 3-4.5; cap 8→12; {0-3} | "faster spawning, smaller waves, enemies won't stay dead long" |
| 15 | 475 | 250 | 3 s; 16; cap 35→60; PREV_MID 3 | 0.8 s; 2-4→3-5; cap 6→10; {0-3} | "Even shorter respawn times" |
| 15b | 675? | 250 | 2.5 s; 16; **cap 60** (4 mids); PREV_MID 3 | 0.8 s; 3-5; cap 10→20; {0-3} | final plateau (last group; comment "-- 675") |

Shape of the curve:
- About 2 minutes of light-only escalation, introducing one new light type every 30-45 s.
- Then each **mid is introduced alone**, with lights paused (a mini-boss beat).
- Then a 15 s light breather, then a 40-60 s ramp with that mid recurring.
- Repeat for mid 2 and mid 3, a 20 s light swarm, then long plateaus where mids and lights respawn quickly.

Unclear points:
1. Is this timeline **per hostile train** or **per run**? At about 11-16 min total it's long for one train. It's probably per-run elapsed combat time, with trains and checkpoints interleaved **[unknown]**.
2. The comment start times assume each SINGLE_MID group lasts about 10-15 s, although `SPAWN_ENABLE_TIME = 1`. The engine probably **waits for the introduced mid to die** before advancing (comment: "Single wave after 1st mid kill") **[inferred]**.
3. Group "14" lasts 150 s but the next comment says 475 (350+125). The comments are slightly stale.
4. Caps look **per group node** (siblings have their own caps).

### 3.3 Boss fights

- `SPAWN_GROUP_BOSS[1] = {7, 8}`: one of the two theme bosses (random **[inferred]**).
- `SPAWN_GROUP_BOSS_EXTRA` runs alongside the boss in two stages. The second stage probably starts at a boss HP threshold or after the first **[unknown]**.
  - Stage 1: a wave every 10 s, cost 2-3, cap 4, pool {0,1}
  - Stage 2: a wave every 8 s, cost 3-5, cap 6, pool {0-3}
- `SPAWN_GROUP_BOSSSPAWN[1] = {9}`: the summoned minion type (skeletons from the skeleton king, thrown mini-robots from the future mech).
- Boss placement on the train is **not in these files [unknown]**. Locale: "KILL THE BOSS" event with a "BOSS" off-screen indicator.

### 3.4 Key holders

`SPAWN_GROUP_KEYHOLDER[1] = {4,5,6}`: the hostage event spawns one mid in its keyBox variant.

### 3.5 Survival / ESE ("SURVIVAL MODE - ONE HIT DEATH")

Here `SPAWN_WAVE_START_MIN` is the **number of enemies in the wave** (the comment says "Number of enemies till next wave"), spawned one at a time every `SPAWN_WAVE_TIME`. There are 38 groups (0-37). Difficulty d ∈ {0,1,2}: a node is **skipped if the current difficulty > its flag**. Nodes flagged 2 are therefore always played; nodes flagged 0 only on the easiest setting. Also, in group 3 the difficulty flag is outside `SPAWN_DATA` (likely a bug, so it's ignored).

| Grp | Spawn interval s | Count | Pool | Sibling (interval, count, pool) | Diff flag |
|---|---|---|---|---|---|
| 0 | 0.6 | 3 | {0,1} | — | 0 |
| 1 | 0.4 | 3 | {0,1} | — | 1 |
| 2 | 0.5 | 4 | {0,1,2} | — | 2 |
| 3 | 0.4 | 4 | {0-3} | — | (misplaced 0) |
| 4 | 0.5 | 5 | {0-3} | — | 1 |
| 5 | 0.5 | 6 | {0-3} | — | 2 |
| 6 | 0.5 | 4 | {2,3} | — | 0 |
| 7 | 0.5 | 2 | {0-3} | 0.11 s, 1, mids | 1 |
| 8 | 0.75 | 5 | {0-3} | 1.5 s, 1, mids | 2 |
| 9 | 1.5 | 2 | {0-3} | 1.5 s, 2, mids | 1 |
| 10 | 0.2 | 1 | **boss** {7,8} | — | 2 |
| 11 | 1.5 | 3 | mids | — | 1 |
| 12 | 1 | 6 | {0-3} | 2 s, 2, mids | 2 |
| 13 | 2.5 | 3 | {0-3} | 2.5 s, 3, mids | 1 |
| 14 | 0.6 | 13 | {0-3} | — | 2 |
| 15 | 0.4 | 8 | {0-3} | 1 s, 2, mids | 1 |
| 16 | 0.5 | 13 | {0-3} | — | 2 |
| 17 | 1 | 10 | {0-3} | 2 s, 3, mids | 1 |
| 18 | 0.75 | 20 | {0-3} | — | 2 |
| 19 | 2 | 6 | mids | — | 2 |
| 20 | 2.5 | 2 | **2 bosses** | — | 2 |
| 21 | 1 | 16 | {0-3} | 3 s, 5, mids | 2 |
| 22 | 0.66 | 12 | {0-3} | 2 s, 4, mids | 2 |
| 23 | 0.3 | 25 | {0-3} | — | 2 |
| 24 | 1.6 | 8 | mids | — | 2 |
| 25 | 0.5 | 20 | {0-3} | 2.5 s, 5, mids | 2 |
| 26 | 3 | 2 | **2 bosses** | 2.5 s, 10, lights | 2 |
| 27 | 0.7 | 30 | {0-3} | 1.4 s, 15, mids | 2 |
| 28 | 0.4 | 40 | {0-3} | — | 2 |
| 29 | 0.6 | 20 | {0-3} | 0.8 s, 15, mids | 2 |
| 30 | 0.6 | 20 | mids | — | 2 |
| 31 | 2 | 2 | **2 bosses** | 1 s, 30, lights → nested 3 s, 10, mids | 2 |
| 32 | 0.5 | 40 | {0-3} | 1 s, 20, mids | 2 |
| 33 | 0.2 | 50 | {0-3} | — | 2 |
| 34 | 0.3 | 30 | {0-3} | 0.7 s, 20, mids | 2 |
| 35 | 0.4 | 30 | mids | — | 2 |
| 36 | 0.3 | 30 | {0-3} | 0.7 s, 20, mids | 2 |
| 37 | 2 | 3 | **3 bosses** | 0.7 s, 50, lights → nested 2 s, 20, mids | 2 |

Pattern:
- Boss waves come every 5-6 waves (10, 20, 26, 31, 37), escalating from 1 to 2 to 3 bosses.
- Light waves grow from 3 to 50.
- Mid-only waves come right before boss waves (19, 24, 30, 35).
- **Daily challenge** versions: "%s WAVES AGAINST THE UNDEAD / NINJAS / ROBOTS. PLAYING AS %s."

### 3.6 Time challenge (`SPAWN_GROUP_TIME_CHALLENGE`)

This is one 60 s group:
- Lights {0-3}: a wave every 0.1 s, budget 3-5 → 5-10, cap 6 → 14.
- Sibling mids: budget 15 → 30, cap 20 → 50, so 1 → 3 mids alive.

---

## 4. Core gameplay rules revealed (mostly locale) **[locale unless noted]**

- **Controls**: MOVE LEFT / MOVE RIGHT / JUMP / SHOOT / ENTER (go into carriages) / TAP; swipe to switch agent. There are no lanes: it's a **single horizontal plane along the train roof and interior**, plus jumping between cars and trains.
- **Jumping between trains** is a scored metric ("MAKE %s TRAIN JUMPS"). Coins sit in the gap between trains.
- **Mayhem meter**: killing enemies fills it ("KILLING ENEMIES POWERS YOUR MAYHEM SYSTEM"). At full mayhem you get a **free gadget** (mech suit / drone / airstrike). Agent perks interact with it:
  - "MAYHEM IS GAINED WHEN TAKING DAMAGE"
  - "MOVE SPEED INCREASES AS MAYHEM INCREASES"
  - "HEALTH GAINED WHEN MAYHEM IS FULL"
- **Combo**: a "COMBO!" popup (`GC_COMBO`). The combo window and multiplier are **[unknown]**.
- **Score**: score multiplier boosters (X2/X3/X4). Social share line: "I scored %s points as %s".
- **Agents**:
  - Per-theme affinities: "EXTRA DAMAGE / RESILIENCE AGAINST NINJAS / UNDEAD / ROBOTS", with negative variants as drawbacks.
  - "HEALTH REGAINED BY KILLING ENEMIES".
  - A **shared health pool** across all equipped agents (up to 3: "COMPLETE A BOSS FIGHT USING ALL THREE CHARACTERS").
- **Armour states**: "FULL ARMOUR" vs "UNDERWEAR" (missions to kill in underpants). Armour pieces get knocked off as you take damage **[inferred]**.
- **Status effects on enemies**: fire (lights flee), freeze (scaled per tier), poison. Bosses have separate DOT visuals.
- **Spin attack**: a player move that gibs corpses and can kill bosses ("KILL A BOSS WITH A SPIN ATTACK").
- **Kills in the air**: enemies can be launched or juggled ("KILL %s ENEMIES WHEN THEY ARE IN THE AIR"). Combined with `ENEMY_WEIGHT`, this suggests knock-up physics.
- **Revive** after death: pay with gems or watch an ad ("REVIVE … FOR FREE"), or "GIVE UP!".
- **Missions**: "CLEAR %s HOSTILE TRAINS" and "COMPLETE A TRAIN WITHOUT TAKING DAMAGE" make **one hostile train the unit of progress**. "KILL %s ENEMIES WHILE ON THE SAME CARRIAGE" means carriages are tracked as zones.

---

## 5. Things that are unclear or missing from these files

1. **Train composition rules**: car order, number of cars, where boss / hostage / weapon crates go, and train length per difficulty. None of this is in these scripts. Check `scripts/DB/db.lua` and `loader.lua`, or it's native.
2. **Train and scroll speed, gravity, jump distances**: not present.
3. **Weapon damage, ranges, projectile speeds** for `LIGHT_MELEE`, `FIREWORK`, `SKULL`, `BOSS_STAKE`, `NINJA_BOMB`, `FUTURE_BOSS_MEGAGUN`, etc.: not present (probably DB).
4. **Score / coin / mayhem reward per kill**: not present.
5. **Exact meaning of `BERSERK_HEALTH` + box, `ENEMY_DAMAGE_TIMER`, `ENEMY_BLIND_DISTANCE` and `ENEMY_BEAM_LEAP_*`**: inferred only.
6. **When `ninja_10` is spawned.** Neither oriental boss is a spawn-type, so slot 9 may be unused for oriental, or used by a mode not visible here.
7. **Whether `SPAWN_GROUP_NORMAL` time is per train or per run**, and whether single-mid groups block until the mid dies.
8. **How `SPAWN_GROUP_BOSS_EXTRA` stages advance.**

Minor data quirks:
- `ninja_9` gibs use the typo `reCount`, so it defaults to 1.
- `future_9` defines `TAUNT` twice.
- `ninja_4` defines `mesh_back_fireworks` twice.
- `horror_7` has unused shield stats.
- `horror_4` has revive stats but `NORMAL_ENEMY` type.
- Survival group 3's difficulty flag is outside `SPAWN_DATA`.

## 6. Suggested Roblox translation notes

- **Units**: the light enemy is 76 px tall, and a Roblox R15 character is about 5 studs. Using **about 15 px = 1 stud**:
  - Light speed 90-170 px/s ≈ 6-11 studs/s, vs player WalkSpeed 16.
  - A 250 px car ≈ 17 studs; a 500 px car ≈ 33 studs.
  - `BERSERK_DIST` 512 px ≈ 34 studs; `BLIND_DISTANCE` 400 ≈ 27 studs.
- **Keep the slot-based, theme-agnostic spawn table** as Attributes/Constants: slot 0-3 lights, 4-6 mids/key holders, 7-8 bosses, 9 minion. Theme packs then just fill the 10 slots.
- **Keep the cost/budget/cap model.** It naturally makes horror crowds bigger and slower and ninja groups smaller and faster, using the same table.
