---
tags: [reference, original-game, balance, reverse-engineering]
status: reference
updated: 2026-10-13
source: /Users/allen/re/storm-drain/unpacked
---
> Reference only: describes the original Android APK, not implemented Roblox behavior or design canon. See [[Original Game]].

# Storm the Train — APK gameplay and balance inventory

Inspected locally on October 13, 2026. Package `com.gamesfaction.stormthetrain`, version **1.7.4**, version code **3788**, from the binary Android manifest. These are the values shipped in this particular APK, not a claim about a current live service.

## What is recoverable

This APK is unusually useful for balance analysis. It contains readable Lua configuration and shop logic, plus an intact native weapon-definition table. No APK or native game code was executed and no backend was contacted.

| Area | Recovered |
| --- | --- |
| Database | 269 records: 70 not marked deprecated, 199 deprecated records retained for migrations |
| Characters | 13 agents, weapons, gadgets, ability levels, movement/jump settings, challenge chains |
| Player weapons | 17 weapon families with 10 upgrade levels each |
| Gadgets | 10 entries: 3 mech suits, 6 drones, 1 airstrike |
| Enemy data | 30 enemy definitions across three environments, plus 1 hostage NPC |
| Native weapon data | 249 records in each architecture; damage, range and firing fields agree between ARM and x86 |
| Economy | 14 boosters, price tiers, unlock selection, rotating-specials pricing, legacy refunds |
| Progression | 16 normal spawn stages, 38 survival entries, boss/keyholder/challenge groups |
| Text and assets | Tutorials, mission descriptions, challenge text, models, animations, images, sounds, obstacle/missile pattern images |

The 70 non-deprecated records comprise 13 characters, 17 weapons, 10 gadgets, 14 boosters, 15 ability definitions and one all-character-purchase entry. “Non-deprecated” describes the database flag, not a guarantee every item is offered in every runtime state.

## Weapons: actual native balance values

The following are the native **base damage field** and **fire interval**, before character modifiers, boosters, secondary effects or special firing behavior. Intervals are displayed as the raw timer values, conventionally seconds in this code. They are not measured sustained firing rates.

| Weapon | Native prefix | Base damage L1 → L10 | Fire interval L1 → L10 |
| --- | --- | --- | --- |
| Rifle | RIFLE | 12 → 21 | 0.175 → 0.175 |
| Dual Rifles | DUALRIFLES | 8 → 14 | 0.1 → 0.1 |
| Rocket Launcher | ROCKETLAUNCHER | 13 → 19 | 0.5 → 0.42 |
| Rail Gun | RAILGUN | 0 → 0 | 0 → 0 |
| Sticky Bomb Launcher | STICKYBOMB | 36 → 42 | 0.5 → 0.34 |
| Shotgun | SHOTGUN | 12 → 14 | 0.45 → 0.32 |
| Minigun | MINIGUN | 6 → 11 | 0.07 → 0.07 |
| Gears Of Gore | CHAINSAW | 3 → 6 | 0.05 → 0.05 |
| Heatray | FLAMETHROWER | 1 → 2 | 0.15 → 0.15 |
| Uzi | UZI | 7 → 12 | 0.125 → 0.125 |
| Dual Uzi | DUALUZI | 4 → 7 | 0.075 → 0.075 |
| Poison Gun | POISON | 2 → 3 | 0.4 → 0.4 |
| Pistol | PISTOL | 20 → 35 | 0.35 → 0.35 |
| Dual Pistols | DUALPISTOLS | 14 → 24 | 0.2 → 0.2 |
| Lightning Gun | LIGHTNINGGUN | 4 → 7 | 0.1 → 0.1 |
| Plasma Cannon | PLASMA_CANNON | 13 → 19 | 0.5 → 0.42 |
| Sticky Rifle | STICKYRIFLE | 36 → 42 | 0.5 → 0.34 |

Interpretation matters:

