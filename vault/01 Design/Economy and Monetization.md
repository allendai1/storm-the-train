---
tags: [design, feature, economy, monetization, progression, boosters]
status: planned
updated: 2026-10-16
---
# Economy and Monetization

> **Status: planned.** This is Claude's draft of currencies, earn rates, prices, boosters,
> the surplus shop and Robux products. The developer settled its key choices on
> 2026-10-13 (marked **[decided]**). Prices and earn rates are still proposals to tune. The [[Game Design Document]] has already
> decided on an **original-style** economy and monetization: gems buy agents and
> boosters, and coins buy upgrades. This note fills in the numbers and the co-op rules.
> Prices with a source are the original's defaults
> ([[Original Game - Items and Economy]] §7, [[Original Game - APK Balance Audit]]).
> Earn rates and Robux prices are new proposals, because the original's IAP prices,
> mission rewards and revive costs weren't recovered. **Check every Roblox policy point
> below against the current Roblox rules before building it.**

## Summary
There are three currencies, and each has one job:

| Currency | Earned by | Spent on | Robux? |
|---|---|---|---|
| **Coins** (soft) | Runs, missions | Weapon and gadget upgrades, cheap boosters | Indirectly, by exchanging gems |
| **Gems** (premium) | Missions, daily challenges, day 7 of the login streak, rare run drops, Robux | Agents, strong boosters, revives, gadget deploys, the surplus shop, skins | Yes, through gem packs |
| **Blueprints** (gate) | Recovered from enemies in runs, banked at checkpoints | Unlocking each upgrade level (L2–L10) | Never sold directly. The surplus shop skips them for gems |

The loop: **runs earn coins and blueprints → the hub turns them into upgrades → upgrades
let you go deeper → deeper runs earn more.** Gems speed up parts of that loop (agents,
boosters, skipping blueprints) but never replace it.

## Principles
- **[proposed] Paid power never makes a teammate's run worse.** Boosters only affect
  the buyer. Pickups are personal, so a paid magnet can't take a teammate's coins.
  Enemy HP never scales with anyone's purchases.
- **[proposed] Every agent can be earned for free**, in about 8 hours of play for a
  100-gem agent (see the targets below).
- **[decided] Leaderboards rank unboosted score, and gem-revived runs count.** See
  [[Score and Combo]].
- **[proposed] No paid random items.** Every Robux and gem purchase is deterministic:
  you see exactly what you get. Roblox requires odds disclosure for paid random items,
  and some regions restrict them, so we avoid the problem entirely.
- **[proposed] Honest pricing**, because the game targets all ages and many Roblox players
  are young:
  - no fake countdowns on Robux offers,
  - no "you'll lose this forever" pressure,
  - the price in Robux is always shown before the Roblox purchase prompt.

