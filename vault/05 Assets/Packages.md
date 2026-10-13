---
tags: [assets, packages]
---
# Packages

Third-party Luau libraries vendored as ModuleScripts in `ReplicatedStorage.Packages`.
Record where each came from so it can be updated or audited later.

| Name | Studio path | Source | Version | Notes |
|------|-------------|--------|---------|-------|
| ProfileStore | `ServerStorage.Packages.ProfileStore` | MadStudioRoblox/ProfileStore (GitHub) | _not installed. Pin the release tag at install_ | Player data. Server-only ([[0008-player-data-profilestore]]) |
| Signal | `ReplicatedStorage.Packages.Signal` | stravant GoodSignal or sleitnick Signal | _not installed_ | Planned ([[0010-third-party-packages]]) |
| Trove | `ReplicatedStorage.Packages.Trove` | sleitnick/RbxUtil Trove | _not installed_ | Planned |
| Promise | `ReplicatedStorage.Packages.Promise` | evaera/roblox-lua-promise | _not installed_ | Planned. Only where it helps (teleport and data flows) |

Server-only libraries go in `ServerStorage.Packages` so clients can't read them.

Related: [[Home]]
