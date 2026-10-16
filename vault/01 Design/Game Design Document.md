---
tags: [design, gdd]
status: planned
updated: 2026-10-16
---
# Game Design Document — Train Mayhem

> **How to read this.** Lines marked **[decided]** were chosen by the developer.
> Lines marked **[proposed]** are Claude's suggestions, drafted from the
> [[Original Game]] reference notes, and are not canon until accepted. When a
> proposal is accepted, change its marker to **[decided]**. When it's rejected,
> delete it or move it to [[#Open questions]].

## Pitch
**[decided]** A co-op, over-the-top action side-scroller where a squad of 1–4
secret agents storms hostile trains roof by roof. Players blast through themed
enemy crews, swap between agents mid-fight, rescue hostages, take down bosses and
leap from train to train. Between runs they head back to their own armoured hub
train to upgrade.

**Title:** **Train Mayhem**. **[decided 2026-10-16]** It replaces the working title Train Runner and
the original's "Storm the Train". Search Roblox for clashes before publishing (see
[[Title Ideas]]).
- **[decided 2026-10-16] Names:**
  - the agency: **ROBLOX Assault Team**,
  - the hub train: **Falcon-8**,
  - the Wild West gang: **the Cowboys**,
  - the hub guide: **Quill**,
  - the shop: the **Surplus Shop**.
  The agents: **Max Mayhem** (the starter) and **Gleep** (the alien). The other four
  are still open.

## Relationship to the original
- **[decided]** This is a **new IP inspired by** the 2016 mobile game *Storm the Train*
  (Games Faction). We keep the core idea (fighting across hostile trains, squad
  swapping, themed trains, a hub train between runs) and use our own name, characters,
  story, art, audio and UI.
- **[decided]** Original names don't carry over: no Graham, Mason, Eagle-7, Chubwick,
  GOAT, Cabal, and so on. The original's art, audio, fonts and level-pattern data are
  reference only and never ship.
- **[decided]** The original's **system shapes** (spawn budget model, enemy slots,
  upgrade ladder, booster types) are kept. Its **numbers are loose reference only**,
  not a balance baseline. Every number in the design notes that the developer hasn't
  explicitly decided is a **first guess**, and gets tuned fresh in playtests.
  - The values the developer chose on purpose stay decided. These include the agent
    speeds (18–33 studs/s), the toughness spread, the 100 HP pool, and the revive and
    run-structure rules.

## Design pillars
**[decided]**
1. **Chaos you can read.** Big explosions, crowds and gags, but the side-on view keeps
   every threat readable at a glance.
2. **Better together.** Every system should be fun solo and better in a squad: revives,
   combo Mayhem and shared objectives like freeing a hostage.
3. **Always moving forward.** The train never stops. Runs flow from fight to leap to
   fight with minimal downtime.
4. **Silly, never mean.** The comedy is in costumes, taunts and cartoon violence. It
   stays within Roblox community standards (stylised knock-outs, no realistic gore).

## Target audience & platforms
- **[decided]** **All ages, with no specific age target.** The design aims at Roblox
  players who like co-op action with friends. The UI, reading level and difficulty
  ramp should still work for younger players, because the Roblox audience skews
  young.
- **[decided]** **PC and mobile at launch. No console.** Console certification and
  console-specific UI are out of scope.
  - **[decided 2026-10-16]** Controls are still designed to work well on touch, as the original
    was a touch game.
  - **[decided 2026-10-16]** Gamepad bindings stay as a nice-to-have for PC players with a
    controller, not a launch requirement.

## Tone
- **[decided]** **Over-the-top comedy action.** Think silly secret-agent squad,
  costume-gag agents, bosses that taunt you, and enemies that go flying.
- **[decided]** **Ragdoll knock-outs that stay on the train.** A knocked-out enemy
  ragdolls onto the carriage roof or floor, lies there briefly, then fades out.
  - There's no gore, matching the "Silly, never mean" pillar and Roblox content rules.
  - Strong hits can still launch a ragdoll down the carriage.
- **[decided 2026-10-16]** The details:
  - Ragdolls fade after about **3 s**.
  - At most **about 12 ragdolls** exist at once; the oldest fade early. This protects
    performance with 4 players and crowds.
  - Knockback from charges, the Smasher Drone and the Melee Suit can still push a
    *living* enemy off the edge of the train, and that counts as a knockout.
  - The pause before fading is when "finish it" mechanics happen: shaking the keys
    loose from a key holder, and stopping an undead enemy from getting back up.

