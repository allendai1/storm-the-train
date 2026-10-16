---
tags: [design, writing, dialogue, tutorial, missions, challenges]
status: proposed
updated: 2026-10-16
---
# Writing and Dialogue

> **Status: proposed.** This is Claude's first pass at the game's words: voice rules,
> agent and enemy barks, announcements, the tutorial flow, the mission list and the
> per-agent daily challenge chains. Every name is a **placeholder** until the naming
> pass ([[Title Ideas]]). Lines are written to be swapped freely. Keep the structure and
> replace the jokes you don't like.

## 1. Voice rules
- **Shouty, short, silly.** In-game barks are **ALL CAPS** and **6 words or fewer**, so
  they read at a glance from the side-on camera, as in the original.
- **Silly, never mean** (GDD pillar 4). No insults about real-world groups, no gore,
  no scary threats. Enemies are cartoon villains and agents are lovable show-offs.
- **All ages.** Simple words and puns over references. Nothing that needs reading
  mid-fight.
- **Each agent sounds different.** Dash brags, Brick performs, Turbo rushes, Nana
  scolds sweetly, Mimi is silent (sound effects only), and Zorp is a delighted
  tourist.
- **[decided 2026-10-16] Barks are text bubbles with a voiced grunt.** Lines show as speech
  bubbles, and each agent and enemy type has a few short voiced grunts or exclamations.
  Lines aren't voiced in full. Mimi stays silent (sound effects only).
- **One bark per moment, at most.** There's a cooldown per agent of about 4 s, and
  important barks (downed, revived, Mayhem ready) skip the cooldown.
- **Announcements** are the game's own voice: big, centred, 1–4 words. They never use
  the original's "Storm the Train" or "Eagle-7".

