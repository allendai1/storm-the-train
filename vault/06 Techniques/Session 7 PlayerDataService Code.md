---
tags: [technique, studio, luau, data, datastore, profilestore, m2]
status: planned
updated: 2026-10-16
---
# Session 7 PlayerDataService Code

> **Needs updates after [[0012-match-the-original]] (2026-10-16):** the schema needs updating: drop `LoginStreak` (the login streak goes), and add per-run heal/revive counts only if they must survive a server move. Missions become a fixed ordered list (store the list index and tier), and boosters are cleared at every checkpoint. See [[Original Mechanics Match]].

## When to use
[[Loop (M2)]] Session 7 (saving). This is **draft reference code, written in a cloud
session without Studio, and it hasn't been run.** A local session installs ProfileStore,
pastes this in, makes the integration edits, and verifies it. Once the scripts exist in
the place, Studio is the source of truth: create the `PlayerDataService` system note in `02 Systems/`
from what was actually built, and stop editing this page.

It implements [[0008-player-data-profilestore]]: one ProfileStore session per player, a
versioned schema, the data mirrored into Player attributes, and no other code touching
player DataStores.

**Checked against the source (2026-10-16).** The calls here match the current
ProfileStore source (`MadStudioRoblox/ProfileStore`, `main`):
- `ProfileStore.New`, `.Mock` and `:StartSessionAsync(key, { Cancel = fn })`,
- `Profile.Data`, `:Reconcile()`, `:AddUserId()`, `:IsActive()`, `:Save()`,
  `:EndSession()` and `.OnSessionEnd`.

Facts from that source that shape this code:
- **ProfileStore binds `BindToClose` itself** and saves every active profile on shutdown,
  so this service doesn't.
- **Auto-save runs every 300 s.** `Profile:Save()` doesn't yield. It spawns one
  `UpdateAsync` and resets that profile's auto-save timer.
- **Without Studio API access**, ProfileStore can't reach DataStores and saves nothing
  ("Roblox API services unavailable - data will not be saved").
- **`Reconcile()`** deep-fills missing string keys from the template. It never touches
  array entries.
- **`StartSessionAsync` returns `nil`** on failure. Its own 120 s timeout is **turned
  off when you pass `Cancel`**, so the `Cancel` here also checks a 120 s `LOAD_TIMEOUT`.
  When another server holds the profile, it takes the session over after about 40 s.
- **The mock store ignores `params`** (and so `Cancel`). It never fails anyway.
- **On shutdown, ProfileStore ends sessions before `PlayerRemoving` runs.** So run coins
  are banked in `OnLastSave`, which fires just before every final save while the profile
  is still active.
- **Its strict type for `params`** only lists `Steal`, so passing `Cancel` needs a cast.

## Steps
1. **Install ProfileStore** in `ServerStorage.Packages.ProfileStore`:
   - Use the official Creator Store asset
     [109379033046155](https://create.roblox.com/store/asset/109379033046155) (linked from
     the repo README), or paste `ProfileStore.luau` from GitHub into a ModuleScript.
   - After inserting, check that it's a single ModuleScript with no extra scripts
     (`search_game_tree`).
   - Record the version or commit, and the date, in [[Packages]]. The 2026-10-16
     `main` file had 2,242 lines, and its SHA-256 starts with `ad43737203688b8e`.
2. **Run the setup snippet** (§1) in the Edit datamodel. It creates `ServerStorage.Packages`
   if it's missing.
3. **Add the types** (§2) to `ReplicatedStorage.Shared.Types`. Check that `Constants` has
   `STARTER_AGENT` and `SQUAD_SIZE`. [[AgentService]] already uses them.
4. **Create** `ServerScriptService.Server.Services.PlayerDataService` (ModuleScript) with
   §3, using `multi_edit` with its className.
5. **Make the integration edits** (§4) in AgentService, CharacterService, RunStateService
   and the PLAY AGAIN reset. `script_read` each one first. Studio is the truth, so adapt
   the call sites to what's there.
