---
tags: [technique, studio, luau, hub, teleport, queue-pads, m2]
status: planned
updated: 2026-10-16
---
# Session 12 Hub Code

> **Needs updates after [[0012-match-the-original]] (2026-10-16):** the hub now also serves as the per-train checkpoint (paid HEALTH pod, booster menu every train), and the run starts on the hub train before leaping to train 1. See [[Original Mechanics Match]].

## When to use
[[Loop (M2)]] Session 12: Hub mode and teleport. This is **draft reference code, written
in a cloud session without Studio, and it hasn't been run.** A local session builds the
place pieces, pastes the scripts, makes the integration edits and verifies them. Once
they exist in the place, Studio is the source of truth: write `02 Systems/` notes for
`QueuePadService`, `TravelService` and the controllers from what was built, and stop
editing this page.

**Do Session 7 first** ([[Session 7 PlayerDataService Code]]). The hub shows the saved
coin balance, and moving between servers relies on profile session locking.

It implements:
- [[Queue Pads]],
- the teleport flow in [[0004-single-place-hub-and-run-modes]],
- the remotes rule in [[0007-networking-and-remotes]]: everything is validated, rate-limited
  and decided by the server, and teleport data isn't trusted.

**Decided by the developer on 2026-10-16** (recorded in [[Loop (M2)]] Session 12):
- **The hub is side-on, like the runs.** It uses the same agent rig, controls and
  camera. The Falcon-8 is a long train you walk along, with the pods and queue pads in a
  row.
- **The results screen offers BACK TO HUB, and PLAY AGAIN is removed.** The run server
  waits until everyone has pressed it, or for 30 s. Then it sends everyone back
  together: a party to one reserved Hub-mode server, a solo player to a public hub.

**Checked against the current Roblox API reference (2026-10-16):**
- `TeleportService:ReserveServer` is **deprecated**; this uses `ReserveServerAsync`, which
  returns `(accessCode, privateServerId)`.
- `TeleportInitFailed(player, teleportResult, errorMessage, placeId, teleportOptions)`
  fires once per player when a teleport fails and the player stays. The `teleportOptions`
  it hands back are ready to retry with: same destination, same reserved server.
- `SetTeleportGui` must be called **on the client**, before the server teleports.
  Teleports and `GetArrivingTeleportGui` **don't work in Studio playtests**.
- `MemoryStoreHashMap:SetAsync(key, value, expiration)`: expiration in seconds, at most 45
  days. `GetAsync` returns `nil` for a missing key.

## Steps
1. **Build the place pieces** with the setup script (§1) in the Edit datamodel. It's
   idempotent and only creates what's missing.
   - Then `screen_capture` the hub (Map.Hub sits at X ≈ −2000, so it doesn't overlap
     Map.Run in the editor).
   - **Let the developer review and adjust the look by hand** before scripting. It's a
     greybox in the Falcon-8's navy and gold ([[Art Direction]]).
2. **Add the Constants and Types** (§2).
3. **Replace `ModeService`** with §3. Compare it with the live script first; the M0
   version is in [[M0 Bootstrap Code]] §3.
4. **Create the new modules:**
   - `Server.Services.TravelService` (§4) and `Server.Services.QueuePadService` (§5),
   - `Client.Controllers.QueuePadController`, `TeleportController` and
     `HubHudController` (§6).
5. **Make the integration edits** (§7). `script_read` each script first.
6. **Verify** (§8): in Studio with `ForceMode = "Hub"` and then `"Run"`, then real
   teleports in a published test place. Write the system notes, tick Session 12 in
   [[Loop (M2)]], amend [[0007-networking-and-remotes]] with `RequestReturnToHub`, and
   remind the developer to save.

