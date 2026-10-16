---
tags: [decision, data, datastore, monetization]
status: accepted
date: 2026-10-13
---
# 0008 — Player data with ProfileStore

## Context
`CLAUDE.md` requires one server module wrapping DataStores, with session locking,
retries and saves on `BindToClose`. The game sells Developer Products
([[Economy and Monetization]]), so receipts must never be granted twice or lost.
Players move between hub and run servers ([[0004-single-place-hub-and-run-modes]]).

## Decision
- Use **ProfileStore** (MadStudioRoblox / loleris, the successor to ProfileService),
  wrapped by a single `ServerScriptService.Server.Services.PlayerDataService`. **No
  other code touches DataStores**, except leaderboards (below).
- Check the exact API names against the ProfileStore docs when installing. Record the
  version in [[Packages]].
- **Store:** `PlayerData`, with profile key `Player_<UserId>`. In Studio, use
  ProfileStore's **mock** store unless a test explicitly needs real data.
- **Schema v1** (template; numbers default to 0):
  - `SchemaVersion`
  - `Coins`, `Gems`
  - `OwnedAgents` `{ [agentId]: true }`, with the two free agents granted on creation
    and at the first checkpoint
  - `Squad` `{ agentId, agentId, agentId }`
  - `Gear` `{ [itemId]: { Owned: level, Unlocked: level } }`
  - `QueuedBoosters` `{ boosterId }`: up to 3, bought in the hub and consumed when a leg
    starts
  - `Missions` `{ Active = { {id, progress} ×3 }, FreeRerollDay }`
  - `Challenges` `{ [agentId]: { Step, LastDay } }`
  - `LoginStreak` `{ Day, LastClaimDay }` (added 2026-10-16, [[Economy and Monetization]])
  - `Discounts` `{ [agentId]: percent }`
  - `Bests` `{ SquadScore, IndividualScore, FurthestTrain }`, with stats counters
  - `StarterPackBought`, plus Game Pass flags (cached; ownership is checked
    with `MarketplaceService`)
  - `ReceiptIds`: recent processed `PurchaseId`s, capped at about 50
- **Migrations:** each schema bump adds a migration function `vN → vN+1`. These run on
  load, in order. Missing fields are filled from the template.
- **Purchases:**
  - `MarketplaceService.ProcessReceipt` waits for the player's profile to be active.
  - If the `PurchaseId` is in `ReceiptIds`, it returns `PurchaseGranted`. Otherwise it
    grants, adds the ID, saves, and returns `PurchaseGranted` **only after the save
    succeeds**. Any failure returns `NotProcessedYet`.
- **What gets committed during a run:** run state (carried blueprints, run coins,
  score) is kept **in memory** on the run server.
  - At each **checkpoint**, run coins are committed and carried blueprints are
    **banked** (decided: blueprints are lost on a wipe).
  - At **run end**, the final coins, personal bests, mission progress and challenge
    progress are committed.
  - If a server crashes mid-leg, that leg's uncommitted coins are lost. That's
    accepted.
- **Moving between servers:** the old server releases the profile on
  `PlayerRemoving`. The new server's session start waits or retries while a loading
  screen shows. ProfileStore's session locking prevents two servers writing at once.
- **Leaderboards:** separate **OrderedDataStores**, one per board, bracket and scope
  ([[Score and Combo]]). Only the run server writes them, once per run end, for
  unboosted scores, with retries and a budget check.

## Alternatives considered
- **Our own DataStore wrapper:** no dependency, but session locking, retries and
  receipt safety are where data loss and item duplication come from. A
  battle-tested library is safer.
- **ProfileService:** the older library. ProfileStore is its maintained successor.

## Consequences
- One dependency on the most sensitive path. Pin its version and read its changelog
  before updating.
- Every system that saves data adds fields here, with a migration. The schema is
  documented in the `PlayerDataService` system note when it's built.

Related: [[Economy and Monetization]] · [[0004-single-place-hub-and-run-modes]] · [[Packages]] · [[Home]]
