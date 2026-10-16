---
tags: [reference, original-game, moc]
status: reference
---
# Original Game (Storm the Train, Android 2016)

Notes from reading the original mobile game **Storm the Train** by Games Faction
(`com.gamesfaction.stormthetrain`, v1.7.4 build 3788). The source is an unpacked APK
at `/Users/allen/re/storm-drain/unpacked`. Most game data ships as plain, commented
Lua 5.1, so the numbers below are the real shipped values.

> **Reference only.** These notes describe the original game, not our design.
> Nothing here is canon for the Roblox project until the user puts it in the
> [[Game Design Document]]. The original's art, audio, fonts and models belong to
> Games Faction; the fonts are Blambot-licensed. Use them for reference and never ship them.

## Detail notes
- [[Original Game - APK Balance Audit]]: verified weapon damage and firing intervals from both native architectures, complete balance inventory, source evidence, exported data, and unresolved formulas.
- [[Original Game - Items and Economy]]: agents and their abilities, weapons, gadgets
  (drones, mech suits), boosters, blueprints, upgrade costs, currencies, Chubwick's
  Surplus, challenge chains, and the economy before v1.6.
- [[Original Game - Enemies and Spawning]]: the three themes, the carriage kit, every
  enemy's stats and behaviour, the spawn budget system, the difficulty curve, bosses,
  hostages, and survival mode.
- [[Original Game - Combat Feel (Native Code)]]: decompiled from `lib/x86/libMainApp.so`
  (Ghidra) and `classes.dex` (jadx). It covers spread (none), fire jitter, the shotgun
  close blast, knockback ÷ weight, flinch rules, muzzle flashes, camera-shake tiers,
  per-damage score and Mayhem, the combo window, i-frames, gibs and the backend config
  keys.
- `lib/`, `res/`, `classes.dex`, `resources.arsc`: the raw binaries from the APK
  (uploaded 2026-10-16). Reference only.
- `scripts/`: the original's **raw Lua data scripts** (uploaded 2026-10-16). It holds the
  item DB `DB/db.lua`, `DB/loader.lua`, every enemy definition in `Enemies/*.lua`, the
  spawn groups, `environments.lua` and the theme files. It's reference only, like
  everything here. Gameplay logic (firing, AI) is in the C++ engine and isn't included.
- [[Original Game - Text, Engine and Assets]]: premise, tutorial and controls, missions,
  UI flow, the engine ("Cabal", C++ with Lua, Box2D and GLES2), SDKs, asset formats and how
  far each one can be extracted, and the art style.

## The original in brief
- **Genre:** a **2D** side-scrolling run-and-gun on the roofs of moving trains. You clear
  a hostile train, jump to the next one, and return now and then to your armoured
  hub train, the **Eagle-7**. Its hub pods are Health, Barracks, Vault (shop),
  Missions, and Chubwick's Surplus.
- **Themes:** Oriental (ninjas), Horror (undead) and Future (robots). Each has its own
  music, its own 37-piece carriage kit and 10 enemy slots: 4 light enemies, 3 mid
  enemies that carry keys, 2 bosses and 1 minion that bosses summon.
- **Squad:** 13 agent definitions share one health pool, and you swipe to switch between them.
  Each agent has a fixed loadout of 2 weapons and 1–5 gadgets, plus fixed traits:
  resilience, speed, spin-attack strength, and a bonus against one enemy faction.
- **Combat extras:**
  - Double-jump spin attack.
  - Mayhem meter: kills fill it, and a full meter gives a free gadget (mech suit,
    drone or air strike).
  - Combo score multiplier.
  - Agent armour comes off in 3 visible stages per body part.
- **Spawning:** each enemy has a spawn cost. Waves are bought from a budget that grows
  over time, with a cap on the total cost alive at once. There are solo introductions
  for mid enemies and long plateaus. A run lasts about 11–16 minutes.
- **Meta:**
  - Coins buy upgrades and gems buy agents.
  - There are 17 weapons and 9 upgradeable gadgets, each with 10 levels, plus a single-level Air Strike. Levels 2–10 cost
    51,400 coins in total per item.
  - Each upgrade level first needs a blueprint, which you take back from enemies and
    deliver to the Eagle-7.
  - 3 active missions from 52 templates, daily challenge chains, and up to 3 boosters
    per train.
- **Converting to Roblox:** about 15 px = 1 stud. That puts light enemies at about
  6–11 studs/s and carriages at about 17 or 33 studs long.

## Not in the extracted data
- Full charged-weapon/DoT formulas, modifier stacking and ammo/clip behavior remain unresolved.
  Base damage, firing intervals and raw range fields have now been recovered from 249 native
  weapon definitions and cross-checked between ARM and x86; see [[Original Game - APK Balance Audit]].
- Train assembly order and scroll speed, score and coins per kill, mission targets,
  and IAP prices.
- The `.cm` 3D model format, which hasn't been decoded.

## Extracted files (outside this repo)
`/Users/allen/re/storm-drain/extracted/`:
- `sprites/`: 17 atlases converted to PNG, plus 1,811 sliced sprites.
- `strings/`: string dumps from the native library, dex and resources.
- `tools/`: the Python converters and parsers used.

They are kept out of git on purpose because the content is copyrighted.

Related: [[Home]] · [[Game Design Document]] · [[Art Direction]] · [[References]]
