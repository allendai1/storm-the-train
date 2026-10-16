---
tags: [reference, original-game, decompiled, run-structure, spawning, events, pickups, boosters, missions, economy]
status: reference
updated: 2026-10-16
---
# Original Game - Run Structure and Meta (Native Code)

> **Reference only, never canon.** This describes *Storm the Train* (2016), not our game.
> It was decompiled from `lib/x86/libMainApp.so` with Ghidra 11.4 on 2026-10-16. An
> analysis agent wrote it, and Claude spot-checked the key claims against the code.
> **[code]** means read from decompiled code or data; **[inferred]** means a reading
> that hasn't been checked in the running game. Addresses are Ghidra's (ELF VA + 0x10000).
> Start with [[Original Game - Combat Feel (Native Code)]]. The proposals for our game are
> in [[Hit Feedback]].

Source: Ghidra pseudocode of `libMainApp_x86.so` and constants read with `rd.py`. This note extends the vault's Lua-based notes and doesn't repeat them. Units: px on 1024×768, with **15 px ≈ 1 stud**. The CDW and jetpack "metres" are **50 px = 1 m** [code, `DAT_00225370`=50]. `[code]` means read directly; `[inferred]` means it's my interpretation.

---

## 1. Difficulty ramp

### 1.1 `LevelManager::RampableValue` is per *train*, not per time
- `Set(start, end, steps)`, then `Update(level)`: `t = min(level/steps, 1)`, `value = round(Tween(linear, start, end, t))` [code, `RampableValue::Update @ 134ec0`].
- It updates only in `LevelManager::NewLevelReached @ 1353d0`, which is called from `CheckpointEvent::SetState` (states 11/12, after the jump to the next train) [code]. **"Level" = the hostile-train index.**
- Three ramps are set in `LevelManager::Clear @ 135070` [code]:

| Ramp | Start → end | Steps | What it controls |
|---|---|---|---|
| `+0x38` | 6000 → 5250 px (400 → 350 studs) | 2 trains | Length of each plain hostile-carriage **span** between events |
| `+0x48` | 1 → 2 | 2 | Minimum events per train |
| `+0x58` | 2 → 3 | 2 | Maximum events per train |

So by train 3 the ramp is done: spans of 5250 px and 2–3 events per train. **None of these ramp spawn caps or wave timers** [code].

### 1.2 The enemy timeline is per *run*, gated by spawning
- `EnemySpawner::Reset` runs only from `EnemyManager::Reset` ← `GameMain::Reset`, so `SPAWN_GROUP_NORMAL` is **one timeline for the whole run** and isn't restarted per train [code]. This answers open question 7 in the vault note. If tutorial 0 is done, `Reset(true)` **skips the Intro group** [code].
- A root group's enable timer counts down **only after that group has spawned at least one enemy** (`ActiveSpawnGroup[8]`). The spawner is also frozen while `EnemyManager` spawning is paused, which happens during boss, survival and tutorial events [code, `EnemySpawner::Update @ 103620`].
- The START→END lerp uses `t = (enable − remaining)/enable` of the **root** group. Children share the root's `t` [code, `CanSpawn`, `SpawnWave`].
- **No per-environment scaling** in code. The same table drives every theme [code].

### 1.3 Event difficulty scales with the current **score**, not the train number
Every event computes `tier = floor(score / 40000)` (`DAT_00225400`) or similar on `Init`/`Trigger`. See §4.

---

## 2. Spawner (`EnemySpawner`)