### §1 Setup script (Edit datamodel, idempotent)
Builds the greybox Falcon-8, the pods, the queue pads, the remotes and the GUIs. It never
changes something that already exists, so hand edits survive re-runs.
```lua
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local NAVY = Color3.fromHex("#1F2A44")
local GOLD = Color3.fromHex("#F2C14E")
local CREAM = Color3.fromHex("#FFF4DC")
local TITLE_FONT = Font.fromEnum(Enum.Font.LuckiestGuy)
local BODY_FONT = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
local ORIGIN = Vector3.new(-2000, 0, 0) -- hub world origin; keeps it clear of Map.Run in the editor
local CAR_LENGTH = 60
local DECK_TOP = 3 -- deck top Y, the same as the run trains, so the side-on camera height fits

local created = 0
-- Returns the existing child untouched, or creates it with props. Second value: was it created?
local function ensure(parent: Instance, className: string, name: string, props: { [string]: any }?): (Instance, boolean)
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing, false
	end
	local inst = Instance.new(className)
	inst.Name = name
	for key, value in props or {} do
		(inst :: any)[key] = value
	end
	inst.Parent = parent
	created += 1
	print("Created", inst:GetFullName())
	return inst, true
end
local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, props: { [string]: any }?): BasePart
	local base: { [string]: any } = {
		Anchored = true, Size = size, Position = position, Color = color,
		Material = Enum.Material.SmoothPlastic, TopSurface = Enum.SurfaceType.Smooth,
	}
	for key, value in props or {} do
		base[key] = value
	end
	return (ensure(parent, "Part", name, base)) :: BasePart
end
local function label(parent: Instance, name: string, text: string, size: UDim2, position: UDim2, font: Font): TextLabel
	return (ensure(parent, "TextLabel", name, {
		Text = text, Size = size, Position = position, BackgroundTransparency = 1,
		FontFace = font, TextScaled = true, TextColor3 = CREAM,
	})) :: TextLabel
end
local function sign(adornee: BasePart, name: string, text: string)
	-- Camera looks along -Z, so the visible face is +Z (NormalId.Back).
	local gui = (ensure(adornee, "SurfaceGui", name, { Face = Enum.NormalId.Back, SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud, PixelsPerStud = 40 }))
	label(gui, "Label", text, UDim2.fromScale(0.9, 0.3), UDim2.fromScale(0.05, 0.1), TITLE_FONT)
end

-- Remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes")
ensure(remotes, "RemoteEvent", "RequestLeavePad")
ensure(remotes, "RemoteEvent", "RequestReturnToHub")

-- Map.Hub
local map = workspace:WaitForChild("Map")
local hub = (ensure(map, "Folder", "Hub"))
local train = (ensure(hub, "Model", "Falcon8"))
local cars = { "SpawnCar", "BarracksCar", "PodsCar", "BoardingCar" }
for i, carName in cars do
	local car, newCar = ensure(train, "Model", carName)
	local x = ORIGIN.X + (i - 1) * CAR_LENGTH
	local deck = part(car, "Deck", Vector3.new(CAR_LENGTH, 1, 12), Vector3.new(x, DECK_TOP - 0.5, 0), NAVY)
	part(car, "Trim", Vector3.new(CAR_LENGTH, 0.4, 0.4), Vector3.new(x, DECK_TOP + 0.2, 6), GOLD, { CanCollide = false })
	part(car, "Body", Vector3.new(CAR_LENGTH - 2, 8, 2), Vector3.new(x, DECK_TOP - 5, -4), NAVY, { CanCollide = false })
	if newCar then
		CollectionService:AddTag(deck, "WalkSurface")
		;(car :: Model).PrimaryPart = deck
	end
end
part(hub, "HubSpawn", Vector3.new(4, 1, 4), Vector3.new(ORIGIN.X - 20, DECK_TOP + 0.5, 0), GOLD,
	{ Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false })

-- Pods: a backdrop behind the walkway (Z < 0), like the checkpoint train's.
local pods = (ensure(hub, "Folder", "Pods"))
local podSpecs = {
	{ name = "BarracksPod", text = "BARRACKS · CHANGE SQUAD", x = 1 * CAR_LENGTH },
	{ name = "ArmoryPod", text = "ARMORY · COMING SOON", x = 2 * CAR_LENGTH - 18 },
	{ name = "SurplusPod", text = "SURPLUS SHOP · COMING SOON", x = 2 * CAR_LENGTH },
	{ name = "MissionsPod", text = "MISSIONS · COMING SOON", x = 2 * CAR_LENGTH + 18 },
}
for _, spec in podSpecs do
	local pod = part(pods, spec.name, Vector3.new(14, 10, 6), Vector3.new(ORIGIN.X + spec.x, DECK_TOP + 5, -9), NAVY,
		{ CanCollide = false })
	sign(pod, "Sign", spec.text)
end

-- Queue pads on the boarding car: 4 squad pads, then the solo pad at the far end.
local padsFolder = (ensure(hub, "Folder", "QueuePads"))
local padSpecs = {
	{ name = "SquadPad1", title = "SQUAD", capacity = 4, countdown = 15, full = 3 },
	{ name = "SquadPad2", title = "SQUAD", capacity = 4, countdown = 15, full = 3 },
	{ name = "SquadPad3", title = "SQUAD", capacity = 4, countdown = 15, full = 3 },
	{ name = "SquadPad4", title = "SQUAD", capacity = 4, countdown = 15, full = 3 },
	{ name = "SoloPad", title = "SOLO", capacity = 1, countdown = 5, full = 5 },
}
local boardingStart = ORIGIN.X + 3 * CAR_LENGTH - CAR_LENGTH / 2 + 6
for i, spec in padSpecs do
	local x = boardingStart + (i - 1) * 11
	local padInstance, newPad = ensure(padsFolder, "Model", spec.name)
	local pad = padInstance :: Model
	local base = part(pad, "Base", Vector3.new(8, 0.3, 10), Vector3.new(x, DECK_TOP + 0.15, 0), GOLD, { CanCollide = false })
	part(pad, "Light", Vector3.new(8, 0.2, 0.4), Vector3.new(x, DECK_TOP + 0.4, 5), CREAM,
		{ Material = Enum.Material.Neon, CanCollide = false })
	part(pad, "Zone", Vector3.new(8, 8, 6), Vector3.new(x, DECK_TOP + 4, 0), GOLD,
		{ Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false })
	part(pad, "Exit", Vector3.new(1, 1, 1), Vector3.new(x - 6, DECK_TOP + 0.5, 0), GOLD,
		{ Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false })
	local post = part(pad, "SignPost", Vector3.new(0.5, 6, 0.5), Vector3.new(x, DECK_TOP + 3, -3), NAVY, { CanCollide = false })
	local billboard = (ensure(post, "BillboardGui", "Sign", {
		Size = UDim2.fromScale(6, 3), StudsOffset = Vector3.new(0, 4.5, 0), AlwaysOnTop = false, LightInfluence = 0,
	}))
	label(billboard, "PadName", spec.title, UDim2.fromScale(1, 0.34), UDim2.fromScale(0, 0), TITLE_FONT)
	label(billboard, "CountLabel", `0/{spec.capacity}`, UDim2.fromScale(1, 0.33), UDim2.fromScale(0, 0.34), BODY_FONT)
	label(billboard, "TimerLabel", "STEP ON", UDim2.fromScale(1, 0.33), UDim2.fromScale(0, 0.67), BODY_FONT)
	if newPad then
		pad.PrimaryPart = base
		CollectionService:AddTag(pad, "QueuePad")
	end
	local defaults: { [string]: any } = {
		Capacity = spec.capacity,
		Countdown = spec.countdown,
		FullCountdown = spec.full,
		Mode = "Run",
		ActiveColor = GOLD, -- light colour when YOU are on it
		BusyColor = Color3.fromHex("#FF9F1C"), -- someone else is on it
	}
	for attribute, value in defaults do
		if pad:GetAttribute(attribute) == nil then
			pad:SetAttribute(attribute, value)
		end
	end
end

-- GUIs (ResetOnSpawn = false on all; the controllers hold on to them)
local function screen(name: string, props: { [string]: any }): ScreenGui
	local defaults = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }
	for k, v in props do defaults[k] = v end
	return (ensure(StarterGui, "ScreenGui", name, defaults)) :: ScreenGui
end
local function frame(parent: Instance, name: string, size: UDim2, position: UDim2, props: { [string]: any }?): Frame
	local base: { [string]: any } = { Size = size, Position = position, BackgroundColor3 = NAVY, BorderSizePixel = 0 }
	for k, v in props or {} do base[k] = v end
	local f = (ensure(parent, "Frame", name, base)) :: Frame
	ensure(f, "UICorner", "UICorner", { CornerRadius = UDim.new(0.15, 0) })
	ensure(f, "UIStroke", "UIStroke", { Color = GOLD, Thickness = 2 })
	return f
end

local queue = screen("QueueGui", { Enabled = true })
local panel = frame(queue, "Panel", UDim2.fromScale(0.3, 0.14), UDim2.fromScale(0.35, 0.8), { Visible = false })
ensure(panel, "UIAspectRatioConstraint", "UIAspectRatioConstraint", { AspectRatio = 3.2 })
label(panel, "Title", "BOARDING… 15", UDim2.fromScale(0.6, 0.5), UDim2.fromScale(0.05, 0.08), TITLE_FONT)
label(panel, "Count", "1/4 AGENTS", UDim2.fromScale(0.6, 0.32), UDim2.fromScale(0.05, 0.6), BODY_FONT)
local leave = (ensure(panel, "TextButton", "LeaveButton", {
	Text = "LEAVE", Size = UDim2.fromScale(0.28, 0.7), Position = UDim2.fromScale(0.68, 0.15),
	BackgroundColor3 = GOLD, TextColor3 = NAVY, FontFace = TITLE_FONT, TextScaled = true,
}))
ensure(leave, "UICorner", "UICorner", { CornerRadius = UDim.new(0.2, 0) })
ensure(leave, "UISizeConstraint", "UISizeConstraint", { MinSize = Vector2.new(56, 56) })

local teleportGui = screen("TeleportGui", { Enabled = false, DisplayOrder = 100, IgnoreGuiInset = true })
local backdrop = (ensure(teleportGui, "Frame", "Backdrop", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = NAVY, BorderSizePixel = 0 }))
label(backdrop, "Title", "ALL ABOARD!", UDim2.fromScale(0.6, 0.15), UDim2.fromScale(0.2, 0.38), TITLE_FONT)
label(backdrop, "Hint", "THE FALCON-8 IS ON ITS WAY", UDim2.fromScale(0.5, 0.06), UDim2.fromScale(0.25, 0.55), BODY_FONT)

local hubHud = screen("HubHudGui", { Enabled = false })
local coins = frame(hubHud, "CoinPanel", UDim2.fromScale(0.14, 0.07), UDim2.fromScale(0.84, 0.03))
ensure(coins, "UIAspectRatioConstraint", "UIAspectRatioConstraint", { AspectRatio = 3 })
label(coins, "Label", "0", UDim2.fromScale(0.9, 0.8), UDim2.fromScale(0.05, 0.1), TITLE_FONT)

-- RunEndGui: BACK TO HUB replaces PLAY AGAIN (styled by cloning the existing button and label).
local runEnd = StarterGui:FindFirstChild("RunEndGui")
local runPanel = runEnd and runEnd:FindFirstChild("Panel")
if runPanel then
	local playAgain = runPanel:FindFirstChild("PlayAgainButton")
	if playAgain and not runPanel:FindFirstChild("BackToHubButton") then
		local back = playAgain:Clone()
		back.Name = "BackToHubButton"
		;(back :: TextButton).Text = "BACK TO HUB"
		back.Parent = runPanel
		;(playAgain :: GuiObject).Visible = false
		created += 1
		print("Created RunEndGui.Panel.BackToHubButton; hid PlayAgainButton")
	end
	local waiting = runPanel:FindFirstChild("WaitingLabel")
	if waiting and not runPanel:FindFirstChild("ReturnLabel") then
		local returnLabel = waiting:Clone()
		returnLabel.Name = "ReturnLabel"
		;(returnLabel :: TextLabel).Text = "BACK TO HUB IN 30s"
		returnLabel.Parent = runPanel
		created += 1
		print("Created RunEndGui.Panel.ReturnLabel (check its position by hand)")
	end
else
	warn("RunEndGui.Panel not found: add BackToHubButton and ReturnLabel by hand")
end

print(`Session 12 setup done: {created} instance(s) created`)
```