## Core loop
**[decided]** Run-based: a run is a chain of hostile trains, with returns to a hub
train between runs.

**[decided]** Runs are **endless**, as in the original, and are split into **legs of 3
hostile trains**:
- A hostile train has **6–8 carriages** and takes about **2–3 minutes** to clear.
- The hub train pulls alongside after **every 3rd train** (a checkpoint).
- The **3rd train of each leg is an event train**. Every 2nd leg, that event is a **boss**.
- **Difficulty ramps across the whole run**, not per train. The spawn timeline runs on
  the run's elapsed combat time and carries on between trains, which answers the open
  question in [[Original Game - Enemies and Spawning]].
- The run ends when the squad is **wiped** or **cashes out** at a checkpoint.

**[decided]** Run anatomy:
| Leg | Train 1 | Train 2 | Train 3 | Then |
|---|---|---|---|---|
| 1 | Normal | Normal | Event (hostage, blueprint thief or survival) | Checkpoint |
| 2 | Normal | Normal | **Boss** | Checkpoint |
| 3 | Normal | Normal | Event | Checkpoint |
| 4 | Normal | Normal | **Boss** | … and so on |

**[decided]** Non-boss event trains **rotate**: the event is picked at random, but never
the same event twice in a row, so every leg feels different. The pool is hostage,
blueprint thief and survival. (The first playable only has the blueprint thief, so the
rule only matters from M3.)

A leg takes about 8–9 minutes, so the 10–15 minute target means an average run reaches
leg 2, and a strong squad meets its first boss at roughly the 15-minute mark.

**[decided]** The loop in detail:
1. **Gear up on the hub train.** Pick a squad of up to 3 agents, spend coins on upgrades, equip up to 3
   boosters, choose missions.
2. **Storm a hostile train.** Fight carriage by carriage against a themed enemy crew.
   An event may trigger: boss, hostage, blueprint thief, survival waves.
3. **Leap to the next train.** "Next train" is announced, the squad jumps across, and
   the theme may change. Loose coins sit between trains.
4. **Checkpoint.** After every 3rd train the hub train pulls alongside: heal, bank blueprints,
   buy upgrades, re-equip boosters, then continue or cash out.
   **[decided]** In a party, continue or cash out is a **majority vote**, and there's
   **no checkpoint timer**: the train waits for every vote. Tie handling and an AFK
   safeguard are proposed in [[Loop (M2)]].
5. **Run ends** when the squad is wiped or cashes out. Coins, blueprints and mission
   progress are kept. The target run length is about 10–15 minutes (the original
   ran 11–16).

## Perspective & controls
- **[decided]** A **2.5D side-scroller** with 3D models and a camera locked side-on.
  Characters move along the length of the train (one axis) and jump up and down. See
  [[0003-2.5d-side-scroller]].
- **[decided]** Scale is **15 original px = 1 stud**. That makes short and long
  carriages about 17 and 33 studs, and light enemies move at about 6–11 studs/s.
