---
tags: [decision, packages, dependencies]
status: proposed
date: 2026-10-13
---
# 0010 — Third-party packages

## Context
`CLAUDE.md` prefers well-known libraries over re-implementing them, with each one
recorded in [[Packages]]. The workflow is Studio-first with no Wally
([[0001-studio-first-with-studio-mcp]]).

## Decision
- Use these, and nothing else at first:

  | Library | Purpose | Studio path |
  |---|---|---|
  | **ProfileStore** (MadStudioRoblox) | Player data ([[0008-player-data-profilestore]]) | `ServerStorage.Packages.ProfileStore` (server-only) |
  | **Signal** (GoodSignal by stravant, or sleitnick's Signal) | Typed events between modules | `ReplicatedStorage.Packages.Signal` |
  | **Trove** (sleitnick) | Cleaning up connections and instances | `ReplicatedStorage.Packages.Trove` |
  | **Promise** (evaera) | Only for async chains such as teleport and data flows, where it helps | `ReplicatedStorage.Packages.Promise` |

- **No framework** (Knit or similar). We use our own bootstrap from `CLAUDE.md`: one
  Script with Services, one LocalScript with Controllers, and `init` then `start`.
- **Installing:** copy each library's source from its **official GitHub release**
  into a ModuleScript in Studio. Record the release tag or commit in [[Packages]].
  Check for unexpected `require(assetId)` calls or network code before adding.
- **Server-only libraries** go in `ServerStorage.Packages`, so clients can't read
  them. This is a small refinement of `CLAUDE.md`'s "Packages in ReplicatedStorage".

## Alternatives considered
- **Wally:** the standard package manager, but it needs Rojo, which isn't used here.
- **Writing our own Signal and Trove:** small, but these are solved problems.

## Consequences
- Four small, well-known dependencies, vendored by hand and pinned.
- Updating means re-copying a release and recording the new version.

Related: [[Packages]] · [[0008-player-data-profilestore]] · [[Home]]