- Rifle's nominal base damage / interval is about **68.6 at L1** and **120 at L10**. This is arithmetic on the definition, not an observed DPS result.
- Rail Gun's zero in the ordinary damage field does **not** mean it deals no damage. The native library has a separate `ChargeWeapon` implementation; charge parameters and its complete damage formula were not decoded in this pass.
- Shotgun has additional `SHOTGUN_CLOSE_1…10` records: base damage **16 → 21**, max-range field **180**. Its full combined/close-range behavior requires following the secondary-weapon logic.
- Heatray, Poison Gun, Lightning Gun, explosives and sticky weapons must be evaluated with their damage-over-time, area, projectile or secondary effects. This report does not rank those using naive DPS.
- Raw range values such as `-1` and `0` can be sentinels or type-specific behavior. They should not be interpreted as literal negative/zero effective range.
- Matching basic numbers do not make Rocket Launcher and Plasma Cannon, or Sticky Bomb Launcher and Sticky Rifle, identical: other fields and projectile behavior differ.

Other useful definitions: light enemy melee **3**, medium melee **6**, Oriental/Horror boss melee **7**, Future boss melee **10**, airstrike **200**, `MECH_AOE` **200**, and `BALL_BODY` **99,999**. Spin-attack definitions range from base damage **2** at level 1 to **15** at level 10. These remain base definition values, subject to their callers and flags.

### Native extraction evidence

Each weapon record is **124 bytes**. The contiguous array begins at x86 virtual address `0x299620` (file offset `0x298620`) and ARM address `0x201608` (see exported per-record offsets). Field layout established from the x86 accessors and firing code:

| Byte offset | Type | Meaning / evidence |
| --- | --- | --- |
| 0 | pointer | Null-terminated weapon-definition name |
| 4 | int32 | Base damage; `Weapon::Fire` converts `[definition+4]` to float and supplies it to firing/damage paths |
| 8 | float32 | `Weapon::GetMinRange` |
| 12 | float32 | `Weapon::GetMaxRange` |
| 16 | float32 | `Weapon::GetFireDelay` |
| 24 | float32 | `Weapon::GetFireRate`; `Weapon::Fire` compares this value to an elapsed firing timer, hence interval rather than shots/second |

`Weapon::GetFireRate` is at x86 `0x161150`, `GetFireDelay` at `0x161110`, `GetMaxRange` at `0x161190`, `GetMinRange` at `0x1611b0`, and `Weapon::Fire` at `0x162150`. Both architectures contain the same 249 names in the same order; the five decoded numeric fields match for every record. This is strong static evidence for the shipped table, not a runtime playtest. Unidentified fields are retained as raw hexadecimal words rather than assigned speculative names.

## Characters and ability balance

| Agent | Default price | Weapon pair | Speed field | Resilience field | Spin level |
| --- | --- | --- | --- | --- | --- |
| Bob | Special IAP unlock | Sticky Rifle, Plasma Cannon | 375 | 0.24 | 9 |
| Graham | Free | Dual Rifles, Rocket Launcher | 425 | 0.52 | 4 |
| Mason | 80 gems | Shotgun, Minigun | 350 | 0.28 | 6 |
| Carrera | 80 gems | Uzi, Poison Gun | 500 | 0.76 | 3 |
| Dino Graham | 100 gems | Heatray, Poison Gun | 425 | 0.52 | 7 |
| Kitty Mason | 100 gems | Rifle, Gears Of Gore | 350 | 0.28 | 9 |
| Carrera Bear | 100 gems | Rail Gun, Dual Pistols | 500 | 0.76 | 5 |
| Dead Zed | 100 gems | Pistol, Uzi | 275 | 0.2 | 2 |
| Hal | 150 gems | Dual Uzi, Shotgun | 400 | 0.64 | 5 |
| Wonder | 150 gems | Rifle, Dual Pistols | 425 | 0.76 | 2 |
| Wei | 150 gems | Rocket Launcher, Lightning Gun | 400 | 0.28 | 9 |
| Razor | 150 gems | Sticky Bomb Launcher, Heatray | 350 | 0.4 | 6 |
| Bingo Bango | 150 gems | Dual Uzi, Sticky Bomb Launcher | 325 | 0.28 | 4 |

These are ability-table lookups, resolved from each character's `abilityID` and `level`. Speed uses engine units. The misspelled `resillence` field is preserved as authored; it should not be renamed “health” or converted into effective HP without tracing the native application logic.

Notable resolved ability values:

- **Bob:** `mayhemMod=1.70`, damage multipliers **1.30** in all three environments. The UI describes Bob as a reward for making any in-app purchase; his record has no ordinary purchase-price tier.
- **Dino Graham:** Ninja damage **1.40**, robot damage **0.60**.
- **Kitty Mason:** Undead damage **1.40**, Ninja damage **0.60**.
- **Carrera Bear:** Robot damage **1.40**, undead damage **0.60**.
- **Wonder:** Undead damage **1.55**, undead defense field **0.60**, `heal_time=0.025`.
- **Wei:** Robot damage **1.55**, robot defense field **0.70**, `mayhemMod=0.45`.
- **Dead Zed:** Undead defense field **0.60**, `heal_fullMayhem=0.15`, `mayhem_dmg=1.0`.
- **Carrera:** `heal_kill=0.05`; **Bingo Bango:** `heal_kill=0.10`, `mayhemMod=1.55`, Ninja defense field **1.40**.
- **Razor:** `speed_mayhem=1.40`, `mayhem_dmg=1.0`.

The localization describes damage/defense modifiers, regeneration, healing on kills/full Mayhem, and Mayhem gained when damaged. Exact healing units, tick frequency, modifier stacking order and effective-health formulas have not been fully traced. Do not interpret `heal_kill=0.05` as “5% health per kill” based on the number alone.

**Stale-data warning:** comments and older direct fields can conflict with the newer ability tables. For example, Wei's comment says “-20% mayhem rate, +20% damage to robots,” but his referenced ability levels resolve to **0.45** and **1.55**. Carrera Bear also has a direct `damageModifiers` table that differs from the resolved abilities. Both are preserved in the export; the full native precedence between legacy character fields and ability fields was not established. The native library does contain the ability-field strings.

Character records also contain per-character bounding boxes, pickup radii, gravity/jump scales, gadget pools, default weapons and five-step challenge chains. Challenge entries include mode, target and sometimes difficulty. The resolved loadouts and original `characterData` are in `characters.json`.

Source: `/Users/allen/re/storm-drain/unpacked/assets/scripts/DB/db.lua` (line 3), ability tables at `/Users/allen/re/storm-drain/unpacked/assets/scripts/DB/db.lua` (line 2603).

## Economy and upgrades

The built-in currencies are **0 = coins**, **1 = gems**, explicitly confirmed by the expenditure/refund logic. Prices below are defaults. `GOAT.db.setPriceTier` allows the backend to override existing tiers with a positive price and either currency.

The normal weapon/gadget ladder is a free initial level followed by nine purchases:

| Upgrade purchase | Coin price | Cumulative coins |
| --- | --- | --- |
| 1 | 1000 | 1000 |
| 2 | 1400 | 2400 |
| 3 | 2000 | 4400 |
| 4 | 3000 | 7400 |
| 5 | 4400 | 11800 |
| 6 | 6200 | 18000 |
| 7 | 8400 | 26400 |
| 8 | 11000 | 37400 |
| 9 | 14000 | 51400 |

That is **51,400 coins** from the free initial level to level 10 for an item using the entire ladder. Blueprint unlocking and buying the unlocked level are separate operations. Airstrike has only one free level.

Booster defaults:

| Booster | Raw modifier | Price |
| --- | --- | --- |
| Score | 2 | 1 gems |
| Score | 3 | 2 gems |
| Mayhem | 2 | 500 coins |
| Mayhem | 3 | 800 coins |
| Coins | 2 | 4 gems |
| Coins | 3 | 6 gems |
| Damage | 1.25 | 400 coins |
| Damage | 1.5 | 2 gems |
| Damage | 2 | 4 gems |
| Health | 0.67 | 2 gems |
| Health | 0.5 | 4 gems |
| Gems | 2 | 800 coins |
| Gems | 3 | 1,600 coins |
| Magnet | — | 4 gems |

Health boosters advertise +50% and +100% but store **0.67** and **0.5**. This is consistent with reducing damage taken, but the actual application must be confirmed in native code. Their raw values should not be reported as +67% or +50% health. Tutorial text says up to **three boosters**, lasting for the **next train**. The shop's Lua offer selector removes other entries with the same title after selecting one, so it offers distinct booster types rather than duplicate tiers of one type.

### Blueprint selection is deliberately weighted

`unlockItems` builds distinct eligible weapon/gadget IDs from all character loadouts, separates items associated with owned versus unowned agents, and finds the lowest unlocked level. Candidates at level differences 0, 1 and 2 are bucketed; larger gaps are excluded for that selection.

