---
tags: [reference, original-game]
status: reference
source: /Users/allen/re/storm-drain/unpacked (Storm the Train v1.7.4 Android APK, Games Faction 2016)
---
> Reference only: describes the **original 2016 mobile game**, not this Roblox project. Not design canon. See [[Original Game]].

# Storm the Train (Android, 2016): assets and binaries findings

Source: `/Users/allen/re/storm-drain/unpacked` (read only, nothing executed).
Scope: everything except `assets/scripts/*.lua`, which other agents cover.
Helper scripts are in `/Users/allen/re/storm-drain/extracted/tools/`. Converted art is in `/Users/allen/re/storm-drain/extracted/sprites/`.

Confidence tags: **[confirmed]** means read directly from the data. **[inferred]** means a reasonable reading of names or structure that has not been checked against the running game.

---

## 0. TL;DR for the Roblox remake

- **Core loop [confirmed by text and code]:** a side-scrolling 2D run-and-gun on the roofs of moving trains.
  - The player's agent jumps from train to train ("NEXT TRAIN", "JUMP FROM HERE", "LEAP TO EAGLE-7") and clears hostile trains of enemies.
  - Each train is themed: **Oriental (ninjas)**, **Horror/Undead (zombies, vampires, skeletons, wolfmen)** or **Future (robots)**.
  - Between runs the player returns to the **Eagle-7**, the player's own armoured train and hub. Its pods (vending machines) are: Health, Barracks, Vault (shop), Missions and Surplus (Chubwick's rotating stock).
- **Controls [confirmed]:**
  - On-screen MOVE LEFT, MOVE RIGHT, JUMP, SHOOT and ENTER buttons, which the player can drag to new positions ("DRAG CONTROLS TO REPOSITION THEM").
  - **Double jump = spin attack**, which also smashes corpses.
  - **Swipe left/right** switches between equipped agents. All agents share one health pool "due to budget cuts".
  - Vehicle and jetpack sections are one-touch: "TAP ANYWHERE TO JUMP" or "TAP ANYWHERE TO BOOST".
- **Systems found in strings and C++ classes:**
  - Agents (13 characters, each with stats and abilities).
  - Weapons: 17 types, 10 upgrade levels each.
  - Gadgets: 6 drones, 3 mech suits and an air strike.
  - Mayhem meter: kills fill it, and a full meter grants a free gadget.
  - Combo/score multiplier.
  - Blueprints: enemies steal them, and you bank them on the Eagle-7 to unlock items and upgrades.
  - Missions: 3 run at once, can be skipped, and pay coins or gems.
  - Daily Challenge Chains via the Challenge Chopper.
  - Boosters: up to 3 consumables per train.
  - Two currencies: coins (soft) and gems (hard).
  - Revive.
  - Visible armour damage: each agent has 3 health states, ending in underwear.
- **Train events [confirmed classes]:**
  - Normal hostile train.
  - **Boss** fight with taunts.
  - **Hostage**: kill the key holder, smash his corpse, grab the key, free the hostage.
  - **Survival** waves with one-hit death.
  - **CDW**, the "Cylindrical Death Weapon": a rolling ball vehicle with a runner section.
  - **Jetpack** flying section.
  - Eagle-7 checkpoint.
  - Intro and tutorial events.
- **Engine:** in-house C++ engine "**Cabal**" (`Ca*` classes), project codename "**GOAT**".
  - Lua 5.1 is the data/script layer, with Box2D physics, OpenGL ES 2, OpenSL ES and stb_image.
  - Characters are 2D cut-out puppets: separate PNG body parts animated by a skeleton stored in the `.cm` model files.
- **Extractability:**
  - Every texture is uncompressed RGBA8888 in a legacy PVR v2 container, stored bottom-up.
  - A pure-Python converter turned all 17 atlases into PNGs and sliced **1,811 individual sprites**. No PVRTexTool was needed.
  - Patterns are tiny TGA grids that encode CDW and jetpack obstacle/coin/missile layouts. They are decodable and directly reusable as level data.
  - Sounds are headerless 16-bit PCM, most likely 22.05 kHz mono.
  - Music is plain MP3.
  - The `.cm` models are a proprietary format, but their structure is regular.

---

## 1. Game text: `assets/Locales/en-GB.locale` (773 lines, read in full)

Format: `KEY = "VALUE"` per line, ASCII, `\n` escapes, printf placeholders (`%s`, `%i`). Mostly ALL CAPS.

### 1.1 Premise and story [confirmed]
- The player runs a team of **agents** for an agency. The guide character is **Chad Chubwick**, who:
  - talks to you through his video drone ("HEY I'M CHAD CHUBWICK'S VIDEO DRONE!!");
  - runs the barracks ("HOME SWEET HOME. I LOVE THE MUSKY SMELL IN HERE");
  - runs a black-market store ("JUST DON'T ASK ME WHERE I GET THEM, OK?").
- Chad's tone is jokey and cheapskate: shared health pool "DUE TO BUDGET CUTS", "TIME FOR A CUPPA?!" He is British.
- Chad's voice lines are in `Sounds/`: `chad_greeting_*`, `chad_love_this`, `chad_heres_what`, `chad_super_duper`.
- Enemies have **stolen the agency's blueprints**. Recovering them unlocks weapons and upgrades ("THE ENEMIES STOLE OUR BLUEPRINTS", "DROP OFF BLUEPRINTS ON THE 'EAGLE-7' TO UNLOCK UPGRADES"). The enemy blueprint carrier taunts "FINDERS KEEPERS!"
- **Eagle-7** is the player's home train: "WELCOME HOME! THE EAGLE-7 GIVES YOU AN OPPORTUNITY TO UPGRADE WEAPONS, CASH IN MISSIONS AND REPLENISH HEALTH."
- Enemy factions and the train indicators that announce them:

  | Faction | Indicator text |
  |---|---|
  | Oriental | "NINJA HORDE!" |
  | Undead/Horror | "THE UNDEAD!" |
  | Future | "EVIL ROBOTS!" |