6. **Verify** (§5). Then write the `PlayerDataService` system note, tick Session 7 in
   [[Loop (M2)]], and remind the developer to save.

### §1 Setup snippet (Edit datamodel, idempotent)
```lua
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local packages = ServerStorage:FindFirstChild("Packages")
if not packages then
	packages = Instance.new("Folder")
	packages.Name = "Packages"
	packages.Parent = ServerStorage
	print("Created ServerStorage.Packages")
end
print("ProfileStore present:", packages:FindFirstChild("ProfileStore") ~= nil)

-- Studio-only switch: true = use the real DataStore in Studio (needs Game Settings →
-- Security → Enable Studio Access to API Services). Default false = mock store.
local server = ServerScriptService:FindFirstChild("Server")
if server and server:GetAttribute("UseRealDataInStudio") == nil then
	server:SetAttribute("UseRealDataInStudio", false)
	print("Added Server.UseRealDataInStudio = false")
end
```

### §2 Additions to `ReplicatedStorage.Shared.Types`
```lua
-- Saved player profile, schema v1 (ADR 0008). JSON-safe only: no Instances, no userdata,
-- no mixed or gappy arrays. Add a migration in PlayerDataService for every change.
export type PlayerData = {
	SchemaVersion: number,
	Coins: number,
	Gems: number,
	OwnedAgents: { [string]: boolean },
	Squad: { string }, -- 1..SQUAD_SIZE agent ids; [1] spawns first
	FirstCheckpointDone: boolean,
	Gear: { [string]: { Owned: number, Unlocked: number } },
	QueuedBoosters: { string },
	Missions: { Active: { { id: string, progress: number } }, FreeRerollDay: number },
	Challenges: { [string]: { Step: number, LastDay: number } },
	Discounts: { [string]: number },
	Bests: { SquadScore: number, IndividualScore: number, FurthestTrain: number },
	Stats: { Runs: number, Knockouts: number, Revives: number, CoinsEarned: number },
	LoginStreak: { Day: number, LastClaimDay: number },
	StarterPackBought: boolean,
	ReceiptIds: { string },
}

-- What RunStateService hands PlayerDataService at the end of a run.
export type RunRecord = {
	score: number, -- unboosted personal score
	squadScore: number,
	trains: number, -- furthest train number reached
	knockouts: number,
	revives: number,
}
```

