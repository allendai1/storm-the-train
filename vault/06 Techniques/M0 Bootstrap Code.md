---
tags: [technique, studio, luau, bootstrap, m0]
status: planned
updated: 2026-10-13
---
# M0 Bootstrap Code

## When to use
Session 1 of [[First Playable (M1)]]. This is **reference code to paste into Studio**,
not live code. **Studio is the source of truth** ([[0001-studio-first-with-studio-mcp]]):
once a script exists in the place, edit it there, and keep its `02 Systems/` note up to
date rather than this page. It hasn't been run yet. Treat it as a first draft, and fix
anything Script Analysis or the playtest flags.

## Steps
1. **Run the setup script** (§1) with `execute_luau`, `datamodel_type = "Edit"`. It's
   idempotent: it only creates what's missing, prints every change, and is safe to
   re-run.
2. **Paste the module sources** (§2–§7) into the matching instances with
   `multi_edit`, or with `script_read` followed by `multi_edit`.
3. **Verify** with [[Studio Setup Checklist]] §7: a playtest shows `[Server] Run mode`
   and `[Client] Run mode`, with no errors.

### §1 Setup script (Edit datamodel, idempotent)
```lua
-- M0 setup. Run with execute_luau (Edit). Creates only missing instances; prints what changed.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local PhysicsService = game:GetService("PhysicsService")

local changes = {}

local function ensure(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing then
		if existing.ClassName ~= className then
			warn(`{existing:GetFullName()} is a {existing.ClassName}, expected {className}. Left unchanged.`)
		end
		return existing
	end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = parent
	table.insert(changes, `created {inst:GetFullName()} ({className})`)
	return inst
end

-- Server
local server = ensure(ServerScriptService, "Script", "Server")
local services = ensure(server, "Folder", "Services")
ensure(services, "ModuleScript", "ModeService")
local util = ensure(server, "Folder", "Util")
ensure(util, "ModuleScript", "Guard")
if server:GetAttribute("ForceMode") == nil then
	server:SetAttribute("ForceMode", "Run") -- Studio only; see ModeService
	table.insert(changes, "set Server.ForceMode = Run")
end

-- Client
local client = ensure(StarterPlayer:WaitForChild("StarterPlayerScripts"), "LocalScript", "Client")
ensure(client, "Folder", "Controllers")

-- Shared, assets, packages, remotes
local shared = ensure(ReplicatedStorage, "Folder", "Shared")
ensure(shared, "ModuleScript", "Constants")
ensure(shared, "ModuleScript", "Types")
ensure(shared, "Folder", "Config")
ensure(ReplicatedStorage, "Folder", "Assets")
ensure(ReplicatedStorage, "Folder", "Packages")
local remotes = ensure(ReplicatedStorage, "Folder", "Remotes")
ensure(ServerStorage, "Folder", "Assets")
ensure(ServerStorage, "Folder", "Packages")

-- M1 remotes (ADR 0007)
for _, name in { "SetInput", "Effects" } do
	ensure(remotes, "UnreliableRemoteEvent", name)
end
for _, name in { "RequestSpin", "RequestInteract", "RequestReady", "Announce", "RunEnded" } do
	ensure(remotes, "RemoteEvent", name)
end

-- Maps (ADR 0004)
local map = ensure(workspace, "Folder", "Map")
ensure(map, "Folder", "Run")
ensure(map, "Folder", "Hub")

-- Collision groups (first guess: nothing body-blocks anything on the narrow roofs)
for _, group in { "Players", "Enemies", "Hitboxes", "Ragdolls", "Pickups" } do
	if not PhysicsService:IsCollisionGroupRegistered(group) then
		PhysicsService:RegisterCollisionGroup(group)
		table.insert(changes, `registered collision group {group}`)
	end
end
local all = { "Default", "Players", "Enemies", "Hitboxes", "Ragdolls", "Pickups" }
for _, other in all do
	PhysicsService:CollisionGroupSetCollidable("Hitboxes", other, false) -- queries only
	PhysicsService:CollisionGroupSetCollidable("Pickups", other, other == "Default")
end
PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Players", "Enemies", false)
PhysicsService:CollisionGroupSetCollidable("Enemies", "Enemies", false)
PhysicsService:CollisionGroupSetCollidable("Ragdolls", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Ragdolls", "Enemies", false)
PhysicsService:CollisionGroupSetCollidable("Ragdolls", "Ragdolls", false)

-- StarterPlayer (ADR 0005)
StarterPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
StarterPlayer.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable
StarterPlayer.AutoJumpEnabled = false
StarterPlayer.EnableMouseLockOption = false
table.insert(changes, "set StarterPlayer movement modes to Scriptable, auto-jump and mouse lock off")

print(`[M0 setup] {#changes} change(s):\n` .. table.concat(changes, "\n"))
```

### §2 `ServerScriptService.Server` (Script)
```lua
--!strict
-- Server bootstrap: picks the mode, then init() and start() for every Service that runs in it.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types") :: ModuleScript)
local servicesFolder = script:WaitForChild("Services")
local ModeService = require(servicesFolder:WaitForChild("ModeService") :: ModuleScript)

local mode = ModeService.resolve()

local active: { [string]: Types.Service } = {}
for _, child in servicesFolder:GetChildren() do
	if child:IsA("ModuleScript") then
		local service = require(child) :: Types.Service
		if service.Modes == nil or table.find(service.Modes, mode) ~= nil then
			active[child.Name] = service
		end
	end
end

-- init(): wire up, never yield. Services that need each other require() each other directly.
for _, service in active do
	if service.init then
		service.init()
	end
end
-- start(): may yield, so each runs in its own thread.
local count = 0
for _, service in active do
	count += 1
	if service.start then
		task.spawn(function()
			service.start()
		end)
	end
end
print(`[Server] {mode} mode, {count} service(s)`)
```

### §3 `Server.Services.ModeService` (ModuleScript)
```lua
--!strict
-- Decides Hub vs Run mode (ADR 0004). ForceMode only works in Studio.
local RunService = game:GetService("RunService")
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Types") :: ModuleScript)

local ModeService = {}
local current: Types.Mode? = nil

function ModeService.resolve(): Types.Mode
	if current then
		return current
	end
	local resolved: Types.Mode
	local servicesFolder = script.Parent
	local serverScript = if servicesFolder then servicesFolder.Parent else nil
	local forced = if serverScript then serverScript:GetAttribute("ForceMode") else nil
	if RunService:IsStudio() and (forced == "Hub" or forced == "Run") then
		resolved = forced
	elseif game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 then
		resolved = "Run" -- reserved server. M2: verify the MemoryStore record and roster
	else
		resolved = "Hub" -- public or free private (VIP) server
	end
	current = resolved
	workspace:SetAttribute("Mode", resolved) -- replicates to clients
	return resolved
end

function ModeService.get(): Types.Mode
	return ModeService.resolve()
end

return ModeService
```

### §4 `Server.Util.Guard` (ModuleScript)
```lua
--!strict
-- Validation + per-player, per-remote token buckets. Every remote handler goes through this (ADR 0007).
local Players = game:GetService("Players")

local Guard = {}

type Bucket = { tokens: number, last: number }
local buckets: { [Player]: { [string]: Bucket } } = {}
local strikes: { [Player]: number } = {}

function Guard.allow(player: Player, key: string, ratePerSec: number, burst: number): boolean
	local now = os.clock()
	local perPlayer = buckets[player]
	if not perPlayer then
		perPlayer = {}
		buckets[player] = perPlayer
	end
	local bucket = perPlayer[key]
	if not bucket then
		bucket = { tokens = burst, last = now }
		perPlayer[key] = bucket
	end
	bucket.tokens = math.min(burst, bucket.tokens + (now - bucket.last) * ratePerSec)
	bucket.last = now
	if bucket.tokens < 1 then
		return false
	end
	bucket.tokens -= 1
	return true
end

-- Log only. Never auto-ban on strikes alone (lag and retries cause false positives).
function Guard.strike(player: Player, reason: string)
	local n = (strikes[player] or 0) + 1
	strikes[player] = n
	if n % 50 == 0 then
		warn(`[Guard] {player.Name} ({player.UserId}) {n} strikes, latest: {reason}`)
	end
end

function Guard.number(value: unknown, min: number, max: number, integer: boolean?): number?
	if typeof(value) ~= "number" then
		return nil
	end
	local n = value :: number
	if n ~= n or n == math.huge or n == -math.huge then -- NaN / infinity
		return nil
	end
	if integer and n ~= math.floor(n) then
		return nil
	end
	if n < min or n > max then
		return nil
	end
	return n
end

function Guard.boolean(value: unknown): boolean?
	if typeof(value) == "boolean" then
		return value :: boolean
	end
	return nil
end

function Guard.string(value: unknown, maxLength: number): string?
	if typeof(value) ~= "string" then
		return nil
	end
	local s = value :: string
	if #s == 0 or #s > maxLength then
		return nil
	end
	return s
end

function Guard.oneOf(value: unknown, allowed: { string }): string?
	if typeof(value) == "string" and table.find(allowed, value :: string) ~= nil then
		return value :: string
	end
	return nil
end

-- Rate-limited connect. The handler still validates its own arguments.
function Guard.connect(remote: Instance, ratePerSec: number, burst: number, handler: (Player, ...unknown) -> ())
	assert(remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent"), `{remote:GetFullName()} is not a remote event`)
	local key = remote.Name;
	(remote :: any).OnServerEvent:Connect(function(player: Player, ...: unknown)
		if not Guard.allow(player, key, ratePerSec, burst) then
			Guard.strike(player, key .. ":rate")
			return
		end
		handler(player, ...)
	end)
end

Players.PlayerRemoving:Connect(function(player)
	buckets[player] = nil
	strikes[player] = nil
end)

return Guard
```

**Usage example** (inside a future `CombatService.init`):
```lua
local Remotes = ReplicatedStorage.Remotes
Guard.connect(Remotes.SetInput, 30, 10, function(player, fire, aim)
	local f = Guard.boolean(fire)
	local a = Guard.number(aim, -1, 1)
	if f == nil or a == nil then
		Guard.strike(player, "SetInput:args")
		return
	end
	CombatService.setInput(player, f, a)
end)
```

### §5 `StarterPlayerScripts.Client` (LocalScript)
```lua
--!strict
-- Client bootstrap: waits for the server's mode, then init() and start() for matching Controllers.
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Types") :: ModuleScript)

if workspace:GetAttribute("Mode") == nil then
	workspace:GetAttributeChangedSignal("Mode"):Wait()
end
local mode = workspace:GetAttribute("Mode") :: Types.Mode

local active: { [string]: Types.Service } = {}
for _, child in script:WaitForChild("Controllers"):GetChildren() do
	if child:IsA("ModuleScript") then
		local controller = require(child) :: Types.Service
		if controller.Modes == nil or table.find(controller.Modes, mode) ~= nil then
			active[child.Name] = controller
		end
	end
end

for _, controller in active do
	if controller.init then
		controller.init()
	end
end
local count = 0
for _, controller in active do
	count += 1
	if controller.start then
		task.spawn(function()
			controller.start()
		end)
	end
end
print(`[Client] {mode} mode, {count} controller(s)`)
```

### §6 `ReplicatedStorage.Shared.Types` (ModuleScript)
```lua
--!strict
-- Shared exported types. Anything crossing a module boundary is typed here.
export type Mode = "Hub" | "Run"
export type RunState = "Lobby" | "InTrain" | "Cleared" | "Wiped" | "Results"

-- Every Service and Controller module returns this shape.
export type Service = {
	Modes: { Mode }?, -- nil = runs in every mode
	init: (() -> ())?, -- wire up; must not yield
	start: (() -> ())?, -- runs in its own thread; may yield
}

-- These mirror the Attributes on templates (read with a typed helper in each service).
export type WeaponStats = {
	Damage: number,
	FireInterval: number,
	Range: number,
	ProjectileSpeed: number?,
	SplashRadius: number?,
	SplashDamage: number?,
}
export type AgentStats = {
	Speed: number,
	Toughness: number,
	SpinLevel: number,
	PrimaryWeapon: string,
	SecondaryWeapon: string,
}
export type EnemyStats = {
	Slot: number,
	Archetype: string,
	MaxHealth: number,
	Speed: number,
	SpawnCost: number,
	Damage: number,
	HitboxWidth: number,
	HitboxHeight: number,
	FreezeScalar: number,
}

return {}
```

### §7 `ReplicatedStorage.Shared.Constants` (ModuleScript)
```lua
--!strict
-- Game-wide tunables. First guesses from First Playable (M1); tune in playtests. No magic numbers inline.
-- Per-asset numbers (weapon damage, enemy HP, agent speed) live as Attributes on the templates instead.
local Constants = {
	PLANE_Z = 0,
	PLANE_Z_TOLERANCE = 0.5, -- studs of Z drift before the server snaps back
	SPEED_TOLERANCE = 1.25, -- × agent Speed before movement is flagged

	PLAYER_MAX_HEALTH = 100,
	JUMP_HEIGHT = 8,
	SPIN_COOLDOWN = 0.6,
	SPIN_LIFT = 4,

	CARRIAGE_GAP = 3,
	LEAP_GAP = 10,
	GAP_FALL_DELAY = 1,
	GAP_FALL_DAMAGE = 15, -- raw, scaled by toughness

	REVIVE_BLEED_OUT = 15,
	REVIVE_HOLD = 2,
	REVIVE_RANGE = 5,
	REVIVE_HEALTH_FRACTION = 0.4,

	COOP_SCALE = { 1.0, 1.6, 2.2, 2.8 }, -- spawn budget and alive cap, by party size
	ENEMY_AI_HZ = 12,
	ENEMY_SPAWN_MIN_DISTANCE = 20,
	RAGDOLL_MAX = 12,
	RAGDOLL_FADE = 3,

	WEAPON_CRATE_RESPAWN = 20,
	COMBO_WINDOW = 2.5,

	CAMERA_FOV = 40,
	CAMERA_WIDTH_STUDS = 70,
	CAMERA_LEAD = 8,
}

return table.freeze(Constants)
```

## Roblox export notes
- `table.freeze` is shallow. `COOP_SCALE` can still be mutated, so treat every
  constant as read-only by convention.
- `Guard.connect` takes `Instance` and asserts the class, because Luau can't easily
  type a union of the two remote classes' `OnServerEvent`.
- `SetInput` sends **two scalars** (`fire`, `aim`) rather than a table, which is safer
  to validate. [[0007-networking-and-remotes]] is updated to match.
- **Character parts need collision groups.** CharacterService (Session 2) and
  EnemyService (Session 4) set `CollisionGroup` on the parts of every character,
  enemy, hitbox and ragdoll they create. The setup script only registers the groups.
- Children are reached with `WaitForChild` and casts rather than dot-indexing
  (`script.Services`), which `--!strict` can flag as unknown properties.
- Init order across services is unspecified. A service that needs another should
  `require()` it directly and only call into it from `start()`.

## Example
- **Run on 2026-10-13** (place `71855801375130`). The changes from this page were:
  - **Scripts were created with `multi_edit`** (with className) **before** the setup
    script ran, and the setup script no longer creates the script instances.
    `Instance.new` gives empty scripts, which `multi_edit` can't fill without a
    matching old string.
  - The bootstraps call `(require :: any)(child)` so `--!strict` accepts a dynamic
    ModuleScript.
  - `COOP_SCALE` is frozen as well.
  - `workspace.StreamingEnabled = false` works from `execute_luau`.
    **`Lighting.Technology` can't be read or written from it** (it lacks the
    RobloxScript capability), so set it by hand.

Related: [[Techniques]] · [[Studio Setup Checklist]] · [[First Playable (M1)]] · [[0004-single-place-hub-and-run-modes]] · [[0007-networking-and-remotes]]
