---
tags: [reference, original-game, economy]
status: reference
source: /Users/allen/re/storm-drain/unpacked (Storm the Train v1.7.4 Android APK, Games Faction 2016)
---
> Reference only: describes the **original 2016 mobile game**, not this Roblox project. Not design canon. See [[Original Game]].

# Storm the Train (2016, Games Faction): item DB reference

Source files (read-only, untrusted APK data, nothing executed):

- `assets/scripts/DB/db.lua`: 5,161 lines, one big `return { ... }` list of item tables
- `assets/scripts/DB/loader.lua`: 761 lines, the `GOAT.db.*` API over that list
- `assets/Locales/en-GB.locale`: string keys mapped to English (`KEY = "TEXT"`)

Display names below come from the locale file. Values in `code` are the raw DB keys or values.

> **Scope update (2026-10-13):** the Lua files contain weapon-definition references, not
> per-weapon damage or firing intervals. A subsequent native-library inspection recovered
> **249 weapon definitions**, including base damage, firing intervals and raw range fields,
> and checked the decoded values against both ARM and x86. See [[Original Game - APK Balance Audit]]
> for the weapon tables and extraction evidence. Charged/DoT formulas, modifier stacking,
> ammo/clip behavior, mission targets/rewards, IAP cash prices and revive/heal prices remain
> unresolved in that audit. Shop price tiers can be overridden by the backend; special-offer
> refresh interval, coin:gem ratio and pricing multipliers are caller parameters whose actual
> defaults were not established.

---

## 1. Schema

### 1.1 Top-level item fields

| Field | Meaning |
|---|---|
| `__id` | Unique numeric ID. `loader` asserts uniqueness and builds `index[__id]`. |
| `tab` | Shop/menu tab: `0` = Air Strike and runtime "specials", `1` = Gadgets, `2` = Barracks (characters), `3` = Weapons, `5` = Gems/IAP. `tabQuery(tab)` returns the non-deprecated, enabled items on a tab. |
| `category` | Item type enum (names from loader comments): `0` character, `1` **IC_WEAPUP** weapon, `6` **IC_TDUP** gadget (drones, mechs, air strike), `11` **IC_EVENT** event upgrade (CDW/Jetpack, now deprecated), `17` consumable/booster, `18` **IC_CHAR_ABIL** character ability, `20` IAP bundle. |
| `serialisable` | Ownership is saved to the profile (`serialiseQuery`). |
| `deprecated` | Legacy item kept only so old purchases can be counted and refunded. |
| `special` | Runtime-created "Surplus" shop entry (never in the DB file). |
| `enabled` | If `false`, hidden from queries. No DB entry sets it. |
| `allowInChallenge` | `1` = the character can be used in challenge chains. Every character except Bob has it. |
| `ownInstructions` | Text explaining how to obtain the item. Bob only: "MAKE ANY IN-APP PURCHASE AND GET BOB FOR FREE". |
| `gadgetType` | Gadget enum `0`–`9` (§5). |
| `gadgetSuccessor` | On a deprecated old gadget: the new gadget ID it migrates to (`patchProfile` v<10). |
| `itemCol` | Shop colour enum: `0` weapon, `1` gadget, `3` air strike/event, `4` IAP. |
| `levels` | Array of per-level tables (below). `numLevels = #levels`. |
| `characterData` | Character, mech, or weapon visual/gameplay data (below). |
| `icon`, `info_postive`, `info_negative` | On ability items: icon plus positive/negative description keys. The misspelling `postive` is in the original. |

### 1.2 Per-level fields (`levels[n]`)

Lookup rule (`getFieldFromItem`): check the item root first. Otherwise start at the requested
level and walk **down** to level 1 until the field is found. A value set at level 1 therefore
carries forward until a later level overrides it. The default level is `min(levelOwned+1, numLevels)`,
which is the *next* purchasable level.

| Field | Meaning |
|---|---|
| `name`, `desc` | Character Barracks name and tagline (locale keys). |
| `title`, `shortName` | Item title and short label (locale keys). |
| `icon`, `gadgetIcon` | Shop icon and in-game HUD gadget-button icon. |
| `priceTier` | Key into `priceTiers` in loader.lua. `setPrices()` turns it into `price` and `currency`. |
| `price`, `currency` | Final cost. Currency `0` = **coins**, `1` = **gems**. |
| `startUnlocked` | Unlocked on a fresh profile. If the price is also 0, it is auto-bought (`postSerialise`). |
| `duration` | Gadget active time in seconds at that level. |
| `wepDef` | Drone weapon definition; changes every other level (tiers 1–5). |
| `consCat`, `modifier`, `iconString`, `infoString` | Consumable fields (§6). |
| ability stat (`resillence`, `speed`, `spinID`, `mayhemMod`, ...) | Value at that ability level (§3). |

### 1.3 `characterData`

Playable characters:

- `modelAffix`, `textureAffix`, `speechAffix`: asset name `chr_<modelAffix>`; speech key `PLAYER_SPEECH_<event>_<speechAffix>_<n>`.
- `defaultWeapon`: weapon ID equipped at start; the character must own it.
- `weapons`: exactly 2 entries `{wepItemID, fireLocator (bone), fireOffset {x,y}}`. Every agent has a primary and a secondary weapon.
- `gadgets`: list of gadget IDs this agent can use (1–5).
- `params`: physics, as below.
  - `CHARACTER_BOUNDINGBOX_X/Y`: hitbox, usually 20×90.
  - `CHARACTER_PICKUP_BOUNDINGBOX_X/Y`: pickup radius box, usually 35×112.
  - `CHARACTER_FORCEFIELD_R`: shield radius, usually 55.
  - `CHARACTER_GRAVITY_SCALE`: usually 2.
  - `CHARACTER_JUMP_SCALE`: usually 1.
  - Mechs add `CHARACTER_SPEED` and `CHARACTER_RESILIENCE`.
- `gibSetup`: gore chunks on death `{textureName, offset, force, repCount, unique}`. Most use character-specific pieces plus a generic eye and heart. Dead Zed uses zombie bone and meat.
- `challenges`: 5-step daily challenge chain (§8).
- `abilities`: list of `{abilityID, level}`. Negative levels are drawbacks (§3).
- Legacy or unused on some characters: `damageModifiers`, `defenceModifiers` (Carrera Bear), `mayhemOnDamage`, `speedWithMayhem` (Razor), `weaponFireLocators` (Mason, Carrera). They are probably superseded by `abilities`.

Weapons: `wepMgrDef` (native weapon definition name), `animID`, `meshList {meshName, textureName}`,
and optional `progAnim {xformName, rotSpeed}` for procedurally spinning parts (Gears of Gore).

Mechs: `characterType`, `spinWepDef` (double-jump spin attack), `mayhemWepDef`, `mechWeapon`
`{wepMgrDef, fireLocator, fireOffset, meshList, progAnim}`, and `params` including speed and resilience.

### 1.4 ID encoding (inferred)

IDs are bit-packed: `(level<<24) | (sub<<16) | (owner<<8) | type`. Examples:

- Graham's weapons: `524801 = 0x08_02_01`, `590337 = 0x09_02_01`.
- Gadgets: `0xNN0006` (Turret `0x030006`, Melee `0x020006`, Damage Mech `0x080006`, Air Strike `6`).
- Original characters: Graham `0x200`, Mason `0x300`, Carrera `0x400`.

Characters added in 1.6 use small IDs (18–31). This is only useful for decoding saves.

---

## 2. What loader.lua does

| Function | Behaviour |
|---|---|
| startup | Seeds RNG with `os.time()`. Loads `DB/db.lua`, indexes by `__id`, sets `levelOwned=0`, `levelUnlocked=0`, `numLevels`. |
| `priceTiers` + `setPriceTier(tier, price, currency)` + `setPrices()` | Default price table (§7). **The backend can override any tier** (price > 0, currency 0/1). `setPrices` writes the tier into each level of non-special, non-deprecated items. |
| `postSerialise()` | For every character and every unlockable weapon/gadget: unlock `startUnlocked` levels and auto-buy any unlocked level whose price is 0. Result: all weapons and gadgets are owned at level 1 for free, and Graham is owned. |
| `buyItem` / `itemBuy` | Raises `levelOwned` by one, or to `level` for specials. Also raises `levelUnlocked`. Note: `itemBuy(uid, level)` ignores `level`. |
| `unlockItem` | Raises `levelUnlocked`. Auto-buys if that level is free. |
| `ownedCharacterUpgradeQuery()` | Owned characters with a weapon or gadget where `levelUnlocked > levelOwned`. Drives the flashing blue "upgrade available" circle in the Barracks. |
| **`unlockItems(n)`** | **Blueprint reward roll** (§7.3): picks which weapon or gadget level is unlocked when blueprints are delivered to the Eagle-7. |
| `remainingUnlocks()` | Sum of `numLevels - levelUnlocked` over unlockable items (categories 1, 6, 11). |
| **`specialsQuery(refreshInterval, coinToGemRatio, lockedMod, unlockedMod)`** | Builds **"Chubwick's Surplus"**: 3 gem-priced offers that skip blueprints (§7.4). |
| `consumablesQuery(numOffered)` | Random booster offer: `numOffered` consumables with distinct `title`s, so ×2 and ×3 of the same booster never appear together. Loops forever if `numOffered` exceeds the 7 distinct types. |
| `countTotalExpenditure()` / `countDeprecatedExpenditure()` / `resetDeprecated()` | Sum every coin and gem spent, for the **1.6.0 "Refund-O-Matic 3000"**, which refunded all old purchases. `countDeprecatedExpenditure` uses an undefined `level` variable (latent bug). |
| `patchProfile(version, numBlueprints)` | Save migrations. v<8 handled the old blueprint `unlockOrder` field, which no longer exists in the DB. v<10 maps old gadgets to `gadgetSuccessor` with `levelOwned+1`. |
| `resetToDefault(includeIAPs)` | Wipes ownership. Skips items with `iapName` unless asked. No current item has `iapName`. |
| `fieldQuery`, `tabQuery`, `itemGet/Set/Validate`, `itemCreate` | Generic accessors. `itemCreate` allocates the next free ID; specials use it. |

