---
tags: [decision, architecture, multiplayer, teleport]
status: accepted
date: 2026-10-13
---
# 0004 — One place with Hub and Run modes

## Context
The [[Game Design Document]] says parties form on the hub train, and runs happen in a
reserved server reached by Teleport. The project is Studio-first with no Rojo
([[0001-studio-first-with-studio-mcp]]). Two separate places would need their shared
scripts synced by hand or through Roblox asset Packages.

## Decision
- The experience is **one place** that runs in one of two **modes**:
  - **Hub mode:** public servers and free private servers (VIP). This is the hub train,
    the shops and party forming.
  - **Run mode:** **reserved servers** created with `TeleportService:ReserveServer` for
    one party's run.
- **Mode detection** at server start:
  - If `game.PrivateServerId == ""`, or `game.PrivateServerOwnerId ~= 0` (a VIP
    server), the server is in **Hub** mode.
  - Otherwise it's a reserved server. It reads its record from `MemoryStoreService`,
    keyed by its `PrivateServerId`: `{ mode = "Run", partyUserIds = {...}, createdAt }`.
    The hub server writes that record before teleporting. If there's no record, the
    server teleports everyone back to the hub.
  - **Studio override:** an Attribute `ForceMode` (`"Hub"` / `"Run"` / empty) on
    `ServerScriptService.Server`, for playtesting each mode.
- **Teleport data isn't trusted.** It travels through the client. The run server
  takes the **party roster from MemoryStore** and each player's squad and boosters from
  their **saved profile** ([[0008-player-data-profilestore]]). It never takes them from
  `GetJoinData()`.
- **Bootstrap:**
  - Each service declares which modes it runs in (e.g. `Modes = { "Run" }`).
  - The server bootstrap reads the mode and runs `init`/`start` only for matching
    services.
  - Shared services (data, currency) run in both modes.
- **Maps:**
  - Both maps are hand-built in `Workspace.Map`: `Map.Hub` (the hub train area) and
    `Map.Run` (the run staging area). That keeps both visible for editing in Studio.
  - At start, the server moves the map it doesn't need into `ServerStorage`.
- **Returning to the hub:** after a run, the party teleports back together. A party
  that wants to stay together goes to a **reserved Hub-mode server**, whose MemoryStore
  record says `mode = "Hub"`. Solo players can go to any public hub.
- **Quick-join** starts within the same hub server. Cross-server quick-join
  (MemoryStore SortedMap of open parties) is a later step.

## Alternatives considered
- **Separate hub and run places.** A cleaner split, but shared code would have to sync
  through Roblox Packages (auto-updating assets) or by hand. That's the kind of
  overhead [[0001-studio-first-with-studio-mcp]] avoided.
- **No teleport: runs happen inside the hub server.** Simplest, but one server would
  host many parties' runs and the hub at once, which would hurt performance and
  isolation.

## Consequences
- One set of scripts. Every service has to be mode-aware.
- The place carries both maps. Only one is in `Workspace` at runtime.
- Needs MemoryStore and Teleport error handling: retries, a fallback back to the hub,
  and a loading screen while the profile session moves between servers.
- Run mode can't be playtested as a real reserved server in Studio, so `ForceMode`
  is used there. Real teleports have to be tested in a published test place.

Related: [[Game Design Document]] · [[0008-player-data-profilestore]] · [[Home]]
