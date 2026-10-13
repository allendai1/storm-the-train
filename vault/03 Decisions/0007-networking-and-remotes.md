---
tags: [decision, networking, security, remotes]
status: accepted
date: 2026-10-13
---
# 0007 — Networking: remotes, input state and validation

## Context
`CLAUDE.md` is non-negotiable on this: the server is authoritative, every remote is
validated for type, range and rate, and there are no server-to-client
`RemoteFunction` invokes. Weapons fire as often as every 0.07 s, so sending one remote
per shot would be expensive and easy to abuse.

## Decision
- **Where remotes live:** `ReplicatedStorage.Remotes`. They're created once in Studio
  (Edit mode) and saved in the place, not created at runtime. Names are PascalCase
  verbs.
- **Client → server** (all validated and rate-limited):

  | Remote | Type | Payload | Rate limit |
  |---|---|---|---|
  | `SetInput` | **UnreliableRemoteEvent** | Two scalars: `fire: boolean`, `aim: number` (−1 to 1, up/down tilt). Sent only when they change. Scalars are safer to validate than a table | 30/s |
  | `RequestSpin` | RemoteEvent | none | 4/s |
  | `RequestSwap` | RemoteEvent | `direction: 1 \| -1` | 2/s |
  | `RequestGadget` | RemoteEvent | `slot: 1 \| 2 \| 3` | 2/s |
  | `RequestInteract` | RemoteEvent | none. The **server** picks the target by proximity: revive, keys, hostage, pods | 4/s |
  | `RequestGemRevive` | RemoteEvent | none | 1/s |
  | `RequestCheckpointChoice` | RemoteEvent | `"Continue" \| "CashOut"` | 1/s |
  | Hub: `RequestPurchase`, `EquipSquad`, `EquipBoosters`, `RerollMission`, `SkipMission`, `ExchangeGems`, `PartyAction` | RemoteEvent | small, typed payloads (IDs as short strings, checked against config tables) | 2–5/s |

- **Validation pattern:** every handler starts with a shared `Validate` helper:
  - `typeof` checks, enum or allow-list membership, number range, and NaN/∞
    rejection,
  - a string length cap and a table size cap,
  - a per-player, per-remote **token bucket**.

  Failures are dropped and counted. Repeated failures are logged, and a player can be
  kicked past a threshold.
- **Server → client:**
  - **Continuous state** uses **Attributes**, which replicate automatically:
    - on the Player: `Health`, `Mayhem`, `Downed`, `BleedOutEndsAt`, `ActiveAgent`,
      `Combo`, `ComboMultiplier`, `Score`, `CarriedBlueprints`,
    - on the run: `Leg`, `TrainIndex`, `NextEvent`.
    Client controllers listen with `GetAttributeChangedSignal`.
  - **One-off events** use RemoteEvents:
    - `Effects` (UnreliableRemoteEvent): hits, knockout numbers, tracers and
      projectile starts, batched per Heartbeat.
    - `Announce`: train start, event start and checkpoint.
    - `RunEnded`: results.
- **No `RemoteFunction`s** at all to start with, in either direction. Hub screens that
  need data read Attributes and replicated folders, or get a reply event.
- **Everything is computed on the server:**
  - fire rate, damage, cooldowns, Mayhem, combo and score,
  - pickups (collected by server proximity checks),
  - currency, purchases, revives and checkpoint choices.

**Amendment (2026-10-13):** aiming was removed (GDD → Controls), so `SetInput` now
carries only `fire: boolean`. The `aim` scalar is gone from the client and the server,
and the server fires along the character's facing. The rest of this decision is
unchanged.

**Amendment (2026-10-13):** parties now form on physical queue pads ([[Queue Pads]]), so
the planned hub remote `PartyAction` is replaced by `RequestLeavePad` (no payload, 2/s).
Joining a pad is a server-side zone check, so it needs no remote.

## Alternatives considered
- **One remote per shot:** precise, but heavy and easy to spam. Input state plus
  server-side fire intervals removes both problems.
- **A networking library** (e.g. ByteNet or Red): smaller payloads, but it's another
  dependency. Revisit this only if bandwidth becomes a measured problem.

## Consequences
- Clients only *ask*. All outcomes come back as Attributes or events, so the UI shows
  server truth.
- Adding a remote means adding its allow-list, validator and rate limit. That's part
  of each system's `02 Systems/` note.

Related: [[0006-humanoid-enemies-and-combat]] · [[0004-single-place-hub-and-run-modes]] · [[Home]]
