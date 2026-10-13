---
tags: [design, gdd]
status: draft
updated: 2026-10-13
---
# Game Design Document — Train Runner

> **How to read this.** Lines marked **[decided]** were chosen by the developer.
> Lines marked **[proposed]** are Claude's suggestions, drafted from the
> [[Original Game]] reference notes, and are not canon until accepted. When a
> proposal is accepted, change its marker to **[decided]**. When it's rejected,
> delete it or move it to [[#Open questions]].

## Pitch
**[proposed]** A co-op, over-the-top action side-scroller where a squad of 1–4
secret agents storms hostile trains roof by roof. Players blast through themed
enemy crews, swap between agents mid-fight, rescue hostages, take down bosses and
leap from train to train. Between runs they head back to their own armoured hub
train to upgrade.

**Working title:** **Train Runner**. **[decided]** It replaces "Storm the Train", which
belongs to the original. It's a working title for now: confirm the final name before
publishing (see [[Title Ideas]]).

## Relationship to the original
- **[decided]** This is a **new IP inspired by** the 2016 mobile game *Storm the Train*
  (Games Faction). We keep the core idea (fighting across hostile trains, squad
  swapping, themed trains, a hub train between runs) and use our own name, characters,
  story, art, audio and UI.
- **[decided]** Original names don't carry over: no Graham, Mason, Eagle-7, Chubwick,
  GOAT, Cabal, and so on. The original's art, audio, fonts and level-pattern data are
  reference only and never ship.
- **[proposed]** The original's **numbers and system shapes**, such as the spawn budget
  model, enemy stat bands and upgrade cost curve, are used as a **starting point for
  balance**. They're tuned for a different medium, so playtest them before trusting them.

## Design pillars
**[proposed]**
1. **Chaos you can read.** Big explosions, crowds and gags, but the side-on view keeps
   every threat readable at a glance.
2. **Better together.** Every system should be fun solo and better in a squad: revives,
   combo Mayhem and shared objectives like freeing a hostage.
3. **Always moving forward.** The train never stops. Runs flow from fight to leap to
   fight with minimal downtime.
4. **Silly, never mean.** The comedy is in costumes, taunts and cartoon violence. It
   stays within Roblox community standards (stylised knock-outs, no realistic gore).

## Target audience & platforms
- **[proposed]** Roblox players aged about 9–16 who like action and shooters, playing
  with friends.
- **[proposed]** PC, mobile and console. Controls are designed mobile-first, since the
  original was a touch game, with keyboard/mouse and gamepad bindings.

## Tone
- **[decided]** **Over-the-top comedy action.** Think silly secret-agent squad,
  costume-gag agents, bosses that taunt you, and enemies that go flying.
- **[proposed]** Use cartoon knock-outs (enemies pop into stars or smoke, or fly off
  the train) rather than the original's gibs, to stay within Roblox content rules.

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

**[proposed]** Run anatomy:
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

**[proposed]** The loop in detail:
1. **Gear up on the hub train.** Pick a squad of up to 3 agents, spend coins on upgrades, equip up to 3
   boosters, choose missions.
2. **Storm a hostile train.** Fight carriage by carriage against a themed enemy crew.
   An event may trigger: boss, hostage, blueprint thief, survival waves.
3. **Leap to the next train.** "Next train" is announced, the squad jumps across, and
   the theme may change. Loose coins sit between trains.
4. **Checkpoint.** After every 3rd train the hub train pulls alongside: heal, bank blueprints,
   buy upgrades, re-equip boosters, then continue or cash out.
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
  - **[proposed]** The starter agent sits at about **28 studs/s** (the original's free
    agent had 425 px/s). Speed upgrades and the Mayhem speed perk can't push an agent
    past 33.
  - **[proposed]** Enemy attacks meant to be dodged must be **jumped**, not outrun,
    because players outrun nearly everything. Any charge or rush has to be faster than
    33 studs/s or cover the whole carriage.

| Action | Keyboard/mouse | Gamepad | Mobile |
|---|---|---|---|
| Move | A / D | Left stick | Left/right buttons |
| Jump / **double jump = spin attack** | Space | A | Jump button |
| Shoot (aim follows facing, light auto-aim) | Left mouse / J | RT | Shoot button |
| Swap agent | Q / E | LB / RB | Swipe or swap button |
| Use gadget (when Mayhem is full) | F | Y | Gadget button |
| Interact (free hostage, enter hub pod) | E (context) | X | Context button |

**[proposed]** Aiming is along the facing direction, with optional slight up/down
mouse aim on PC. Mobile buttons can be repositioned, as in the original.

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
  - **[proposed]** The UI shows toughness as 1–5 stars rather than the raw multiplier.
- **[decided]** Each player brings a **squad of up to 3 agents**, as in the original,
  and swaps between them. Only the active agent is on screen, so a full party shows 4
  agents, not 12. All of a player's agents share that player's health pool, which was
  the original's core hook.
  - **[proposed]** New players start with the 2 free agents, so they can swap from
    their first run. The third slot fills when they unlock a third agent.
  - **[proposed]** Swap cycles to the next agent (Q/E or LB/RB pick a direction). On
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
- **[proposed]** Details still to confirm:
  - The starting gem price (5 is a placeholder until the gem economy is set).
  - A player who bleeds out with teammates still standing **spectates** and rejoins at
    the next checkpoint with full HP.
  - Reviving is interrupted if the reviver takes damage, so teammates have to clear
    space first.
- **[proposed]** Solo play is the same game with a 1-player party. Enemy spawn budget
  and caps scale with party size.
- **[proposed]** Matchmaking: parties are formed on the hub, with quick-join for open
  slots. The run takes place in a reserved server, with Teleport from the lobby place.

## Key mechanics
**[proposed]** These are adapted from the original. See the reference notes for its
numbers.
- **Roster.** **[decided]** **6 agents at launch, 2 of them free**: the starter plus
  one unlocked early through play. The other 4 cost gems, which can also be earned
  through play, more slowly. More agents, including costume agents, come after launch.
  **[decided]** The six concepts in [[Launch Agents]] are accepted (names are
  placeholders). Brick Broadsley is the second free agent. Theme matchups are +40%
  against one theme and −25% against another.
- **Agents.** Each has 2 fixed weapons, 1–3 gadgets and traits: resilience, speed,
  spin-attack strength, and a bonus against one enemy faction. Swapping is instant
  with a short cooldown.
- **Weapons.** Archetypes are carried over (rifle, dual SMGs, shotgun, minigun, rocket,
  sticky bombs, flamethrower, poison, lightning, rail/charge gun, plasma), each with
  10 upgrade levels. Use [[Original Game - APK Balance Audit]] as the baseline
  damage and fire-interval table.
- **Spin attack.** Double jump does damage around you and finishes off knocked-down
  enemies.
- **Mayhem meter.** Kills fill it. When full, you get a free gadget: a drone (turret,
  melee, healer, freeze, defender, smasher), a mech suit, or an air strike. In co-op,
  each player has their own meter.
- **Combo multiplier.** Chained kills multiply score.
- **Visible armour damage.** Agents' outfits break apart in 3 stages as health drops,
  as cartoon costume damage.

## Enemies & themes
- **[decided]** Four themes: **Ninjas**, **Undead/horror**, **Robots/future** and
  **Wild West bandits** (new to this game).
- **[proposed]** Each theme fills the same **10 enemy slots**, so one spawn script
  drives every theme:
  - slots 0–3 are light grunts,
  - slots 4–6 are mids, who also carry keys and blueprints,
  - slots 7–8 are bosses,
  - slot 9 is the boss minion.
  Starting stat bands come from [[Original Game - Enemies and Spawning]]:
  - lights have 18–45 HP,
  - mids have 160 HP,
  - bosses have 550–700 HP.
- **[proposed]** Spawning uses a **budget model**. Each enemy has a cost, and waves are
  bought from a budget that ramps over time, with a cap on the total cost alive at
  once. Each new mid is introduced alone as a mini-boss beat.
- **[decided]** The **first playable has 1 theme: Wild West bandits**. They're the
  most "train" flavoured theme and the most clearly our own IP. The other themes
  follow once the loop is fun. The roster draft is in [[Wild West Enemies]].

## Train events
**[proposed]**
| Event | Summary | Milestone |
|---|---|---|
| Normal train | Clear carriages front to back | First playable |
| Blueprint thief | An enemy carrying a blueprint; kill it and grab the drop | First playable |
| Boss | Boss fight on a flatbed, with taunts and summoned minions | M3 |
| Hostage | Kill the key-holder mid, grab the key, free the hostage | M3 |
| Survival | Survive N waves; one-hit death | M3 |
| Vehicle/runner section | Auto-run obstacle stretch (the original's "rolling ball" and jetpack segments) | Later |

## Progression & economy
**[decided]** **Original-style** economy and monetization.

**[proposed]** The structure, adapted from [[Original Game - Items and Economy]]:
- **Coins** are the soft currency. You earn them in runs and missions, and spend them
  on weapon and gadget upgrades (L2–L10) and some boosters. As a baseline, the original
  costs ran from 1,000 to 14,000 per level, for 51,400 in total per item.
- **Gems** are the premium currency. You earn a few through missions and challenges,
  and buy more with Robux (Developer Products). You spend them on agents, the
  stronger boosters and the rotating surplus shop.
- **Blueprints** gate each upgrade level. Enemies "steal" them, and you recover them
  in runs and bank them at the hub. Unlocks are weighted towards gear you own and
  your lowest-level items.
- **Boosters**: up to 3 per train, for score, Mayhem, coins, damage, health, gems and
  magnet.
- **Missions**: 3 active at once, rerollable or skippable. There are also daily
  challenge chains per agent.
- **Surplus shop**: a rotating gem shop selling upgrade levels with "no blueprints
  required", in three offers (cheap, mid and premium).

## Monetization
- **[decided]** In the **original's style**: premium currency buys agents and
  boosters, and coins buy upgrades.
- **[proposed]** Gem packs (Developer Products), a starter pack, an "unlock all agents"
  bundle (Game Pass), revive-for-gems, cosmetic skins and costume agents.
- **[proposed]** Guardrails, because this is co-op:
  - Paid power should never make a teammate's run worse.
  - Paid boosters affect only the buyer. A gems booster doesn't change your
    teammates' damage.
  - Damage and health boosters have a party-wide cap.
  - Free players can earn every agent through play, more slowly.
- **[proposed]** **Roblox policy:** any paid random item, such as a random booster offer
  bought with Robux-bought gems, must disclose odds. Keep paid offers deterministic,
  like the original's surplus shop, to avoid the issue.

## Leaderboards
- **[decided]** **Co-op leaderboards only. No PvP.**
- **[proposed]** The details:
  - There are two boards: **furthest train reached** and **best run score**.
  - Each comes in **global** and **friends** versions.
  - Each is **split by party size**: solo, duo, and 3–4 players.
  - Scores are counted by the server only and submitted when the run ends.
  - Boards are shown on a wall of the hub train and on the run-end screen.
  - They ship with the meta systems in M4.

## Hub train
**[proposed]** This is our version of the original's Eagle-7, with a new name to pick.
It has walk-up pods for:
- **Medbay**: heal,
- **Barracks**: agents and squad,
- **Armory**: upgrades,
- **Missions**,
- **Surplus shop**.

It's a hand-built Workspace area that players walk around in, and it doubles as the
party lobby.

## Milestones
**[proposed]**
1. **M0, Bootstrap.** Server/client bootstraps, Remotes, Constants and Types in
   Studio (see `CLAUDE.md`).
2. **M1, First playable.** One theme, one hostile train built from carriage templates,
   the 2.5D movement lock, 1 agent with 2 weapons, 4 light enemies and 1 mid, budget
   spawning, and 1–4 player co-op with a shared run.
3. **M2, Loop.** Hub train, next-train leap, checkpoint, agent swap, Mayhem and
   gadgets, coins and saving (DataStore service).
4. **M3, Content.** Bosses, hostages, survival, the remaining themes, more agents and
   weapons.
5. **M4, Meta and monetization.** Blueprints, upgrades, missions, boosters, the surplus
   shop, gems and Developer Products.
6. **M5, Polish and launch.** Final title, art pass, onboarding and tutorial, analytics.

## Open questions
- Final title (working title is Train Runner), and names for the agency, the hub
  train and the agents ([[Title Ideas]]).
- Revive gem price, and what happens to a player who bleeds out (spectate until the
  checkpoint is proposed).
- Review the Wild West roster draft ([[Wild West Enemies]]).
- Tune the launch agents ([[Launch Agents]]): the Invisible Bow's charge formula and
  what the 3 mech suits do.
- How is score calculated? It decides the score leaderboard. The combo multiplier,
  kills, train-clear bonuses and no-damage bonuses are candidates.

Related: [[Home]] · [[Status]] · [[Art Direction]] · [[Original Game]] · [[0003-2.5d-side-scroller]]