- **[decided]** Player movement uses the **original's speeds at that scale**: agents
  move at **18–33 studs/s** (the original's 275–500 px/s), set per agent. That's
  faster than Roblox's default WalkSpeed of 16, and two to three times faster than
  light enemies, so players control the fight. A fast agent crosses a long carriage in
  about one second.
  - **[decided]** The starter agent sits at about **28 studs/s** (the original's free
    agent had 425 px/s). Speed upgrades and the Mayhem speed perk can't push an agent
    past 33.
  - **[decided]** Falling into a gap between cars puts you back on the nearest roof after
    1 s, with 15 raw damage ([[0005-side-on-movement-and-camera]]).
  - **[decided 2026-10-16]** Charges run at **2.5× the enemy's walk speed**, as in the
    original ([[Wild West Enemies]]). Fast agents can outrun them; slow agents have to jump
    them or take the hit. This replaces the earlier rule that dodged attacks must always be
    jumped, not outrun. Bullets and similar attacks are still dodged by jumping.

| Action | Keyboard/mouse | Gamepad | Mobile |
|---|---|---|---|
| Move | A / D (or ← / →) | Left stick | Left/right buttons |
| Jump / **double jump = spin attack** | Space | A | Jump button |
| Shoot the active weapon (aim follows facing, light auto-aim) | Left mouse / J | RT | Shoot button |
| Switch weapon | Walk into a **weapon crate** | Walk into a crate | Walk into a crate |
| Swap agent | Q / E | LB / RB | Swipe or swap button |
| Use gadget (when Mayhem is full; pick 1 of the active agent's 3) | 1 / 2 / 3 (F repeats the last pick) | D-pad (Y repeats the last pick) | Tap the glowing Mayhem ring, then 1 of 3 |
| Interact (free hostage, grab keys, enter a carriage or hub pod) | W (or ↑) | X | Context button |

**[decided]** Interact moved from E to **W / ↑**, so E stays "swap to next agent". In a
side-scroller, up is the natural "go in / use" key, and W is otherwise unused because
movement is on one axis. Nothing on PC shares a key now.

**[decided]** There's **no aiming**: weapons shoot straight along the direction the agent
faces, on every platform. The developer decided this on 2026-10-13, dropping the earlier
optional up/down mouse aim on PC. The rifle's light auto-aim cone still applies. Mobile
buttons can be repositioned, as in the original.

## Multiplayer
- **[decided]** **Co-op squad of 1–4 players.** Each player controls one agent on screen.
- **[decided]** Health is pooled **per player**, not across the party, and downed
  players can be **revived**.
- **[decided]** Each player's pool is **100 HP**. The active agent's **toughness**
  multiplies the damage that player takes, as the original's `resillence` stat did.
  Lower means tougher.
  - Agents keep the **original's spread** (0.20–0.76 on its shipped agents), so
    toughness pairs with speed: fast agents are fragile and slow agents are tanky. For
    example, a 500 px/s agent took 0.76 and a 275 px/s agent took 0.20.
  - Enemy damage is tuned against a **starter agent at 0.52**. A light grunt's 3-damage
    punch costs the starter about 1.6 HP.
  - **[decided]** The UI shows toughness as 1–5 stars rather than the raw multiplier.
- **[decided]** Each player brings a **squad of up to 3 agents**, as in the original,
  and swaps between them. Only the active agent is on screen, so a full party shows 4
  agents, not 12. All of a player's agents share that player's health pool, which was
  the original's core hook.
  - **[decided]** New players start with the 2 free agents, so they can swap from
    their first run. The third slot fills when they unlock a third agent.
  - **[decided]** Swap cycles to the next agent (Q/E or LB/RB pick a direction). On
    mobile, a swipe cycles, or there's a squad strip of 3 portraits to tap. The HUD
    shows each teammate's active agent only, to keep 4-player screens clean.
- **[decided]** Revive rules:
  - At 0 HP a player is **downed** and **bleeds out over 15 s**.
  - A teammate standing next to them holds **Interact for 2 s** to revive them at
    **40% HP**. Teammate revives are **unlimited**.
  - A downed player can **self-revive with gems**. The price **doubles with each use
    in a run**, for example 5 → 10 → 20 gems.
  - If the **whole squad is down**, anyone has **10 s** to gem-revive. Otherwise the run
    ends. Solo players get the same 10 s prompt.
- **[decided]** More revive rules:
  - The starting gem price is 5, tuned with the rest of the economy.
  - A player who bleeds out with teammates still standing **spectates** and rejoins at
    the next checkpoint with full HP.
  - Reviving is interrupted if the reviver takes damage, so teammates have to clear
    space first.
- **[decided]** Solo play is the same game with a 1-player party. Enemy spawn budget
  and caps scale with party size.
- **[decided]** Matchmaking: parties are formed on the hub by standing on **queue pads**
  ([[Queue Pads]], decided 2026-10-13; they replace a party menu), with quick-join for open
  slots. The run takes place in a reserved server, with Teleport from the lobby place.
  The hub and runs are **one place in two modes** ([[0004-single-place-hub-and-run-modes]]).

## Key mechanics
**[decided]** These are adapted from the original. See the reference notes for its
numbers.
- **Roster.** **[decided]** **6 agents at launch, 2 of them free**: the starter plus
  one unlocked early through play. The other 4 cost gems, which can also be earned
  through play, more slowly. More agents, including costume agents, come after launch.
  **[decided]** The six concepts in [[Launch Agents]] are accepted (names are
  placeholders). Brick Broadsley is the second free agent. Theme matchups are +40%
  against one theme and −25% against another in co-op. **[decided 2026-10-16]** Solo
  uses the original's −40%.
- **Agents.** Each has 2 fixed weapons, 1–3 gadgets and traits: resilience, speed,
  spin-attack strength, and a bonus against one enemy faction. Swapping is instant
  with a short cooldown.
- **Weapon crates.** **[decided]** You switch between your agent's two weapons by walking
  into a **weapon crate** on the train, as in the original. There's no secondary fire
  button and no weapon-swap button. Crate rules are in [[First Playable (M1)]].
- **Weapons.** Archetypes are carried over (rifle, dual SMGs, shotgun, minigun, rocket,
  sticky bombs, flamethrower, poison, lightning, rail/charge gun, plasma), each with
  10 upgrade levels. Use [[Original Game - APK Balance Audit]] as the baseline
  damage and fire-interval table.
- **Spin attack.** Double jump does damage around you and finishes off knocked-down
  enemies.
- **Mayhem meter.** Kills fill it. When full, you get a free gadget: a drone (turret,
  melee, healer, freeze, defender, smasher), a mech suit, or an air strike. In co-op,
  each player has their own meter. The full design (fill rates, choosing a gadget,
  drones, mech suits, Air Strike) is in [[Gadgets and Mayhem]].
  **[decided]** You pick 1 of your active agent's 3 gadgets. One Air Strike per party at a
  time. Mech upgrades add duration only.
- **Combo multiplier.** Chained kills multiply score, up to ×6. Score, combo and bonuses
  are drafted in [[Score and Combo]] (proposed).
- **Visible armour damage.** Agents' outfits break apart in 3 stages as health drops,
  as cartoon costume damage.

## Enemies & themes
- **[decided]** Four themes: **Ninjas**, **Undead/horror**, **Robots/future** and
  **Wild West bandits** (new to this game).
- **[decided]** Each theme fills the same **10 enemy slots**, so one spawn script
  drives every theme:
  - slots 0–3 are light grunts,
  - slots 4–6 are mids, who also carry keys and blueprints,
  - slots 7–8 are bosses,
  - slot 9 is the boss minion.
  Starting stat bands come from [[Original Game - Enemies and Spawning]]:
  - lights have 18–45 HP,
  - mids have 160 HP,
  - bosses have 550–700 HP.
- **[decided]** Spawning uses a **budget model**. Each enemy has a cost, and waves are
  bought from a budget that ramps over time, with a cap on the total cost alive at
  once. Each new mid is introduced alone as a mini-boss beat.
- **[decided]** The **first playable has 1 theme: Wild West bandits**. They're the
  most "train" flavoured theme and the most clearly our own IP. The other themes
  follow once the loop is fun. The roster draft is in [[Wild West Enemies]].

## Train events
**[decided]**
| Event | Summary | Milestone |
|---|---|---|
| Normal train | Clear carriages front to back | First playable |
| Blueprint thief | An enemy carrying a blueprint; kill it and grab the drop | First playable (a stub: counted, not saved; banking arrives in M4) |
| Boss | Boss fight on a flatbed, with taunts and summoned minions | M3 |
| Hostage | Kill the key-holder mid, grab the key, free the hostage | M3 |
| Survival | Survive N waves; one-hit death | M3 |
| Vehicle/runner section | Auto-run obstacle stretch (the original's "rolling ball" and jetpack segments) | Later |

## Progression & economy
**[decided]** **Original-style** economy and monetization.

**[decided]** The structure is below, adapted from [[Original Game - Items and Economy]].
The full draft (earn rates, prices, boosters, surplus shop, Robux products, earn-time
targets) is in [[Economy and Monetization]].
- **Coins** are the soft currency. You earn them in runs and missions, and spend them
  on weapon and gadget upgrades (L2–L10) and some boosters. As a baseline, the original
  costs ran from 1,000 to 14,000 per level, for 51,400 in total per item.
- **Gems** are the premium currency. You earn a few through missions and challenges,
  and buy more with Robux (Developer Products). You spend them on agents, the
  stronger boosters and the rotating surplus shop.
- **Blueprints** gate each upgrade level. Enemies "steal" them, and you recover them
  in runs and bank them at the hub. Unlocks are weighted towards gear you own and
  your lowest-level items.
- **Boosters**: up to 3 at a time, for score, Mayhem, coins, damage, health, gems and
  magnet. Each lasts for the next **leg** (3 trains), because checkpoints come every 3
  trains.
- **Missions**: 3 active at once, rerollable or skippable. There are also daily
  challenge chains per agent.
- **Surplus shop**: a rotating gem shop selling upgrade levels with "no blueprints
  required", in three offers (cheap, mid and premium).

## Monetization
- **[decided]** In the **original's style**: premium currency buys agents and
  boosters, and coins buy upgrades.
- **[decided]** The Robux products are gem packs (Developer Products), a one-per-account
  **Starter Pack**, a **Launch Squad** Game Pass for the 4 paid launch agents, and a
  **Coin Bonus** Game Pass (×1.5 coin pickups). Gems buy revives and cosmetic skins.
  There are **no ads** and no first-purchase gift. Prices and details are in
  [[Economy and Monetization]].
- **[decided]** Carried blueprints are lost if the squad wipes before banking them. The
  medbay heals to full for free at every checkpoint.
- **[decided]** Guardrails, because this is co-op:
  - Paid power should never make a teammate's run worse.
  - Paid boosters affect only the buyer. A gems booster doesn't change your
    teammates' damage.
  - Damage and health boosters have a party-wide cap: in a party, at most +50% damage
    and ×0.67 damage taken. The strongest tiers are solo only.
  - Free players can earn every agent through play, more slowly.
- **[decided]** **Roblox policy:** any paid random item, such as a random booster offer
  bought with Robux-bought gems, must disclose odds. Keep paid offers deterministic,
  like the original's surplus shop, to avoid the issue.

## Leaderboards
- **[decided]** **Co-op leaderboards only. No PvP.**
- **[decided]** There are **three boards**: **furthest train reached**, **best squad
  score** (the sum of the party's scores) and **best individual score**. Scoring is in
  [[Score and Combo]].
- **[decided]** Boards rank **unboosted** score, so paid score boosters can't buy a
  rank. **Gem-revived runs count normally.** The doubling revive price is the limit.
- **[decided]** The details:
  - Each board comes in **global** and **friends** versions.
  - The furthest-train and squad boards are **split by party size**: solo, duo, and 3–4
    players. The individual board is **one bracket** for co-op runs (2–4 players), since
    solo personal scores already appear on the solo squad board.
  - Scores are counted by the server only and submitted when the run ends.
  - Boards are shown on a wall of the hub train and on the run-end screen.
  - They ship with the meta systems in M4.

## Hub train
**[decided]** This is our version of the original's Eagle-7. **[decided 2026-10-16]** It's called the
**Falcon-8**.
It has walk-up pods for:
- **Medbay**: heal,
- **Barracks**: agents and squad,
- **Armory**: upgrades,
- **Missions**,
- **Surplus shop**,
- **Exchange** (gems to coins; see [[Economy and Monetization]]).

It's a hand-built Workspace area that players walk around in, and it doubles as the
party lobby. **[decided 2026-10-16]** You walk it **side-on, like the runs**, with the pods and
[[Queue Pads]] in a row along the train.

## Milestones
**[decided]**
1. **M0, Bootstrap.** Server/client bootstraps, Remotes, Constants and Types in
   Studio (see `CLAUDE.md`).
2. **M1, First playable.** Spec and Studio checklist: [[First Playable (M1)]]. One theme, one hostile train built from carriage templates,
   the 2.5D movement lock, 1 agent with 2 weapons, 4 light enemies and 1 mid, budget
   spawning, and 1–4 player co-op with a shared run.
3. **M2, Loop.** Spec and Studio checklist: [[Loop (M2)]]. Hub train, next-train leap, checkpoint, agent swap, Mayhem and
   gadgets, coins and saving (DataStore service).
4. **M3, Content.** Bosses, hostages, survival, the remaining themes, more agents and
   weapons.
5. **M4, Meta and monetization.** Blueprints, upgrades, missions, boosters, the surplus
   shop, gems and Developer Products.
6. **M5, Polish and launch.** Final title, art pass, onboarding and tutorial, analytics.

## Open questions
- Final agent names ([[Launch Agents]], [[Title Ideas]]).
- Playtest the Mayhem fill rates and mech armour ([[Gadgets and Mayhem]]).
- Playtest the score values and the 2.5 s combo window ([[Score and Combo]]).
- Tune the economy ([[Economy and Monetization]]): Robux prices and earn rates.

Related: [[Home]] · [[Status]] · [[Art Direction]] · [[Original Game]] · [[0003-2.5d-side-scroller]]
