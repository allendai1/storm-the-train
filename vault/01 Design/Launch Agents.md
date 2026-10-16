---
tags: [design, feature, agents, roster, balance]
status: planned
updated: 2026-10-16
---
# Launch Agents

> **Status: planned.** The developer decided the roster size (6 agents, 2 free) in the
> [[Game Design Document]] and **accepted these six concepts** on 2026-10-13. Lines marked
> **[decided]** are settled. Loadouts and numbers not marked **[decided]** are still
> proposals to tune. Names are **placeholders** and may change in the naming pass in
> [[Title Ideas]]. Before keeping any
> name, search Roblox and run a basic trademark check. The numbers come from the
> original's agent and weapon tables
> ([[Original Game - Items and Economy]], [[Original Game - APK Balance Audit]]). They're a
> starting point for playtesting, not final balance.

## Summary
The Agency's six launch agents are a squad of misfits. Each has one costume or
personality gag that reads at a glance from the side view, and fits the
over-the-top comedy tone. Mechanically they follow the original's design pattern:
- Every agent sits on a **speed vs. toughness curve**: fast agents are fragile and slow
  agents are tanky. This uses the decided original spread.
- Every agent has **2 fixed weapons**, **3 gadgets**, and **0–2 perks**.
- The four paid agents each **specialise against one enemy theme and struggle against
  another**. Each theme has exactly one specialist and one agent who struggles with it.

A player brings up to 3 agents into a run and swaps between them. All of that player's
agents share one 100 HP pool. Picking a squad that covers the themes ahead is the
strategic layer, and swapping mid-run is the skill layer.

## The roster at a glance

| # | Agent | One-line gag | Role | Unlock | Speed (px/s → studs/s) | Toughness | Effective HP* |
|---|---|---|---|---|---|---|---|
| 1 | **Dash Daring** | Square-jawed agent in a tux who narrates his own heroics | All-rounder | Free (starter) | 425 → 28.3 | 0.52 ★★★ | 192 |
| 2 | **Brick Broadsley** | Retired pro wrestler in a mask and cape, carrying a tiny briefcase | Tank | Free (first checkpoint) | 300 → 20 | 0.20 ★★★★★ | 500 |
| 3 | **Turbo** | Roller-skating courier who's always late, and always fast | Skirmisher / reviver | 80 gems | 500 → 33.3 | 0.76 ★ | 132 |
| 4 | **Nana Nitro** | Sweet little granny with a knitting bag full of explosives | Crowd control / support | 100 gems | 350 → 23.3 | 0.28 ★★★★ | 357 |
| 5 | **Mimi the Mime** | A silent mime whose invisible props really work | Acrobat / precision | 100 gems | 450 → 30 | 0.64 ★★ | 156 |
| 6 | **Zorp** | An alien "exchange agent" in a tourist shirt who thinks Earth is a theme park | Heavy hitter | 150 gems | 375 → 25 | 0.40 ★★★ | 250 |

\*Effective HP = 100 ÷ toughness, i.e. how much raw enemy damage it takes to down that
agent. It's shown here for balance only; the UI shows stars.

The speeds and toughness values all come from the original's ability tables, and stay inside the
decided ranges (275–500 px/s and 0.20–0.76). Gender mix: 2 men, 3 women, 1
alien. Silhouettes: tux, giant cape, skates and helmet, tiny granny with a huge bag,
beret and stripes, big-headed alien.

## Agents

### 1. Dash Daring — "AGENT NUMBER ONE (HE SAYS)"
The starter, and the face of the game. He's competent and confident, with a terrible
sense of self-awareness. His hair never moves, even in an explosion.
- **Weapons:**
  - **Service Rifle** (Rifle archetype): 12 damage every 0.175 s. A steady, accurate
    bread-and-butter weapon.
  - **Pocket Rocket** (Rocket Launcher archetype): 13 damage plus splash, every 0.5 s.
    It teaches new players about area damage and crowds.
- **Gadgets:** Turret Drone, Melee Drone, Air Strike.
- **Spin attack:** level 4.
- **Perks:** none. He's the pure all-rounder that every other agent is measured against,
  as the original's starter was.
- **Theme bonus:** none, so he's never a wrong pick.
- **Barks:** "Daring by name…", "Nailed it.", "That was a *planned* fall."

### 2. Brick Broadsley — "THE MAIN EVENT"
A retired pro wrestler who joined the Agency for the entrances. He's huge and slow, and
plays to a crowd that isn't there.
- **Weapons:**
  - **Scattergun** (Shotgun archetype): 12 per pellet (16 up close) every 0.45 s.
    Devastating at short range.
  - **Crowd Pleaser** (Minigun archetype): 6 damage every 0.07 s after a short spin-up.
    It holds a whole carriage.
- **Gadgets:** Defender Drone, Melee Suit ("the Heavyweight": he puts on the Championship Belt and grows into it), Air Strike.
- **Spin attack:** level 6. It's his signature move.
- **Perk:** **Feeds off the crowd.** He gains Mayhem when he takes damage (the original's
  "Mayhem from damage taken"). Tanking hits charges his gadget, which suits a front-line
  agent.