| Rule | Detail | Source |
|---|---|---|
| Wave timer | Counts down only while `aliveCost + avg(budgetMin, budgetMax) ≤ cap`. On a spawn failure (no valid location) it retries after **0.25 × wave time**. A child's first wave is at **0.5 × wave time** | [code] `UpdateSpawnGroup @ 1033b0`, `ActivateChildSpawnGroup` |
| Budget | `budget = rand(min, min(max, cap − aliveCost))`, with min, max and cap each lerped and rounded. Loop: pick a random ID from the pool and re-roll if it costs more than what's left. Stop when what's left < the cheapest cost in the pool | [code] `SpawnWave @ 102df0` |
| Alive-cost accounting | Each group **claims** the alive cost of the enemy IDs in its own pool. For the **root** group, children claim first, then **all unclaimed alive cost (e.g. a leftover mid) is added to the root**. That's why "lights cap 9" stays blocked while a 15-cost mid lives: the "after mid kill" beat is emergent, not scripted | [code] `GetCurrentEnemyCost`, `ClaimCost`, `ClaimAllCost` |
| Spawn side | Default: a 1-in-3 roll to spawn **behind** (left of the camera − 50 px), only if the player isn't moving forward and the train extends 200 px past that point. Otherwise **ahead**: camera right + 50 px (≈3 studs off-screen), only if the train extends 200 px (13 studs) beyond. `SPAWN_FLAG_SINGLE_MID` forces **ahead** | [code] `GetSpawnLocation @ 102b50` |
| Within a wave | Each extra enemy is placed a further **40–150 px** (3–10 studs) out on the same side | [code] |
| Despawn | 512 px (34 studs) beyond either screen edge | [code] `EnemyManager::Reset` |
| Mids | The 3 mid slots are shuffled per run (already known). Group chaining = `NEXT` (+0x30) when the root timer expires; `SIBLING` (+0x34) is activated as a chain of children | [code] |
| `EventSpawner` (CDW, jetpack, mech) | Keeps the alive cost at a target of `{0,4,5,6,8}[state]`. Spawns once the deficit is > 30 % of target, up to 70 % of target at once, using **only enemy types already seen this run**. No mids while a mid is alive | [code] `EventSpawner::Update @ 106760`, `GetSpawnID` |

Key holders and bosses are spawned by events via `AddRandomEnemy(x, group)`, using group 3 (`KEYHOLDER`) and group 1 (`BOSS`), not by the timeline. See §4.

---

## 3. Train and level generation

### 3.1 The event queue per train [code, `MakeMoreCarriages @ 136260`, `PopulateEventQueue @ 135950`]
Carriages are streamed when the train end comes within 512 px of the screen's right edge. The generator alternates **span → event → span → event…**:

```
n = rand(min, max)                     // ramps 1-2 on train 1, then 2-3
queue = [ (n-1) × deck events ] + [BOSS] + [CHECKPOINT]
train = span(6000→5250 px) | event | span | event | … | span | BOSS | span | CHECKPOINT(engine)
```
- **Deck** (`PrepareEventDeck @ 135790`): Fisher–Yates shuffle of {Hostage 0, Jetpack 2, CDW 3, Survival 4}, filtered by `IsEventAvailable`. Unlock bits: 0x80 Hostage, 0x20 Jetpack, 0x40 CDW, 0x800 Survival, 8 Boss, 0x10 Checkpoint. It's dealt **without repeats until empty**, then reshuffled. All events have **equal weight** [code].
- **Every hostile train ends with a boss, then the checkpoint**, and therefore also with the Eagle-7 home-train visit [code]. Train 1 can have 0–1 deck events; later trains have 1–2.
- `Mission::Activate` can call `PushEventFirst` to put the event a mission needs at the front of the deck. Example: the "kill a boss" mission unlocks 8 = boss. That's how missions double as the tutorial gate [code].
- Event IDs: 0 Hostage, 1 Boss, 2 Jetpack, 3 CDW, 4 Survival, 5 Intro, 6 GadgetIntro, 7 BlueprintIntro, 8 CharSwapIntro, 9 EagleStart, 10 Checkpoint, 11 none [code].
- A normal run starts with `ForceEvent(9)` (EagleStart: start on the Eagle and jump to train 1). The tutorial runs force 5 → 9 → 8 → 7 in sequence [code, `GameControl::Begin`/`ForceNextTutorial`].