- Boss taunts:
  - Ninja: "THE SAMURAI WILL WIN!"
  - Vampire: "YOU CAN'T KILL THE DEAD!"
  - Skeleton: "YOU WILL NEVER DESTROY ME!"
  - Robot: "KILL ALL HUMANS", "BIDDY BIDDY BIDDY"
- Hostage lines: NPC "HELP!!!" and "YAY! I'M FREE".
- Credits: "GAMES FACTION IS" Lee Hickey, Malcolm Reed, Ben Dorman, Rob Jones, Joe Saunders.

### 1.2 Tutorial and instructions (core mechanics and controls) [confirmed]

Intro (`TUTORIAL_INTRO_1..7`), in order:
1. The drone introduces itself.
2. "...ANOTHER PESKY ZOMBIE! SHOOT IT QUICK!"
3. "MORE INCOMING!"
4. "KILLING ENEMIES POWERS YOUR MAYHEM SYSTEM"
5. "FULL MAYHEM GIVES YOU A FREE GADGET. GRAB IT NOW!"
6. "GOOD JOB, NOW GET TO THE EAGLE-7"

On death during the tutorial: "TRY NOT TO DIE IN THE TUTORIAL!"

Other tutorial steps:
- **Recruit:** "THIS JOB REQUIRES A TEAM. HERE'S %s GEMS TO GET YOU STARTED!" You must buy a second agent and equip it in your second slot before leaving the barracks.
- **Character swap:** "YOU CAN SWITCH BETWEEN YOUR EQUIPPED AGENTS... JUST SWIPE LEFT OR RIGHT" and "ALL AGENTS SHARE A SINGLE HEALTH POOL."
- **Blueprints:** chase the thief, then bank the blueprints on the Eagle-7.
- **Vehicle sections:** CDW "TAP ANYWHERE TO JUMP. AVOID MISSILES AND OBSTACLES"; Jetpack "TAP ANYWHERE TO BOOST. AVOID MISSILES AND OBSTACLES".
- **Survival:** "GET READY, YOU'RE PLAYING: SURVIVAL MODE - ONE HIT DEATH". Text: "SURVIVE %i WAVES", "WAVE %i/%i", "EVENT SURVIVED!"
- **Boosters:** "YOU CAN EQUIP UP TO 3 BOOSTERS FOR THE DURATION OF THE NEXT TRAIN."
- **Upgrades:** "THE FLASHING BLUE CIRCLE UNDERNEATH AN AGENT MEANS THERE ARE UPGRADES AVAILABLE... CENTER THE AGENT AND PURCHASE THE UPGRADE FOR THE WEAPON OR GADGET." This implies a centred **carousel** of agents in the Barracks.
- **Control labels:** `GC_MOVE_LEFT`, `GC_MOVE_RIGHT`, `GC_JUMP`, `GC_SHOOT`, `GC_ENTER`, `GC_TAP`, `GC_COMBO` ("COMBO!"), `GC_METERS`. Plus `CUSTOMISE_CONTROLS`.
- **Ability text:** "SPIN ATTACK STRENGTH (DOUBLE JUMP)". The spin attack is the double jump.

### 1.3 Characters (agents) [confirmed]

| ID (internal) | Name | Tagline | Personality (from speech) |
|---|---|---|---|
| graham | GRAHAM | "AGENT NO.1" | Cocky secret-agent lead in a suit and headset: "I WAS BORN FOR THIS", "I'M THE BEST!" |
| dinoGraham | DINO GRAHAM | "EXTINCTION EVENT COMING UP" | Graham in a T-rex onesie, embarrassed: "I LOOK RIDICULOUS", "HOPE NO ONE'S WATCHING" |
| mason | MASON | "OLD SCHOOL TOUGHNESS" | Gruff action-movie veteran: "YIPPEE KI YAY", "MEH", "I HATE THESE JETPACKS!" |
| kittyMason | KITTY MASON | "UNLEASH THE KITTY KAT" | Mason in a cat costume: "MEOW!", "ARE WE GOING TO THE VETS?!" |
| carrera | CARRERA | "TOTAL HEALTH FREAK" | Feisty heroine: "YOU HIT GIRLS?", "CANDY FROM A BABY!" |
| carrera_bear | CARRERA BEAR | "TRULY GRIZZLY" | Carrera in a bear onesie: "I CAN BEAR IT!", "YOU RIPPED MY COSTUME" |
| rogue | RAZOR | "DEADLY AND ON YOUR SIDE" | Mercenary: "PAY DAY!", "JUST LIKE BUDAPEST!" |
| hal | HAL | "BRING THE HEAT" | Laid-back Rasta: "CHILL OUT MAN", "RASTA STYLE!" |
| deadZed | DEAD ZED | "DEAD BUT NOT DEAD!" | Friendly zombie whose every line is "AARRGH!" |
| cowgirl | WONDER | "YEE-HA LET'S GO" | Cowgirl: "ROPE EM UP!", "I'D PREFER A HORSE!" |
| wei | WEI | "YES WEI!" | Hyper anime girl: "HE HE HE", "ROBO-WEI, HE HE!" |
| bingo | BINGO BANGO | "HE AIN'T CLOWNING ABOUT" | Killer clown: "CLOWNS DON'T CRY!" |
| bob | BOB | "HERE COME THE BIG GUNS" | Robot: "DIRECTIVES DOWNLOADED", "DAMAGE DETECTED". Free with any in-app purchase. |