### §2 Constants and Types
Add to `ReplicatedStorage.Shared.Constants`:
```lua
	-- Hub, queue pads and travel (Session 12). First guesses.
	SERVER_RECORD_MAP = "ServerRecords", -- MemoryStore hash map, keyed by PrivateServerId
	SERVER_RECORD_TTL = 3600, -- seconds; a reserved server reads its record once, at start
	SERVER_RECORD_READ_ATTEMPTS = 5,
	TELEPORT_ATTEMPTS = 3,
	TELEPORT_RETRY_DELAY = 2, -- seconds, doubled on each retry
	QUEUE_CHECK_INTERVAL = 0.1, -- pad membership checks (10 Hz)
	QUEUE_LEAVE_BLOCK = 1.5, -- seconds after LEAVE before you can rejoin a pad
	TELEPORT_FLIGHT_TIMEOUT = 30, -- seconds; a teleport still unfinished after this counts as failed
	RETURN_TO_HUB_TIMEOUT = 30,
	RETURN_RETRY_INTERVAL = 10,
	RUN_ROSTER_TIMEOUT = 45, -- Run lobby: start with whoever arrived after this long
```
Add to `ReplicatedStorage.Shared.Types`:
```lua
-- The MemoryStore record a hub writes before teleporting a party into a reserved server (ADR 0004).
export type ServerRecord = {
	mode: Mode,
	partyUserIds: { number },
	createdAt: number, -- os.time()
}
```