## 2. Announcements (system text)
| Moment | Text |
|---|---|
| Train starts | **ALL ABOARD!** |
| Mid introduced | **HERE COMES TROUBLE!** (plus the mid's name) |
| Timeline finished | **REACH THE ENGINE!** |
| Train cleared | **TRAIN CLEARED!** |
| Next train ahead | **NEXT TRAIN — LEAP!** |
| Theme changes | **NEW TERRITORY!** (plus the theme name) |
| Checkpoint | **HUB TRAIN ALONGSIDE!** |
| Checkpoint vote | **CONTINUE OR CASH OUT?** |
| Event: hostage | **FREE THE HOSTAGE!** → **FIND THE KEYS!** → **SHAKE 'EM LOOSE!** → **GRAB THE KEYS!** |
| Event: thief | **BLUEPRINT THIEF!** → (on drop) **FINDERS KEEPERS!** |
| Event: survival | **SURVIVE!** (plus waves left) |
| Event: boss | **BOSS INCOMING!** |
| Mayhem full | **MAYHEM READY!** |
| Teammate downed | **(NAME) IS DOWN!** |
| Squad wiped | **SQUAD WIPED!** |
| Cashed out | **CASHED OUT!** |
| New best | **NEW SQUAD BEST!** |

## 3. Agent barks
Categories: **Start** (train begins) · **Swap** (swapped in) · **Crate** (weapon switch) ·
**Hit** (took a big hit) · **Down** · **Thanks** (revived) · **Help** (reviving a
teammate) · **Mayhem** (meter full / gadget) · **Mech** (entering their suit) · **Win**
(train cleared).

### Dash Daring: the brag
| Category | Lines |
|---|---|
| Start | "DARING BY NAME!" · "LET'S DO THIS. STYLISHLY." |
| Swap | "THE STAR HAS ARRIVED." · "MISS ME?" |
| Crate | "UPGRADE ACCEPTED." · "OOH, SHINY." |
| Hit | "NOT THE HAIR!" · "THAT WAS PLANNED." |
| Down | "I MEANT TO DO THAT…" |
| Thanks | "I HAD IT, BUT THANKS." |
| Help | "HOLD STILL, I'M HEROIC." |
| Mayhem | "TIME TO SHOW OFF!" |
| Win | "NAILED IT." · "AS EXPECTED." |

### Brick Broadsley: the showman
| Category | Lines |
|---|---|
| Start | "LADIES AND GENTLEMEN…" · "RING THE BELL!" |
| Swap | "THE MAIN EVENT IS HERE!" |
| Crate | "NEW MOVE UNLOCKED!" |
| Hit | "IS THAT ALL?" · "BARELY FELT IT!" |
| Down | "THE CHAMP… IS TIRED." |
| Thanks | "BACK IN THE RING!" |
| Help | "TAG TEAM, BUDDY!" |
| Mayhem / Mech | "ARE YOU NOT ENTERTAINED?!" · "BELT TIME!" |
| Win | "AND STILL CHAMPION!" |

### Turbo: always in a rush
| Category | Lines |
|---|---|
| Start | "EXPRESS DELIVERY!" · "LET'S ROLL!" |
| Swap | "SORRY I'M LATE!" |
| Crate | "SPECIAL DELIVERY!" |
| Hit | "OW, MY SKATES!" |
| Down | "RETURN TO SENDER…" |
| Thanks | "BACK ON WHEELS!" |
| Help | "PICKUP IN TWO SECONDS!" |
| Mayhem | "BEEP BEEP!" |
| Win | "SIGNED, SEALED, DELIVERED!" |

### Nana Nitro: sweetly terrifying
| Category | Lines |
|---|---|
| Start | "MIND YOUR MANNERS, DEARS." · "BACK IN MY DAY…" |
| Swap | "NANA'S HERE, SWEETIE." |
| Crate | "OH, HOW LOVELY." |
| Hit | "HOW RUDE!" · "MY CARDIGAN!" |
| Down | "JUST A LITTLE NAP…" |
| Thanks | "WHAT A POLITE YOUNG AGENT." |
| Help | "UP YOU GET, DEAR." |
| Mayhem / Mech | "WHO WANTS A COOKIE?" · "ROCKING TIME!" |
| Win | "EAT YOUR VEGETABLES!" (a running gag with Ma Rattler) |

### Mimi the Mime: silent by design
Mimi never speaks. Her lines are **sound effects plus a pose**, written in the
script as cues:

| Category | Cue |
|---|---|
| Start | Mimes rolling up her sleeves, then a *kazoo flourish* |
| Swap | Steps out of an invisible door, *door creak* |
| Crate | Mimes unwrapping a present, *ta-da sting* |
| Hit | *Slide whistle down* |
| Down | Mimes a tiny white flag, *sad trombone* |
| Thanks | Mimes a big heart, *harp gliss* |
| Help | Mimes pulling a rope, *rope creak* |
| Mayhem | Mimes a lightbulb over her head, *ding!* |
| Win | Takes a bow to *invisible applause* |

### Zorp: the delighted tourist
| Category | Lines |
|---|---|
| Start | "TAKE ME TO YOUR CONDUCTOR!" · "THE RIDE BEGINS!" |
| Swap | "GREETINGS, EARTHLINGS!" |
| Crate | "SOUVENIR!" |
| Hit | "FASCINATING. OUCH." |
| Down | "ZORP NEEDS A MOMENT…" |
| Thanks | "EARTHLINGS ARE SO KIND!" |
| Help | "BEAMING YOU UP!" |
| Mayhem / Mech | "SAUCER TIME!" · "FIVE STARS!" |
| Win | "FIVE STARS, WOULD RIDE AGAIN!" |

## 4. Enemy lines (the Cowboys, Wild West)
| Who | When | Lines |
|---|---|---|
| Any bandit | Spots a player | "YEEHAW!" · "GET 'EM!" · "THAT'S THE ONE!" |
| Any bandit | Knocked out | "OOF!" · "MY HAT!" · "NOT AGAIN!" |
| Six-Shooter | Before firing (the tell) | "DRAW!" |
| Dynamite Dan | Lighting a fuse | "FIRE IN THE HOLE!" |
| Big Bart | Wind-up | "*glug glug*… HERE I COME!" |
| Big Bart | Staggered | "WHOA, WHOA, WHOA!" |
| Lasso Lucy | Lassoing | "GOT YA, PARTNER!" |
| Saloon Door Sam | Doors broken | "MY DOORS! I JUST FIXED THOSE!" |
| Blueprint thief | Running away | "FINDERS KEEPERS!" · "NO TAKEBACKS!" |
| "Mad Dog" McGraw (boss) | Taunts | "THIS TRAIN AIN'T BIG ENOUGH!" · "DRAW!" · "FASTEST GUN ON THE RAILS!" |
| Ma Rattler (boss) | Taunts | "GET 'EM, BOYS!" · "NOBODY TOUCHES MY TRAIN!" · "EAT YER VEGETABLES!" |
| Rattler Runts | Swarming | "MA SAYS HI!" · "WE'RE TELLIN' MA!" |
| Conductor Earl (hostage) | Tied up / freed | "HELP! HELP!" / "MUCH OBLIGED!" |

## 5. Hub voice
The hub needs one friendly guide, replacing the original's Chubwick: **Quill**
(**[decided 2026-10-16]**), the Quartermaster. They're the cheerful boss of the Falcon-8 for the
Agency (ROBLOX Assault Team), and speak through a little video drone (a nod to the
original's drone). In the notes, "the Quartermaster" means Quill. Sample lines:
- First visit: "WELCOME ABOARD, AGENT! LET'S GET YOU SORTED."
- Barracks: "PICK YOUR SQUAD. THREE AGENTS, ONE HEALTH BAR. NO PRESSURE!"
- Party: "BRING FRIENDS. BANDITS HATE THAT."
- Armory: "BLUEPRINTS PLUS COINS EQUALS SHINY UPGRADES."
- Surplus: "NO BLUEPRINTS? NO PROBLEM. JUST GEMS."
- Checkpoint: "PATCHED YOU UP! CONTINUE OR CASH OUT?"

## 6. Tutorial and onboarding flow
The goal is to be playing within 30 seconds, and to teach each system the first time
it matters, not up front. Each prompt shows the right input glyph for PC or mobile.
**[decided 2026-10-16] It's skippable from the start:** **SKIP TUTORIAL** is there from the
first frame, so experienced players and friends joining a party aren't held up.

**First launch: the Training Train** (solo, 4 short carriages, about 3 minutes)
1. "MOVE!" (A/D or ◀ ▶). Run to the first gap.
2. "JUMP THE GAP!" (Space or JUMP).
3. "SHOOT!" Two Bandana Bandits that don't attack back.
4. "TOUCH THE CRATE TO SWITCH WEAPONS!" Rifle to rocket, on a group of three.
5. "DOUBLE-JUMP TO SPIN!" A crowd of four slow bandits.
6. "JUMP THE SHOT!" A Six-Shooter fires slowly, with an exaggerated "DRAW!" tell.
7. "HIT HIM WHILE HE DRINKS!" Big Bart with half HP, and his stagger explained.
8. "TRAIN CLEARED!" → the Quartermaster's welcome → the hub.

**Then, at the moment it matters:**
- **First hub visit:** the Quartermaster points to the Party pod ("PLAY WITH FRIENDS")
  and the big **PLAY** button. Barracks and shops are introduced when they unlock.
- **First Mayhem full:** the ring pulses. "MAYHEM READY! PICK A GADGET (1·2·3)." The
  game slows the spawns briefly. One time only.
- **First checkpoint:** a full heal, then "BRICK HAS JOINED YOUR SQUAD!" and the swap
  tutorial ("SWAP AGENTS: Q / E or SWIPE"). Then the continue or cash-out vote,
  explained once.
- **First teammate downed:** "HOLD W NEAR THEM TO REVIVE!"
- **First time you're downed:** "HANG ON! A TEAMMATE CAN REVIVE YOU." (Solo also shows
  the gem revive, once gems exist in M4.)
- **First blueprint pickup:** "BLUEPRINTS UNLOCK UPGRADES. BANK THEM AT THE HUB TRAIN!"
- **First event, boss and hostage:** that event's announcement chain, plus a one-line
  hint.

## 7. Missions
Three are active at a time, drawn from the pool for the content the player has seen.
A coin reward is 500–2,000 depending on difficulty; a few pay 5–15 gems. Targets scale
by the player's mission tier (tiers 1–3).

| # | Mission (tier 1 target) | Type | Reward | Needs |
|---|---|---|---|---|
| 1 | Knock out 50 bandits | Kills | 500 coins | M1 |
| 2 | Knock out 15 bandits with spin attacks | Kills | 800 coins | M1 |
| 3 | Knock out 10 enemies in mid-air | Kills | 1,000 coins | M1 |
| 4 | Knock out 8 enemies on the same carriage | Kills | 1,000 coins | M1 |
| 5 | Stagger Big Bart 3 times | Mid | 1,000 coins | M1 |
| 6 | Break 3 sets of saloon doors | Mid | 1,000 coins | M3 |
| 7 | Free a lassoed teammate | Co-op | 800 coins | M3 |
| 8 | Collect 5 weapon crates in one train | Pickups | 500 coins | M1 |
| 9 | Clear a train without collecting a weapon crate | Challenge | 1,500 coins | M1 |
| 10 | Clear a train without taking damage | Challenge | **10 gems** | M1 |
| 11 | Clear 5 hostile trains | Progress | 1,000 coins | M2 |
| 12 | Reach leg 2 | Progress | 1,500 coins | M2 |
| 13 | Reach a ×4 combo | Score | 1,000 coins | M2 |
| 14 | Reach a ×6 combo | Score | **10 gems** | M2 |
| 15 | Score 20,000 in one run | Score | 1,500 coins | M2 |
| 16 | Collect 300 coins between trains | Pickups | 800 coins | M2 |
| 17 | Use 5 gadgets | Gadgets | 800 coins | M2 |
| 18 | Have two drones out at once in your squad | Co-op | 1,000 coins | M2 |
| 19 | Block 20 shots with a Defender Drone | Gadgets | 1,000 coins | M2 |
| 20 | Knock out 10 enemies with one Air Strike | Gadgets | 1,500 coins | M2 |
| 21 | Revive teammates 3 times | Co-op | 1,000 coins | M1 |
| 22 | Swap agents 10 times in one run | Squad | 500 coins | M2 |
| 23 | Clear a train using all 3 squad agents | Squad | 1,500 coins | M2 |
| 24 | Defeat a boss | Boss | 1,500 coins | M3 |
| 25 | Defeat a boss without being downed | Boss | **15 gems** | M3 |
| 26 | Finish a boss with a spin attack | Boss | 2,000 coins | M3 |
| 27 | Free 2 hostages | Event | 1,500 coins | M3 |
| 28 | Complete a survival event | Event | 1,500 coins | M3 |
| 29 | Catch 3 blueprint thieves | Event | 1,000 coins | M2 |
| 30 | Reach the Ninja / Undead / Robot train | Exploration | 1,000 coins | M3 |
| 31 | Deal 2,000 damage with theme bonus active | Squad | 1,000 coins | M3 |
| 32 | Buy any upgrade in the Armory | Meta | 500 coins | M4 |

## 8. Daily challenge chains (agent trials)
- Once a day, you can play one **short survival challenge** with that agent, even if
  you don't own them. The original's "challenge chopper" idea is kept.
- Each agent has a **5-step chain**, one step per day. Missing a day doesn't reset the
  chain; it just waits.
- Finishing all 5 gives a **one-time 25% discount** on that agent ([[Economy and Monetization]]). If you already own them, you get 20 gems instead.
- Step rewards: **500 coins → 3 gems → 1,000 coins → 5 gems → 10 gems plus the
  discount**.
- Survival challenges are **one-hit death** (the original's "survival mode"). Waves
  scale by step (5 → 7), and difficulty goes 0 → 2.

| Agent | Step 1 | Step 2 | Step 3 | Step 4 | Step 5 |
|---|---|---|---|---|---|
| Dash | Wild West, 5 waves | Ninjas, 5 | Robots, 6 | Undead, 6 | Wild West, 7 (hard) |
| Brick | Undead, 5 | Wild West, 5 | Ninjas, 6 | Robots, 6 | Undead, 7 (hard) |
| Turbo | Robots, 5 (her bonus) | Wild West, 5 | Ninjas, 6 | Undead, 6 (her weakness) | Robots, 7 (hard) |
| Nana | Undead, 5 (her bonus) | Wild West, 5 | Robots, 6 | Ninjas, 6 (her weakness) | Undead, 7 (hard) |
| Mimi | Ninjas, 5 (her bonus) | Robots, 5 | Undead, 6 | Wild West, 6 (her weakness) | Ninjas, 7 (hard) |
| Zorp | Wild West, 5 (his bonus) | Ninjas, 5 | Undead, 6 | Robots, 6 (his weakness) | Wild West, 7 (hard) |

Each chain opens on the agent's strong theme, puts them against their weak theme at
step 4, and ends hard on their best theme. It teaches the matchups by playing them.
Until the other themes ship in M3, every step uses the Wild West.

## Open questions
- ~~Is "the Quartermaster" the right hub guide concept?~~ **[decided 2026-10-16] Yes.** The
  final name is still open ([[Title Ideas]]).
- ~~Should barks be voiced, or text-only bubbles with grunts?~~ **[decided 2026-10-16] Text
  bubbles with a voiced grunt** (§1).
- ~~Should the tutorial be compulsory on first launch?~~ **[decided 2026-10-16] No, it's
  skippable from the start** (§6).

Related: [[Game Design Document]] · [[Launch Agents]] · [[Wild West Enemies]] · [[Economy and Monetization]] · [[First Playable (M1)]] · [[Title Ideas]] · [[Home]]
