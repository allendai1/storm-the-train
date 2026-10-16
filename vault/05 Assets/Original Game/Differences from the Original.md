---
tags: [reference, original-game, comparison, design, loop, mechanics]
status: reference
updated: 2026-10-16
---
# Differences from the Original

> **Status: reference.** A side-by-side of how Train Mayhem differs from *Storm the Train*
> (2016), compiled on 2026-10-16 from the vault: our design notes and the decompile notes
> ([[Original Game]]). It records differences; it doesn't decide anything. Where ours is
> marked **built**, Status or the system notes say it was checked in Studio.

## The biggest differences in how it feels
1. **Co-op instead of solo.** The original is one player with one shared 10 HP pool, paying
   gems or watching ads to revive. Ours is 1–4 players, each with 100 HP: downs, 2 s
   teammate revives, squad wipes and checkpoint votes (built for one player; co-op
   untested).
2. **Legs, not single trains.** The original has a checkpoint and a boss after **every**
   train, with 1–3 events per train from a shuffled deck. Ours has a checkpoint every 3rd
   train, one event train per leg, and a boss every 2nd leg (decided). Bosses are rarer
   and bigger; cash-out is a risk vote.
3. **Enemies hit about 10× softer (not decided; see "Damage scale" below).**
4. **Lower, simpler movement.** We jump 8 studs (the original 14 with 2× gravity), the leap
   between trains is a normal jump (the original's is a scripted auto-run), and the spin
   is still a quick burst with a cooldown (the "spin until landing" pop-up is planned).
   The higher jump, the double-jump rule and the scripted leap were turned down.
5. **Enemies are more predictable for now.** Ours chase the nearest player, can spawn on
   screen and don't flinch. The original's perception, off-screen spawns and flinches are
   accepted ([[Combat Polish]]) but not built. Big Bart charges when you come close and can
   be staggered; the original's berserker charged every ~30 damage taken and couldn't be
   stopped (our stagger is a deliberate change).
6. **You pick your gadget.** A full meter offers 1 of 3 (the original gave a free gadget).
   Mechs have an armour bar instead of a draining timer; one drone each instead of up to
   three; the Air Strike has a countdown and is one per party.
7. **No gore; knockouts are final.** Ragdolls fade in 3 s; knocking enemies off the train
   counts. The original's persistent corpses, gibbing, key boxes in corpses, corpse-smasher
   drone and undead revive are gone (undead revive is reserved for our Undead theme).
8. **Score rewards knockouts, not damage.** The original pays per point of damage with a
   1 s combo up to ×25 and no auto-aim. Ours pays per knockout with a 2.5 s combo capped
   at ×6, flat bonuses, and a 6° rifle auto-aim cone.

## Damage scale (not decided)
- The original: the squad shares **10 HP** (`InitHealth(10.0)`, [[Original Game - Player and Camera (Native Code)]] §4), and a light enemy's melee hit is 3.
- Ours: **100 HP** per player, with the **same raw values** (light melee 3, mid 6, boss 8,
  [[Wild West Enemies]]).
- So a hit costs about **a tenth** as much of your health as in the original. That's why
  [[Wild West Enemies]] asks whether one bandit really needs about 48 s to down Max.
- Options: scale enemy damage ×10 (or partly, since co-op revives make downs less
  final), or keep it and let crowds supply the threat. Decide in the first playtest.

## Loop and structure
| Area | The original | Ours | Ours: state |
|---|---|---|---|
| Players | Solo, one 10 HP pool | 1–4 co-op, 100 HP each | Built (solo); co-op untested |
| Train | Background scrolls at 60 studs/s | Static train, client parallax at 50 | Built (ADR 0009) |
| Run shape | Endless; checkpoint after every train | Endless; legs of 3 trains | Built |
| Events | 1–3 per train from a shuffled deck, plus a boss on every train | One event train per leg; boss every 2nd leg | Thief stub built; rest M3 |
| Train layout | Procedural spans and height rules | Fixed 7-car, ~200-stud train | Built; procedural variety not designed |
| Leap | Scripted: auto-run, jump window, landing push | Ordinary jump over a 10-stud gap, gap coins | Built; scripted leap turned down |
| Checkpoint | Bank blueprints, clear boosters, **paid** heal, pods | Free full heal, majority vote to continue or cash out | Built (vote untested with 2+) |
| Run end | Death → revive screen (gems or ad) or give up; no cash-out recorded | Squad wipe (10 s gem window) or cash-out; coins always kept | Built (gems in M4) |
| Revive | 2ⁿ gems (max 32), ad revives, 3 s invulnerability, radial push, enemies flee | Downed 15 s, 2 s teammate revive at 40%, gems 5 → 10 → 20, spectate till checkpoint | Downed/wipe built; grace and push planned; flee deferred |
| Difficulty | One spawn timeline per run; event strength from score (every 40k) | Per-train ramp (+10% cap, −5% interval per train), co-op scaling | Built; score tiers turned down |
| Mid introduction | Emergent stall | Scripted solo beat | Built (deliberate) |
| Hostage | 2 key holders, smash the corpse's key box, carry to a pad | One key holder: spin the dazed bandit to shake the keys loose | M3 |
| Survival | min(8, tier + 3) waves, one-hit death, crate per wave | "Survive N waves, one-hit death" | M3, details not designed |
| Blueprint thief | Timer on total play time | Thief train event plus carriers | Stub built |
| Theme change | Random other theme at the checkpoint | "May change"; rule open | Only Wild West exists |
| Hub | Menu pods | Walkable side-on Falcon-8, queue pads, reserved servers | Session 12 drafted |

## Player mechanics
| Area | The original | Ours | Ours: state |
|---|---|---|---|
| Jump | 14 studs, 2× gravity, ~0.93 s air, unlimited coyote time | 8 studs, default gravity | Built; 14 turned down; coyote/buffer open in F3 |
| Spin | Lasts until landing, gun paused, 45° pop-up, half damage taken for 0.2 s at start and end; any jump inside a carriage spins | 6-damage burst in 5 studs, 0.6 s cooldown | Built; "until landing" pop-up planned; half-damage windows not in the vault |
| Swap | Instant, no cooldown, works mid-air and mid-spin; squad size unclear (2 or 3) | Q/E or swipe, 1.5 s cooldown, keeps HP, Mayhem, combo | Built (cooldown deliberate) |
| Aim | None; shots go along the facing | No manual aim, but 6° rifle / 4° minigun auto-aim | Built; decided before the decompile showed no auto-aim |
| Crates | Every 205–273 studs ahead; coins plus a random weapon | Personal crates at fixed spots, 20 s respawn, drop on every mid knockout; flips to your agent's other weapon | Built |
| Shotgun | One long ray plus a ~12-stud blast with a big push | 5 pellets over 10° | Built (kept on purpose) |
| Bullet knockback | Every hit pushes, ÷ enemy weight | None; explosions pop up | Turned down; pop-up planned |
| Hit i-frames | 0.3 s after every hit | — | Planned |
| Gap fall | Not traced | Back on a roof after 1 s, 15 damage | Built |
| Interiors | Enterable carriages with low jumps | Roof-only | Not designed |
| Lightning weapon | A piercing line | Turbo's Spark Plug chains | Planned (written before the decompile) |

## Enemies
| Area | The original | Ours | Ours: state |
|---|---|---|---|
| Themes | Oriental, Horror, Future; 10 slots each | Same 10-slot scheme, plus Wild West first | 4 lights + Big Bart built |
| Spawning | Budget and alive-cap; just off-screen ahead; behind 1 in 3 when not advancing | Same budget model; spawn points can be on screen | Built; off-screen planned |
| Perception | Front-facing or after being hit, line of sight, loses you mid-jump-over, backs off at min range | Always the nearest player | Built; rules planned |
| Ranged telegraph | Shot 0.5–0.6 s into the animation, every 4 s ± 30%, none in the first 4 s | "!" and a 0.5 s tell, 2.5–4 s | Built; timing planned |
| Flinch | Gun-hit flinch with cooldown; bosses never | None | Planned |
| Charger | Triggered by ~30 damage taken, 2.5× walk, unstoppable | Triggered by proximity, 1 s wind-up, 30 damage staggers, speed 36 (→ 26.7 planned) | Built; stagger deliberate |
| Lobber | Explodes on contact; backs off while reloading; hurts other enemies | Lies for a 1.5 s fuse; hurts players only | Built; aimed lob, blink and friendly fire planned; back-off deferred |
| Knockouts | Gore, persistent corpses, gibs; fallen enemies climb back | Final ragdolls (3 s); off the train = knockout | Built (deliberate) |
| New in ours | — | The Grappler (Lasso Lucy) | M3 |

## Gadgets and Mayhem
| Area | The original | Ours | Ours: state |
|---|---|---|---|
| Fill | Per damage (0.035 per point) plus on kill; ×0.2 while a gadget runs | Per knockout (light 4, mid 20, boss per damage) | Built; ×0.2 turned down |
| Choice | A free gadget | Pick 1 of the active agent's 3 | Built |
| Paid deploys | 2–3 currency | 5 gems doubling, one per train | M4 |
| Drones | Up to 3 of a type, mixed | One per player | Built |
| Turret | Least-turn targeting, exploding shots | Nearest within 25 studs | Built |
| Healer | Owner only, charge-based | You and teammates within 10 studs; pauses bleed-out | Planned |
| Smasher | Smashes corpses for health | Slams the biggest crowd | Planned (deliberate) |
| Freeze | Hard stop × scalar | Slow, then freeze after 3 hits | Planned |
| Mechs | 2.5 s invulnerable entry; damage drains the timer; screen-wide exit blast | Entry stomp, armour bar, eject grace | Heavyweight built |
| Air Strike | 14 rockets at once, no countdown | 3 s countdown and marker, 14-shell curtain, one per party, bosses take half | Sweep built; curtain planned |

## Score, combo and economy
| Area | The original | Ours | Ours: state |
|---|---|---|---|
| Score | Per damage × combo level × mode scalar; no distance or clear score | Per knockout × combo tier, plus flat bonuses | Built (values proposed) |
| Combo | 1 s window, up to level 25 | 2.5 s window, tiers up to ×6 | Built (deliberate) |
| Leaderboards | One high-score board | Three co-op boards by party size, unboosted | M4 |
| Achievements | 9 themes × 3 tiers | None (badges maybe later) | Open |
| Coins | Pickups along the track, crate coins, coin packs | Gap coins, enemy drops, run-end score bonus, missions; gems → coins at the Exchange | Partly built |
| Gems | Replace a coin every ~400 placed; missions | Missions, challenges, rare drops, login day 7 | M4 |
| Agents | 13, one free | 6, two free, all earnable | 2 built |
| Boosters | Random offer; cleared every checkpoint | Every type on sale; one leg; party caps | M4 |
| Missions | Fixed list of 69; skip 1,000 coins | Drawn by type; free daily reroll; skip 5 gems | M4 |
| Healing | Paid heal | Free full heal at checkpoints | Built |
| Ads | Rewarded videos, ad revives, interstitials | None | Decided |

## Not in ours at all
- CDW (rolling ball) and jetpack vehicle runs (ours: "later", not designed).
- Enterable carriage interiors.
- A boss on every train, several events per train, a checkpoint per train.
- The scripted leap, the 14-stud jump and the double-jump rule (turned down).
- Bullet knockback on every hit; Mayhem ×0.2 during gadgets (turned down).
- Gore, gibbing, corpse smashing, undead revive (Undead theme later).
- Teleporting, hovering and chain-bomb enemies.
- Enemies climbing back onto the train or leaping between trains.
- The forcefield bubble and the 2.5 s invulnerable mech entry.
- Achievements, per-mode high scores, time-challenge mode.
- Ads, paid heals, coin packs, random booster offers (decided out).

## Only in ours
- Co-op: downs, teammate revives, spectating, the squad gem-revive prompt, assists.
- Legs, the checkpoint vote and cash-out.
- The walkable hub, queue pads, reserved servers, free private servers.
- Party rules: personal pickups, party-capped boosters, one Air Strike per party, support
  gadgets that help teammates, boss HP scaling.
- The gadget choice, the mech armour bar and eject, the Air Strike countdown.
- Wild West, the Grappler, Big Bart's stagger.
- Knock-offs count as knockouts; flat score bonuses; run-end coins from score.
- Fixed-spot weapon crates; the gap-fall rule; the swap cooldown.
- The Exchange, the login streak, passes, no ads, every agent earnable.

## Open contradictions in the reference notes
- **Squad size:** the native code blocks swapping when "you don't have 2 agents equipped"
  and a challenge avoids "your two equipped characters", but mission text says "ALL THREE
  CHARACTERS". The original may use 2 or 3; the GDD's "up to 3, as in the original" is
  unconfirmed.
- **Drones at once:** the locale says one, the native code allows up to three.

Related: [[Original Game]] · [[Game Design Document]] · [[From the Original - Proposals]] · [[Combat Polish]] · [[Wild West Enemies]]