If any owned-agent item exists in the lowest bucket, selection is **entirely within that bucket**, uniformly across its items. Otherwise the nonempty buckets get these relative weights:

| Bucket | Weight |
| --- | --- |
| Owned-agent items, one level above minimum | 500 |
| Owned-agent items, two above minimum | 100 |
| Unowned-agent items, at minimum | 500 |
| Unowned-agent items, one above minimum | 100 |
| Unowned-agent items, two above minimum | 50 |

These are relative weights, not fixed percentages; empty buckets are omitted. After choosing a bucket the algorithm chooses an item uniformly and unlocks its next level. Shared gear counts as owned if an owned agent uses it. Free unlocked levels are automatically bought.

### Rotating special offers

The specials code considers still-locked future levels and computes a cumulative price from the next unowned level to the target level. Each incremental coin cost is converted to gems using a supplied `coinToGemRatio`, multiplied by `lockedMod` or `unlockedMod`, rounded upward, then accumulated. It chooses up to three distinct items from low/middle/high price-index bands using a clamped normal distribution. Refresh interval and conversion/modifier values are caller parameters; their actual defaults were not established here.

There is an all-character IAP entry, but its local record does not supply a cash price. Gem/coin packs, ad rewards, mission rewards, starting grants, revive costs and service-provided offers need further native/backend-data analysis. The 199 deprecated records should not be treated as today's shop catalog; the loader contains refund and profile-migration logic for them.

Sources: `/Users/allen/re/storm-drain/unpacked/assets/scripts/DB/loader.lua` (line 118), `/Users/allen/re/storm-drain/unpacked/assets/scripts/DB/loader.lua` (line 252), `/Users/allen/re/storm-drain/unpacked/assets/scripts/DB/loader.lua` (line 538).

## Gadgets

| Gadget | Levels | Initial duration | Final duration |
| --- | --- | --- | --- |
| Damage Mech | 10 | 15 | 26.7 |
| Melee Suit | 10 | 15 | 26.7 |
| Heal Suit | 10 | 15 | 26.7 |
| Turret Drone | 10 | 30 | 57 |
| Melee Drone | 10 | 30 | 56 |
| Freeze Drone | 10 | 36 | 63 |
| Defender Drone | 10 | 51 | 87 |
| Smasher Drone | 10 | 10 | 19 |
| Healer Drone | 10 | 15 | 28.5 |
| Air Strike | 1 | — | — |

Durations are raw configured timer values, apparently seconds. Turret, melee and freeze drones also switch native weapon definitions at selected upgrade levels: for example Turret progresses through `DRONE_TURRET_1…5` while its duration rises from 30 to 57. The loader inherits unspecified fields from earlier levels: a missing `wepDef` on an intermediate upgrade does not mean the drone becomes unarmed. Top-level item fields take precedence over level fields.

Source: `/Users/allen/re/storm-drain/unpacked/assets/scripts/DB/db.lua` (line 832) and `/Users/allen/re/storm-drain/unpacked/assets/scripts/DB/db.lua` (line 1978).

## Enemies and bosses

These are explicit Lua base values. Omitted fields may inherit native defaults; runtime difficulty/scaling could change effective stats.