### §3 `Server.Services.PlayerDataService` (ModuleScript)
```lua
--!strict
-- Player data (ADR 0008): one ProfileStore session per player, mirrored into Player attributes.
-- This is the ONLY module that touches player DataStores. Gameplay code calls the functions
-- below; it never edits profile data or the mirrored attributes itself.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types") :: ModuleScript)
local Constants = require(Shared:WaitForChild("Constants") :: ModuleScript)
local ProfileStore = require(ServerStorage:WaitForChild("Packages"):WaitForChild("ProfileStore") :: ModuleScript) :: any

type PlayerData = Types.PlayerData
type RunRecord = Types.RunRecord

-- The parts of a ProfileStore profile this service uses (the package's own types don't
-- resolve through WaitForChild requires).
type Profile = {
	Data: PlayerData,
	OnLastSave: any, -- ProfileStore signal (reason): fires just before the final save, still active
	OnSessionEnd: any, -- ProfileStore signal: :Connect(fn)
	IsActive: (self: Profile) -> boolean,
	Reconcile: (self: Profile) -> (),
	AddUserId: (self: Profile, userId: number) -> (),
	Save: (self: Profile) -> (),
	EndSession: (self: Profile) -> (),
}

local STORE_NAME = "PlayerData"
local KEY_PREFIX = "Player_"
local SCHEMA_VERSION = 1
local LOAD_TIMEOUT = 120 -- seconds. Passing Cancel turns off ProfileStore's own timeout, so we keep one

local TEMPLATE: PlayerData = {
	SchemaVersion = SCHEMA_VERSION,
	Coins = 0,
	Gems = 0,
	OwnedAgents = { [Constants.STARTER_AGENT] = true },
	Squad = { Constants.STARTER_AGENT },
	FirstCheckpointDone = false,
	Gear = {},
	QueuedBoosters = {},
	Missions = { Active = {}, FreeRerollDay = 0 },
	Challenges = {},
	Discounts = {},
	Bests = { SquadScore = 0, IndividualScore = 0, FurthestTrain = 0 },
	Stats = { Runs = 0, Knockouts = 0, Revives = 0, CoinsEarned = 0 },
	LoginStreak = { Day = 0, LastClaimDay = 0 },
	StarterPackBought = false,
	ReceiptIds = {},
}

-- MIGRATIONS[n] upgrades data from schema n to n + 1, in place. Add one with every
-- SCHEMA_VERSION bump and never edit an old one. New fields alone don't need a migration
-- (Reconcile fills them in); renames, moves and type changes do.
local MIGRATIONS: { [number]: (data: any) -> () } = {}

local PlayerDataService = {}

local store: any = nil
local profiles: { [Player]: Profile } = {}
local loading: { [Player]: true } = {} -- guards against loading the same player twice
local removed: { [Player]: true } = {} -- left while their profile was still loading

local function useMockStore(): boolean
	if not RunService:IsStudio() then
		return false
	end
	local server = ServerScriptService:FindFirstChild("Server")
	return not (server ~= nil and server:GetAttribute("UseRealDataInStudio") == true)
end

local function deepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for k, v in value :: any do
		copy[k] = deepCopy(v)
	end
	return copy :: any
end

-- Upgrades the saved data to SCHEMA_VERSION, in place. Run it on a copy. Returns false for data saved by a newer
-- server build, which this server must not touch.
local function migrate(data: any): boolean
	local version = if type(data.SchemaVersion) == "number" then data.SchemaVersion else 1
	if version > SCHEMA_VERSION then
		return false
	end
	while version < SCHEMA_VERSION do
		local step = MIGRATIONS[version]
		if step == nil then
			error(`missing migration v{version} -> v{version + 1}`)
		end
		step(data)
		version += 1
		data.SchemaVersion = version
	end
	return true
end

local function ownedList(data: PlayerData): { string }
	local list = {}
	for agentId, owned in data.OwnedAgents do
		if owned then
			table.insert(list, agentId)
		end
	end
	table.sort(list)
	return list
end

-- Mirrors what clients and other services read. Same formats AgentService already uses.
local function mirror(player: Player, data: PlayerData)
	player:SetAttribute("Coins", data.Coins)
	player:SetAttribute("Gems", data.Gems)
	player:SetAttribute("OwnedAgents", table.concat(ownedList(data), ","))
	player:SetAttribute("Squad", table.concat(data.Squad, ","))
	player:SetAttribute("FirstCheckpointDone", data.FirstCheckpointDone)
end

-- Returns the live data only while the session is active, so a write can't be lost.
local function activeData(player: Player): PlayerData?
	local profile = profiles[player]
	if profile ~= nil and profile:IsActive() then
		return profile.Data
	end
	return nil
end

local function isWholeNonNegative(n: number): boolean
	return n == n and n >= 0 and n < math.huge and math.floor(n) == n
end

-- NaN or inf in Data would make every save fail (JSON can't hold them), so stats are sanitised.
local function whole(n: number): number
	return if type(n) == "number" and isWholeNonNegative(n) then n else 0
end

local function onPlayerAdded(player: Player)
	if loading[player] or profiles[player] ~= nil then
		return -- joined while start() was connecting; already being loaded
	end
	loading[player] = true
	local startedAt = os.clock()
	local function gone(): boolean
		return removed[player] == true or player.Parent ~= Players
	end
	-- Note: the mock store ignores Cancel (it never fails anyway).
	local profile: Profile? = store:StartSessionAsync(KEY_PREFIX .. player.UserId, {
		Cancel = function(): boolean
			return gone() or os.clock() - startedAt > LOAD_TIMEOUT
		end,
	} :: any)
	loading[player] = nil

	if profile == nil then
		-- Never let them play on a blank profile: its next save would overwrite their real data.
		if not gone() then
			player:Kick("Your data couldn't load. Please rejoin in a moment.")
		end
		removed[player] = nil
		return
	end
	if gone() then
		removed[player] = nil
		profile:EndSession() -- they left while it was loading
		return
	end

	profile:AddUserId(player.UserId) -- GDPR erasure requests find profiles by UserId
	-- Migrate a copy: a step that errors halfway must not leave half-upgraded data to be saved.
	local upgraded = deepCopy(profile.Data)
	local ok, current = pcall(migrate, upgraded)
	if not ok or not current then
		warn(`[PlayerDataService] {player.UserId}: can't use saved data ({if ok then "newer schema" else current})`)
		profile:EndSession() -- saves the untouched original
		player:Kick("This server is out of date. Please rejoin.")
		return
	end
	profile.Data = upgraded
	profile:Reconcile()

	-- Fires before every final save: leaving, shutdown (ProfileStore's BindToClose ends sessions
	-- before PlayerRemoving runs) or another server taking over. Bank the leg's run coins first.
	profile.OnLastSave:Connect(function()
		local banked, err = pcall(PlayerDataService.commitRunCoins, player)
		if not banked then
			warn(`[PlayerDataService] {player.UserId}: run coins not banked: {err}`)
		end
	end)
	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players and not ProfileStore.IsClosing then
			player:Kick("Your data was opened on another server. Please rejoin.")
		end
	end)

	profiles[player] = profile
	mirror(player, profile.Data)
	player:SetAttribute("DataLoaded", true)
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if profile == nil then
		if loading[player] then
			removed[player] = true -- onPlayerAdded ends the session when the load returns
		end
		return
	end
	profile:EndSession() -- OnLastSave banks run coins, then it saves and releases the lock