---

## 3. Character abilities (category 18)

Each character lists 3–6 abilities with a level from −10 to 10. Abilities are innate per agent
and **not purchasable** in this version: there are no prices and nothing levels them up. Every
agent has Resilience (100), Speed (101) and Spin (102). The rest are perks or drawbacks.

### 3.1 Value tables

| Lvl | 100 Resilience `resillence` (dmg-taken mult) | 101 Speed `speed` | 102 Spin `spinID` | 103/104/105/106 Mayhem rate / dmg vs Undead / Robots / Ninjas | 107/108/109 Def vs Undead / Robots / Ninjas (dmg-taken mult) |
|---|---|---|---|---|---|
| 1 | 1.00 | 275 | 1 | 1.10 | 0.90 |
| 2 | 0.88 | 300 | 2 | 1.20 | 0.80 |
| 3 | 0.76 | 325 | 3 | 1.30 | 0.70 |
| 4 | 0.64 | 350 | 4 | 1.40 | 0.60 |
| 5 | 0.52 | 375 | 5 | 1.50 | 0.50 |
| 6 | 0.40 | 400 | 6 | 1.55 | 0.45 |
| 7 | 0.28 | 425 | 7 | 1.60 | 0.40 |
| 8 | 0.24 | 450 | 8 | 1.65 | 0.35 |
| 9 | 0.20 | 475 | 9 | 1.70 | 0.30 |
| 10 | 0.16 | 500 | 10 | 1.75 | 0.25 |
| −1…−10 | — | — | — | 0.90, 0.80, 0.70, 0.60, 0.50, 0.45, 0.40, 0.35, 0.30, 0.25 | 1.10, 1.20, 1.30, 1.40, 1.50, 1.55, 1.60, 1.65, 1.70, 1.75 |

| Lvl | 110 Heal over time `heal_time` | 111 Heal on kill `heal_kill` | 112 Heal on full Mayhem `heal_fullMayhem` | 113 Speed scales with Mayhem `speed_mayhem` | 114 Mayhem from damage taken `mayhem_dmg` |
|---|---|---|---|---|---|
| L | 0.025 × L | 0.05 × L | 0.05 × L | 1.0 + 0.1 × L | 0.2 × L |
| 1 / 10 | 0.025 / 0.25 | 0.05 / 0.50 | 0.05 / 0.50 | 1.1 / 2.0 | 0.2 / 2.0 |

Locale descriptions:

- Resilience: "RESILIENCE AGAINST ATTACK"
- Spin: "SPIN ATTACK STRENGTH (DOUBLE JUMP)". The spin attack is a double-jump attack, and `spinID` selects a native spin weapon def of increasing strength.
- 110–114: "HEALTH REGAINED OVER TIME", "…BY KILLING ENEMIES", "…WHEN MAYHEM IS FULL", "MOVE SPEED INCREASES AS MAYHEM INCREASES", "MAYHEM IS GAINED WHEN TAKING DAMAGE".

The units of 110–112 are unclear. They are most likely a fraction of max health per second,
per kill, and per full-Mayhem event. 0.50 per kill seems large, so it may scale with
something else.

---

## 4. Playable characters (category 0, tab 2 "Barracks")

13 agents. **Players field a squad of agents and swipe to switch between them.** From the
tutorial: "all agents share a single health pool", and the player must buy and equip a second
agent before leaving the Barracks. Price tiers: `char_low` = 80 gems, `char_med` = 100 gems,
`char_high` = 150 gems.

### 4.1 Roster, price, loadout