| Definition | Behavior class | Health | Move speed | Spawn cost |
| --- | --- | --- | --- | --- |
| future_1 | NORMAL_ENEMY | 20 | 110 | 1.7 |
| future_2 | HOVER_ENEMY | 30 | 150 | 3 |
| future_3 | HOVER_ENEMY | 40 | 150 | 3 |
| future_4 | SUICIDE_ENEMY | 18 | 130 | 3 |
| future_5 | AGILE_ENEMY | 160 | 170 | 15 |
| future_6 | BERSERKER_ENEMY | 160 | 160 | 15 |
| future_7 | SHIELD_ENEMY | 160 | 180 | 15 |
| future_8 | FUTURE_SPAWN_BOSS | 700 | 225 | 40 |
| future_9 | BERSERKER_BOSS | 700 | 250 | 40 |
| future_10 | NORMAL_ENEMY | 20 | 250 | 2 |
| horror_1 | UNDEAD_ENEMY | 20 | 90 | 1.7 |
| horror_2 | UNDEAD_ENEMY | 40 | 110 | 1.7 |
| horror_3 | UNDEAD_ENEMY | 35 | 90 | 2 |
| horror_4 | NORMAL_ENEMY | 45 | 110 | 2.5 |
| horror_5 | TELEPORT_ENEMY | 160 | 170 | 15 |
| horror_6 | BERSERKER_ENEMY | 160 | 160 | 15 |
| horror_7 | NORMAL_ENEMY | 160 | 180 | 15 |
| horror_8 | TELEPORT_BOSS | 600 | 155 | 40 |
| horror_9 | SPAWN_BOSS | 600 | 250 | 40 |
| horror_10 | UNDEAD_ENEMY | 25 | 160 | 2 |
| ninja_1 | NORMAL_ENEMY | 25 | 140 | 3 |
| ninja_2 | AGILE_ENEMY | 30 | 160 | 3 |
| ninja_3 | AGILE_ENEMY | 40 | 170 | 3 |
| ninja_4 | COWARD_ENEMY | 30 | 160 | 3 |
| ninja_5 | AGILE_ENEMY | 160 | 170 | 15 |
| ninja_6 | BERSERKER_ENEMY | 160 | 160 | 15 |
| ninja_7 | SHIELD_ENEMY | 160 | 180 | 15 |
| ninja_8 | BERSERKER_BOSS | 600 | 250 | 40 |
| ninja_9 | SHIELD_BOSS | 550 | 180 | 40 |
| ninja_10 | AGILE_ENEMY | 30 | 225 | 3 |
| npc_1 | HOSTAGE_NEUTRAL | 25 | 200 | 0.1 |

Mechanics directly exposed in the enemy data:

- Undead revive probabilities/times: `horror_1` **33% / 1.5**, `horror_2` **75% / 1.5**, `horror_3` **70% / 2**, `horror_10` **60% / 2**. These are configured probabilities, not observed outcomes. `horror_4` contains revive fields but uses `NORMAL_ENEMY`, so their presence alone does not establish revival.
- Mid-tier enemies generally have **160 health** and cost **15** spawn budget. Bosses cost **40**, with base health **550–700**.
- Shield fields: `ninja_7` and `future_7` have **90** shield health; `ninja_9` has **250**. `horror_7` also stores shield fields but is `NORMAL_ENEMY`, so a live shield is not confirmed merely from those fields.
- Freeze scalars are generally **1.0** for small enemies, **0.6** for mid-tier enemies and **0.3** for bosses, exposing differentiated freeze handling.
- Teleport enemy `horror_5`: interval min/max **3–6**, teleport time **0.8**, recovery **0.4**. Vampire boss `horror_8`: teleport interval **4–7**, hover interval **5–8**, teleport time **0.8**, recovery **0.3**.
- Berserker entries expose health thresholds, attack distance, hit-box size and weapon definitions. Agile enemies expose spin-jump timings. Other classes include hovering, cowardly, suicide and summoning bosses.

The complete `EnemySetup`, `WeaponData` and behavior class for all 31 files are in `enemies.json`.

## Spawning, levels and progression

The spawn system uses a **cost budget**, not just a head-count cap. Wave min/max values specify cost to spend; cap values bound active enemy cost. Spawn IDs are zero-based: `0` maps to suffix `_1`, and `9` to `_10`. The environment supplies the `ninja`, `horror` or `future` prefix.

- Normal spawning starts with a **15**-duration group, **0.6** wave interval, wave budget **3 → 4**, active-cost cap **3 → 6**, and only spawn ID 0.
- There are **16** root stages in the normal progression. Sibling nodes run additional groups alongside a root; export consumers must traverse those too.
- The final normal root uses duration **250**, interval **2.5**, wave budget **16**, cap **60**, and all three randomized mid-enemy slots. Its sibling uses interval **0.8**, cap **10 → 20**, and the first four ordinary enemy IDs.
- The three mid-tier enemy slots are randomized, and flags can introduce one slot or all slots up to a chosen position.
- Boss selection uses IDs **7/8** (files `_8/_9`); keyholders use **4/5/6**; boss-spawned support uses **9** (file `_10`).
- Survival defines **38** entries with difficulty/boss flags. The time challenge has a **60**-duration root with **0.1** wave interval plus a mid-enemy sibling group.

