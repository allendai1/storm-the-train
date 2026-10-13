---
tags: [system, m0, security]
status: implemented
side: server
---
# Guard

## Purpose
Shared argument validation and per-player, per-remote token-bucket rate limiting.
**Every** remote handler goes through it ([[0007-networking-and-remotes]]). It doesn't
own any remotes itself.

## Code
- Studio path: `ServerScriptService.Server.Util.Guard`

## Expects in the place
- Remotes in `ReplicatedStorage.Remotes` (created in M0):
  - `SetInput`, `Effects` (UnreliableRemoteEvent),
  - `RequestSpin`, `RequestInteract`, `RequestReady`, `Announce`, `RunEnded` (RemoteEvent).
- Runtime-generated content (with reason): _none_

## Public API
- `Guard.connect(remote, ratePerSec, burst, handler)`: connects `OnServerEvent` with
  rate limiting. Over-rate calls are dropped and get a strike. The handler still
  validates its own arguments.
- `Guard.allow(player, key, ratePerSec, burst): boolean`
- `Guard.strike(player, reason)`: logs only, with a warning every 50 strikes. It never
  bans on strikes alone.
- Validators that return the value or `nil`:
  - `Guard.number(v, min, max, integer?)` rejects NaN and ±inf,
  - `Guard.boolean(v)`,
  - `Guard.string(v, maxLength)`,
  - `Guard.oneOf(v, allowed)`.

## Data / state
- `buckets[player][remoteName]` and `strikes[player]`, cleared on `PlayerRemoving`.

## Depends on
- nothing

## Notes
- No remote handlers use it yet (M0). Usage example: [[M0 Bootstrap Code]] §4.
