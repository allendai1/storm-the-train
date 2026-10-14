---
tags: [design, feature, gadgets, mayhem, mechs, drones, balance]
status: planned
updated: 2026-10-13
---
# Gadgets and Mayhem

> **Status: planned.** This is Claude's draft of the Mayhem meter, the 6 drones, the 3 mech
> suits and the Air Strike. The developer settled its key rules on 2026-10-13. Those
> lines are marked **[decided]**, and the rest are still proposals. The [[Game Design Document]] already says that
> kills fill a per-player Mayhem meter and a full meter gives a free gadget. Everything
> below adds detail to that. Durations come from the original's gadget table
> ([[Original Game - Items and Economy]] §5). Damage, armour and fill numbers are new
> proposals, because the original's drone and mech weapon values weren't recovered.

## Summary
Gadgets are the payoff for fighting well. Kills fill your **Mayhem meter**. When it's
full, you deploy one of your **active agent's 3 gadgets**:
- **6 drones** are helpers that fight beside you for 10–90 s.
- **3 mech suits** turn you into a big, armoured, short-lived powerhouse.
- **1 Air Strike** clears the carriage.

Each agent has a fixed gadget list ([[Launch Agents]]), so gadgets are part of what makes
each agent feel different. Swapping agents while your meter is full changes which
gadgets you can pick.

## Player experience
- The meter visibly fills during a fight, and the HUD **pops** when it's full: a flash, a
  sound, a short bark from the agent. You then choose *which* gadget fits the moment.
  That might be a Defender before Ma Rattler's gatling sweep, a Healer when the squad is
  low, or an Air Strike when the carriage is packed.
- A mech suit is the biggest moment in a run. A landing stomp on entry, a huge
  silhouette, a different moveset, then you pop out when it ends.
- In co-op, gadgets are how you help each other. Healers and Heal Suits heal
  everyone nearby, Defenders cover the people behind them, and assists fill your meter.

## Mayhem meter
- **[proposed] It's a 0–100 meter per player.** It's kept when you swap agents and
  carried between trains in a run. It resets when the run ends.
- **[proposed] Ways to fill it:**

  | Source | Mayhem |
  |---|---|
  | Light enemy knocked out | 4 |
  | Mid enemy knocked out | 20 |
  | Boss | 1 per 10 damage you deal (so boss fights still charge gadgets) |
  | Spin-attack knockout | ×1.5 on the above |
  | Assist (you damaged it, a teammate knocked it out) | 50% of the kill value |
  | Agent perks | Nana fills ×1.3. Brick gains 0.5 per point of raw (pre-toughness) damage he takes |

  The target is a full meter roughly every **45–60 s** of steady fighting, which is about 2–3
  gadgets per train. Check that in the first playtest.
- **[proposed] Co-op balance.** Enemy counts scale up less than one-for-one with party
  size (×2.8 enemies for 4 players), so each player gets fewer kills in a full party.
  Assists make up most of the difference.
- **[proposed] The meter empties when you deploy** a gadget. It doesn't decay while full,
  so you can save a full meter for the right moment, for example the next train's boss.