The Lua loader establishes group dependencies, but the native scheduler determines details such as interpolation, timing edge cases and what happens after the last group. Stage labels/comments are not a substitute for tracing that code.

Sources: `/Users/allen/re/storm-drain/unpacked/assets/scripts/Enemies/spawnGroups.lua` (line 1), `/Users/allen/re/storm-drain/unpacked/assets/scripts/Enemies/spawnLoader.lua` (line 9).

Tutorial/localization evidence adds these player-facing rules:

- Equipped agents can be swapped and **share one health pool**.
- Killing enemies fills Mayhem; full Mayhem awards a free gadget.
- Blueprints are returned to the Eagle-7 to unlock upgrades.
- Spin strength is described as the double-jump attack.
- Challenge chains progress through individual missions and offer a final prize and an agent discount; discount/reward amounts are placeholders supplied elsewhere.
- Vehicle challenges include jetpack and Cylindrical Death Weapon obstacle/missile avoidance.

These descriptions are content evidence, not an independent verification of every runtime rule. Mission strings expose objectives involving specific enemies, weapon crates, score multipliers, hostages, consecutive damage-free trains, spin kills, vehicles, revive use and simultaneous drones. Numeric mission targets are often `%s` placeholders and are not recoverable from the text alone.

Source: `/Users/allen/re/storm-drain/unpacked/assets/Locales/en-GB.locale` (line 392).

## Additional useful material and next analysis targets

`assets/Patterns` contains 50 small TGA files named by obstacle/missile challenge and difficulty. They are potential machine-readable level-pattern data, not merely promotional artwork. Their color-to-gameplay encoding was not decoded here. `assets/Models` contains 168 `.cm` model/animation files, including train carriage variants, prisons, weapon carriages and checkpoint stations. The environment Lua scripts describe scenery selection/weights and sky layouts. The existing `extracted/sprites` folder already contains unpacked visual assets.

`libMainApp.so` retains many meaningful C++ dynamic symbols despite being stripped. Promising targets for a deeper pass are `ChargeWeapon`, `EnemyDotData`, `Character::GetEnvironmentDamageModifier`, `Player::TakeDamage`, `GameMissionManager`, `PickupManager`, `PlayerProfile`, `SpawnData` and the caller of `GOAT.db.specialsQuery`. Those should reveal charged/DoT damage, modifier stacking, reward rates, mission target curves, difficulty scaling and exact shop constants. `classes.dex` was not fully decompiled in this pass; the gameplay-rich files already found are the Lua and native library.

## Export guide

All exports are static reads of this APK. JSON Lua tables preserve numeric keys as JSON object keys (including negative ability levels); they are not automatically changed to zero-based lists.

- `game-database.json`: all 269 records, including explicit deprecated flags, added display names and source lines.
- `characters.json`: 13 resolved loadouts/ability maps plus original character data.
- `enemies.json`: all 31 enemy/NPC definitions, configured stats, weapons and behavior types.
- `native-weapon-definitions.json`: all 249 native records per architecture, decoded fields, raw words, addresses and cross-architecture comparison.
- `price-tiers.json`: bundled default prices/currencies.
- `spawn-groups.json`: all group tables, nested sibling nodes and flags.
- `localization.json`: parsed English strings; where a key is duplicated, the last assignment wins as in Lua.
- `native-symbols.json`: x86 dynamic symbols for follow-up reverse engineering.
- `source-hashes.json`: SHA-256 fingerprints of source inputs.

The ZIP contains this report and all JSON exports. Key limitations: the game was not run, server overrides were not fetched, and not every native mechanic or unknown structure field was decoded. The data is sufficient for a substantial offline balance inventory; a definitive combat simulator or economy model would require the remaining native logic.


## Related notes and data location

- [[Original Game]]
- [[Original Game - Items and Economy]]
- [[Original Game - Enemies and Spawning]]
- [[Original Game - Text, Engine and Assets]]

The report and JSON bundle are stored outside the vault at:
`/Users/allen/Documents/Codex/2026-10-13/c/outputs/storm-the-train-data.zip`

Individual JSON exports listed above are in that same `outputs/` directory. No extracted artwork, audio, APK, or native binary was added to this vault.