### 3.2 Carriage choice [code, `TrainManager` ctor table `@0x29a320`, `LevelNode`]
- There are 35 records, shared by all three themes (each mesh name is prefixed with the theme): coach 250/500 (front 37 px / rear 180 px), closed coaches, freight 500 (180 px), half-freight (99 px), flatbed 250/500 (37 px), prisons ×3 (hostage), coal tender 250, engine 752 px.
- **Appearance runs**: segments of **2000–2500 px** that share a look group (1 open, 2 low, 4 closed). Each new segment differs from the previous one [code, `GetRandomAppearanceDist`, `GetRandomAppearance`].
- **Run-length rules by height class**: coaches 2–3 in a row, tall freight 2–3, flatbeds 1–2. **Allowed-next mask**: coach → coach/flatbed; tall → tall/flat/engine/tender; flatbed → anything. Height changes therefore go through flatbeds [code, `GetMin/MaxRepetitionAmount`, `InitCarriageRecord`, `IsValidNewCarriage`]. There are 50 tries, then it falls back to a flatbed.
- **New train**: spawned **475 px (32 studs) after the old train's end**, starting with **1500 px (100 studs) of low coaches and flatbeds** as the landing zone [code, `SpawnNewTrain`, `StartNextTrain`].
- **Train end**: 3 coal tenders + the engine (≈1500 px). Inserting an engine always adds an **engine coin shape** [code, `EndActiveTrain`, `Train::InsertLevelNode`].
- **Next environment**: picked at the checkpoint. It's random among the unlocked themes **excluding the current one**, unless a "REACH_X" mission forces a theme (flags 0x10000/0x20000/0x40000) [code, `PickNextTrainJumpEnvironment`, `GameMain::PickRandomEnvironment`].

### 3.3 Checkpoint flow (`CheckpointEvent::SetState @ cf200`) [code]
End the train → jump to the Eagle (`TrainJump`) → `LevelCompleted` (the "train completed" mission count) → **bank blueprints** (`ItemDatabase::UnlockItems`) and **clear the boosters** → Eagle hub (with tutorials) → spawn the next train → **booster menu** → jump → change environment → `NewLevelReached`.

**Finish line:** `EnableFinishLine` is used only by CDW and jetpack, at the target distance (§4). There's no finish line on normal trains [code].

---

## 4. Events: rules and rewards

**Reward core** [code, `LevelEvent` ctor, `GiveCurrencyReward @ 134970`, `GiveScoreReward @ 134920`]:
`coins = floor(f × 500)` and `score = f × 20000` (a flat event score that ignores combo), where `f ∈ [0,1]`. The coins also feed the gem counter (§5).