end

function PlayerDataService.init()
	store = ProfileStore.New(STORE_NAME, TEMPLATE)
	if useMockStore() then
		store = store.Mock
	end
end

function PlayerDataService.start()
	print(`[PlayerDataService] {if useMockStore() then "mock" else "live"} store "{STORE_NAME}"`)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

-- Yields until the player's data has loaded. False if they left or were kicked first.
function PlayerDataService.waitForData(player: Player): boolean
	while profiles[player] == nil and player.Parent == Players do
		task.wait(0.1)
	end
	return profiles[player] ~= nil
end

function PlayerDataService.isLoaded(player: Player): boolean
	return activeData(player) ~= nil
end

-- Read-only view for other services. Change data only through the functions below.
function PlayerDataService.get(player: Player): PlayerData?
	return activeData(player)
end

-- Requests an immediate save. Use it at checkpoints and run end, not on every pickup.
function PlayerDataService.saveNow(player: Player)
	local profile = profiles[player]
	if profile ~= nil and profile:IsActive() then
		profile:Save()
	end
end

function PlayerDataService.addCoins(player: Player, amount: number): boolean
	assert(isWholeNonNegative(amount), "addCoins: amount must be a whole number >= 0")
	local data = activeData(player)
	if data == nil then
		warn(`[PlayerDataService] addCoins({amount}) for {player.UserId} with no active profile`)
		return false
	end
	data.Coins += amount
	data.Stats.CoinsEarned += amount
	player:SetAttribute("Coins", data.Coins)
	return true
end

-- Moves run coins collected since the last commit into the saved balance. RunCoins is the
-- run's running total (PickupService); RunCoinsCommitted is how much of it is banked.
function PlayerDataService.commitRunCoins(player: Player): number
	local runCoins = player:GetAttribute("RunCoins")
	local committed = player:GetAttribute("RunCoinsCommitted")
	local total = if typeof(runCoins) == "number" then math.floor(runCoins) else 0
	local banked = if typeof(committed) == "number" then committed else 0
	if not isWholeNonNegative(total) or not isWholeNonNegative(banked) then
		warn(`[PlayerDataService] {player.UserId}: bad RunCoins {runCoins} / {committed}`)
		return 0
	end
	local pending = math.max(0, total - banked)
	if pending > 0 and not PlayerDataService.addCoins(player, pending) then
		return 0
	end
	player:SetAttribute("RunCoinsCommitted", total)
	return pending