| Agent (ID) | Tagline | Price | Default weapon | Secondary weapon | Gadgets |
|---|---|---|---|---|---|
| **Graham** (512) | "AGENT NO.1" | Free (starter) | Dual Rifles | Rocket Launcher | Turret, Melee drone, Air Strike |
| **Mason** (768) | "OLD SCHOOL TOUGHNESS" | 80 gems | Shotgun | Minigun | Defender, Freeze, Air Strike |
| **Carrera** (1024) | "TOTAL HEALTH FREAK" | 80 gems | Uzi | Poison Gun | Smasher, Healer, Air Strike |
| **Dino Graham** (20) | "EXTINCTION EVENT COMING UP" | 100 gems | Heatray (flamethrower) | Poison Gun | Damage Mech, Turret, Defender |
| **Kitty Mason** (21) | "UNLEASH THE KITTY KAT" | 100 gems | Rifle | Gears of Gore (chainsaw) | Melee Suit, Melee drone, Freeze |
| **Carrera Bear** (22) | "TRULY GRIZZLY" | 100 gems | Rail Gun | Dual Pistols | Heal Suit, Defender, Healer |
| **Dead Zed** (24) | "DEAD BUT NOT DEAD!" | 100 gems | Pistol | Uzi | Freeze |
| **Hal** (30) | "BRING THE HEAT" | 150 gems | Dual Uzi | Shotgun | Melee Suit, Melee drone, Defender, Air Strike |
| **Wonder** (cowgirl, 23) | "YEE-HA LET'S GO" | 150 gems | Rifle | Dual Pistols | Defender, Turret, Healer, Smasher |
| **Wei** (26) | "YES WEI!" | 150 gems | Rocket Launcher | Lightning Gun | Heal Suit, Melee Suit, Damage Mech, Turret, Melee drone |
| **Razor** (model "rogue", 25) | "DEADLY AND ON YOUR SIDE" | 150 gems | Sticky Bomb Launcher | Heatray | Damage Mech, Turret, Freeze, Air Strike |
| **Bingo Bango** (clown, 18) | "HE AIN'T CLOWNING ABOUT" | 150 gems | Dual Uzi | Sticky Bomb Launcher | Freeze, Defender, Melee drone, Air Strike |
| **Bob** (robot, 31) | "HERE COME THE BIG GUNS" | **IAP gift**: "make any in-app purchase and get Bob for free". No price tier. Not allowed in challenges. | Sticky Rifle | Plasma Cannon | Turret, Melee drone, Freeze, Air Strike |

Cost of the full paid roster: 2×80 + 4×100 + 5×150 = **1,310 gems**. There is also an
"unlock all characters" IAP bundle (§7.5).

Costume variants reuse a base agent's gibs and voice style: Dino Graham, Kitty Mason and
Carrera Bear are joke-costume versions of Graham, Mason and Carrera.

### 4.2 Abilities per agent

Value in brackets is the effective number from §3.

| Agent | Resil. (dmg-taken) | Speed | Spin | Perks (+) and drawbacks (−) |
|---|---|---|---|---|
| Graham | 5 (0.52) | 7 (425) | 4 | — (pure all-rounder) |
| Mason | 7 (0.28) | 4 (350) | 6 | Mayhem from damage taken 4 (0.8) |
| Carrera | 3 (0.76) | 10 (500) | 3 | Heal on kill 1 (0.05) |
| Dino Graham | 5 (0.52) | 7 (425) | 7 | +Dmg vs Ninjas 4 (×1.40); −Dmg vs Robots −4 (×0.60) |
| Kitty Mason | 7 (0.28) | 4 (350) | 9 | +Dmg vs Undead 4 (×1.40); −Dmg vs Ninjas −4 (×0.60) |
| Carrera Bear | 3 (0.76) | 10 (500) | 5 | +Dmg vs Robots 4 (×1.40); −Dmg vs Undead −4 (×0.60). Legacy field `damageModifiers` = Oriental 0.8, Future 1.2. |
| Dead Zed | **9 (0.20)** | **1 (275)** | 2 | Mayhem from damage 5 (1.0); Heal on full Mayhem 3 (0.15); Def vs Undead 4 (×0.60 taken); jump scale 0.9 |
| Hal | 4 (0.64) | 6 (400) | 5 | +Dmg vs Ninjas 4 (×1.40); Def vs Ninjas 4 (×0.60); Heal on full Mayhem 1 (0.05) |
| Wonder | 3 (0.76) | 7 (425) | 2 | +Dmg vs Undead 6 (×1.55); Def vs Undead 4 (×0.60); Heal over time 1 (0.025) |
| Wei | 7 (0.28) | 6 (400) | 9 | +Dmg vs Robots 6 (×1.55); Def vs Robots 3 (×0.70); **−Mayhem rate −6 (×0.45)**; gravity 1.8 (floatier) |
| Razor | 6 (0.40) | 4 (350) | 6 | Mayhem from damage 5 (1.0); Speed scales with Mayhem 4 (×1.4). Legacy fields: `mayhemOnDamage{rate=1}`, `speedWithMayhem{350,450}`. |
| Bingo Bango | 7 (0.28) | 3 (325) | 4 | Mayhem rate 6 (×1.55); Heal on kill 2 (0.10); −Def vs Ninjas −4 (×1.40 taken) |
| Bob | 8 (0.24) | 5 (375) | 9 | Mayhem rate 9 (×1.70); +Dmg vs Undead / Robots / Ninjas 3 each (×1.30). Bigger hitbox 26×110, gravity 2.2, jump 1.2. |