| Event | Rules and numbers | `f` (reward fraction) |
|---|---|---|
| **Boss** | The arena is 1000 px (67 studs) of boss carriages (height ≤ 290, adjacent within ±30 px) with barriers at both ends. The boss is at arena start + 600 px. Normal spawning is paused and enemies flee. By `tier = floor(score/40000)`: **bosses** `[1,1,1,2,2,2]` (275 px apart). The **BOSS_EXTRA stage** is 0 for tier 0, then `[1,2,0,1,2]` for tiers 1–5+. The stage is **picked once by score; it doesn't advance with boss HP**. Extra waves: the first comes at 0.5 × wave time, then every wave time; they spawn just off-screen on a random side | `tier×0.15 + 0.25`, max 1 (1.0 at tier ≥ 5). That's **125 → 500 coins, 5000 → 20000 score** |
| **Hostage** | Prison carriages from the ordered records (0x8008). There are **2 pressure pads** (key-box sensors) on two carriages. Loop ×2: spawn a **key holder** (group 3, key-box visuals, patrols) → kill it → "SMASH" the box → the key flies out (±200, 400 px/s with spin) and can be picked up after 0.5 s → carry it to a pad, which closes that cell. After 2 keys the hostage carriage opens ("NPC_HOSTAGE_FREE") | Same score tier formula as the boss |
| **Survival (in run)** | The arena is 1250 px (83 studs) of 264 px-high carriages. Waves = `min(8, tier + 3)`. Start node skip = `min(15, floor(score/100000)×10 + 5)`. Difficulty = `min(2, floor(score/100000))`. There's a 0.75 s lead-in, a 2.5 s break between waves, **+100 × wave** accumulator score per wave, and one **weapon crate** dropped per cleared wave (if none exists) ≥ 50 px from the player. Enemies spawn 50–100 px off-screen on a random side | `waves × 0.125` (3 waves = 187 coins) |
| **CDW** (cylinder ride) | Target `min(1200, floor(score/20000)×50 + 400)` m. Speed 700 px/s (47 studs/s), then 750, 775, 800, 825 and 850 px/s after 150, 350, 700, 1000 and 1500 m. Enemy spawn spacing tweens 1000 → 400 px over 90 m (×0.8–1.2). Groups of 1–2 or 2–4. Coin and mine **patterns** come from `PatternDataManager` | Coins on reaching the target: `min(1, m/2000)`. Score on end: `min(1, m/2000)` |
| **Jetpack** | Target `min(800, floor(score/20000)×50 + 300)` m. The jetpack has **10 or 20 HP** (event upgrade level 0/1), and a hit > 7.5 gives 1 s of invulnerability. Spawn spacing 1000 → 700 px over 90 m | Coins at the target `min(1, m/1200)`, score `min(1, m/2000)` |
| **Challenge chopper / `FE_ChopperEvent`** | Front-end and hub vehicle that launches the daily challenge (§8). CDW and jetpack challenges replace the target with the challenge target | n/a |

[code] for all of the above: `BossEvent::Init @ b5190`, `HostageEvent::Init/SetState/Update`, `EnemySurvivalEvent::Trigger/Update @ 103bb0/1041f0`, `CDWEvent::Init @ b8420`, `JetpackEvent::Init/Update`. The tier tables are at `DAT_00230000/00230014`.
`EnemySurvivalEvent::SpawnMinesAtX` builds a vertical column of mines from roof + 35 px up to y 795, every 75 px [code]. Its caller isn't visible.

---

## 5. Pickups (`PickupManager`)