- Speech categories, keyed `PLAYER_SPEECH_<CAT>_<CHAR>_<n>`: `START_DEFAULT`, `START_SURVIVAL`, `START_CDW`, `START_JETPACK`, `CELEBRATE` (x5), `DAMAGE` (x4), `ENTER_CDW`, `ENTER_JETPACK`, `ENTER_MAYHEM` (mech suit).
- Lines shared by all agents: `DRONE` ("GO GET EM"), `AIRSTRIKE` ("3.. 2.. 1..", "INCOMING!"), `SWAP` ("I'M BACK!").
- Speech appears as comic speech bubbles (`GameController::AddSpeech`).
- **Ability descriptors** (`CHAR_ABILITY_*`). Agents have positive and negative traits drawn from:
  - resilience;
  - move speed;
  - spin-attack strength;
  - extra damage, or resilience, against one faction (undead / robots / ninjas), and the negative versions;
  - heal over time;
  - heal on kill;
  - heal when Mayhem is full;
  - speed that rises with Mayhem;
  - Mayhem gained when taking damage;
  - Mayhem rate up or down.
- The data keys in the `.so` (`resillence`, `speed`, `mayhemMod`, `spinID`, `horror_dmg`, `future_dmg`, `oriental_dmg`, `*_def`, `heal_time`, `heal_kill`, `heal_fullMayhem`, `mayhem_dmg`, `speed_mayhem`) match these descriptors.

### 1.4 Weapons and gadgets [confirmed]
- **Weapons (17):**
  - Pistol, Dual Pistols, Uzi, Dual Uzi, Rifle, Dual Rifles, Shotgun, Minigun
  - Rocket Launcher, Sticky Bomb Launcher, Sticky Rifle
  - Rail Gun (a charge weapon), Lightning Gun, Heatray, Poison Gun, Plasma Cannon
  - Gears of Gore (saw/gear launcher)
- In the `.so`, every weapon has defs `_1` to `_10` (10 upgrade levels). There are also CHAINSAW and FLAMETHROWER defs, and SHOTGUN has an extra `SHOTGUN_CLOSE_n` variant for close range.
- **Gadgets:**
  - Drones: Turret, Defender (blocks projectiles), Smasher (corpse smasher), Melee, Freeze, Healer.
  - Mech suits: Damage Mech, Melee Suit (the "Defence" mech), Heal Suit.
  - Air Strike.
- Gadget availability can be locked, with reasons such as "DRONE ALREADY ACTIVE", "BETWEEN TRAINS", "MECH SUIT ACTIVE", "JETPACK ACTIVE", "CDW ACTIVE", "ON EAGLE-7" and "ENVIRONMENT CHANGING". These are a good spec for gadget gating rules.

### 1.5 Missions (`MISSION_*`, 52 templates) [confirmed]
Three are active at once (`GetNumConcurrentMissions`). They can be skipped for a fee (`MISSION_SKIP_*`), and they pay gems or coins ("IN TOTAL" or "IN A SINGLE GAME" variants). Examples by theme:

| Theme | Missions |
|---|---|
| Kill counts | "KILL %s ENEMIES", "KILL %s ZOMBIES / HOVER ROBOTS / WOLFMEN / YELLOW NINJAS", "KILL %s BOSSES" |
| Style kills | "KILL %s ENEMIES WHEN THEY ARE IN THE AIR", "KILL %s ENEMIES USING THE SPIN ATTACK", "KILL A BOSS WITH A SPIN ATTACK", "KILL %s ENEMIES BY TRIGGERING THE EXPLODING ROBOT", "KILL %s ENEMIES WHILE ON THE SAME CARRIAGE" |
| Armour state | "MAKE %s KILLS IN YOUR UNDERWEAR", "KILL A BOSS IN YOUR UNDERPANTS", "COLLECT %s COINS IN YOUR UNDERWEAR", "MAKE %s KILLS WHILE WEARING FULL ARMOUR", "HEAL FROM UNDERPANTS TO FULL HEALTH PLAYING AS CARRERA" |
| Gadgets and vehicles | "FINISH A BOSS WITH A MELEE DRONE", "BLOCK %s PROJECTILES WITH A DEFENDER DRONE", "USE TWO DRONES AT THE SAME TIME", "DEPLOY THE HEALER DRONE WHEN UNDER 10% HEALTH", "USE AIRSTRIKES TO KILL %s ENEMIES", "RIDE THE CYLINDRICAL DEATH WEAPON FOR %sM", "COLLECT %s COINS IN THE JETPACK" |
| Progress | "REACH THE FUTURE TRAIN", "REACH THE ORIENTAL TRAIN", "MAKE %s TRAIN JUMPS", "CLEAR %s HOSTILE TRAINS", "COMPLETE %s CONSECUTIVE HOSTILE TRAINS WITHOUT TAKING DAMAGE" |
| Score | "GET %s POINTS", "GET A %sX SCORE MULTIPLIER", 4x and 6x multiplier variants |
| Odd ones | "DIE INSIDE A CARRIAGE ON THE ORIENT EXPRESS", "COMPLETE A TRAIN WITHOUT COLLECTING A WEAPON CRATE", "COLLECT ALL COINS BETWEEN TWO TRAINS", "BUY ANY ITEM IN THE BARRACKS" |

- There is a "SMASH %s CORPSES USING SPIN ATTACKS OR A CORPSE SMASHER DRONE" mission. Corpses persist and can be gibbed.
- Weapon **crates** are a pickup that gives a random weapon (`Player::GiveRandomWeapon`).
- Mission icons: `ui_mission_icon_{deaths,events,pickups,distance,score,gadgets,buy}.png`.

### 1.6 Daily challenges [confirmed]
- "CHALLENGE CHAINS: CLIMB ABOARD THE CHALLENGE CHOPPER AND TEST YOUR SKILLS IN A SPECIAL MISSION WITH A DIFFERENT AGENT."
- Rules: completing the current mission unlocks the next; completing a chain claims the top prize; the final reward is a one-time discount on that agent ("YOU HAVE EARNED A ONE-TIME OFFER OF %s%% OFF %s!").
- Challenge types:
  - Survival: "%s WAVES AGAINST THE UNDEAD / NINJAS / ROBOTS. PLAYING AS %s."
  - CDW: "TRAVEL %s METERS."
  - Jetpack: "TRAVEL %s METERS."