Design pattern: each agent trades **tankiness against speed**, roughly along a single curve,
and gets 1–3 thematic perks. Cosmetic variants get an anti-synergy with one enemy faction
alongside a bonus against another. Several source comments are stale and contradict the data:

- Wei: comment says "-20% mayhem, +20% robots"; data has ×0.45 and ×1.55.
- Bingo: comment says "+20% Oriental".
- Dead Zed: comment says "+10 dmg Ninjas, +40% shield vs undead".

---

## 5. Gadgets (category 6): drones, mech suits, air strike

Gadgets are activated in a run. Each agent has a fixed gadget list (§4.1). Locked-reason
strings show the rules:

- Only one drone at a time ("DRONE ALREADY ACTIVE"). There is also a mission to "use two drones at the same time", so something allows two.
- Air strike cannot overlap itself.
- Mech suits are the **Mayhem** state ("MECH SUIT ACTIVE" is shown as `LOCKED_REASON_MAYHEM_ACTIVE`).
- Gadgets are blocked between trains, during events, and while on the Eagle-7.
- The tutorial says "FULL MAYHEM GIVES YOU A FREE GADGET".

All drones and mechs have **10 levels**. Level 1 is free. Upgrades cost the item tiers in §7.1
and require a **blueprint unlock** first (or a Surplus purchase).

### 5.1 Duration (seconds) per level

| Gadget (ID, `gadgetType`) | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | Weapon tier changes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Turret Drone (196614, 0) | 30 | 33 | 36 | 39 | 42 | 45 | 48 | 51 | 54 | 57 | `DRONE_TURRET_1`@L1, `_2`@L3, `_3`@L5, `_4`@L7, `_5`@L9 |
| Melee Drone (131078, 1) | 30 | 33 | 36 | 39 | 41* | 44 | 47 | 50 | 53 | 56 | `DRONE_MELEE_1..5` @ L1/3/5/7/9 |
| Freeze Drone (851974, 2) | 36 | 39 | 42 | 45 | 48 | **41*** | 54 | 57 | 60 | 63 | `DRONE_FREEZE_1..5` @ L1/3/5/7/9 |
| Defender Drone (262150, 3) | 51 | 55 | 59 | 63 | 67 | 71 | 75 | 79 | 83 | 87 | — (blocks projectiles) |
| Smasher Drone (327686, 4) | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | — (smashes corpses, per mission text) |
| Healer Drone (786438, 5) | 15 | 16.5 | 18 | 19.5 | 21 | 22.5 | 24 | 25.5 | 27 | 28.5 | — |
| Damage Mech (524294, 6) | 15 | 16.3 | 17.6 | 18.9 | 20.2 | 21.5 | 22.8 | 24.1 | 25.4 | 26.7 | — |
| Melee Suit / "Defence mech" (917510, 7) | same as Damage Mech | | | | | | | | | | — |
| Heal Suit (983046, 8) | same as Damage Mech | | | | | | | | | | — |
| Air Strike (6, 9) | single level, free, `tab=0` | | | | | | | | | | — |

\*Data errors: Freeze L6 = 41 is almost certainly a typo for 51. Melee L5 = 41 breaks the +3
step (expected 42).

Upgrade pattern: duration rises about 3–10% per level, and the drone's *weapon* gets a new tier every 2 levels.

### 5.2 Mech suits (player transforms into a mech)

| Mech | Speed | Resilience | Gravity | Jump | Weapons |
|---|---|---|---|---|---|
| Damage Mech ("DAMAGE MECH") | 500 | 1.00 | 2 | 1 | gun `DAMAGE_MECH_GUN` (right hand, offset 0,70); spin `DAMAGE_MECH_SPIN`; Mayhem weapon `DAMAGE_MECH_SPIN_GUN` |
| Melee Suit ("MELEE SUIT", `CHARACTER_MECH_DEFENSE`) | 350 | 1.00 | 3.5 | 1.25 | `DEFENCE_MECH_GUN`: twin rotating saw blades (rotSpeed −14 each hand); spin `DEFENCE_MECH_SPIN`; no Mayhem weapon |
| Heal Suit ("HEAL SUIT") | 450 | 1.00 | 3 | 1.25 | `HEAL_MECH_GUN`; spin `HEAL_MECH_SPIN`; Mayhem weapon `HEAL_MECH_SPIN_GUN` |

---

## 6. Weapons (category 1, tab 3)

There are 17 weapons. Each has 10 levels: L1 is free and unlocked at start, and L2–L10 use the
`item_lev1`…`item_lev9` coin tiers (§7.1). A weapon is effectively gated by owning an agent
that carries it. db.lua holds only the `wepMgrDef` names; base damage and fire intervals per level
are in the native library and are tabulated in [[Original Game - APK Balance Audit]].

