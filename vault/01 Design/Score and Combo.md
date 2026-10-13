---
tags: [design, feature, score, combo, leaderboards]
status: proposed
updated: 2026-10-13
---
# Score and Combo

> **Status: proposed.** This is Claude's draft of how score is earned in a run, for review.
> The [[Game Design Document]] has already decided on **co-op leaderboards** (best run
> score and furthest train). This note defines the score that the "best run score"
> board ranks. The original's per-kill score values weren't recovered
> ([[Original Game - Enemies and Spawning]]). We know it had a **"COMBO!" score
> multiplier** with missions for 3×, 4× and 6×, a no-damage-train mission, and paid
> ×2/×3 score boosters. All numbers below are new proposals.

## Summary
Score rewards **playing well, not just surviving long**. The run's distance already has
its own board (furthest train). So the score board should separate a stylish squad from
a squad that just scraped through. Most score comes from **knockouts multiplied by your
combo**, and the rest comes from clearing trains, events and helping teammates.

## Player experience
- Every knockout pops a number. Chain them and the **combo counter** climbs, the
  multiplier ticks up (×2, ×3, ×4, ×6), and the HUD gets louder.
- Your combo is your own. Assists keep it alive, so in co-op you build combos
  *together* without stealing kills.
- The run-end screen shows the **squad score** and each player's share, with a few
  callouts: "Highest combo", "Most revives", "Untouchable" (no damage on a train).

## Rules & numbers

### Knockout points
| Enemy | Points |
|---|---|
| Light (slots 0–3) | 10 |
| Mid (slots 4–6) | 100 |
| Boss (slots 7–8) | 1,000 to the player who lands the final hit, plus 500 to each teammate who damaged the boss |
| Boss minion (slot 9) | 5 |
| Hostage harmed by you | 0 (and it breaks your combo) |

### Combo multiplier
- Each knockout within **2.5 s** of your previous one adds 1 to your combo count. An
  **assist** (you damaged it, a teammate knocked it out) **refreshes the 2.5 s timer**
  but doesn't add to the count.
- Multiplier tiers:

  | Combo count | 0–4 | 5–9 | 10–19 | 20–34 | 35+ |
  |---|---|---|---|---|---|
  | Multiplier | ×1 | ×2 | ×3 | ×4 | **×6** (cap) |

  The ×3, ×4 and ×6 tiers match the original's multiplier missions.
- The combo **ends** when the timer runs out, when you're **downed**, or between trains
  (the leap resets it).
- Taking damage **doesn't** end the combo. Players outrun almost everything, so
  aggressive play should pay.
- The multiplier applies to **knockout points only**. Bonuses below are flat.

### Flat bonuses
| Bonus | Points | Who gets it |
|---|---|---|
| Train cleared | 500 + 100 × train number in the run | Every player still in the run |
| **Untouchable**: a train with no damage taken | 1,000 | Each player who took no damage on that train |
| Hostage freed | 1,000 | The whole squad |
| Blueprint thief caught | 500 | The player who knocks it out |
| Survival event completed | 1,000 | Every player still standing |
| Teammate revived | 250 | The reviver |
| Leap between trains | 50 | Each player who makes the jump |

### Run score
- Each player has a **personal score**: their knockouts × combo, plus their bonuses.
  It's used for missions ("GET %s POINTS") and their personal best.
- The **squad score** is the **sum of personal scores**. It's what the "best run score"
  leaderboard ranks. Boards are split by party size (solo, duo, 3–4), so bigger parties
  don't crowd out smaller ones.
- **Server-side only.** The server tracks knockouts, combo timers and bonuses, and
  submits the score when the run ends. The client only displays it.

### Rough size of a run
An average 10–15 minute run (reaching leg 2) is roughly 400 light and 15 mid knockouts,
1 boss, about 6 trains and 2 events per player. That's about **6,500 base knockout
points**, about **×2.5 average combo**, and about **8,000 in bonuses**, so roughly
**25,000** per player. Combo is about two thirds of the total. That's the intent: skill
moves you up the board, and survival alone doesn't. Check against real runs.

## Systems involved
_None built yet._ When built, this is a score service on the server that listens to
knockout, damage, revive and event signals, plus a HUD combo display on the client.

## Studio build list
_Not started._
- [ ] HUD in `StarterGui`: score counter, combo counter and multiplier badge, and a
  template for floating knockout numbers (cloned at runtime, not built in code).
- [ ] Run-end screen: squad score, per-player breakdown and callouts.

## Open questions
- **Score boosters vs. leaderboards.** The original sold ×2/×3 score boosters for gems.
  On a leaderboard that's pay-to-rank.
- **Gem revives vs. leaderboards.** Paid revives make runs longer, and longer runs score
  more. The rising price limits this, but doesn't remove it.
- Is the squad score (sum of players) right for the board, or should it rank the best
  individual score?
- Is the 2.5 s combo window too tight on mobile? Playtest it.

## Implementation notes
_Not built. Design only._

Related: [[Game Design Document]] · [[Gadgets and Mayhem]] · [[Wild West Enemies]] · [[Home]]