- Supporting text: "DAILY CHALLENGE", "NEW DAY IN:", "DAY STREAK LOST", "COME BACK TOMORROW". Day-frame UI art (`ui_daily_*`) shows ticks, padlocks and a gem pile.

### 1.7 UI flow, shop and economy [confirmed]
- **Front end:** "TAP TO START". The `CharacterCarousel` class plus `ui_carousel_spin` and `ui_carousel_win` sounds suggest the Barracks agent carousel spins and settles on an agent.
  - I found **no prize-wheel or lottery strings** in the locale or the `.so`.
  - "carousel" therefore most likely refers to the Barracks character selector [inferred].
- **Eagle-7 vending pods** (`VM_*` keys and `player_checkpoint_*.cm` models):

  | Pod | Function |
  |---|---|
  | HEALTH | "THE HEALING STATION", REPLENISH to FULL HEALTH |
  | BARRACKS | agents, equipment, upgrades |
  | VAULT (bank) | shop |
  | MISSIONS | review, claim, skip |
  | SURPLUS | "CHUBWICK'S SURPLUS - NO BLUEPRINTS REQUIRED!", stock refreshes on a countdown "REFRESH IN:" |
  | CHALLENGES | via the chopper |

- **Shop tabs:** WEAPONS, GADGETS, MORE GEMS, MORE COINS, "GET COINS AND GEMS" (offers).
- **Item states:** EQUIP, EQUIPPED, REPLACE, OWNED, MAX, "BLUEPRINT REQUIRED", SALE.
- **Offers tab:** watch an ad for free coins; Twitter follow, Facebook like and store review rewards; restore purchases.
- **Revive:** "OOPS!", REVIVE FOR <gems>, or "FOR FREE" by watching an ad, or "GIVE UP!"
- **Game over:** "YOU SCORED", "NEW HIGH SCORE", "NEW MISSIONS", "NEW ITEMS", CONTINUE, SHOP, HOME, SHARE.
- **Blueprint reward popup:** "BLUEPRINT RECOVERED", "ITEM UNLOCKED", "UPGRADE %i UNLOCKED".
- **Boosters (consumables):**

  | Booster | Values / effect |
  |---|---|
  | SCORE | x2, x3, x4 multiplier |
  | MAYHEM | fills faster |
  | COINS | multiplier |
  | GEMS | multiplier |
  | DAMAGE | +25%, +50%, +100% |
  | HEALTH | more health |
  | MAGNET | "COINS AND GEMS FLY TO YOU" |

- **Version history:** "UPDATE 1.6.0 ... 9 NEW CHARACTERS, NEW WEAPON AND GADGET SYSTEM, NEW CHARACTER SKILL SYSTEM, NEW CHALLENGE SYSTEM, NEW BOOSTER SYSTEM". It refunded all purchases through the "REFUND-O-MATIC 3000".
- **Share text:** "I scored %s points as %s in #StormTheTrain. My best is %s - Beat that!" uses the `Social/post_<char>.png` posters.

---

## 2. AndroidManifest and packaging

Decoded with `tools/axml.py`, a small binary-XML parser.

- **Package:** `com.gamesfaction.stormthetrain`.
- **Version:** versionName **1.7.4**, versionCode **3788**.
- **SDK levels:** minSdk 16, targetSdk 19.
- **Requirements:** GLES 2.0 required. The main activity is `com.gamesfaction.stormthetrain.GameActivity`, `screenOrientation=6` (sensorLandscape), launchMode singleTask.
- **Deep link:** scheme `stormthetrain://`.
- **Permissions:**
  - `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`
  - `WRITE_EXTERNAL_STORAGE` (maxSdk 18)
  - `com.android.vending.BILLING`
- **Ads:**
  - **Heyzap** mediation. Its activities are declared, and the dex holds adapters for AdColony, AppLovin, Chartboost, Facebook Audience Network, InMobi, HyprMX, MoPub and Google Ads.
  - **Vungle** and **Unity Ads** activities.
  - An interstitial/rewarded API is bridged to native code (`fetchRewardedVideo`, `showInterstitial`, ...).
- **Analytics and crash reporting:**
  - **Fabric/Crashlytics.** Versions: crashlytics 2.5.5, core 2.3.8, NDK 1.1.2, Answers 1.3.6, Beta 1.1.4, fabric 1.3.10.
  - Answers events: `answers_characterBought`, `answers_videoWatched`, `answers_inAppPurchase`.
  - **Flurry**, per the leftover `com/gamesfaction/stormthetrain/analytics.tmp` Java source. Log tag "Cabal/Analytics".
  - Google Tag Manager config in `res/raw/gtm_analytics`.
- **Google Play Games:** has an APP_ID meta-data entry.
  - `resources.arsc` holds 28 `CgkI...` IDs: 27 achievements and 1 leaderboard, `leaderboard_high_score`.
  - Achievements come in tiers I to III: good_student, skippy, mutiny, massacre, completist, globe_trotter, techie, seasoned, metamorph.