### §3 `Server.Services.ModeService` (replaces the M0 version)
```lua
--!strict
-- Decides Hub vs Run mode (ADR 0004) and moves the unused map out of Workspace.
-- ForceMode only works in Studio. A reserved server reads its MemoryStore record; with no valid
-- record it becomes an "orphaned" Hub and TravelService sends its players to a public hub.
local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types") :: ModuleScript)
local Constants = require(Shared:WaitForChild("Constants") :: ModuleScript)

local ModeService = {}
local current: Types.Mode? = nil
local record: Types.ServerRecord? = nil

local function validRecord(value: any): Types.ServerRecord?
	if type(value) ~= "table" or (value.mode ~= "Run" and value.mode ~= "Hub") or type(value.partyUserIds) ~= "table" then
		return nil
	end
	local ids: { number } = {}
	for _, id in value.partyUserIds do
		if type(id) == "number" and id == math.floor(id) then
			table.insert(ids, id)
		end
	end
	return { mode = value.mode, partyUserIds = ids, createdAt = tonumber(value.createdAt) or 0 }
end

-- Yields (MemoryStore). Only the server bootstrap calls this, before any init().
local function readRecord(key: string): Types.ServerRecord?
	local map = MemoryStoreService:GetHashMap(Constants.SERVER_RECORD_MAP)
	local delaySeconds = 1
	for attempt = 1, Constants.SERVER_RECORD_READ_ATTEMPTS do
		local ok, value = pcall(function()
			return map:GetAsync(key)
		end)
		if ok then
			return validRecord(value)
		end
		warn(`[ModeService] record read failed ({attempt}): {value}`)
		task.wait(delaySeconds)
		delaySeconds *= 2
	end
	return nil
end

local function stowUnusedMap(mode: Types.Mode)
	local map = workspace:FindFirstChild("Map")
	local unused = map and map:FindFirstChild(if mode == "Hub" then "Run" else "Hub")
	if unused then
		local stowed = ServerStorage:FindFirstChild("StowedMap") or Instance.new("Folder")
		stowed.Name = "StowedMap"
		stowed.Parent = ServerStorage
		unused.Parent = stowed
	end
end

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
		record = readRecord(game.PrivateServerId)
		if record then
			resolved = record.mode
		else
			resolved = "Hub"
			workspace:SetAttribute("Orphaned", true)
			warn("[ModeService] reserved server with no record: players will be sent to a public hub")
		end
	else
		resolved = "Hub" -- public or free private (VIP) server
	end
	current = resolved
	workspace:SetAttribute("Mode", resolved) -- replicates to clients
	stowUnusedMap(resolved)
	return resolved
end

function ModeService.get(): Types.Mode
	return ModeService.resolve()
end

-- The reserved server's party (Run or party-Hub servers). nil = no roster (public hub, Studio).
function ModeService.roster(): { number }?
	ModeService.resolve()
	return if record then record.partyUserIds else nil
end

return ModeService
```