end

-- Call when a new run starts (PLAY AGAIN), after RunCoins is reset to 0.
function PlayerDataService.resetRun(player: Player)
	player:SetAttribute("RunCoinsCommitted", 0)
end

function PlayerDataService.owns(player: Player, agentId: string): boolean
	local data = activeData(player)
	return data ~= nil and data.OwnedAgents[agentId] == true
end

function PlayerDataService.grantAgent(player: Player, agentId: string): boolean
	local data = activeData(player)
	if data == nil then
		return false
	end
	if data.OwnedAgents[agentId] ~= true then
		data.OwnedAgents[agentId] = true
		if #data.Squad < Constants.SQUAD_SIZE and table.find(data.Squad, agentId) == nil then
			table.insert(data.Squad, agentId)
		end
		mirror(player, data)
	end
	return true
end

-- squad: already validated by AgentService. Re-checked here because it gets saved.
function PlayerDataService.setSquad(player: Player, squad: { string }): boolean
	local data = activeData(player)
	if data == nil or #squad < 1 or #squad > Constants.SQUAD_SIZE then
		return false
	end
	local seen: { [string]: boolean } = {}
	for _, agentId in squad do
		if data.OwnedAgents[agentId] ~= true or seen[agentId] then
			return false
		end
		seen[agentId] = true
	end
	data.Squad = table.clone(squad)
	player:SetAttribute("Squad", table.concat(data.Squad, ","))
	return true
end

function PlayerDataService.markFirstCheckpointDone(player: Player)
	local data = activeData(player)
	if data ~= nil and not data.FirstCheckpointDone then
		data.FirstCheckpointDone = true
		player:SetAttribute("FirstCheckpointDone", true)
	end
end

function PlayerDataService.recordRunEnd(player: Player, record: RunRecord)
	local data = activeData(player)
	if data == nil then
		return
	end
	local bests = data.Bests
	bests.IndividualScore = math.max(bests.IndividualScore, whole(record.score))
	bests.SquadScore = math.max(bests.SquadScore, whole(record.squadScore))
	bests.FurthestTrain = math.max(bests.FurthestTrain, whole(record.trains))
	data.Stats.Runs += 1
	data.Stats.Knockouts += whole(record.knockouts)
	data.Stats.Revives += whole(record.revives)
end