## Coins
### Earning
- **[decided 2026-10-16] Pickups.** Loose coins sit between trains (the original's "coins in the
  gap"), and knocked-out enemies sometimes drop coins. Pickups are **personal**: each
  player sees and collects their own.
- **[decided 2026-10-16] Run-end bonus.** At the end of a run you get **1 coin per 25 points of
  personal score**. That's about 1,000 coins for an average 25,000-point run. This answers
  the open question in [[Score and Combo]]: score feeds coins, so the score booster
  (which multiplies personal score) pays off in coins too, while leaderboards still
  rank unboosted score.
- **[proposed] Missions** pay mostly coins (500–2,000 each).
- **[decided 2026-10-16] Cashing out.** Coins are always kept, whether you wipe or cash out. Only
  blueprints are at risk (see below).

### Spending: the upgrade ladder (original values)
Every weapon, drone and mech suit has 10 levels. L1 is free, and each later level needs
a blueprint unlock **and** coins:

| Level | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | Total |
|---|---|---|---|---|---|---|---|---|---|---|
| Coins | 1,000 | 1,400 | 2,000 | 3,000 | 4,400 | 6,200 | 8,400 | 11,000 | 14,000 | **51,400** |

The launch roster has **21 upgradable items**: 12 weapons, 6 drones and 3 mech suits. The
Air Strike has only one level. Maxing everything is **1,079,400 coins** and **189
blueprint unlocks**.

## Blueprints
- **[proposed] Drops.** Blueprint carriers drop them (any light or mid can spawn with
  stolen blueprints; see [[Wild West Enemies]]), and so does the blueprint-thief event.
  The target is **about 1 blueprint per train** per player.
- **[proposed] Personal loot.** When a carrier is knocked out, every player in the run
  gets the blueprint. Nobody fights over drops.
- **[decided] Bank them or lose them.** Blueprints you carry are **banked at the next
  checkpoint**. If the squad wipes before then, carried blueprints are lost. That puts
  real weight on the **cash out or continue** choice at each checkpoint. (The original
  also banked blueprints at the hub train.)
- **[proposed] Unlock selection** uses the original's weighted catch-up roll:
  - It always unlocks your **lowest-level owned gear first**.
  - Then gear one or two levels above that.
  - Then, occasionally, gear belonging to agents you don't own yet, as a teaser.

  It keeps an owned loadout evenly levelled.

## Gems
### Earning for free
- **[proposed] Sources:**
  - Missions: some pay 5–15 gems.
  - Daily challenges (below).
  - **Rare gem drops in runs**, about 1 per 10 minutes. The original's gem booster
    multiplies these.
  - First-time milestones: e.g. first boss, first leg 3, first hostage.
- **[proposed] Target:** about **12 free gems per hour** of regular play.

### Robux gem packs (Developer Products)
| Pack | Gems | Robux | Bonus |
|---|---|---|---|
| Handful | 40 | 99 | — |
| Pouch | 110 | 249 | +10% |
| Satchel | 240 | 499 | +20% |
| Strongbox | 520 | 999 | +30% |
| Vault | 1,400 | 2,499 | +40% |

**[proposed]** At about 2.4 Robux per gem, a 100-gem agent is about 240 Robux and a
first revive (5 gems) about 12 Robux. The pack names are placeholders.

### Gem prices
| Item | Gems | Source |
|---|---|---|
| Turbo | 80 | Original tier `char_low` |
| Nana Nitro, Mimi the Mime | 100 each | Original tier `char_med` |
| Zorp | 150 | Original tier `char_high` |
| Self-revive | 5, then doubling: 10, 20, 40… per run | GDD decision; the starting price is proposed here |
| Gadget deploy (meter not full) | 5, then doubling: 10, 20, 40… per run; 1 per train | Decided 2026-10-16 ([[Gadgets and Mayhem]]) |
| Mission skip | 5 | Proposed. Reroll is free once a day |
| Boosters | 1–6 | Original (see below) |
| Surplus shop offers | Varies | See below |
| Cosmetic skins | 50–150 | Proposed |
| Gems → coins exchange | 10 → 4,000 · 50 → 22,000 · 100 → 48,000 | Proposed; replaces the original's coin packs |

**[proposed] No Robux coin packs.** Coins come from gems through the hub exchange, so
there's one premium currency to understand.

## Boosters
Up to **3 boosters** can be equipped at the start of a run and at each checkpoint.
- **[proposed] Change from the original:** a booster lasts for the **next leg** (3 trains),
  not one train. Our checkpoints only come every 3 trains, so a one-train booster
  would only ever cover the first train of a leg.
- **[proposed] All types are always on sale.** The original showed a random selection;
  a fixed list is clearer and avoids anything that looks like a random paid offer.

| Booster | Tiers (effect → price, original) | Co-op rule |
|---|---|---|
| Score | ×2 → 1 gem · ×3 → 2 gems | Personal score only. Leaderboards ignore it |
| Mayhem | ×2 → 500 coins · ×3 → 800 coins | Your meter only |
| Coins | ×2 → 4 gems · ×3 → 6 gems | Your pickups only |
| Gems | ×2 → 800 coins · ×3 → 1,600 coins | Your gem drops only |
| Damage | +25% → 400 coins · +50% → 2 gems · +100% → 4 gems | **In a party of 2+, capped at +50%.** +100% is solo only |
| Health (damage taken) | ×0.67 → 2 gems · ×0.5 → 4 gems | **In a party of 2+, capped at ×0.67.** ×0.5 is solo only |
| Magnet | Coins and gems fly to you → 4 gems | Your pickups only |

The original's cross-feed stays: coins buy the boosters that earn gems, and gems buy the
boosters that earn coins.

## Surplus shop
A rotating hub shop with **3 offers**: one cheap, one mid and one premium. Each sells a
gear upgrade level for gems with **"no blueprints required"**. As in the original, an
offer buys every level up to the one shown.
- **[proposed] Price** = the coin cost of the levels skipped ÷ **400**, × **1.5** for
  blueprint-locked levels (× 1.0 for levels you've already unlocked). For example, a locked L2 is
  about 4 gems, and a whole item from L1 to L10 is about 193 gems.
- **[proposed] Refresh** every **8 hours**, shown as a real timer. Offers only include gear
  for **agents you own**.
- It's deterministic: you see the exact item and level before you pay.

## Missions and daily challenges
- **[proposed] Missions:** 3 active at once, drawn from the original's mission types (kill
  counts, bosses, gadgets, trains without damage, combo tiers…). There's one free
  reroll a day, and a skip costs 5 gems. Missions pay coins, sometimes gems.
- **[proposed] Daily challenge = agent trial.** Once a day you can play a short
  **survival challenge with an agent you may not own**, keeping the original's "challenge
  chopper" idea. Each agent has a 5-day chain. Finishing it gives gems and a
  **one-time 25% discount** on that agent (the original gave a % discount). It's how free
  players try agents before saving up for them.

- **[decided 2026-10-16] Daily login streak:** a free **7-day coin streak**. This one is
  new: the original didn't have it.
  - The rewards grow each day, and **day 7 gives gems** as well as coins. Then the cycle
    starts again at day 1.
  - **Missing a day resets the streak** to day 1. A "day" is the UTC date.
  - It's claimed automatically on the first hub visit of the day, with a popup.
  - The amounts are still to tune, next to the earn-rate targets (Session 13).
  - Saved as `LoginStreak { Day, LastClaimDay }` ([[0008-player-data-profilestore]]).

## Hub services
- **[decided] The medbay heals to full for free** at every checkpoint. The original
  charged an unknown price, but checkpoints are only every ~8 minutes, and a paid heal in
  co-op would split squads into "can afford it" and "can't".

## Robux products
### Game Passes (one-time)
**[decided]** The products are gem packs, the Launch Squad pass, the Starter Pack and the
Coin Bonus pass. Prices are still proposed.

| Pass | Robux | What it gives | Note |
|---|---|---|---|
| **Launch Squad** | 799 | Turbo, Nana, Mimi and Zorp | Clearly named as the **launch** agents, so it isn't misleading when new agents arrive. If you already own some of them, you get their gem price back |
| **Coin Bonus** | 399 | Permanent ×1.5 coins from pickups | Progress-only and personal. It stacks with the Coins booster (×1.5 × ×3 at most) |

### Developer Products (repeatable or limited)
| Product | Robux | What it gives |
|---|---|---|
| Gem packs | 99–2,499 | See above |
| **Starter Pack** (one per account) | 199 | 150 gems, 10,000 coins, and an exclusive Dash skin |

### Other
- **[decided] No first-purchase gift.** The original's "Bob for any purchase" idea isn't
  carried over.
- **[proposed] Private servers are free.** Runs already use reserved servers. Free private
  servers make it easy for friends to play, and drive engagement.
- **[proposed] Premium Payouts.** Roblox pays developers for time Premium subscribers
  spend in the experience. That favours long, friendly co-op sessions over aggressive
  sales.
- **[decided] No ads.** No rewarded video ads, not even for a free revive. Revives come
  from teammates or gems only.

## Earn-rate targets (for tuning)
| Milestone | Target play time |
|---|---|
| First upgrade (1,000 coins plus 1 blueprint) | First run |
| Brick (free, at first checkpoint) | First run |
| Max one item (51,400 coins) | About 5 hours |
| First paid agent for free (80–100 gems) | About 7–8 hours |
| All 4 paid agents for free (430 gems) | About 36 hours |
| Max one agent's whole kit (about 4 items) | About 20 hours |
| Max everything (1.08 M coins) | About 100+ hours |

These assume **about 2,000 coins per average 12-minute run (about 10,000 per hour)**: pickups
plus the score bonus. Tune against real runs.

## Systems involved
_None built yet._ When built:
- a **player data service**, the single DataStore wrapper from `CLAUDE.md`, with session
  locking, retries and `BindToClose`,
- a **currency/shop service**, server-authoritative: every price check, purchase and grant
  happens on the server,
- a **receipt handler** for Developer Products: `ProcessReceipt`, idempotent per
  `PurchaseId`, granting only after the profile save succeeds,
- **boosters**, **missions**, **surplus** and **challenge** services (M4).

## Studio build list
_Not started._
- [ ] Hub pods: Armory (upgrades), Barracks (agents), Surplus shop, Missions board,
  Medbay and Exchange. These are physical pods on the hub train in `Workspace`, plus
  their ScreenGuis in `StarterGui`.
- [ ] Shop item, booster slot and mission row **templates** to clone, not build in code.
- [ ] Currency HUD (coins, gems, carried blueprints).
- [ ] Login streak popup (`LoginStreakGui`, 7 day slots cloned from a template).

## Open questions
- Is the Robux pricing right? Pack sizes, about 2.4 Robux per gem, and Launch Squad at 799.
- Does the Coin Bonus pass need the earn-time targets retuned? Payers would max gear
  about a third faster.
- ~~Should rewards go to a free daily login streak?~~ **[decided 2026-10-16] Yes**, a 7-day coin
  streak with gems on day 7 (see Missions and daily challenges).

## Implementation notes
_Not built. Design only._

Related: [[Game Design Document]] · [[Score and Combo]] · [[Launch Agents]] · [[Gadgets and Mayhem]] · [[Original Game - Items and Economy]] · [[Home]]