| Item | Rule | Source |
|---|---|---|
| Pickup types | 0 = **weapon crate** (coins + `GiveRandomWeapon`), 1 = coin, 2 = gem, 3 = blueprint | [code] `HandleContact @ 147300` |
| Coin value | **1 coin each**, × coin booster, then **×2 with the coin-doubler IAP** | [code] `PlayerProfile::AddCoins` |
| Crate coins | `rand(b, b+10)`, with `b = min(100, 10 + (runTimer/600 s) × 90)`: **10–20 coins at the start, rising to 100–110 at 10 min** | [code] `AddPickup @ 146d20` |
| Crate spacing | Every **3072–4096 px (205–273 studs)** ahead of the camera, once feature 0x400 is unlocked | [code] `Update`, `Reset` |
| **Gem drop** | A counter adds every coin placed (shape coins, crate coins, event coins). When it passes a random threshold in [0, 400], the next coin **becomes a gem**, and the counter drops by 400. **That's 1 gem per 400 coins on average** | [code] `AddCurrency @ 146840`, `LevelEventCoinsAwarded` |
| Coin shapes | The next shape is at the last coin + **768–1280 px (51–85 studs)**, never on an engine. The shape class comes from the geometry: 0 = on a two-height coach, 1/2 = a line 135–140 px above a flat run ≥ 250 px (2 over flatbeds), 3 = **step up** (at the next carriage's start), 4 = **step down/gap** (at the carriage end, when the next carriage is > 120 px lower), 5 = over the engine. There are 20 bitmap-grid defs; a centred flag offsets the shape | [code] `CoinShape::Init @ d0a60`, `CoinData::BuildCoinShapeDef` |
| **Magnet** | Only from the **Magnet booster** (consCat 0). Radius **360 px (24 studs)**; it pulls toward the player's chest. Pull speed ramps **0 → 900 px/s (60 studs/s) over 1.2 s** per coin. It **lingers 5 s** after the booster ends. There's no magnet pickup | [code] `Update @ 1476b0` (disassembly), `CurrencyPickup::Update` |
| Lifetime | No timer. Pickups are culled when **2048 px (137 studs) behind** the screen's left edge | [code] |
| Blueprint thief | The interval is `min(1200 s, 80 s + n^1.28)`, with n = blueprints held + owned − 1. It runs on cumulative play time saved in the profile, during normal play only. On a valid kill the thief drops a type-3 pickup with a toss | [code] `BlueprintController::StartGame/Update`. The exact meaning of n is [inferred] |
| `ResetNextPickupDistances` | Re-rolls the next crate (3072–4096 px) and coin-shape (768–1280 px) distances. It's called by the jetpack event. **Spawning is distance-based** | [code] |

---

## 6. Score
- Reasons: 0 damage, 1 kill, 2 gib, 3 event (flat) [code, the callers of `GameMain::AddScore`].
- `points = value × 20 × comboLevel × modeScalar × scoreBooster`. `modeScalar` is ×0.2 in a mech, ×0.05 during CDW and ×0.5 during jetpack. Event points (reason 3) skip the combo and mode scalars but **do get the score booster** [code, `GameControl::AddScore @ 110bf0`, `GetScoreScalar @ 110b20`, table `DAT_00232d18`=20,20,20,1].
- **No score for distance, train clears or leaps** [code: there are no other callers]. The only flat bonuses are event rewards (5k–20k) and survival waves (100 × wave).
- **High score is kept per game mode** (7 modes) at the run total, set in `GO_Totup::WillAppear` [code, `SetHighScore`].

---

## 7. Boosters (`ConsumableManager`)
| consCat | Effect (`modifier` from db.lua) | Read in |
|---|---|---|
| 0 | Magnet (on or off) | `PickupManager::Update` |
| 1 | Damage **taken** × (0.67 / 0.5) | `Character::HandleDamage`, mechs |
| 2 | Coins × | `PlayerProfile::AddCoins` |
| 3 | Mayhem gain × | `GameMain::AddMayhem` |
| 4 | Damage **dealt** × (1.25 / 1.5 / 2) | `Enemy::ReduceHealthByDamage`, `Shield::TakeDamage` |
| 5 | Score × | `GameControl::AddScore` |
| 6 | Gems × | `PlayerProfile::AddGems` |

- **Up to 3 equipped.** `GetConsumableModifier` returns the **first** equipped item of a category, so there's **no stacking within a category**. Different categories multiply independently [code `@ d12a0`].
- **Duration = one train.** `ClearEquipped` runs at checkpoint state 5 (before the booster menu), at game over and at `GameController::Begin` [code].

---

## 8. Missions, achievements, challenges

### 8.1 Missions (`GameMissionManager`) [code]
- **3 active slots** (`GetNumConcurrentMissions` = 3).
- There's a fixed **ordered list of 69 missions** (the ctor `@ 11a5c0`). `ChooseNewMission` takes the **first** mission in list order that is allowed (feature or `levelOwned` requirement), not active and not complete, with iteration ≤ the global tier. When nothing qualifies, the tier goes up by 1, so **the list repeats with the same targets**. A completed mission is `PromoteIteration`'d.
- **Reward = 1–6 gems** (`TotupMission` → `AddGems`).
- **Skip = 1000 coins**, flat (`MissionRow` ctor). The mission is force-completed with **no gem reward**. There's **no reroll**.
- The flag reads "IN TOTAL" (cumulative) or "IN A SINGLE GAME".
- The first missions in order:

| # | Mission | Target | Gems |
|---|---|---|---|
| 0 | Kill | 50 total | 1 |
| 1 | Kill boss (unlocks bosses, pushes a boss event) | 1 | 3 |
| 2 | Collect crates | 8 | 1 |
| 3 | Reach Future (forces the theme) | 1 | 1 |
| 4 | Score | 24,000 total | 3 |
| 5 | Get ×4 multiplier | – | 1 |
| 6 | Kill zombies | 25 | 1 |
| 7 | CDW (unlocks CDW) | 400 m | 3 |
| 8 | Reach Oriental | 1 | 1 |
| 9 | Use revive | 1 | 1 |
| 10 | Coins in underwear | 150 total | 3 |
| 11 | Rescue hostage (unlocks hostage) | 1 | 3 |

  Later entries include:
  - #19 kill 100 with the jetpack (unlocks the jetpack),
  - #26 Survival (unlocks 0x800),
  - "Train without damage", "Kill 300", "CDW 800 m" (4 gems) and "Distance trains 20" (6 gems).

  The # column is the list position, i.e. the order in which `Mission::Init` is called.

### 8.2 Achievements (`AchievementManager` ctor `@ ae140`) [code; names matched to IDs through the Google Play ID order in `strings.xml`, [inferred]]
| Name | Tracks | I / II / III |
|---|---|---|
| Good Student | Tutorials 0 / 4 / 6 done | 1 / 1 / 1 |
| Skippy | Train jumps | 1 / 50 / 500 |
| Mutiny | **Bosses** killed (`IsBoss`) | 1 / 30 / 150 |
| Massacre | Enemies killed | 500 / 5,000 / 100,000 |
| Completist | Lowest mission iteration (full list passes) | 1 / 3 / 10 |
| Globe Trotter | Distance moved (m = px/50) | 10,000 / 100,000 / 1,000,000 |
| Techie | Gadgets deployed | 30 / 300 / 1,000 |
| Seasoned | **Cumulative score** (added at game over) | 250,000 / 2,000,000 / 50,000,000 |
| Metamorph | Character swaps | 20 / 500 / 1,000 |

IDs 0x11–0x13 (1/1/1) and 0x1A–0x1C (1/5/10) are registered but never incremented, because `ChallengeCompleted` is empty. They're cut [code].

### 8.3 Daily challenge (`ChallengeManager`) [code]
- **One per UTC day.** The period is 86,400 s and the reset falls at `now − now % 86400`.
- Gated by tutorial 6.
- A **5-step chain per character**. It uses the `challenges` table from that character's DB entry (`mode`, `target`, `difficulty`).
- Modes: 1–3 = survival in Oriental, Horror or Future (**one-hit death, no revive, gadgets locked**; target = waves), 4 = CDW metres, 5 = jetpack metres.
- **Rewards by step: 300, 600, 1200 and 2400 coins, then 20 gems.**
- After the 5th step a new random `allowInChallenge` character is picked, never one of your two equipped characters.

### 8.4 Specials (Chubwick's Surplus)
`ItemDatabase` ctor defaults passed to `specialsQuery`: **refreshInterval 600 s, coinToGemRatio 400, lockedMod 1.2, unlockedMod 1.0** [code `@ 130f80`]. No server override for these is visible in code.

---

## 9. Economy constants

| Constant | Value | Source |
|---|---|---|
| Coin → gem ratio | **400** (Specials pricing *and* the in-run gem-drop rate) | [code] |
| Specials refresh | **10 min** | [code] |
| Revive (gems) | `2^n`, capped at 32: **1, 2, 4, 8, 16, 32, 32…**, with n = heals and revives used this run. The first death with zero progress revives free ("HEAL_DEAD_START"). An ad option is tagged "revive". There's no revive in survival or challenge mode | [code] `HealDisplay::GetReviveCost @ 1243e0` |
| Heal (coins, paid) | `(1 − hp%) × 150 × 2^n`, capped at 20,000 | [code] `GetHealCost` |
| `offers.offerGems` | 10 | [code] `GetParam_Int32` default |
| `offers.recruitGems` | 50 | [code] |
| `offers.interstitialDelay` | 600 s | [code] |
| `offers.timeDelay` | 86,400 s (special-offer popup) | [code] |
| `rr_promo.coins` / `rr_promo.gamesRequired` | 2500 / 1 | [code] |
| `iap.coinDoubler.enabled` / `iap.allCharacters.enabled` | false / true | [code] |
| IAP packs | coins `currency_20/10/5/2`, gems `gems_4..1` | [code] `RegisterIAP` |

---

## Most useful for our game
- **Loop (M2), run ramp:** the original ramps the **layout** per train (span 400 → 350 studs and events per train 1–2 → 2–3, done by train 3). The **enemy timeline runs once per run** and pauses during events. This supports our "combat-time timeline across the run". Our cap +10 %/train is a reasonable substitute, because the original has no per-train cap scaling.
- **Event difficulty keyed to score tiers** (every 40k: more bosses and extra adds, more survival waves; CDW and jetpack targets +50 m per 20k). It gives catch-up for weaker players. Consider tying our event strength to the run score or leg number.
- **Emergent mid beat:** the root group counts unclaimed alive cost, so lights stall until the mid dies. If we copy the claim rule, we don't need a scripted "wait for mid kill".
- **Spawn ahead, just off-screen** (≈3 studs past the edge, 3–10 studs between extra enemies, a 1-in-3 behind roll only when the player isn't advancing). This maps directly onto our side-on camera.
- **Boss at the end of every train in the original.** Our "boss every 2nd leg" is much rarer. Event rewards of 125–500 coins and 5k–20k score scale with tier, so our flat bonuses (1,000) are small next to the original's event payouts.
- **Gap coins exist as a shape class** (step-down/gap at the carriage end), plus an engine coin shape on every train. Coin shapes every 51–85 studs, crates every 205–273 studs.
- **Economy:** gem drop = 1 per 400 coins placed, which matches the Surplus ratio of 400. Revive 1/2/4/8/16/32 gems; paid heal 150 × 2^n coins per missing 100 % HP. Our free medbay is a deliberate change.
- **Magnet:** 24 studs radius, pull 0 → 60 studs/s over 1.2 s, 5 s linger. Boosters: there's no same-category stacking, and every booster is cleared at each checkpoint. In the original that's one train, because every train ends at a checkpoint. *(Claude's note: in our 3-train legs, the equivalent rule "until the next checkpoint" would mean a whole leg. Our decided "one train" rule doesn't match it; see [[From the Original - Proposals]].)*
- **Missions:** a linear 69-mission sequence with 1–6 gem rewards, skip 1000 coins, no reroll. Our "skip 5 gems + daily reroll" is a deliberate change. Missions also gate the tutorial and event unlocks via `PushEventFirst`, which is a good pattern for introducing events.
- **Daily challenge** rewards of 300/600/1200/2400 coins then 20 gems over 5 days are a ready baseline for our agent-trial chain.

## Couldn't determine
- The 20 coin-shape bitmaps (BSS `0x2b15a0`, filled by a static initialiser I couldn't locate).
- The exact BOSS_EXTRA stage contents beyond the stage index. The Lua group data is already in the vault.
- The caller of `SpawnMinesAtX`, and what `PatternDataManager` contains (CDW and jetpack coin, mine and missile patterns).
- How achievement names map to IDs is inferred from ordering, not proven.
- Achievement IDs 0x11–0x13 and 0x1A–0x1C (unused).
- Whether "underwear" missions mean "no armour".
- The blueprint thief's spawn placement inside its jump table (`DAT_0022ff6c`), and its per-event gating.
- Server overrides for the Specials parameters, if any exist outside `ItemDatabase`.
- The full list of `offers.*` and `iap.*` keys beyond those listed.

Related: [[Original Game]] · [[Original Game - Combat Feel (Native Code)]] · [[Original Game - Enemies and Spawning]] · [[Hit Feedback]]
