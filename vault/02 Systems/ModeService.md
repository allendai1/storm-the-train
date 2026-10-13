---
tags: [system, m0]
status: implemented
side: server
---
# ModeService

## Purpose
Decides whether this server runs in **Hub** or **Run** mode ([[0004-single-place-hub-and-run-modes]])
and publishes it as `workspace.Mode`. Both bootstraps use it to filter which
Services/Controllers run.

## Code
- Studio path: `ServerScriptService.Server.Services.ModeService`
- Bootstraps: `ServerScriptService.Server` (Script), `StarterPlayer.StarterPlayerScripts.Client`
  (LocalScript). Both `require` every child of `Services` / `Controllers`, skip modules
  whose `Modes` list excludes the current mode, call every `init()`, then every `start()`
  in `task.spawn`.

## Expects in the place
- Attributes: `ServerScriptService.Server.ForceMode` = `"Run"` or `"Hub"`. **Studio only**,
  ignored on live servers.
- Runtime-generated content (with reason): _none_

## Public API
- `ModeService.resolve(): Types.Mode`. Resolves once and caches. It sets `workspace.Mode`.
- `ModeService.get(): Types.Mode`. Same as `resolve`.

## Remotes
None. Clients read the replicated `workspace` attribute `Mode`.

## Data / state
- Resolution order: Studio + `ForceMode` → reserved server (`PrivateServerId ~= ""` and
  `PrivateServerOwnerId == 0`) = Run → otherwise Hub.

## Depends on
- `ReplicatedStorage.Shared.Types` (`Mode`, `Service`)

## Notes
- M2 must verify the MemoryStore record and roster before trusting a reserved server.
- Verified 2026-10-13: a playtest prints `[Server] Run mode, 1 service(s)` and
  `[Client] Run mode, 0 controller(s)`, with no errors.