- **Theme bonus:** none. As the second free agent he should be a safe pick too.
- **Unlock:** **[decided]** Brick is the second free agent, given at the player's **first
  checkpoint**. That moment also triggers
  the squad-swap tutorial, so swapping is taught right when the player gets a second
  agent.
- **Barks:** "ARE YOU NOT ENTERTAINED?!", "Ring the bell!", "*Flexes*"

### 3. Turbo — "SIGNED, SEALED, DELIVERED"
A roller-skating courier recruited because nobody could catch her. She's the fastest
agent on the rails and the most fragile.
- **Weapons:**
  - **Twin Zippers** (Dual SMGs archetype): 4 damage every 0.075 s. A spray that works
    on the move.
  - **Spark Plug** (Lightning Gun archetype): 4 damage every 0.1 s, chaining between
    grouped enemies.
- **Gadgets:** Healer Drone, Smasher Drone, Air Strike.
- **Spin attack:** level 3.
- **Perk:** **Pit stop.** She heals a little on each kill (the original's "heal on kill").
- **Theme bonus:** **+40% damage vs Robots** (lightning shorts them out), **−25% vs
  Undead** (you can't electrocute what's already dead).
- **Co-op role:** with the top speed (33 studs/s) she can **reach downed teammates
  first**. Revives are a 2 s hold, so speed is a real support stat.
- **Barks:** "Express delivery!", "Beep beep!", "Sorry I'm late. Wait, I'm early?"

### 4. Nana Nitro — "BACK IN MY DAY…"
A sweet, tiny grandmother and the Agency's longest-serving agent. Her knitting is
explosive and so is her temper.
- **Weapons:**
  - **Yarn Bombs** (Sticky Bomb Launcher archetype): 36 damage every 0.5 s. They stick,
    then go off with area damage.
  - **Blow-Dryer of Doom** (Heat Ray / flamethrower archetype): 1 damage every 0.15 s
    plus burning. It's short range and sets crowds on fire.
- **Gadgets:** Healer Drone, Freeze Drone, Heal Suit ("Rocking Chair Mech").
- **Spin attack:** level 4. It's a handbag swing.
- **Perk:** **Knits fast.** Mayhem fills about 1.3× faster.
- **Theme bonus:** **+40% damage vs Undead** ("I've buried three husbands, dear"),
  **−25% vs Ninjas** (too fast for her eyes).
- **Co-op role:** the natural support. She has crowd control, a healer drone, and enough
  toughness to stand next to a downed teammate and revive them.
- **Barks:** "Eat your vegetables!", "Who wants a cookie?", "In MY day trains had
  manners!"

> **[decided]** Ma Rattler, the Wild West boss, also says "EAT YER VEGETABLES!"
> ([[Wild West Enemies]]). Both keep the line for now, as a running gag.

### 5. Mimi the Mime — "…"
A mime who never says a word, and whose invisible props work for real. She's
acrobatic and precise, and she's funnier the more serious things get.
- **Weapons:**
  - **Finger Guns** (Dual Pistols archetype): 14 damage every 0.2 s. Yes, she's pointing
    her fingers, and yes, they fire.
  - **Invisible Bow** (Rail Gun / charge archetype): hold to draw an invisible bow and
    release a piercing shot. **[decided 2026-10-16] No damage scaling:** the draw takes
    **0.8 s**, and the shot does a fixed **70, piercing** every enemy in line. Releasing
    before the draw finishes cancels the shot; once drawn, it fires on release. (The
    original's charge-weapon maths wasn't recovered.) On mobile it's hold-to-charge on
    the shoot button.
- **Gadgets:** Defender Drone ("Invisible Wall"), Freeze Drone, Melee Drone.
- **Spin attack:** level 8, the strongest at launch. Her cartwheel kick is her main
  answer to crowds.
- **Perk:** none beyond her spin.
- **Theme bonus:** **+40% damage vs Ninjas** (the only agent quieter than them), **−25%
  vs Wild West** (cowboys heckle, and she loses her focus).
- **Barks:** none, by design. She does silent reactions and props instead. Her "voice
  lines" are sound effects: a slide whistle, a kazoo, an exaggerated sigh.

### 6. Zorp — "TAKE ME TO YOUR CONDUCTOR"
An alien on an exchange programme who's convinced Earth is a theme park and the train
is the best ride. He takes photos mid-fight.
- **Weapons:**
  - **Ray Blaster** (Plasma Cannon archetype): 13 damage every 0.5 s. A heavy bolt that
    pierces through the first enemy.
  - **Goo Gun** (Poison archetype): 2 damage every 0.4 s, plus goo that deals damage over
    time and **slows** enemies.
- **Gadgets:** Turret Drone, Freeze Drone, Damage Mech ("the Saucer").
- **Spin attack:** level 5.
- **Perk:** **Alien regen.** He slowly regains health over time (the original's "heal over
  time").
- **Theme bonus:** **+40% damage vs Wild West** (bandits panic at a flying saucer),
  **−25% vs Robots** (they keep hacking his tech).
- **Barks:** "Fascinating!", "Earthlings are so bouncy!", "Five stars, would ride again."

## Rules & numbers
- **[decided] Theme matchups.** Each theme has one specialist and one agent who struggles:

  | Theme | +40% damage | −25% damage |
  |---|---|---|
  | Wild West | Zorp | Mimi |
  | Ninjas | Mimi | Nana |
  | Undead | Nana | Turbo |
  | Robots | Turbo | Zorp |

  **[decided]** The bonus keeps the original's +40%, but the penalty is **softened to
  −25%** for co-op. That way a player whose squad struggles with a theme still pulls
  their weight for the team. Swapping still matters: when the next train's theme is
  announced, swap to your specialist. **[proposed]** Solo uses the same −25%, so there's
  one rule to learn and balance.
- **[proposed] Agent stats are fixed.** As in the original, agents don't level up. Their
  speed, toughness, spin and perks never change. Progression comes from upgrading their
  weapons and gadgets (10 levels each, gated by coins and blueprints, per the GDD).
- **[proposed] Swap cooldown: 1.5 s.** The original's value wasn't recovered. The swap
  keeps your HP, position and Mayhem. On swapping in, the agent says one line, and the
  original's shared "I'M BACK!" line is a good model for that.
- **[proposed] Duplicates in a party are allowed.** Two players can both bring Dash. That
  avoids lobby arguments, and the speed/toughness curve already pushes squads to
  diversify.
- **[proposed] Gem prices:** 80 / 100 / 100 / 150, which is **430 gems** for the paid
  four. This follows the original's tiers (80, 100 and 150). The real prices wait for
  the gem economy.
- **[proposed] Co-op gadget rules** (full gadget design in [[Gadgets and Mayhem]]): the Healer Drone and Heal Suit heal **every
  teammate in range**, not just the owner. The Defender Drone blocks projectiles for
  anyone behind it. This keeps "Better together" true for support agents.
- **[proposed] DPS reference at weapon level 1.** These are nominal numbers (damage ÷
  interval, before splash, pellets, burning or chaining). They're for sanity-checking
  only, not a ranking:

  | Agent | Primary | Nominal | Secondary | Nominal |
  |---|---|---|---|---|
  | Dash | Service Rifle | 69 | Pocket Rocket | 26 + splash |
  | Brick | Scattergun | 27 per pellet | Crowd Pleaser | 86 (after spin-up) |
  | Turbo | Twin Zippers | 53 | Spark Plug | 40 + chain |
  | Nana | Yarn Bombs | 72 + area | Blow-Dryer | 7 + burn |
  | Mimi | Finger Guns | 70 | Invisible Bow | 70 + pierce (0.8 s draw) |
  | Zorp | Ray Blaster | 26 + pierce | Goo Gun | 5 + DoT + slow |

## Systems involved
_None built yet._ When built, this will need an agent/squad service (loadout, swap and
the shared HP pool) and a weapon service. Create their notes in `02 Systems/` from
[[Templates/System|the System template]].

## Studio build list
_Not started. Studio work begins once the design is complete._
- [ ] One rig model per agent in `ReplicatedStorage.Assets.Agents` (e.g. `DashDaring`),
  with tunables as **Attributes** so they can be tweaked in the Properties panel:
  `Speed`, `Toughness`, `SpinLevel`, `ThemeBonus`, `ThemePenalty`.
- [ ] Weapon models in `ReplicatedStorage.Assets.Weapons`, one per weapon above.
- [ ] Squad-select UI in `StarterGui` (the Barracks pod on the hub train), plus the
  in-run squad strip with 3 portraits.
- [ ] Gadget models: drones, the 3 mech suits, and the Air Strike marker.

## Art & audio needs
See [[Art Direction]] (still empty). Each agent needs:
- a silhouette you can recognise at a glance from the side, plus 3 stages of costume damage (GDD),
- idle, run, jump, spin, shoot, swap-in, downed and revived animations,
- 3–5 barks (Mimi gets sound effects instead).

## Post-launch agent ideas
These are not part of the launch 6, just for later:
- **Frank**, an agent stuck in a hot dog costume since a food-truck stakeout.
- A shark-suit agent.
- A robot butler.
- A cowboy sheriff, who would be the obvious Wild West specialist.

## Open questions
- Final agent names (the current ones are placeholders).
- ~~Mimi's Invisible Bow needs a charge formula.~~ **[decided 2026-10-16]** A fixed 70 piercing
  shot after a 0.8 s draw (above). Tune the numbers in playtests.

## Implementation notes
- **M2 Session 10 (2026-10-14):** Dash and Brick are built as greybox templates with these
  stats ([[AgentService]]). Brick's hitbox (2 × 6.3) and spin numbers (9 / 6 studs for level
  6) are first guesses. The swap cooldown is 1.5 s, as proposed.
_Not built. Design only._

Related: [[Game Design Document]] · [[Gadgets and Mayhem]] · [[Wild West Enemies]] · [[Title Ideas]] · [[Home]]