| Weapon (ID) | `wepMgrDef` | Used by |
|---|---|---|
| Rifle (28) | RIFLE | Kitty Mason, Wonder |
| Dual Rifles (524801) | DUALRIFLES | Graham |
| Rocket Launcher (590337) | ROCKETLAUNCHER | Graham, Wei |
| Rail Gun (655873) | RAILGUN | Carrera Bear |
| Sticky Bomb Launcher (721409) | STICKYBOMB | Razor, Bingo Bango |
| Shotgun (525057) | SHOTGUN | Mason, Hal |
| Minigun (590593) | MINIGUN | Mason |
| Gears of Gore (chainsaw, 656129) | CHAINSAW | Kitty Mason. 9 meshes with spinning gears (rot 6, −9, 24). |
| Heatray (flamethrower, 721665) | FLAMETHROWER | Dino Graham, Razor |
| Uzi (525313) | UZI | Carrera, Dead Zed |
| Dual Uzi (29) | DUALUZI | Hal, Bingo Bango |
| Poison Gun (590849) | POISON | Carrera, Dino Graham |
| Pistol (27) | PISTOL | Dead Zed |
| Dual Pistols (revolvers, 656385) | DUALPISTOLS | Carrera Bear, Wonder |
| Lightning Gun (721921) | LIGHTNINGGUN | Wei |
| Plasma Cannon (8) | PLASMA_CANNON | Bob |
| Sticky Rifle (16) | STICKYRIFLE | Bob |

Also referenced in the locale and missions: "weapon crates" are an in-run pickup, likely a
temporary weapon or ammo. They are not defined here.

---

## 7. Economy

### 7.1 Currencies and price tiers (defaults; the server can override each tier)

Two currencies: **Coins** (`currency=0`, soft) and **Gems** (`currency=1`, premium).

| Tier | Price | Currency | Used for |
|---|---|---|---|
| `free` | 0 | coins | starter character, L1 of every weapon and gadget |
| `char_low` / `char_med` / `char_high` | 80 / 100 / 150 | gems | characters |
| `item_lev1` | 1,000 | coins | weapon/gadget level 2 |
| `item_lev2` | 1,400 | coins | L3 |
| `item_lev3` | 2,000 | coins | L4 |
| `item_lev4` | 3,000 | coins | L5 |
| `item_lev5` | 4,400 | coins | L6 |
| `item_lev6` | 6,200 | coins | L7 |
| `item_lev7` | 8,400 | coins | L8 |
| `item_lev8` | 11,000 | coins | L9 |
| `item_lev9` | 14,000 | coins | L10 |
| `cons_*` | see §7.2 | mixed | boosters |

- Cost to max one weapon or gadget (L1 to L10): **51,400 coins**.
- 26 upgradable items (17 weapons + 6 drones + 3 mechs) × 51,400 = **1,336,400 coins** to max everything.
- There are 26 × 9 = **234 blueprint unlocks** in total.
- Level cost grows about 1.4× per step at first, easing to about 1.27× near the cap.

### 7.2 Consumables / "Boosters" (category 17)

The tutorial says "YOU CAN EQUIP UP TO 3 BOOSTERS FOR THE DURATION OF THE NEXT TRAIN". The
offer is random and distinct per type (`consumablesQuery`).

| ID | Booster | `consCat` | Effect (`modifier`) | Label | Price |
|---|---|---|---|---|---|
| 1 | Score | 5 | ×2 score | X2 | 1 gem |
| 2 | Score | 5 | ×3 score | X3 | 2 gems |
| 3 | Mayhem | 3 | ×2 Mayhem fill rate | X2 | 500 coins |
| 4 | Mayhem | 3 | ×3 | X3 | 800 coins |
| 5 | Coins | 2 | ×2 coins | X2 | 4 gems |
| 7 | Coins | 2 | ×3 coins | X3 | 6 gems |
| 9 | Damage | 4 | ×1.25 weapon damage | +25% | 400 coins |
| 10 | Damage | 4 | ×1.5 | +50% | 2 gems |
| 11 | Damage | 4 | ×2 | +100% | 4 gems |
| 12 | Health | 1 | 0.67 (damage-taken mult, so about +50% effective health) | +50% | 2 gems |
| 13 | Health | 1 | 0.5 (about +100% effective health) | +100% | 4 gems |
| 14 | Gems | 6 | ×2 gems collected | X2 | 800 coins |
| 15 | Gems | 6 | ×3 | X3 | 1,600 coins |
| 17 | Magnet | 0 | "COINS AND GEMS FLY TO YOU" | — | 4 gems |

Commented out in the source: Coins ×4 (`cons_coins_3`), Gems ×4 (`cons_gems_3`).

Coins buy the boosters that earn gems, and gems buy the boosters that earn coins. This is a
deliberate currency cross-feed.

### 7.3 Blueprints: the upgrade unlock gate