### §4 `Server.Services.TravelService` (ModuleScript, both modes)
```lua
--!strict
-- Travel between Hub and Run servers (ADR 0004).
--   Hub → Run: reserve a server, write its MemoryStore record, teleport the pad's party.
--   Run → Hub: the post-run BACK TO HUB return (a party goes to one reserved Hub server).
-- Also turns away players who aren't on a Run server's roster, and empties orphaned servers.
-- Teleport data is never used: the destination reads the roster from MemoryStore.
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants") :: ModuleScript)
local Types = require(Shared:WaitForChild("Types") :: ModuleScript)
local ModeService = require(script.Parent:WaitForChild("ModeService") :: ModuleScript)
local Guard = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("Guard") :: ModuleScript)

local TravelService = {}

type InFlight = { attempts: number, startedAt: number, onFailed: ((Player) -> ())? }
local inFlight: { [Player]: InFlight } = {}
local groupCallActive: { [Player]: true } = {} -- a group TeleportAsync is still being retried
local returning = false

local function retry(label: string, attempts: number, fn: () -> any): (boolean, any)
	local delaySeconds = Constants.TELEPORT_RETRY_DELAY
	for attempt = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		warn(`[TravelService] {label} failed ({attempt}/{attempts}): {result}`)
		if attempt < attempts then
			task.wait(delaySeconds)
			delaySeconds *= 2
		end
	end
	return false, nil
end

local function canTeleport(): boolean
	if RunService:IsStudio() then
		warn("[TravelService] teleports don't work in Studio playtests; use a published test place")
		return false
	end
	return true
end

local function present(players: { Player }): { Player }
	local list = {}
	for _, player in players do
		if player.Parent == Players then
			table.insert(list, player)
		end
	end
	return list
end

-- Reserves a server and writes its record. Returns the access code, or nil.
local function reserve(mode: Types.Mode, players: { Player }): string?
	local ok, reserved = retry("ReserveServerAsync", Constants.TELEPORT_ATTEMPTS, function()
		local accessCode, privateServerId = TeleportService:ReserveServerAsync(game.PlaceId)
		return { accessCode = accessCode, privateServerId = privateServerId }
	end)
	if not ok then
		return nil
	end
	local ids = {}
	for _, player in players do
		table.insert(ids, player.UserId)
	end
	local record: Types.ServerRecord = { mode = mode, partyUserIds = ids, createdAt = os.time() }
	local map = MemoryStoreService:GetHashMap(Constants.SERVER_RECORD_MAP)
	local written = retry("record SetAsync", Constants.TELEPORT_ATTEMPTS, function()
		return map:SetAsync(reserved.privateServerId, record, Constants.SERVER_RECORD_TTL)
	end)
	return if written then reserved.accessCode else nil
end

local function clearFlight(player: Player)
	inFlight[player] = nil
	if player.Parent == Players then
		player:SetAttribute("Teleporting", false)
	end
end

-- Starts a group teleport. False if it couldn't start (nobody moves; the caller recovers).
-- onFailed(player) runs for anyone whose teleport later fails for good (they stay here).
local function teleport(players: { Player }, options: TeleportOptions?, onFailed: ((Player) -> ())?): boolean
	players = present(players)
	if #players == 0 then
		return true
	end
	for _, player in players do
		inFlight[player] = { attempts = 1, startedAt = os.clock(), onFailed = onFailed }
		groupCallActive[player] = true
		player:SetAttribute("Teleporting", true)
	end
	local ok = retry("TeleportAsync", Constants.TELEPORT_ATTEMPTS, function()
		return TeleportService:TeleportAsync(game.PlaceId, players, options)
	end)
	for _, player in players do
		groupCallActive[player] = nil
		if not ok then
			clearFlight(player)
		end
	end
	return ok
end

-- A teleport that failed for good: clear it and tell the caller.
local function failFlight(player: Player)
	local entry = inFlight[player]
	local onFailed = entry and entry.onFailed
	clearFlight(player)
	if onFailed then
		onFailed(player)
	end
end

local function onTeleportInitFailed(player: Player, result: Enum.TeleportResult, message: string, _placeId: number, retryOptions: TeleportOptions)
	local entry = inFlight[player]
	if entry == nil or groupCallActive[player] then
		return -- not ours, or the group call's own retry loop is still handling it
	end
	warn(`[TravelService] teleport failed for {player.UserId}: {result.Name} {message}`)
	if entry.attempts >= Constants.TELEPORT_ATTEMPTS or result == Enum.TeleportResult.Unauthorized then
		failFlight(player)
		return
	end
	entry.attempts += 1
	-- retryOptions targets the same destination (the same reserved server for a party).
	task.delay(Constants.TELEPORT_RETRY_DELAY * entry.attempts, function()
		if inFlight[player] ~= entry or player.Parent ~= Players then
			return
		end
		local ok = pcall(function()
			TeleportService:TeleportAsync(game.PlaceId, { player }, retryOptions)
		end)
		if not ok then
			onTeleportInitFailed(player, Enum.TeleportResult.Failure, "retry call errored", 0, retryOptions)
		end
	end)
end

-- Hub → Run. Yields. False if the departure couldn't start at all.
function TravelService.sendToRun(players: { Player }, onFailed: (Player) -> ()): boolean
	if #players == 0 or not canTeleport() then
		return false
	end
	local accessCode = reserve("Run", players)
	if accessCode == nil then
		return false
	end
	local options = Instance.new("TeleportOptions")
	options.ReservedServerAccessCode = accessCode
	return teleport(players, options, onFailed)
end

-- → Hub. A group of 2+ goes to one reserved Hub-mode server; one player goes to a public hub.
-- If reserving fails, the group falls back to a public hub (they get home, maybe not together).
-- onFailed(player) runs for anyone whose teleport later fails for good.
function TravelService.sendToHub(players: { Player }, onFailed: ((Player) -> ())?): boolean
	players = present(players)
	if #players == 0 then
		return true
	end
	if not canTeleport() then
		return false
	end
	local options: TeleportOptions? = nil
	if #players >= 2 then
		local accessCode = reserve("Hub", players)
		if accessCode then
			local reserved = Instance.new("TeleportOptions")
			reserved.ReservedServerAccessCode = accessCode
			options = reserved
		end
	end
	return teleport(players, options, onFailed)
end

-- Run mode, entering Results. Everyone returns together once all have pressed BACK TO HUB or
-- RETURN_TO_HUB_TIMEOUT passes. onUnavailable runs when teleports can't work (Studio).
function TravelService.beginReturn(onUnavailable: () -> ())
	if returning then
		return
	end
	returning = true
	local returnAt = workspace:GetServerTimeNow() + Constants.RETURN_TO_HUB_TIMEOUT
	workspace:SetAttribute("ReturnAt", returnAt)
	for _, player in Players:GetPlayers() do
		player:SetAttribute("ReturnVote", false)
	end
	task.spawn(function()
		local nextTry = 0
		while returning do
			local now = workspace:GetServerTimeNow()
			local pending: { Player } = {}
			local allVoted = true
			for _, player in Players:GetPlayers() do
				if player:GetAttribute("Teleporting") ~= true then
					table.insert(pending, player)
					if player:GetAttribute("ReturnVote") ~= true then
						allVoted = false
					end
				end
			end
			if #pending > 0 and (allVoted or now >= returnAt) and now >= nextTry then
				nextTry = now + Constants.RETURN_RETRY_INTERVAL
				if not TravelService.sendToHub(pending) and not canTeleport() then
					TravelService.cancelReturn()
					onUnavailable()
					return
				end
			end
			task.wait(0.25)
		end
	end)
end

function TravelService.cancelReturn()
	returning = false
	workspace:SetAttribute("ReturnAt", nil)
	for _, player in Players:GetPlayers() do
		player:SetAttribute("ReturnVote", nil)
	end
end

local function sendAwayOrKick(player: Player, reason: string)
	local function kick(target: Player)
		target:Kick(reason)
	end
	if not TravelService.sendToHub({ player }, kick) then
		kick(player)
	end
end

local function onPlayerAdded(player: Player)
	if ModeService.get() == "Run" then
		local roster = ModeService.roster()
		if roster ~= nil and table.find(roster, player.UserId) == nil then
			warn(`[TravelService] {player.UserId} isn't on this run's roster`)
			sendAwayOrKick(player, "This run is private.")
		end
	elseif workspace:GetAttribute("Orphaned") == true then
		sendAwayOrKick(player, "This server isn't available. Please rejoin.")
	end
end

function TravelService.start()
	TeleportService.TeleportInitFailed:Connect(onTeleportInitFailed)
	Players.PlayerRemoving:Connect(function(player)
		inFlight[player] = nil
		groupCallActive[player] = nil
	end)
	-- Watchdog: a teleport that never completes and never reports failure counts as failed,
	-- so nobody stays frozen behind the ALL ABOARD screen.
	task.spawn(function()
		while true do
			task.wait(1)
			for player, entry in inFlight do
				if not groupCallActive[player] and os.clock() - entry.startedAt > Constants.TELEPORT_FLIGHT_TIMEOUT then
					warn(`[TravelService] teleport for {player.UserId} timed out`)
					failFlight(player)
				end
			end
		end
	end)
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	if ModeService.get() == "Run" then
		local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestReturnToHub")
		Guard.connect(remote, 1, 2, function(player: Player)
			if returning and player:GetAttribute("Teleporting") ~= true then
				player:SetAttribute("ReturnVote", true)
			end
		end)
	end
end

return TravelService
```

