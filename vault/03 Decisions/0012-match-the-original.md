---
tags: [decision, design, original-game, loop, mechanics, economy]
status: accepted
date: 2026-10-16
---
# 0012 — Match the original's mechanics; keep co-op

## Context
After comparing the two games ([[Differences from the Original]]), the developer decided
on 2026-10-16 that Train Mayhem should **play like *Storm the Train* as closely as
possible**, keeping co-op. Many of our own choices made earlier the same day (legs of 3
trains, a boss every 2nd leg, the free heal, rifle auto-aim, per-knockout score, the
stagger, the gadget pick, our economy tweaks) are reversed by this.

## Decision
**Match the original** (the values are converted in [[Original Mechanics Match]]):
- **Run structure:** a **boss at the end of every train and a checkpoint after every
  train** (no 3-train legs). 1–3 events per train from a shuffled deck, with event
  strength rising with score. The **scripted train-to-train leap**.
- **Aim:** none. Shots go along your facing; no auto-aim cones.
- **Score and combo:** score per point of damage × combo level (1 s window, up to level
  25). No flat bonuses for clears or leaps.
- **Enemies:** the original's perception, telegraph timing, flinches, spawn placement,
  archetype behaviours (the berserker charges every ~30 damage taken and can't be
  staggered), enemies recovering from falls, fleeing, bullet knockback ÷ weight.
- **Spin and movement:** the 14-stud jump with 2× gravity, the double-jump velocity rule,
  the spin lasting until landing with the pop-up knockback and half-damage windows, the
  original's coyote rule, instant swaps with no cooldown.
- **Mayhem and gadgets:** Mayhem per damage dealt (×0.2 while a gadget or mech runs), the
  free gadget on a full meter, up to 3 drones, the original's drone, mech and Air Strike
  rules.
- **Weapons:** the original's weapon set and behaviours (shotgun ray plus close blast,
  the charge-curve rail, the straight lightning line), crates by distance that pay coins.
- **Health:** the original's damage scale. Our 100 HP stands for the original's 10, so
  every original damage and heal value is ×10.
- **Economy:** the original's paid heal, revive pricing, boosters (random offer, cleared at
  every checkpoint), fixed mission list, Surplus timing, and coin and gem sources.

**Keep** (deliberately different):
- **Co-op for 1–4 players** and what it needs: per-player health, downed and teammate
  revives, spectating until the next checkpoint, the checkpoint continue or cash-out vote,
  queue pads and the walkable hub, personal pickups, party scaling.
- **Final knockouts** (no persistent bodies, no gore). Mechanics that used corpses are
  adapted ([[Original Mechanics Match]]).
- **No ads.** Rewarded-ad options (ad revives, ad offers) are dropped, not replaced.
- Roblox platform choices: static train with a scrolling world ([[0009-static-trains-scrolling-world]]),
  2.5D on the Z plane, PC and mobile, server-authoritative combat.
- Theme content: the Wild West Cowboys, the agent roster and names, the art direction.

## Alternatives considered
- **Keep our hybrid** (decided earlier on 2026-10-16): friendlier to co-op and Roblox
  players, but drifts from the game the project is built to recreate.
- **Match everything, including solo play and gore:** loses the project's co-op pillar
  and isn't suitable for Roblox.

## Consequences
- **Supersedes** the parts of these that conflict: the GDD's core loop, scoring and
  economy sections; [[Loop (M2)]] (legs, the leap, the checkpoint); [[Score and Combo]];
  [[Gadgets and Mayhem]]; [[Economy and Monetization]]; [[Combat Polish]] (the stagger and
  our spin version); [[Wild West Enemies]] (the charge rule, damage); [[Launch Agents]]
  (weapon behaviours); the controls rule on auto-aim. Each note carries a banner pointing
  to [[Original Mechanics Match]], which wins on conflict.
- **Built systems change** in Studio (the list is in [[Original Mechanics Match]]): scoring,
  combo, the spin and jump, swapping, auto-aim, the leap, the checkpoint cadence, Big Bart,
  Dynamite Dan, the Mayhem fill and gadget choice, crates and the medbay.
- [[Combat Polish Code]] is partly out of date (the stagger stays out, the spin follows
  the original fully); the local session reconciles it.
- Sessions 7 and 12 drafts need small updates (paid heals, booster clearing).
- Co-op balance has to be found in playtests: the original was tuned for one player.

Related: [[Original Mechanics Match]] · [[Differences from the Original]] · [[Game Design Document]] · [[Original Game]]