Enemies steal the agency's **blueprints**. Killing the carrier drops one ("FINDERS KEEPERS!"),
and delivering blueprints to the **Eagle-7** checkpoint train unlocks upgrade levels ("BLUEPRINT
RECOVERED / UPGRADE %i UNLOCKED"). An unlocked level still has to be **bought with coins**
("BLUEPRINT REQUIRED" is shown on locked levels).

`unlockItems(n)` picks each unlock using weighted buckets over all weapons and gadgets of all characters:

1. Find the lowest `levelUnlocked` across the pool. Items more than 2 levels above it are ignored.
2. Split items into those belonging to an **owned** agent and those belonging to an unowned one, and group each set by distance from the lowest level (+0, +1, +2).
3. If any **owned item at the lowest level** exists, pick only from that group (weight 1000).
4. Otherwise use the weights: owned+1 = 500, owned+2 = 100, unowned+0 = 500, unowned+1 = 100, unowned+2 = 50.

The effect is catch-up behaviour that keeps your owned gear evenly levelled and occasionally
teases unowned agents' gear.

### 7.4 "Chubwick's Surplus": rotating gem shop ("NO BLUEPRINTS REQUIRED!")

`specialsQuery(refreshInterval, coinToGemRatio, lockedMod, unlockedMod)` works as follows:

1. Loop over each weapon and gadget, and over each level above the owned level.
2. Accumulate a cumulative price. Coin prices are divided by `coinToGemRatio`. Each step is multiplied by `lockedMod` if the level is still blueprint-locked, otherwise by `unlockedMod`, then rounded up with `ceil`.
3. Every *locked* level becomes a candidate priced in gems at the cumulative cost, so it buys all intermediate levels at once.
4. Sort the candidates by price and pick 3 using a normal distribution within the percentile bands **0–20%, 20–40% and 40–100%**: one cheap, one mid and one premium offer. Each pick removes all other offers for that item.
5. Refresh on a server-set timer ("REFRESH IN:"). Buying sets `levelOwned` straight to that level.

### 7.5 IAP and other monetisation hooks

- **ID 32**, tab 5, category 20: "LIMITED TIME OFFER! UNLOCK ALL PLAYABLE CHARACTERS FOR ONE AMAZING PRICE." The price comes from the store and is not in the file.
- **Bob**: free with any IAP.
- Coin and gem packs are sold in "THE VAULT", with a "GET COINS FOR FREE! WATCH AN ADVERT" entry. The pack definitions are not in db.lua.
- The Vault also has "Restore items", and Review/Twitter/Facebook rewards.
- **Revive**: "REVIVE … FOR [price]" or "FOR FREE" via an ad, or "GIVE UP!". The price is not in the DB.
- **Healing Station** on the Eagle-7: "REPLENISH" to "FULL HEALTH". The price is not in the DB.
- **Mission skip**: "SKIP MISSION … TO SKIP MISSION". Paid; cost not given.
- Rate-me prompt rewards gems ("…FOR %s GEMS").
- Out-of-currency popups lead to the shop or a free ad.
- The tutorial grants starting gems ("HERE'S %s GEMS") and coins for the first upgrade.

### 7.6 Legacy economy (pre-1.6, all `deprecated`, refunded)

There are 104 or more deprecated stubs that keep only `price`/`currency`. Decoded by ID packing,
the old game had 3 characters (Graham, Mason, Carrera). Each had:

- 7 weapon slots: 2 free, 5 at 800 coins.
- 5 upgrade levels per weapon at 1,200 / 1,600 / 2,000 / 2,400 / 3,000 coins.
- A 9-step track at 500 → 4,500 coins.
- Two 4-step tracks at 2,000 → 5,000.
- A 3-step track at 3,000 / 9,000 / 18,000.
- Several free/1,000-coin pairs.

There were also old gadgets at 250 coins, old gadget IDs mapped to new successors, and
CDW/Jetpack event upgrades at 100 gems. Update 1.6.0 notes: "9 NEW CHARACTERS, NEW WEAPON AND
GADGET SYSTEM, NEW CHARACTER SKILL SYSTEM, NEW CHALLENGE SYSTEM, NEW BOOSTER SYSTEM". All
purchases were refunded "plus a little more".

---

## 8. Challenge chains (per-character `challenges`)

From the locale:

- "CLIMB ABOARD THE CHALLENGE CHOPPER": a **daily** challenge with a different agent.
- Complete the current step to unlock the next one. "DAY STREAK LOST" and "NEW DAY IN:" mean one step per day.
- Completing the 5-step chain claims a top prize plus a **one-time % discount on that agent** ("%s%% OFF").
- Survival challenges are **"SURVIVAL MODE - ONE HIT DEATH"**.

Modes: `1` Oriental (ninjas) survival, `2` Horror (undead) survival, `3` Future (robots)
survival. For these, `target` = waves, and the text reads "%s WAVES AGAINST THE NINJAS/UNDEAD/ROBOTS".
`4` CDW and `5` Jetpack use `target` = metres ("TRAVEL %s METERS"). `difficulty` runs 0–2.

| Agent | Step 1 | Step 2 | Step 3 | Step 4 | Step 5 |
|---|---|---|---|---|---|
| Bob*, Mason, Dino Graham, Wonder | Ninjas 5 waves (d0) | Jetpack 500 m | Robots 6 (d1) | CDW 800 m | Undead 7 (d2) |
| Graham | Undead 5 (d0) | CDW 500 m | Robots 6 (d1) | Jetpack 500 m | Ninjas 7 (d2) |
| Razor | Undead 5 (d0) | CDW 500 m | Robots 6 (d1) | Jetpack 500 m | Ninjas 7 (d2) |
| Carrera | Undead 5 (d0) | CDW 500 m | Robots 6 (d1) | Jetpack 500 m | Ninjas 7 (**d1**) |
| Carrera Bear, Hal, Bingo Bango | Undead 5 (d0) | CDW 500 m | Ninjas 6 (d1) | CDW 800 m | Robots 7 (d2) |
| Kitty Mason, Dead Zed, Wei | Jetpack 400 m | Robots 5 (d0) | Undead 5 (d1) | Ninjas 5 (d1) | Jetpack 600 m |

\*Bob has a chain defined but no `allowInChallenge`.

---

## 9. Game structure inferred from strings (for context)

- **Run structure:** an endless run of hostile **trains**. The player jumps between them ("MAKE %s TRAIN JUMPS", "NEXT TRAIN / JUMP FROM HERE"). Train themes:
  - **Oriental / "Orient Express"**: ninjas, Samurai boss
  - **Horror**: the undead, wolfmen, Vampire and Skeleton bosses
  - **Future**: hover robots, exploding robot, Robot boss
- **Eagle-7 checkpoint train:** a hub with Healing station, Barracks, Vault, Missions, Surplus and Challenges. Enter via "LEAP TO EAGLE-7".
- **Events on a train:**
  - Boss ("KILL THE BOSS")
  - Hostage rescue: find the key holder, kill him, smash the body, grab the key, free the hostage
  - **CDW** ("Cylindrical Death Weapon"): a rolling vehicle mini-game, tap to jump, avoid missiles and obstacles
  - **Jetpack**: tap to boost
  - Survival waves ("SURVIVE %i WAVES")
- **Mayhem:** kills fill the meter, and a full meter grants a free gadget or mech suit. Modified by the Mayhem booster and abilities 103/112/113/114.
- **Health/armour:** shared squad HP. Missions mention "full armour" and "in your underwear/underpants", so damage visibly strips armour down to underwear. A multiplier combo system: "GET A 3X/4X/6X SCORE MULTIPLIER", "COMBO!".
- **Mission types (locale):**
  - Kill counts: by enemy type, in air, on same carriage, with jetpack, CDW, airstrike, mech or spin
  - Bosses: kill N, no damage, with spin, with all 3 characters, in underwear, finish with Melee drone
  - Collection: coins (in underwear, in CDW, in jetpack, between trains), crates
  - Score and multiplier
  - Reach the Oriental or Future train
  - Revive yourself, rescue hostages, clear N trains, train without damage / swapping / pickups
  - Gadget use: use two drones, block N projectiles with Defender, deploy Healer under 10% HP
  - Smash N corpses with spin or Smasher, buy anything, complete Survival
  - "Die inside a carriage on the Orient Express"
  - Character-specific: Graham 3× multiplier N times; Carrera heal from underpants to full
  - Squad of three: "COMPLETE A BOSS FIGHT USING ALL THREE CHARACTERS" implies 3 equipped agent slots.
- **NPC:** Chad Chubwick (video drone or narrator; runs the Surplus shop).

---

## 10. Unclear or worth verifying

- Base weapon damage/fire intervals and spin-attack damage are recovered in [[Original Game - APK Balance Audit]]. Still unresolved: charged/DoT formulas, drone and mech weapon stats, and modifier stacking (all native, `libMainApp.so`).
- The units of `heal_time`, `heal_kill` and `heal_fullMayhem` are unknown. Treat them as fractions of max HP until confirmed.
- `CHARACTER_RESILIENCE` and the `resillence` ability are assumed to be damage-taken multipliers (lower = tankier), consistent with the "def" tables.
- Server values: `refreshInterval`, `coinToGemRatio`, `lockedMod`, `unlockedMod` for Surplus, plus any price-tier overrides.
- `tab=0` for Air Strike: probably "not shown in a shop tab" (always available, free).
- Data typos: Freeze Drone L6 duration 41, Melee Drone L5 duration 41.
- The Heal Suit `title` uses a short-name key (`GADGET_SN_HEAL_MECH_SUIT`). This is harmless.