### §5 `Server.Services.QueuePadService` (ModuleScript, Hub mode)
```lua
--!strict
-- Queue pads ([[Queue Pads]]): membership by server-side zone checks at 10 Hz, the countdowns,
-- LEAVE (RequestLeavePad), and departure through TravelService. The client only displays.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants") :: ModuleScript)
local Types = require(Shared:WaitForChild("Types") :: ModuleScript)
local Guard = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("Guard") :: ModuleScript)
local TravelService = require(script.Parent:WaitForChild("TravelService") :: ModuleScript)

type Pad = {
	model: Model,
	zone: BasePart,
	exit: BasePart?,
	capacity: number,
	countdown: number,
	fullCountdown: number,
	members: { Player },
	departsAt: number, -- server time; 0 = idle
	departing: boolean, -- frozen: no joins or leaves
	launched: boolean, -- the teleport has started (the server is reserved)
}

local QueuePadService = {}
QueuePadService.Modes = { "Hub" } :: { Types.Mode }

local pads: { Pad } = {}
local padOf: { [Player]: Pad } = {}
local blockedUntil: { [Player]: number } = {}

local function now(): number
	return workspace:GetServerTimeNow()
end

local function numberAttribute(inst: Instance, name: string, default: number): number
	local value = inst:GetAttribute(name)
	return if typeof(value) == "number" and value == value and value > 0 then value else default
end

local function inZone(zone: BasePart, position: Vector3): boolean
	local p = zone.CFrame:PointToObjectSpace(position)
	local half = zone.Size / 2
	return math.abs(p.X) <= half.X and math.abs(p.Y) <= half.Y and math.abs(p.Z) <= half.Z
end

local function publish(pad: Pad)
	pad.model:SetAttribute("Count", #pad.members)
	pad.model:SetAttribute("DepartsAt", pad.departsAt)
	pad.model:SetAttribute("Departing", pad.departing)
end

local function setPad(player: Player, pad: Pad?)
	local old = padOf[player]
	if old == pad then
		return
	end
	if old then
		local index = table.find(old.members, player)
		if index then
			table.remove(old.members, index)
		end
		if #old.members == 0 and not old.departing then
			old.departsAt = 0
		end
		publish(old)
	end
	padOf[player] = pad
	if pad then
		table.insert(pad.members, player)
		local t = now()
		if pad.departsAt == 0 then
			pad.departsAt = t + pad.countdown
		end
		if #pad.members >= pad.capacity then
			pad.departsAt = math.min(pad.departsAt, t + pad.fullCountdown)
		end
		publish(pad)
	end
	if player.Parent == Players then
		player:SetAttribute("QueuePad", if pad then pad.model.Name else "")
	end
end

local function anyTeleporting(pad: Pad): boolean
	for _, member in pad.members do
		if member:GetAttribute("Teleporting") == true then
			return true
		end
	end
	return false
end

local function finishDeparture(pad: Pad)
	pad.departing = false
	pad.launched = false
	pad.departsAt = if #pad.members > 0 then now() + pad.countdown else 0
	publish(pad)
end

local function depart(pad: Pad)
	local party = {}
	for _, member in pad.members do
		if member:GetAttribute("Teleporting") ~= true then
			table.insert(party, member)
		end
	end
	-- Yields while the server is reserved. The pad stays frozen (departing) the whole time.
	local started = #party > 0 and TravelService.sendToRun(party, function(_player: Player)
		-- Their teleport failed for good. They're still on the pad; finishDeparture restarts it.
	end)
	if started then
		pad.launched = true -- tick() now waits for the members to leave or fail
	else
		pad.model:SetAttribute("Status", "COULDN'T DEPART")
		task.delay(3, function()
			pad.model:SetAttribute("Status", nil)
		end)
		finishDeparture(pad)
	end
end

local function tick()
	local t = now()
	for _, player in Players:GetPlayers() do
		local current = padOf[player]
		if player:GetAttribute("Teleporting") == true or (current and current.departing) then
			continue -- frozen while departing
		end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local found: Pad? = nil
		if root and t >= (blockedUntil[player] or 0) then
			if current and inZone(current.zone, root.Position) then
				found = current
			else
				for _, pad in pads do
					if not pad.departing and #pad.members < pad.capacity and inZone(pad.zone, root.Position) then
						found = pad
						break
					end
				end
			end
		end
		setPad(player, found)
	end
	for _, pad in pads do
		if pad.departing then
			-- TravelService's watchdog clears Teleporting within TELEPORT_FLIGHT_TIMEOUT.
			if pad.launched and not anyTeleporting(pad) then
				finishDeparture(pad)
			end
		elseif pad.departsAt > 0 and t >= pad.departsAt and #pad.members > 0 then
			pad.departing = true
			publish(pad)
			task.spawn(depart, pad)
		end
	end
end

local function onLeave(player: Player)
	local pad = padOf[player]
	if pad == nil or pad.departing then
		return
	end
	setPad(player, nil)
	blockedUntil[player] = now() + Constants.QUEUE_LEAVE_BLOCK
	local character = player.Character
	if character and pad.exit then
		-- Step them just off the pad, keeping their facing. Exit sits on the Z = 0 plane.
		character:PivotTo(CFrame.new(pad.exit.Position + Vector3.new(0, 3, 0)) * character:GetPivot().Rotation)
	end
end

function QueuePadService.init()
	for _, model in CollectionService:GetTagged("QueuePad") do
		if not model:IsA("Model") or not model:IsDescendantOf(workspace) then
			continue
		end
		local zone = model:FindFirstChild("Zone")
		if not (zone and zone:IsA("BasePart")) then
			warn(`[QueuePadService] {model:GetFullName()} has no Zone part`)
			continue
		end
		local exit = model:FindFirstChild("Exit")
		local capacity = math.floor(numberAttribute(model, "Capacity", 4))
		local pad: Pad = {
			model = model,
			zone = zone,
			exit = if exit and exit:IsA("BasePart") then exit else nil,
			capacity = capacity,
			countdown = numberAttribute(model, "Countdown", 15),
			fullCountdown = numberAttribute(model, "FullCountdown", 3),
			members = {},
			departsAt = 0,
			departing = false,
			launched = false,
		}
		table.insert(pads, pad)
		publish(pad)
	end
end

function QueuePadService.start()
	print(`[QueuePadService] {#pads} pad(s)`)
	Guard.connect(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestLeavePad"), 2, 2, onLeave)
	Players.PlayerRemoving:Connect(function(player)
		setPad(player, nil)
		blockedUntil[player] = nil
	end)
	while true do
		tick()
		task.wait(Constants.QUEUE_CHECK_INTERVAL)
	end
end

return QueuePadService
```

### §6 Client controllers
**`Client.Controllers.QueuePadController`** (Hub)
```lua
--!strict
-- Pad signs, pad lights and your QueueGui panel. Display only: the server decides membership.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types") :: ModuleScript)

local player = Players.LocalPlayer

type PadView = { model: Model, count: TextLabel?, timer: TextLabel?, light: BasePart?, idleColor: Color3 }

local QueuePadController = {}
QueuePadController.Modes = { "Hub" } :: { Types.Mode }

local function secondsLeft(departsAt: any): number
	return if typeof(departsAt) == "number" and departsAt > 0
		then math.max(0, math.ceil(departsAt - workspace:GetServerTimeNow()))
		else 0
end

function QueuePadController.start()
	local views: { PadView } = {}
	for _, model in CollectionService:GetTagged("QueuePad") do
		if model:IsA("Model") and model:IsDescendantOf(workspace) then
			local sign = model:FindFirstChild("Sign", true)
			local light = model:FindFirstChild("Light")
			local lightPart = if light and light:IsA("BasePart") then light else nil
			table.insert(views, {
				model = model,
				count = if sign then sign:FindFirstChild("CountLabel") :: TextLabel? else nil,
				timer = if sign then sign:FindFirstChild("TimerLabel") :: TextLabel? else nil,
				light = lightPart,
				idleColor = if lightPart then lightPart.Color else Color3.new(1, 1, 1),
			})
		end
	end

	local gui = player:WaitForChild("PlayerGui"):WaitForChild("QueueGui") :: ScreenGui
	local panel = gui:WaitForChild("Panel") :: Frame
	local title = panel:WaitForChild("Title") :: TextLabel
	local countLabel = panel:WaitForChild("Count") :: TextLabel
	local leave = panel:WaitForChild("LeaveButton") :: TextButton
	local requestLeave = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestLeavePad") :: RemoteEvent
	leave.Activated:Connect(function()
		requestLeave:FireServer()
	end)

	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.1 then
			return
		end
		elapsed = 0
		local myPad = player:GetAttribute("QueuePad")
		local mine: PadView? = nil
		for _, view in views do
			local m = view.model
			local count = m:GetAttribute("Count") or 0
			local capacity = m:GetAttribute("Capacity") or 0
			local departing = m:GetAttribute("Departing") == true
			local status = m:GetAttribute("Status")
			local left = secondsLeft(m:GetAttribute("DepartsAt"))
			if view.count then
				view.count.Text = `{count}/{capacity}`
			end
			if view.timer then
				view.timer.Text = if typeof(status) == "string" then status
					elseif departing then "ALL ABOARD!"
					elseif left > 0 then `{left}s`
					else "STEP ON"
			end
			if view.light then
				local active = m:GetAttribute("ActiveColor")
				local busy = m:GetAttribute("BusyColor")
				view.light.Color = if m.Name == myPad and typeof(active) == "Color3" then active
					elseif (count :: number) > 0 and typeof(busy) == "Color3" then busy
					else view.idleColor
			end
			if m.Name == myPad then
				mine = view
			end
		end
		panel.Visible = mine ~= nil
		if mine then
			local m = mine.model
			local left = secondsLeft(m:GetAttribute("DepartsAt"))
			title.Text = if m:GetAttribute("Departing") == true then "ALL ABOARD!" else `BOARDING… {left}`
			countLabel.Text = `{m:GetAttribute("Count") or 0}/{m:GetAttribute("Capacity") or 0} AGENTS`
			leave.Visible = m:GetAttribute("Departing") ~= true
		end
	end)
end

return QueuePadController
```

**`Client.Controllers.TeleportController`** (both modes)
```lua
--!strict
-- The teleport/loading screen: shown while you're being teleported and, after arriving, until
-- your saved data has loaded (the profile may still be moving from the previous server).
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local TeleportController = {}
-- Needs Session 7: until PlayerDataService sets DataLoaded, this screen stays up.

function TeleportController.start()
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("TeleportGui") :: ScreenGui
	local title = gui:WaitForChild("Backdrop"):WaitForChild("Title") :: TextLabel
	-- SetTeleportGui must be called on the client before each teleport, and it doesn't persist
	-- across teleports. Hand it an enabled copy so the carried screen is visible.
	local function armTeleportGui()
		local carried = gui:Clone()
		carried.Enabled = true
		local carriedTitle = carried:FindFirstChild("Title", true)
		if carriedTitle and carriedTitle:IsA("TextLabel") then
			carriedTitle.Text = "ALL ABOARD!"
		end
		TeleportService:SetTeleportGui(carried)
	end
	armTeleportGui()
	local wasTeleporting = false
	local function refresh()
		local teleporting = player:GetAttribute("Teleporting") == true
		if wasTeleporting and not teleporting then
			armTeleportGui() -- a teleport failed: re-arm for the retry
		end
		wasTeleporting = teleporting
		gui.Enabled = teleporting or player:GetAttribute("DataLoaded") ~= true
		title.Text = if teleporting then "ALL ABOARD!" else "LOADING…"
	end
	player:GetAttributeChangedSignal("Teleporting"):Connect(refresh)
	player:GetAttributeChangedSignal("DataLoaded"):Connect(refresh)
	refresh()
end

return TeleportController
```

**`Client.Controllers.HubHudController`** (Hub)
```lua
--!strict
-- The hub HUD: the saved coin balance. Hides the run HUD in the hub.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types") :: ModuleScript)

local player = Players.LocalPlayer
local HubHudController = {}
HubHudController.Modes = { "Hub" } :: { Types.Mode }

function HubHudController.start()
	local playerGui = player:WaitForChild("PlayerGui")
	local runHud = playerGui:WaitForChild("HudGui", 5)
	if runHud and runHud:IsA("ScreenGui") then
		runHud.Enabled = false
	end
	local gui = playerGui:WaitForChild("HubHudGui") :: ScreenGui
	local coins = gui:WaitForChild("CoinPanel"):WaitForChild("Label") :: TextLabel
	gui.Enabled = true
	local function refresh()
		coins.Text = tostring(player:GetAttribute("Coins") or 0)
	end
	player:GetAttributeChangedSignal("Coins"):Connect(refresh)
	refresh()
end

return HubHudController
```

### §7 Integration edits (adapt to the scripts as they are)
`script_read` each one first. These describe the call sites from the system notes, not the
live code.
- **Hub movement reuses the run systems.** Make these run in both modes (remove `Modes`
  or set `{ "Hub", "Run" }`):
  - **[[CharacterService]]:**
    - spawn at `Map.Hub.HubSpawn` in Hub mode, and `Map.Run.Staging.StagingSpawn` in Run,
    - in Hub, skip the weapon equip (CombatService doesn't run there) and the Health
      setup,
    - the plane lock and gap-fall recovery work as they are (the decks are tagged
      `WalkSurface`).
  - **[[InputController]] and [[CameraController]]:** in Hub mode, don't send `SetInput`
    or `RequestSpin`. They have no server handler there. Movement and jumping stay.
  - **TouchControlsController** ([[HudController]]): hide `ShootButton` in Hub mode.
  - **[[AgentService]] and SquadController:**
    - run in both modes, so the Barracks works in the hub,
    - `EquipSquad` is also allowed when `ModeService.get() == "Hub"`,
    - SquadController looks for the `BarracksPod` in `Map.Hub.Pods` in Hub mode, and keeps
      using the checkpoint train's in Run,
    - `RequestSwap`, the first-checkpoint grant and the tutorial hint stay Run-only.
- **[[RunStateService]] (Run):**
  - **The lobby**, when `ModeService.roster()` isn't nil (a real run server):
    - there's no READY button,
    - start the 5 s countdown once every roster player present has `DataLoaded`, and at
      least one player has arrived, or after `RUN_ROSTER_TIMEOUT` (45 s) with whoever is
      there,
    - **co-op scaling uses the roster size** at that moment,
    - with no roster (Studio `ForceMode = "Run"`), keep the READY flow as it is.
  - **Results:**
    - call `TravelService.beginReturn(playAgainReset)`, where `playAgainReset` is the
      existing PLAY AGAIN reset. It only runs in Studio, where teleports can't work, so
      repeated testing still works there,
    - stop treating `RequestReady` in `Results` as PLAY AGAIN,
    - call `TravelService.cancelReturn()` inside that reset.
- **RunEndController** ([[HudController]]):
  - `BackToHubButton.Activated` fires `RequestReturnToHub`, then shows "WAITING…" while
    your `ReturnVote` is true,
  - `ReturnLabel` shows "BACK TO HUB IN {n}s" from the workspace attribute `ReturnAt`,
  - `PlayAgainButton` stays hidden (the setup script hid it).
- **HudController:** Run-only, if it isn't already. HubHudController also disables
  `HudGui` in the hub.
- **PlayerDataService ([[Session 7 PlayerDataService Code]]): no change.** It runs in both modes. The hub's
  `PlayerRemoving` releases the profile as the player teleports, and the run server's
  session start waits for that release.

## §8 Verify
1. **Hub in Studio** (`ForceMode = "Hub"`). The console shows
   `[Server] Hub mode, … service(s)` and `[QueuePadService] 5 pad(s)`. Then:
   - **Maps:** `Map.Run` moves to `ServerStorage.StowedMap`.
   - **Spawn:** you appear at `HubSpawn`, side-on, and can walk the whole Falcon-8.
   - **Barracks:** the prompt shows at the `BarracksPod`, and `EquipSquad` saves the squad.
   - **HUD:** HubHudGui shows the coin balance, and HudGui is hidden.
   - **Pads:** step on a squad pad. Its sign reads "1/4 · 15s", the light turns
     `ActiveColor`, and QueueGui shows "BOARDING… n". Step off: the panel goes, and an
     empty pad resets to "STEP ON". LEAVE moves you to `Exit`, and you can't rejoin for
     1.5 s.
   - **Departure:** at 0 the pad shows "ALL ABOARD!", then "COULDN'T DEPART". Studio
     can't teleport (the console warns), and the countdown restarts while you stand there.
   - **Solo pad:** it departs after 5 s.
   - **Multi-player:** with Studio's 2-player local server, check that both players count
     on one pad, a full pad drops to 3 s, and a third player can't join a full pad.
2. **Run in Studio** (`ForceMode = "Run"`):
   - there's no roster, so the READY lobby works as before,
   - at run end, the results show BACK TO HUB and the 30 s countdown,
   - pressing it (or waiting) can't teleport in Studio, so it falls back to the PLAY
     AGAIN reset,
   - the console warns once, with no errors.
3. **Published test place** (Session 13 setup: a second private experience,
   "Train Mayhem (test)", [[Studio Setup Checklist]]):
   - two accounts on a squad pad depart together into one Run server,
   - the run server logs its roster, and a third account that isn't on it is sent away,
   - coins carry over (Session 7),
   - BACK TO HUB brings both to the same reserved hub,
   - a solo run returns to a public hub.
   - Also check **whether a group teleport with no options lands in one public server**.
     It's used as the fallback when reserving fails.

## Choices made in this draft (review them)
- **Pads are in a row on the boarding car, with the solo pad last.** Walking to a far pad
  passes over nearer ones and joins them for a moment. That's harmless: an empty pad
  resets, and a full pad can't be joined. Move them onto a siding by hand if it feels
  odd.
- **The solo pad departs 5 s after you step on** (`Countdown` and `FullCountdown` 5). The
  squad pads use 15 s, dropping to 3 s when full.
- **A party returning together goes to a reserved Hub server.** Friends outside the party
  can't follow them in through Roblox's "Join". Leaving and rejoining puts a player in a
  public hub.
- **Players not on a run's roster are sent to a public hub** (kicked if that fails), as
  "mid-run join: no" requires.
- **A reserved server with no MemoryStore record becomes an "orphaned" hub** that sends
  everyone to a public hub. That's ADR 0004's "teleport back to the hub".
- **A player whose teleport fails for good goes back onto the pad.** The next departure
  reserves a new server, so they can end up split from a party that already left.
  Retrying with the party's access code would keep them together; that's a later
  improvement.
- **Reviewed 2026-10-16** by a read-only code review against the Roblox API docs. Fixed:
  - a pad unfreezing while its server was still being reserved, which could depart twice,
  - players stuck as `Teleporting` forever, with a 30 s flight watchdog,
  - an off-roster player staying when their redirect failed (now kicked),
  - overlapping group and single retries,
  - the teleport screen not carrying over (`SetTeleportGui` now gets an enabled copy,
    re-armed after a failure),
  - HudGui staying on in the hub,
  - setup re-runs overwriting hand-tuned pad attributes.

  The pads are read once at start. That's fine because `StreamingEnabled` is off (M0); turning
  streaming on would need `GetInstanceAddedSignal("QueuePad")`.
- **Pad lights use the pad's `ActiveColor`.** The spec says "your player colour". If the
  place already has a per-player colour attribute, swap it in.

Related: [[Loop (M2)]] · [[Queue Pads]] · [[0004-single-place-hub-and-run-modes]] · [[0007-networking-and-remotes]] · [[Session 7 PlayerDataService Code]] · [[Techniques]]