- **IAP:** Google IAB v3 (`util/IabHelper`). The SKU prefix is `com.gamesfaction.goat.` with these items:

  | Item | Display name |
  |---|---|
  | `currency_2` | Large Pile of Coins |
  | `currency_5` | Bucket of Coins |
  | `currency_10` | Sack of Coins |
  | `currency_20` | "Special Offer - Best Value" |
  | `gems_1` | Pile of Gems |
  | `gems_2` | Hatful of Gems |
  | `gems_3` | Locker of Gems |
  | `gems_4` | Truck-load of Gems |
  | `coindoubler` | "Coin Doubler": double the value of every coin |
  | `allcharacters` | All Characters bundle |

  Prices are in `scripts/DB` (another agent's scope).
- **Backend and promo:**
  - `backend.gamesfaction.com` with `http://%s:8301/v1/connect?...` (remote config: `offers.*`, `rr_promo.*` cross-promo for "Rally Run", `offers.interstitialDelay`).
  - Branch link `bnc.lt`.
- **Social:** Facebook and Twitter pages (gamesfaction); `shareImage`; email support form.
- **Secrets:** the manifest contains a Fabric API key, and the `.so` contains a Google Play licence public key. I did not copy either into this report beyond noting they exist; keep them out of the vault.
- **Signing:** `META-INF` holds a standard v1 JAR signature (CERT.RSA, SF, MF). Nothing else of interest there.
- **Native libraries:** `lib/` holds armeabi-v7a and x86 builds of `libMainApp.so` plus the Crashlytics native libs.

---

## 3. Native code: `libMainApp.so` (strings only, not executed)

- The binary is stripped of debug info but **exports thousands of mangled C++ symbols**. That gives an almost complete class and method list (about 400 classes).
- Extracted lists:
  - `/Users/allen/re/storm-drain/extracted/strings/so_classes.txt`: class name, method count, method names.
  - `/Users/allen/re/storm-drain/extracted/strings/so_plain.txt`: constant strings.
- There is no `strings` or `c++filt` binary on this machine, so I used Python equivalents in `tools/`.

### 3.1 Engine architecture
- **Engine "Cabal"** (`Ca*` classes, Java package `com.gamesfaction.cabal.cacore`), roughly:

  | Area | Classes and notes |
  |---|---|
  | Core | `CaEngine`/`CaApplication`, `CaScheduler`, `CaMessageDispatcher`, `CaSignal`, `CaSmallBlock` allocators, free-lists (`ms_freelist` per class), `CaTween`, `CaRand`/`CaNoise` |
  | Rendering | `CaRenderer` (GLES2), `CaRenderBatch`, `CaSpriteManager`/`CaTexturePage`, `CaCamera` |
  | Models | `CaResource_Model2` (2D cut-out models) and `CaResource_Model3`, animated by `CaAnimationHierarchy*` and `CaAnimationClip`/`Channel` |
  | Particles | `CaParticleSystem`/`Emitter`, data-driven effect templates |
  | UI | UIKit-like retained UI: `CaUIView`, `CaUIViewController`, `CaUINavigationViewController`, `CaUITableView`, `CaUIButton`, `CaUILabel`, `CaUIImage`, NinePiece panels |
  | Fonts | `CaUIFontBitmap` (BMFont) |
  | Audio | `CaSoundEngine_Android` (OpenSL ES); music goes through Java `MusicPlayer` |
  | Physics | `CaPhysics2D` wrapping **Box2D** (b2World, contacts, joints) |
  | Scripting | `CaScriptEngine`, **Lua 5.1.4** with `CaScriptBindHelper` (C++ member dispatch to Lua), LuaFileSystem 1.6.2, lua-cmsgpack (`cabal.msgpack`) |
  | Platform | `CaPlatform::{IAP, Advert, Fabric, Backend}` |
  | Libraries | zlib 1.2.7, minizip, stb_image, stb_image_write |

- **Lua is the data layer.**
  - The C++ side binds `GOAT.EnemyData`, `GOAT.SpawnData`, `GOAT.TerrainManager` and `GOAT.db.*` (itemCreate, itemBuy, setPrices, specialsQuery, consumablesQuery, ...).
  - It loads `Enemies/enemyLoader.lua`, `Enemies/spawnLoader.lua`, `environments.lua` and `DB/loader.lua`.
  - Gameplay rules live in C++. Tuning (enemy stats, spawn groups, environments, item database and prices) lives in Lua.
- **Save files:** `goat_profile.dat` and `tmp_profile.dat` (PlayerProfile, ItemDatabase and GameMissionManager serialise).

### 3.2 Gameplay classes (the most useful for design)
- **Flow:** `GameMain` (states, score, mayhem, environment choice, promotions) runs `GameControl` (modes: default, `SurvivalGameControl`, `VehicleEventGameControl`). `GameController` is the HUD/input view controller with indicators, key messages, speech, combo, wave label, missile notifications and gadget buttons.
- **Level generation:**
  - `LevelManager` holds an event deck (`PrepareEventDeck`, `PickNextEvent`, `PopulateEventQueue`, `ForceEvent`) plus left/right barriers and a finish line.
  - `LevelNode` is a linked list of carriages built from **carriage records** with repetition rules and "appearances".
  - `TrainManager` (`SpawnNewTrain`, `SwapActiveTrain`, checkpoint carriage record) and `Train`/`Carriage` handle the trains, and `TrainJump` handles jumping between them.
  - Trains are assembled procedurally from modular carriage models.
- **Events** (subclasses of `LevelEvent`): `IntroEvent`, `EagleStartEvent`, `CheckpointEvent` (Eagle-7), `BossEvent`, `HostageEvent`, `EnemySurvivalEvent` (waves, mines, pickups), `CDWEvent`, `JetpackEvent`, `BlueprintIntroEvent`, `GadgetIntroEvent`, `CharacterSwapIntroEvent`, `FE_ChopperEvent` (challenge chopper).
  - Events give currency and score rewards and pick the next train's environment (`PickNextTrainJumpEnvironment`).
- **Player:**
  - `Player` (109 methods) wraps the active `Character`. It supports swapping, a shared health state, revive, forcefield, spin attack, jetpack, chopper, mech suits (`GiveMechSuit`), vehicle (CDW) and blueprint pickup.
  - Character params: `CHARACTER_RESILIENCE`, `_SPEED`, `_MAYHEM_MOD`, bounding boxes, `_FORCEFIELD_R`, `_GRAVITY_SCALE`, `_JUMP_SCALE`.
  - Animations: `JUMP_FIRE`, `PRE_FIRE`, `IDLE_FIRE`, `MECH_ENTER`, `CHOPPER_IDLE`, NTE (next-train) `RUN`/`JUMP`/`LAND`, `JE_HOVER`, death twitches.
- **Enemies:**
  - The `Enemy` base class (156 methods) has carriage-aware AI: patrol, flee, jump between carriages, train leap, target leap, leap attack, spin jump, flee on fire, damage-over-time effects (fire, poison, freeze), corpses and gibs.
  - **Archetypes:** NORMAL, AGILE, BERSERKER, COWARD, FRENZY, HOVER, SHIELD, SUICIDE (exploding robot), TELEPORT, UNDEAD (may revive: `UNDEAD_REVIVE_PROBABILITY`), HOSTAGE_NEUTRAL.
  - **Bosses:** BERSERKER_BOSS, FUTURE_SPAWN_BOSS, SHIELD_BOSS, SPAWN_BOSS, TELEPORT_BOSS.
  - Enemy def fields: `ENEMY_HEALTH`, `MOVESPEED`, `WEIGHT`, `SPAWN_COST`, `BEAM_LEAP_MIN/MAX`, `FREEZE_SCALAR`, `BLIND_DISTANCE`, primary/secondary/death/leap weapon, and more.
  - Enemy weapons: LIGHT/MEDIUM_MELEE, FIREBALL, STAKE, BEAM, NINJA_BOMB, FIREWORK, SKULL, BOSS_LEAP_ATTACK, FUTURE_BOSS_MEGAGUN, and more.
- **Spawning:**
  - `EnemySpawner` works on a cost budget (`ClaimCost`, `FindLowestCost`, spawn groups with child/next chaining).
  - Spawn params: `SPAWN_WAVE_TIME`, `SPAWN_WAVE_START/END_MIN/MAX`, `SPAWN_CAP_START/END` (difficulty ramps through `LevelManager::RampableValue`).
  - Spawn group types: NORMAL, BOSS, BOSS_EXTRA, KEYHOLDER, BOSSSPAWN, SURVIVAL, TIME_CHALLENGE.
- **Combat:**
  - `WeaponManager` handles ballistic, ray, beam, rail and AOE damage, shields, line of sight and targeting. `ChargeWeapon` is the railgun.
  - Damage effects: EE_FIRE_DOT, EE_POISON_DOT, EE_FROZEN_DOT.
  - Gore: `GibManager` and `SpecialGibs`.
- **Other systems:**
  - `MayhemMeter` (a row of chips, `ui_mayhem_chip_%i_on/off`).
  - `ComboCounter`.
  - `GadgetManager` (deploy price/currency, locked reasons, Airstrike).
  - Drones: `Drone` subclasses Turret, Defender, Corpse (Smasher), Melee, Freeze and Healer.
  - Mechs: `Mech` subclasses `DamageMech`, `DefenceMech` and `HealMech`, all time-limited (`InitDuration`).
  - `PickupManager` (coins, gems, crates, blueprints, key box, magnet).
  - `HealthProjectile` (heal-on-kill orbs).
  - `ObstacleManager` with mines and missiles (`MissileNotification`); `PatternSpawner` and `PatternDataManager` read the TGA patterns.
  - `CDW` vehicle: health levels, velocity damage, speed-up, explosion death.
  - `ChallengeChopper` and the `VendingMachine` pods.
  - `CameraController`, `EnvironmentManager` (parallax `TerrainLayer`s, sky per environment including `SKY_XMAS1..3`), `CutsceneManager`.
- **Meta systems:** `PlayerProfile` (coins, gems, blueprint banking with time, high score, custom button positions, feature unlocks, interstitial pacing), `ItemDatabase`, `GameMissionManager`, `ChallengeManager` (daily reset), `Specials` (surplus refresh), `ConsumableManager`, `AchievementManager`.

### 3.3 classes.dex
- Game Java code is thin glue: `GameActivity`, `Ads`, `IAP`, `GameCenter` (Play Games wrapper), `Social`, `FabricWrapper`, `AsyncHTTP`, and IabHelper utilities.
- The SKUs are built in native code (section 2). All gameplay is native C++ plus Lua.

---

## 4. Asset formats and extractability

### 4.1 Models: `assets/Models/*.cm` (168 files, 1.7 MB)
- **Header [confirmed]:** u32 0, u32 12, **magic `0x54FE23DD`**, u32 26 (version?), u32 0, u32 2, then sizes and counts.
  - The u32 at 0x24 looks like a node count: 11 for agents, 9 for enemies, 5 for drones.
  - The u32 at 0x28 looks like a key or frame count.
  - The float at 0x2C is always **15.0**, probably the animation fps.
  - The format is uncompressed little-endian floats and is identical across all files.
- **Content [inferred]:**
  - These are Cabal `CaResource_Model2` files: hierarchies of transforms (`xform_*`) with flat textured quads (`mesh_*`) plus baked animation clips (`drone_idle`, `ball_drive_1..3`, `takeoff`, `chopper_attack`).
  - Prop and vehicle files contain readable node names, with Maya artefacts such as `pasted__xform_effect_2`, so they were authored in **Maya**.
  - Character and enemy files show no readable names (probably hashed).
  - Body-part textures follow the pattern `chr_<part>_<char>_<state>.png`. Parts are head, body, armL/R, forearmL/R, handL/R, legL/R, plus extras such as tail and braids. **State 1 to 3** is the armour damage level; underwear is the lowest.
- **Name prefixes:**

  | Prefix | Count | Contents |
  |---|---|---|
  | `oriental_` / `horror_` / `future_` | 37 each | Modular carriages per theme: `coach_250/500`, `coach_closed_500_1..6`, `coach_weapons_500`, `coach_500_boxes`, `flatbed_250/500`, `freight_250/500`, `freight_half`, `freight_cannon`, `prison_1..3` (hostage cars), `engine_1`, `engine_coal_1`. 250/500 is the carriage length in world units. |
  | `player_` | 11 | Eagle-7 engine and cars plus checkpoint pods: bank, barracks, health, missions, surplus |
  | `chr_` | 16 | 13 agents plus 3 mech suits |
  | `robot_1..9` | 9 | Robot enemies |
  | ninja, skeleton, vampire, zombie, wolfman | 9 | `ninja_light/medium/heavy`, `skeleton_light/heavy`, `vampire_medium/heavy`, `zombie_light`, `wolfman_medium` |
  | `drone_` | 7 | drone_1..4, freeze, healer, helper |
  | other | 5 | `vehicle_ball` (the CDW), `helicopter_player`, `challenge_chopper`, `hostage_1`, `frontend_logo` |

- **Extractability:** there is no public tool for this format, but the structure is regular enough to reverse with a few hours of work. For a Roblox remake, the more practical route is to rebuild rigs from the sliced sprites, or just use them as reference.

### 4.2 Atlases: `assets/Atlases` (17 `.atlas` + 17 `.pvr`, 74 MB)
- **`.atlas` files** are Lua tables: `textureName`, w, h, filter, and a list of `{name, w, h, x, y}`. There is no rotation or trimming.
- **`.pvr` files** are **legacy PVR v2** (52-byte header, tag `PVR!`), flags `0x8012` = **OGL_RGBA_8888, uncompressed**, with no mipmaps.
  - Sizes: 1024² (some 1024x512); `ui_hres` is 2048².
  - **Pixel rows are stored bottom-up** even though the flip flag is not set. Atlas y=0 is the top after a vertical flip.
- **Conversion: done.** `tools/atlas_extract.py` (pure Python, zlib only) wrote:
  - `/Users/allen/re/storm-drain/extracted/sprites/*.png`: 17 full atlases;
  - `/Users/allen/re/storm-drain/extracted/sprites/sprites/<atlas>/*.png`: **1,811 sprites**.
  - PVRTexTool is not needed. Pillow is not installed, and the script does not need it.
- **Contents:**

  | Atlas | Contents |
  |---|---|
  | `players_hres` | All agent body parts x3 damage states, weapons (`wpn_*`), drones, CDW ball parts, jetpack, pickups (blueprint, key box, gems), gibs |
  | `characters_2x_hres` | @2x full-armour parts for the barracks |
  | `enemies_hres` | Ninja/robot/skeleton/vampire/zombie/wolfman parts, weapons, gibs |
  | `env_<theme>_{,new_,shared_}hres` | Carriages, decor, parallax backgrounds. Future has neon cityscapes with Chinese signage; Horror has coffins, webs, skull engine and RIP stones; Oriental is the third set. |
  | `env_player_train_hres` | Eagle-7 and its pods; Chad's head and body |
  | `fx` | Particles |
  | `frontend` | Logo, helicopters, Chad, Rally Run cross-promo car |
  | `ui_hres` | Fonts, item cards, icons, buttons |
  | `logo` | Games Faction splash |

### 4.3 Patterns: `assets/Patterns/*.tga` (50 files) [decoded]
- **Format:** tiny 32-bit TGAs (type 2 raw or type 10 RLE, origin bottom-left).
- **Meaning:** each pixel is a grid cell. **Width = distance along the run (columns)** and **height = vertical lanes**.
  - 15 lanes for CDW and for jetpack obstacles; 8 lanes for jetpack missiles.
  - Black or transparent cells are empty.
- **Families** (filenames are hard-coded in the `.so`, chosen by difficulty level):
  - `cdw_missile_level0-2_*` and `cdw_obstacle_level0-2_*`: CDW ball-vehicle runner.
  - `jp_missile_level1-5_*` and `jp_obstacle_level1-4_*`: jetpack flyer.
- **Colour legend [inferred from layouts]:**

  | Colour | Probable meaning | Evidence |
  |---|---|---|
  | Red | Missile spawn row | Only colour in missile files besides yellow; one red per lane = one missile with a warning bar |
  | Yellow | Coin | Most common colour; draws lines, arcs and boxes (coin trails) |
  | Blue | Mine | Sparse, regularly spaced; forms "ceilings" in CDW and corner hazards in jetpack patterns |
  | Azure | Ground mine (probably) | Sits on the bottom row under coin arches ("jump the arc") |
  | Green / magenta / cyan | Gems, crates or moving-mine variants | Few per pattern; often inside coin boxes |

  - The alpha channel varies, 0 or 255, on otherwise identical colours. It may flag a variant (for example `Mine_1` vs `Mine_1_Moving`) or it may be export noise. This needs confirming from code or gameplay footage.
- **Examples:**
  - `jp_missile_level5_4` is a 6x8 chevron of missiles.
  - `cdw_obstacle_level2_1` is 68 columns long. It has a mine ceiling on rows 0 and 2 and repeated coin arches over ground mines.
- **Reuse:** the grids can be loaded directly as Roblox level-chunk data. A decoder with ASCII preview is in `tools/tga.py` (run with `SHOW=1`).

### 4.4 Sounds: `assets/Sounds/*.raw` (102 files, 5.9 MB)
- **Format:** headerless **signed 16-bit little-endian PCM, mono**.
  - Mono: adjacent-sample correlation falls smoothly from lag 1 to lag 2, which a stereo interleave would not do.
  - The rate is **most likely 22,050 Hz**: Chad's voice pitch comes out at about 129 Hz at that rate, which is natural.
  - Total is about 134 s at 22.05 kHz. To convert: prepend a WAV header.
- **Names:**
  - Weapons (`weapon_*`).
  - Enemy deaths and gibs.
  - Boss taunt/attack/die lines for 2 bosses per theme.
  - Hostage lines and Chad lines.
  - Vending pod open/close.
  - Mayhem enter/exit/reached.
  - Missile warning.
  - Train click-clack, hover and whistle.
  - Helicopter loop.
  - Ball engine start/loop/rev.
  - UI: carousel spin/win, item bought, score counter.

### 4.5 Music: `assets/Music/*.mp3`
- `theme_main`, `theme_oriental`, `theme_horror`, `theme_future` (one per environment).
- MPEG-1 Layer III, 44.1 kHz joint stereo, 256 kbps (future is 320 kbps), about 90 s each and presumably looped. ID3v2.2 tags with no title text.

### 4.6 Fonts: `assets/Fonts/*.fnt`
- **AngelCode BMFont text format.** Pages are inside `ui_hres`.
- Faces:
  - **"BadaBoom BB"** (30, 36 shadow, 42, 52 shadow, 60 shadow, numbers).
  - **"Anime Ace 2.0 BB"** (20 pt).
  - Both are Blambot comic fonts. Check their licences before reusing them; Roblox has similar comic faces such as Bangers and Luckiest Guy.
- `debug.fnt` is for the debug overlay.

### 4.7 Shaders: `assets/Shaders`
GLSL ES 2.0 pairs: `FlatVertexColours`, `Textured`, `TexturedVertexColours`, `SDF`. The SDF fragment shader uses derivative-based anti-aliasing. Everything is unlit 2D, with no 3D lighting.

### 4.8 Social posters and other PNGs
- `Social/post_<char>.png` (750x830) plus `_small` (227x250): one per agent, 13 in total.
  - They are Polaroid frames with a blurred line-up background, a teal sunburst and the agent in a dynamic pose.
  - The name is in a grey comic font under the photo, with the STORM THE TRAIN logo bottom right.
- `Social/recruit_poster.png` (1024x580) shows the whole cast and a "PLAY NOW" button.
- `assets/vg_*.png` are 60 px ad-overlay buttons (close, CTA, mute, privacy).
- `Textures/debug.png` is a debug texture.
- `res/` is almost entirely SDK drawables (Google sign-in, Cast, Unity Ads). The game icon is `ic_launcher.png` (mdpi to xxxhdpi, up to 192 px).

### 4.9 Art style (for `01 Design/Art Direction` reference)
- **Character style:** chunky "big-head" chibi proportions, about 2.5 heads tall.
  - Thick dark outlines with flat colour and soft cel shading.
  - Exaggerated brows and determined faces.
  - Oversized guns held at the hip.
- **Animation:** characters are 2D cut-out puppets, built from separate limbs.
- **Visible damage:** each body part has 3 armour states, so damage shows as ripped costumes and finally underwear. This is a signature gag worth keeping.
- **Humour:** costume variants (dino, kitty, bear onesies) are characters in their own right.
- **Palette:**
  - UI: dark slate backgrounds with **cyan/teal glossy** accents and logo.
  - Purple and magenta for gems; gold for coins.
  - Item cards are colour-coded: **blue = weapons, purple = gadgets, red/orange = boosters and strikes**.
- **Environments:**
  - Horror: brown wood carriages with rope, rivets, coffins, cobwebs, skull-nosed engine.
  - Future: dark steel and neon, blurred skyscraper parallax with Chinese neon signs.
  - Eagle-7: gunmetal armoured train with teal lights.
- **Readability:** strong silhouettes against blurred backdrops. Comic-book speech bubbles and BadaBoom lettering.

---

## 5. Remake implications (suggestions, not canon)

1. Keep the **train-roof lane plus carriage-jump** structure.
   - Build carriage templates in Roblox (`ReplicatedStorage.Assets`) in 250 and 500 length modules per theme.
   - Assemble trains from carriage records, mirroring `LevelNode` and `TrainManager`.
2. Use an **event deck** per train: Normal, Boss, Hostage, Survival, CDW, Jetpack, with the Eagle-7 checkpoint every N trains.
3. Port the **TGA patterns** as CDW and jetpack chunk data. The grid data is legally risky to ship as-is, but it is a useful design reference.
4. **Shared health pool across a 2 to 3 agent squad, with swipe or keybind swaps**, plus Mayhem leading to a free gadget, makes a strong co-op-friendly hook.
5. Meta loop: missions (3 concurrent), daily challenge chains, blueprints that gate upgrades, and a surplus shop with rotating stock. Roblox equivalents are DataStore-backed services.
6. Do not ship any extracted art, audio or fonts. They are © Games Faction, and the fonts are Blambot-licensed. Use them only as reference.

## 6. Open questions
- The pattern colour legend: confirm against `PatternSpawner::CreateObject` (needs disassembly) or gameplay video.
- Sound sample rate: confirm by listening to one file converted to WAV at 22,050 Hz.
- Animation layout inside `.cm` files: not decoded.
- No prize wheel was found. If one is remembered from the game, it may be the Barracks carousel, or it was added in a version later than 1.7.4.

## 7. Files produced
- this note.
- `/Users/allen/re/storm-drain/extracted/tools/`:
  - `axml.py`: binary manifest parser.
  - `pystrings.py`, `dexstrings.py`: strings tools.
  - `classes.py`: C++ symbol to class list.
  - `cmhdr.py`: `.cm` header survey.
  - `pvr2png.py`, `atlas_extract.py`: PVR to PNG plus sprite slicing.
  - `tga.py`: pattern decoder.
- `/Users/allen/re/storm-drain/extracted/strings/so_strings.txt`, `so_plain.txt`, `so_classes.txt`, `dex_strings.txt`, `arsc_strings.txt`.
- `/Users/allen/re/storm-drain/extracted/sprites/*.png` (17 atlases) and `/Users/allen/re/storm-drain/extracted/sprites/sprites/` (1,811 sprites).