## Deploying a gadget
- **[decided] You choose which gadget.** When the meter is full, the active agent's 3
  gadget slots light up:
  - **PC:** keys **1 / 2 / 3**. **F** repeats your last pick.
  - **Gamepad:** **D-pad** left / up / right.
  - **Mobile:** tap your **glowing Mayhem ring** on the left edge, and the 3 gadgets fan
    out beside it.
  - **[decided] Display:** your meter is a **ring on the left edge** that fills clockwise
    and **glows when full**. On PC the 3 gadgets fan out from it with their 1/2/3 keys.
    Teammates' meters are thin rings around their portraits that glow when ready, so a
    squad can see who has a gadget up. See [[Art Direction]] §10.

  The original seems to have handed you a specific free gadget ("FULL MAYHEM GIVES YOU A
  FREE GADGET. GRAB IT NOW!"). Choosing is more interesting and suits a squad game.
  (This replaces the single "Use gadget" row in the GDD's controls table.)
- **[proposed] When gadgets are blocked** (adapted from the original's lock reasons; the
  button shows why):
  - between trains, during the leap and while on the hub train,
  - while the theme is changing,
  - **one drone per player** at a time ("DRONE ALREADY ACTIVE"),
  - no new gadget while you're **in a mech suit**,
  - **[decided] one Air Strike per party** at a time. While a teammate's strike is
    incoming, your Air Strike slot shows "STRIKE INCOMING" and your meter stays full.
- **[proposed] Swapping and gadgets.**
  - A **drone stays** when you swap agents. It belongs to the player, not the agent.
  - **You can't swap while in a mech suit.** The suit is that agent's.
- **[proposed] No paid deploys.** The original's gadget manager had a deploy price, so it
  may have sold extra uses. Here gadgets come only from Mayhem, so nobody pays to
  out-gadget their teammates (see the monetization guardrails in the GDD). Mayhem
  boosters, which make the meter fill faster, are the paid lever instead.

## Upgrades
- **[proposed]** Drones and mech suits have **10 levels**, as in the original. Level 1 is free,
  and later levels cost coins and need blueprints, on the GDD's upgrade ladder. The
  Air Strike has **one level** and is never upgraded.
- **[proposed]** Each level adds about **3–10% duration**. Drones with a weapon also get a
  **weapon tier** at levels 1/3/5/7/9 (5 tiers): each tier adds about 25% weapon
  damage, plus a visual upgrade, e.g. a second barrel.

## Gadgets at a glance

| Gadget | Type | What it does | Duration L1 → L10 (s) | Used by (agent's name for it) |
|---|---|---|---|---|
| **Turret Drone** | Drone | Hovers by you and shoots the nearest enemy | 30 → 57 | Dash, Zorp |
| **Melee Drone** | Drone | Chases enemies and punches them | 30 → 56 | Dash, Mimi |
| **Freeze Drone** | Drone | Fires freeze shots that slow, then freeze, enemies | 36 → 63 | Nana, Mimi, Zorp |
| **Defender Drone** | Drone | Blocks enemy projectiles for you and anyone behind you | 51 → 87 | Brick, Mimi ("Invisible Wall") |
| **Smasher Drone** | Drone | Slams down on enemy groups, knocking lights off the train | 10 → 19 | Turbo |
| **Healer Drone** | Drone | Heals you and teammates nearby | 15 → 28.5 | Turbo, Nana |
| **Damage Mech** | Mech suit | Fast gun mech | 15 → 26.7 | Zorp ("the Saucer") |
| **Melee Suit** | Mech suit | Slow, heavy brawler that knocks enemies off the train | 15 → 26.7 | Brick ("the Heavyweight") |
| **Heal Suit** | Mech suit | Support mech: damage beam plus party heals and fast revives | 15 → 26.7 | Nana ("the Rocking Chair Mech") |
| **Air Strike** | Strike | Countdown, then a bombing run along the carriage | — (one level) | Dash, Brick, Turbo |

The durations are the original's values. Its two obvious typos are fixed: Melee L5 is 42,
not 41, and Freeze L6 is 51, not 41. Every agent's 3 gadgets are listed in
[[Launch Agents]]. Each mech suit belongs to **one** launch agent and is themed for them.
A later agent with the same mech type gets their own look.

## Drones
All drones follow their owner, hover just above and behind them on the side-view plane,
and can't be damaged. **[proposed]** Their weapon numbers are below.

### Turret Drone
- Fires at the nearest enemy in **25 studs**: **8 damage every 0.25 s** at tier 1 (32
  nominal DPS), rising about 25% per tier.
- It's the simplest "more damage" gadget and the starter's first gadget.

### Melee Drone
- Flies out to the nearest enemy and punches it: **15 damage every 0.6 s**, about 25%
  more per tier. It returns to you between targets.
- It's good at finishing bosses (the original had a "Finish a boss with a Melee Drone"
  mission).

### Freeze Drone
- Fires a freeze shot every 1 s. Each hit **slows** an enemy by 25%. **Three hits freeze it
  solid** for 2 s × that enemy's freeze scalar: lights 1.0, mids 0.6, bosses 0.3 (see
  [[Wild West Enemies]]).
- A **spin attack on a frozen light knocks it out instantly**, popping it out of the ice.
  That's a satisfying combo to teach.
- Higher tiers fire faster and freeze for longer.

### Defender Drone
- Hovers in front of you, on the side you're facing, and **absorbs enemy projectiles**:
  bullets, dynamite, gatling fire, rolling pins. It doesn't stop melee or charges.
- In co-op it protects **every teammate behind it**. Teammates can stand in a line
  behind the Defender.
- It has the longest duration of any gadget (51–87 s), so it's a "set up for the next
  fight" gadget.

### Smasher Drone
- A heavy drone that rises and **slams down on the biggest enemy group** every 1.5 s:
  10 damage, knockback, and it **knocks light enemies off the train**.
- It also finishes off downed enemies: it shakes the keys loose from a dazed key
  holder, and stops an undead enemy getting back up.
- **[proposed] Change from the original.** The original's "corpse smasher" only
  smashed corpses, which would do almost nothing in the Wild West, where knockouts are
  final and ragdolls fade out. Its short duration (10–19 s) makes it a burst
  crowd-clearer instead.

### Healer Drone
- Heals **2 HP per second** to you and **every teammate within 10 studs**. That's about
  30 HP over its full duration at L1, and about 57 at L10.
- **[decided] It pauses the bleed-out timer** of a downed teammate in its range. It
  can't revive them, but it buys time.

## Mech suits
Deploying a mech suit puts your agent inside it for its duration.
- **[proposed] Entry stomp:** landing in the suit does **200 damage in a 6-stud radius**
  (the original's `MECH_AOE` value). Bosses take half. That clears the lights around
  you and leaves a mid badly hurt.
- **[proposed] Armour:** the suit has its **own armour bar**. Enemy hits drain the armour,
  not your health pool. You're ejected when either the timer or the armour runs out. That
  protects your HP while you're in the suit and makes the suit's size a real
  trade-off.
- **[proposed] Ejecting** gives you 1 s of invulnerability and a small knockback ring, so
  you aren't punished for popping out in a crowd.
- **[proposed] You don't take damage from your toughness while suited.** Only the
  suit's armour matters. (Mechs in the original had their own resilience of 1.00.)
- Their speeds and physics come from the original's mech table, converted at 15 px = 1
  stud.

| Suit | Speed | Armour* | Primary | Double jump (spin) | Special |
|---|---|---|---|---|---|
| **Damage Mech** (Zorp's Saucer) | 500 px/s → 33 studs/s | 100 | **Heavy cannon**: 25 damage every 0.2 s | **Spinning barrage**: bullets fired in a full circle | The fastest suit, with normal gravity |
| **Melee Suit** (Brick's Heavyweight) | 350 → 23 | 200 | **Spinning foam-finger arms** ("WE'RE #1"): 12 damage every 0.1 s at melee range, with strong knockback | **Body slam**: a ground pound that knocks lights off the train | Heavy gravity (3.5): falls fast and slams hard |
| **Heal Suit** (Nana's Rocking Chair Mech) | 450 → 30 | 150 | **Knitting-needle beam**: 15 damage every 0.25 s to enemies | **Healing ring**: heals teammates in 12 studs for 15 HP | Heals nearby teammates 3 HP/s, and **revives downed teammates in 0.5 s** instead of 2 s |

\*Armour is in raw damage points: a light punch takes 3. **[decided]** Armour doesn't change
with the suit's level. Upgrades add **duration only**, as in the original.

The original's Melee Suit used **twin rotating saw blades**. Those become foam fingers
here, to fit "Silly, never mean".

## Air Strike
- **3-second countdown** with a target marker on the carriage, then planes or drones
  make a **bombing run along your carriage and half of each neighbouring one**.
- **[decided] One per party at a time**, so stacked strikes can't nuke a boss.
- **200 damage** to every enemy caught in it (the original's value). **[proposed]** Bosses
  take **100**. No friendly fire, and hostages are never hit.
- One level and never upgraded, as in the original. Every agent who has it gets the same
  strike. The voice line is shared: "3… 2… 1… INCOMING!" (the original's shared line).
- **[proposed] It's the safety valve:** the gadget that saves a squad that's being
  overwhelmed. That's why the starter, the tank and the fragile fast agent carry it.

## Systems involved
**M2 Session 11 (2026-10-14):** the M2 subset is built as [[GadgetService]] (with
MayhemService and MayhemController). The meter fill values, gadget numbers and lock rules
are as proposed here; the tunables are template attributes.

_Original plan:_ When built, this needs a Mayhem/gadget service (meter, deploy
validation, durations), drone and mech controllers, and the shared revive and health
logic from the GDD. The **server owns the meter and every deploy**: the client asks to
deploy, the server checks the meter, the lock rules and a rate limit, and spawns the
gadget. Create the notes in `02 Systems/` when it's built.

## Studio build list
_Not started. Studio work begins once the design is complete._
- [ ] Drone models in `ReplicatedStorage.Assets.Drones`: `TurretDrone`, `MeleeDrone`,
  `FreezeDrone`, `DefenderDrone`, `SmasherDrone`, `HealerDrone`. Each needs a
  `PrimaryPart` and **Attributes** for its tunables (`Duration`, `Damage`,
  `FireInterval`, `Range`, `HealPerSecond`, …).
- [ ] Mech suit models in `ReplicatedStorage.Assets.Mechs`: `Saucer`, `Heavyweight`,
  `RockingChairMech`. Attributes: `Speed`, `Armour`, `GravityScale`, `JumpScale`.
- [ ] Air Strike target marker and planes in `ReplicatedStorage.Assets.Effects`.
- [ ] HUD in `StarterGui`: the Mayhem meter, the 3 gadget slots for the active agent, and
  timer rings on active gadgets. Built by hand, then scripted, per `CLAUDE.md`.

## Art & audio needs
See [[Art Direction]] (still empty).
- Every drone must read clearly from the side and at a distance, with one bold shape
  and colour per drone type. With 4 players there can be 4 drones on screen at once.
- Each mech needs enter, exit and eject animations, and a very different silhouette
  from the agent.
- Audio: a "Mayhem full" sting, a gadget deploy sound per type, the Air Strike countdown
  voice, and a bark for each agent entering their mech.

## Open questions
- Are the Mayhem fill values and the 45–60 s target right? They need a playtest.
- Mech armour values (100 / 150 / 200): playtest them. They don't scale with level.

## Implementation notes
_Not built. Design only._

Related: [[Game Design Document]] · [[Launch Agents]] · [[Wild West Enemies]] · [[Original Game - Items and Economy]] · [[Home]]