return PlayerDataService
```

No `Modes` field, so it runs in both Hub and Run mode: both need the player's data.

### §4 Integration edits (adapt to the scripts as they are)
`script_read` each script first. The call sites below are described from the system notes,
not the live code.
- **AgentService** ([[AgentService]]):
  - **Join:** stop setting `OwnedAgents`/`Squad` to `STARTER_AGENT`. Instead:
    `if not PlayerDataService.waitForData(player) then return end`, then read the mirrored
    attributes as before.
  - **`DevGrantAllAgents`:** call `PlayerDataService.grantAgent` for each template. That
    saves only to the mock store unless `UseRealDataInStudio` is on.
  - **`AgentService.grant` and `owns`:** delegate to `PlayerDataService.grantAgent` and
    `PlayerDataService.owns`.
  - **`EquipSquad`:** after its own validation, call `PlayerDataService.setSquad(player,
    ids)`. That sets the `Squad` attribute, so drop AgentService's own write. Keep the
    swap-if-removed logic.
  - **`onCheckpoint`:** decide the first-checkpoint grant from `FirstCheckpointDone`, as
    now, then call `PlayerDataService.markFirstCheckpointDone(player)` alongside the
    Brick grant.
- **CharacterService** ([[CharacterService]]): the first `spawn(player)` must wait for
  `PlayerDataService.waitForData(player)`. Otherwise a player can spawn as Max/Dash before
  their saved `Squad` arrives.
- **RunStateService** ([[RunStateService]]):
  - **Checkpoint arrival:** for each player, `PlayerDataService.commitRunCoins(player)` and
    then `PlayerDataService.saveNow(player)`.
  - **`finish()`** (wipe and cash-out alike, since coins are always kept):
    - `commitRunCoins` for each player,
    - then the **run-end bonus** (1 coin per 25 points). Check how it's applied today: if
      it's added into `RunCoins`, `commitRunCoins` already covers it. If it's only put in
      the `RunEnded` result, call `PlayerDataService.addCoins(player, bonus)`,
    - then `recordRunEnd(player, { score, squadScore, trains, knockouts, revives })` and
      `saveNow(player)`.
  - **PLAY AGAIN:** after pickups reset `RunCoins`, call `PlayerDataService.resetRun(player)`.
- **HUD:** no change. The run HUD keeps showing `RunCoins`. The saved `Coins` balance is
  for the hub's currency HUD (M4).

### §5 Verify
1. **Mock mode** (the default in Studio). Playtest:
   - the console shows `[PlayerDataService] mock store "PlayerData"`, plus
     ProfileStore's own API-access line,
   - the player has `DataLoaded`, `Coins = 0`, `OwnedAgents`/`Squad` = the starter, and
     no errors.
2. **A run:**
   - collect coins, reach the checkpoint: `Coins` rises by the run coins, and
     `RunCoinsCommitted` = `RunCoins`,
   - get Brick: `FirstCheckpointDone`, and `OwnedAgents` lists both,
   - finish: `Coins` includes the run-end bonus exactly once,
   - PLAY AGAIN, a second checkpoint: no double count.
3. **Persistence:** turn on Game Settings → Security → Studio Access to API Services and
   set `UseRealDataInStudio = true`. Then:
   - play, earn coins and Brick, stop, play again: they're still there,
   - stopping the playtest while the profile is active saves through ProfileStore's
     `BindToClose` (with API access, Stop takes a moment),
   - afterwards, set `UseRealDataInStudio` back to `false`. This only touches your own
     profile key.
4. **The failure path:** temporarily add `profile = nil` right after the
   `StartSessionAsync` call. The mock store ignores `Cancel`, so a Cancel that's always
   true won't fail it. The player is kicked with "couldn't load", and nothing is saved.
   Remove the line afterwards.
5. **A newer schema:** temporarily set the saved `SchemaVersion` to 2 (via §3's `get` in
   the Server datamodel). The next session kicks with "out of date" and doesn't overwrite
   it. Put it back afterwards.
6. Not testable in Studio: two servers fighting over one profile (session takeover). That
   needs the published test place (Session 13).

## Choices made in this draft (review them)
- **Run coins are banked at every final save**, not only at checkpoints and run end.
  That covers leaving mid-leg, a server shutdown or update, and a session takeover. It
  follows "coins are always kept" ([[Economy and Monetization]]). Only a real crash loses
  the current leg's coins, as ADR 0008 accepts.
- **Reviewed 2026-10-16** by a read-only code review against the ProfileStore source.
  Fixed:
  - shutdown losing run coins,
  - a failed migration saving half-upgraded data,
  - `Cancel` turning off the load timeout,
  - NaN/inf stats breaking saves,
  - a join/leave race leaving a lock on a player who had gone.
- **`FirstCheckpointDone` is a new top-level field.** ADR 0008's schema lists a `Stats`
  table under `Bests`; here it's its own `Stats` table with `Runs`, `Knockouts`, `Revives`
  and `CoinsEarned`.
- **A newer saved schema kicks the player** rather than loading the data. It can only
  happen briefly during a rolling update, and it protects the data.
- **Receipt handling (`ProcessReceipt`) isn't included.** No Developer Products exist yet.
  Add it in M4 following ADR 0008's rules: grant, add the `PurchaseId`, and return
  `PurchaseGranted` only after the save succeeds. ProfileStore's `OnAfterSave` and
  `LastSavedData` fit that.
- **Gems, gear, boosters, missions, challenges, discounts and the login streak** are in
  the template, so they're saved from day one, but nothing writes them until their systems
  exist.

Related: [[0008-player-data-profilestore]] · [[Loop (M2)]] · [[Packages]] · [[AgentService]] · [[RunStateService]] · [[Techniques]]
