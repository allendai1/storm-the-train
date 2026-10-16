---
tags: [technique, code, background, parallax, plugin, studio-tooling]
status: implemented
updated: 2026-10-16
---
# Background Kit Code

> **Status: implemented. Installed in Studio on 2026-10-16** (local session; the Studio
> scripts are the source of truth from here on). Differences from the drafts below:
> - `Shared.BackgroundKit` and ParallaxController use `WaitForChild` for `Shared` modules.
> - **Plugin additions:**
>   - a row of buttons listing the existing themes (click one to pick it),
>   - **Rename** (renames the picked theme to the name in the box),
>   - **Delete** (a second click confirms; re-parents to nil, so Ctrl+Z undoes it),
>   - a **Train** section (Edit train, Check train, Train done) that opens
>     `ServerStorage.Assets.Carriages.WildWest` and `Trains.HubCheckpoint` in
>     `Workspace.TrainStudio` at `TrainStart`, in the carriages folder's `Layout` order,
>     with ghosts for repeated templates. Add selection refuses parts of the open train.
> - BackgroundStudioService also restores carriage templates left open in `TrainStudio`.
> - Studio places a docked widget as a tab next to Explorer/Properties; look there if
>   clicking the button seems to do nothing.
> - The plugin only updates after **Save as Local Plugin** again.
>
> Originally drafted in a cloud session on 2026-10-16. Reviewed the same day by a read-only code review; its fixes are applied
> (below). It implements the [[Background Kit]] standard ([[0011-background-kit]],
> proposed). The Luau compiles; Roblox's own Script Analysis hasn't seen it. Before
> replacing [[ParallaxController]], **read the current script in Studio** and keep anything
> it does that this version doesn't.

## When to use
Setting up the Background Kit in a local Studio session (with the Studio MCP), then
whenever a theme's background layers are built or changed.

## Steps
1. **Save the place** first (the plugin moves and edits saved models).
2. `ReplicatedStorage.Shared.BackgroundKit`: create the ModuleScript (§1).
3. `StarterPlayer.StarterPlayerScripts.Client.Controllers.ParallaxController`: replace its
   source with §2, after comparing it with the current one.
4. `ServerScriptService.Server.Services.BackgroundStudioService`: create the ModuleScript
   (§3). It has no `Modes`, so it runs in every mode.
5. **The plugin:** create a Script `ServerStorage.Tools.BackgroundKitPlugin` (the
   `ServerStorage.Tools` folder keeps it versioned with the place without running it),
   paste §4, then right-click it → **Save as Local Plugin**. A **Train Mayhem → Background
   Kit** button appears in the Plugins tab.
6. Run the Wild West migration (§5) with `execute_luau` in the Edit datamodel. It only
   sets the `Slot` attributes; the existing copy counts are enough with the new controller.
7. Open the panel, type `WildWest`, press **Edit**, then **Validate**. Fix what it reports,
   set `Continuous = true` on the rails and the ground slab, press **Done**, save.
8. Verify (§6).

## §1 `ReplicatedStorage.Shared.BackgroundKit` (ModuleScript)
```lua
--!strict
-- The standard background layer slots, and the maths ParallaxController and the
-- Background Kit plugin share. Background Kit (vault: 01 Design/Background Kit).
local Constants = require(script.Parent.Constants)

local BackgroundKit = {}

export type SlotSpec = {
	name: string,
	zNear: number, -- the band's edge nearest the camera (world Z; the play plane is PLANE_Z)
	zFar: number, -- the band's far edge
	tileLength: number, -- the default for a new layer
	maxHeight: number?, -- content above this pokes out where it shouldn't (Track only)
	trianglesVisible: number, -- triangle budget for everything on screen in this slot
	colour: Color3, -- the plugin's guide colour
	use: string,
}

export type Variant = {
	template: Model,
	name: string,
	weight: number,
	every: number?, -- appears on every Nth tile instead of by chance (set-pieces)
	offset: number,
	rest: CFrame, -- the template's pivot; only X is replaced at runtime
}

export type LayerInfo = {
	model: Model,
	slot: string?,
	tileLength: number,
	tiles: number,
	random: { Variant },
	scheduled: { Variant },
	totalWeight: number,
	seed: number,
}

-- Z bands are relative to the play plane: positive Z is toward the camera.
BackgroundKit.SLOTS = {
	Foreground = { name = "Foreground", zNear = 24, zFar = 12, tileLength = 140, trianglesVisible = 1000,
		colour = Color3.fromRGB(74, 58, 46), use = "Rare, dark, simple shapes passing in front of the train" },
	Track = { name = "Track", zNear = 4, zFar = -4, tileLength = 30, maxHeight = 3, trianglesVisible = 2000,
		colour = Color3.fromRGB(90, 70, 50), use = "Ties, rails and ballast under the train" },
	Ground = { name = "Ground", zNear = 60, zFar = -640, tileLength = 200, trianglesVisible = 4000,
		colour = Color3.fromRGB(226, 193, 150), use = "The floor slab plus low scatter (rocks, tufts)" },
	Near = { name = "Near", zNear = -20, zFar = -120, tileLength = 120, trianglesVisible = 5000,
		colour = Color3.fromRGB(126, 148, 102), use = "Props you can read: cacti, fences, bushes, signs" },
	Mid = { name = "Mid", zNear = -140, zFar = -320, tileLength = 240, trianglesVisible = 3000,
		colour = Color3.fromRGB(184, 154, 122), use = "Big landmarks: towns, canyon walls, water towers" },
	Far = { name = "Far", zNear = -350, zFar = -600, tileLength = 500, trianglesVisible = 5000,
		colour = Color3.fromRGB(217, 162, 124), use = "The skyline: mesas, mountains, city silhouettes" },
} :: { [string]: SlotSpec }

BackgroundKit.SLOT_ORDER = { "Foreground", "Track", "Ground", "Near", "Mid", "Far" }

-- The widest screen we plan for (21:9). Wider screens put the camera closer, so far
-- layers show more and need more copies. Super-wide monitors (32:9) aren't covered; clamp
-- the camera's aspect in CameraController if they matter.
BackgroundKit.MAX_ASPECT = 2.4

function BackgroundKit.cameraDistance(aspect: number): number
	return (Constants.CAMERA_WIDTH_STUDS / 2) / (math.tan(math.rad(Constants.CAMERA_FOV / 2)) * aspect)
end

-- Half the width the camera sees at `depth` studs behind the play plane.
function BackgroundKit.halfVisibleWidth(depth: number, aspect: number?): number
	local d = BackgroundKit.cameraDistance(aspect or BackgroundKit.MAX_ASPECT)
	return math.max(0, (Constants.CAMERA_WIDTH_STUDS / 2) * (d + depth) / d)
end

-- The fewest copies that always cover the screen, for content down to `deepest`
-- studs behind the plane (negative for Foreground content in front of it).
-- ParallaxController centres its copies on the camera, which guarantees
-- (Tiles / 2 − 0.5) tile lengths of cover on each side; that has to reach the screen edge.
function BackgroundKit.minTiles(tileLength: number, deepest: number): number
	local half = BackgroundKit.halfVisibleWidth(deepest)
	return math.max(2, math.ceil(2 * half / tileLength + 1))
end

local function nameSeed(name: string): number
	local h = 17
	for i = 1, #name do
		h = (h * 31 + string.byte(name, i)) % 2147483647
	end
	return h
end

-- Reads a layer Model: `TileLength` and `Tiles` attributes, a `Tile` Model, and any
-- `Tile_<Name>` variants (`Weight`, or `Every` + `Offset` for set-pieces).
function BackgroundKit.readLayer(layer: Model): LayerInfo?
	local tileLength = layer:GetAttribute("TileLength")
	local tiles = layer:GetAttribute("Tiles")
	if type(tileLength) ~= "number" or tileLength <= 0 or type(tiles) ~= "number" or tiles < 1 then
		warn(`[BackgroundKit] {layer:GetFullName()} needs TileLength and Tiles attributes`)
		return nil
	end
	local random: { Variant } = {}
	local scheduled: { Variant } = {}
	local totalWeight = 0
	for _, child in layer:GetChildren() do
		if child:IsA("Model") and (child.Name == "Tile" or string.sub(child.Name, 1, 5) == "Tile_") then
			local every = child:GetAttribute("Every")
			local weight = child:GetAttribute("Weight")
			local offset = child:GetAttribute("Offset")
			local variant: Variant = {
				template = child,
				name = child.Name,
				weight = if type(weight) == "number" and weight > 0 then weight else 1,
				every = if type(every) == "number" and every >= 2 then math.floor(every) else nil,
				offset = if type(offset) == "number" then math.floor(offset) else 0,
				rest = child:GetPivot(),
			}
			if variant.every then
				table.insert(scheduled, variant)
			else
				table.insert(random, variant)
				totalWeight += variant.weight
			end
		end
	end
	if #random == 0 then
		warn(`[BackgroundKit] {layer:GetFullName()} needs a Tile`)
		return nil
	end
	-- Sorted so a given tile index always gets the same pick, whatever the child order.
	local byName = function(a: Variant, b: Variant): boolean
		return a.name < b.name
	end
	table.sort(random, byName)
	table.sort(scheduled, byName)
	local slot = layer:GetAttribute("Slot")
	return {
		model = layer,
		slot = if type(slot) == "string" then slot else nil,
		tileLength = tileLength,
		tiles = math.floor(tiles),
		random = random,
		scheduled = scheduled,
		totalWeight = totalWeight,
		seed = nameSeed(layer.Name),
	}
end

-- Which variant tile index `j` shows. It depends only on j, so a stretch of scenery
-- looks the same if the camera comes back to it. If two set-pieces land on the same j,
-- the first by name wins.
function BackgroundKit.pickVariant(info: LayerInfo, j: number): Variant
	for _, variant in info.scheduled do
		if (j - variant.offset) % (variant.every :: number) == 0 then
			return variant
		end
	end
	if #info.random == 1 then
		return info.random[1]
	end
	local roll = Random.new(info.seed * 7919 + j):NextNumber() * info.totalWeight
	for _, variant in info.random do
		roll -= variant.weight
		if roll <= 0 then
			return variant
		end
	end
	return info.random[#info.random]
end

return BackgroundKit
```

## §2 `Client.Controllers.ParallaxController` (ModuleScript, replaces the current one)
Changes from the built version, as the vault describes it:
- reads `Tile_<Name>` variants (`Weight`, `Every`, `Offset`) through `BackgroundKit`,
- keeps a **scroll distance that never wraps**, so tile index j always shows the same
  variant (the built one wraps the scroll by the tile length),
- **centres its copies on the camera** (the built one keeps more on the −X side, which
  can leave the +X screen edge short on wide phones),
- pools copies by variant, and parks unused ones with `Parent = nil`,
- moves every part in **one `BulkMoveTo` per frame** (offsets cached per copy), instead of
  a `PivotTo` per tile,
- ignores a theme load that a newer `Theme` change has overtaken,
- keeps each template's pivot Y, Z and rotation, and only sets X.
```lua
--!strict
-- Scrolls the theme's background layers past the static train, on this client only
-- (ADR 0009). Each layer recycles copies of its `Tile` (and any `Tile_<Name>` variants)
-- around the camera. Background Kit (vault: 01 Design/Background Kit).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Shared.Constants)
local BackgroundKit = require(ReplicatedStorage.Shared.BackgroundKit)

-- A clone with its parts and their offsets from the template's pivot, cached once so
-- every frame is a single BulkMoveTo.
type Copy = { model: Model, variant: BackgroundKit.Variant, parts: { BasePart }, offsets: { CFrame } }
type LayerState = {
	info: BackgroundKit.LayerInfo,
	active: { [number]: Copy },
	pools: { [Model]: { Copy } },
}

local ParallaxController = { Modes = { "Run" } }

local container: Folder? = nil
local layers: { LayerState } = {}
local loadId = 0
-- Total distance the world has scrolled. It never wraps, so tile index j always means
-- the same stretch of scenery and variant picks stay put.
local travel = 0
local moveParts: { BasePart } = {}
local moveCFrames: { CFrame } = {}

local function clear()
	if container then
		container:Destroy()
		container = nil
	end
	layers = {}
end

local function load(themeName: string?)
	loadId += 1
	local myLoad = loadId
	clear()
	if not themeName then
		return
	end
	local backgrounds = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Backgrounds")
	if myLoad ~= loadId then
		return -- the theme changed again while we waited
	end
	local theme = backgrounds:FindFirstChild(themeName)
	if not theme then
		warn(`[ParallaxController] no background set for theme {themeName}`)
		return
	end
	local folder = Instance.new("Folder")
	folder.Name = "Background"
	folder.Parent = Workspace
	container = folder
	for _, child in theme:GetChildren() do
		if child:IsA("Model") then
			local info = BackgroundKit.readLayer(child)
			if info then
				table.insert(layers, { info = info, active = {}, pools = {} })
			end
		end
	end
end

local function acquire(state: LayerState, variant: BackgroundKit.Variant): Copy
	local pool = state.pools[variant.template]
	if pool and #pool > 0 then
		local copy = table.remove(pool) :: Copy
		copy.model.Parent = container
		return copy
	end
	local model = variant.template:Clone()
	local parts: { BasePart } = {}
	local offsets: { CFrame } = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(parts, d)
			table.insert(offsets, variant.rest:ToObjectSpace(d.CFrame))
		end
	end
	model.Parent = container
	return { model = model, variant = variant, parts = parts, offsets = offsets }
end

local function release(state: LayerState, copy: Copy)
	copy.model.Parent = nil -- pooled copies don't render
	local pool = state.pools[copy.variant.template]
	if not pool then
		pool = {}
		state.pools[copy.variant.template] = pool
	end
	table.insert(pool, copy)
end

local function step(dt: number)
	travel += Constants.TRAIN_SPEED * dt
	local camera = Workspace.CurrentCamera
	if not camera or not container then
		return
	end
	local camX = camera.CFrame.Position.X
	table.clear(moveParts)
	table.clear(moveCFrames)
	for _, state in layers do
		local length, count = state.info.tileLength, state.info.tiles
		-- Centred on the camera: (count / 2 − 0.5) tiles of cover each side (BackgroundKit.minTiles).
		local first = math.floor((camX + travel) / length - count / 2 + 0.5)
		local last = first + count - 1
		for j, copy in state.active do
			if j < first or j > last then
				release(state, copy)
				state.active[j] = nil
			end
		end
		for j = first, last do
			local copy = state.active[j]
			if not copy then
				copy = acquire(state, BackgroundKit.pickVariant(state.info, j))
				state.active[j] = copy
			end
			local rest = copy.variant.rest
			local pivot = CFrame.new(j * length - travel, rest.Y, rest.Z) * rest.Rotation
			for i, part in copy.parts do
				table.insert(moveParts, part)
				table.insert(moveCFrames, pivot * copy.offsets[i])
			end
		end
	end
	if #moveParts > 0 then
		Workspace:BulkMoveTo(moveParts, moveCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function ParallaxController.init() end

function ParallaxController.start()
	local function reload()
		local theme = Workspace:GetAttribute("Theme")
		load(if type(theme) == "string" then theme else nil)
	end
	Workspace:GetAttributeChangedSignal("Theme"):Connect(reload)
	RunService:BindToRenderStep("Parallax", Enum.RenderPriority.Camera.Value + 1, step)
	reload()
end

return ParallaxController
```

## §3 `Server.Services.BackgroundStudioService` (ModuleScript)
```lua
--!strict
-- If the Background Kit plugin left a theme open for editing in Workspace.BackgroundStudio,
-- put it back where ParallaxController reads it and drop the editor guides. This only
-- changes the running server, never the saved place. Background Kit (vault: 01 Design/Background Kit).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BackgroundStudioService = {} -- no Modes: runs in every mode

function BackgroundStudioService.init()
	local studio = Workspace:FindFirstChild("BackgroundStudio")
	if not studio then
		return
	end
	local guides = studio:FindFirstChild("EditorGuides")
	if guides then
		guides:Destroy()
	end
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local backgrounds = assets and assets:FindFirstChild("Backgrounds")
	if not backgrounds then
		warn("[BackgroundStudioService] ReplicatedStorage.Assets.Backgrounds is missing")
		studio:Destroy()
		return
	end
	for _, theme in studio:GetChildren() do
		-- Only folders the plugin opened (it marks them), never other things kept there.
		if theme:IsA("Folder") and theme:GetAttribute("BackgroundKitTheme") == true then
			local existing = backgrounds:FindFirstChild(theme.Name)
			if existing then
				warn(`[BackgroundStudioService] two copies of theme {theme.Name}; using the one in BackgroundStudio`)
				existing:Destroy()
			end
			theme.Parent = backgrounds
			print(`[BackgroundStudioService] theme {theme.Name} was open in the Background Kit; moved it back for this session`)
		end
	end
	studio:Destroy()
end

return BackgroundStudioService
```

## §4 The Background Kit plugin (Script, saved as a Local Plugin)
The panel:
- **Theme:** a name box, **Edit** (opens the theme next to the train), **New theme**
  (the six standard layers, empty), **Done** (validates and puts it back).
- **View:** **Game camera** (the game's FOV and distance for the viewport's shape, at the
  train), **Free view** (FOV back to 70), **Refresh ghosts**.
- **Add selection to layer:** one button per slot.
- **Check:** **Validate**, **Fix part settings**, **Clear log**, and the log itself.

Every change is one undo step (Ctrl+Z); the plugin never calls `Destroy()`, so undo can
always put things back. It doesn't load in playtests. **Add selection** only takes whole
props from the Workspace: never templates, the map, tiles themselves, or a piece inside
another prop, and it logs anything it skips or moves. Guides
(ghosts, band plates, seam posts, variant labels) live in
`Workspace.BackgroundStudio.EditorGuides`, are locked, and are deleted by **Done**.
```lua
--!strict
-- Train Mayhem Background Kit: a Studio plugin for building each theme's background layers.
-- Install: put this Script somewhere that doesn't run (e.g. ServerStorage.Tools), then
-- right-click it → Save as Local Plugin. Reload it after editing Shared.BackgroundKit.
-- Its panel UI is built in code because it's Studio tooling, not game UI (the
-- hand-built GUI rule in CLAUDE.md is for the game's ScreenGuis).
-- Vault: 01 Design/Background Kit, 06 Techniques/Background Kit Code.
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local Workspace = game:GetService("Workspace")

if RunService:IsRunning() then
	return -- edit-time tool only; don't load in playtest DataModels
end

local STUDIO = "BackgroundStudio"
local OPEN_MARK = "BackgroundKitTheme" -- attribute on the theme folder while it's open here
local GUIDES = "EditorGuides"
local GHOST_SPAN = 260 -- studs of ghost copies right of the tile (the train is about 201)
local TOL = 0.05
local DEFAULT_NAMES = { Part = true, MeshPart = true, Model = true, Union = true, UnionOperation = true,
	WedgePart = true, CornerWedgePart = true, TrussPart = true }
local POST_HEIGHT = { Foreground = 30, Track = 3, Ground = 6, Near = 18, Mid = 40, Far = 90 }

------------------------------------------------------------------ shared modules
local function requireShared(name: string): any
	local shared = ReplicatedStorage:FindFirstChild("Shared")
	local module = shared and shared:FindFirstChild(name)
	if module and module:IsA("ModuleScript") then
		return require(module) :: any
	end
	return nil
end

------------------------------------------------------------------ output panel
local logLines: { string } = {}
local outputLabel: TextLabel? = nil
local statusLabel: TextLabel? = nil

local function escape(s: string): string
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local LEVEL_COLOUR = { ERROR = "#FF6B5B", WARN = "#F2B33D", OK = "#5BE38A", INFO = "#9AA4B1" }

local function log(level: string, text: string)
	table.insert(logLines, `<font color="{LEVEL_COLOUR[level] or "#9AA4B1"}"><b>{level}</b></font>  {escape(text)}`)
	while #logLines > 80 do
		table.remove(logLines, 1)
	end
	if outputLabel then
		outputLabel.Text = table.concat(logLines, "\n")
	end
	print(`[Background Kit] {level}: {text}`)
end

local function clearLog()
	table.clear(logLines)
	if outputLabel then
		outputLabel.Text = ""
	end
end

------------------------------------------------------------------ place helpers
local function backgrounds(): Instance?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	return assets and assets:FindFirstChild("Backgrounds")
end

local function studioFolder(create: boolean): Folder?
	local existing = Workspace:FindFirstChild(STUDIO)
	if existing and existing:IsA("Folder") then
		return existing
	end
	if not create then
		return nil
	end
	local folder = Instance.new("Folder")
	folder.Name = STUDIO
	folder.Parent = Workspace
	return folder
end

local function openTheme(): Folder?
	local studio = studioFolder(false)
	if not studio then
		return nil
	end
	for _, child in studio:GetChildren() do
		if child:IsA("Folder") and child:GetAttribute(OPEN_MARK) == true then
			return child
		end
	end
	return nil
end

-- The train's rear end. Tiles open with their left end here so you build next to the train.
local function trainOrigin(): Vector3
	local map = Workspace:FindFirstChild("Map")
	local run = map and map:FindFirstChild("Run")
	local start = run and run:FindFirstChild("TrainStart")
	if start and start:IsA("BasePart") then
		return start.Position
	end
	return Vector3.new(0, 3, 0)
end

local function planeZ(): number
	local constants = requireShared("Constants")
	return if constants and type(constants.PLANE_Z) == "number" then constants.PLANE_Z else 0
end

local function variantsOf(layer: Instance): { Model }
	local list: { Model } = {}
	local main = layer:FindFirstChild("Tile")
	if main and main:IsA("Model") then
		table.insert(list, main)
	end
	for _, child in layer:GetChildren() do
		if child:IsA("Model") and string.sub(child.Name, 1, 5) == "Tile_" then
			table.insert(list, child)
		end
	end
	return list
end

local function layersOf(theme: Instance, kit: any): { Model }
	local list: { Model } = {}
	for _, child in theme:GetChildren() do
		if child:IsA("Model") then
			table.insert(list, child)
		end
	end
	local order: { [string]: number } = {}
	for i, slot in kit.SLOT_ORDER do
		order[slot] = i
	end
	table.sort(list, function(a, b)
		local sa, sb = a:GetAttribute("Slot"), b:GetAttribute("Slot")
		local oa = if type(sa) == "string" and order[sa] then order[sa] else 99
		local ob = if type(sb) == "string" and order[sb] then order[sb] else 99
		return if oa == ob then a.Name < b.Name else oa < ob
	end)
	return list
end

local function layerForSlot(theme: Instance, slot: string): Model?
	for _, child in theme:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("Slot") == slot then
			return child
		end
	end
	return nil
end

local function boxOf(inst: Instance): (Vector3?, Vector3?)
	local cf: CFrame, size: Vector3
	if inst:IsA("BasePart") then
		cf, size = inst.CFrame, inst.Size
	elseif inst:IsA("Model") then
		local ok, c, s = pcall(function()
			return inst:GetBoundingBox()
		end)
		if not ok or (s :: Vector3).Magnitude == 0 then
			return nil, nil
		end
		cf, size = c :: CFrame, s :: Vector3
	else
		return nil, nil
	end
	local half = size / 2
	local r, u, b = cf.RightVector * half.X, cf.UpVector * half.Y, cf.LookVector * half.Z
	local e = Vector3.new(
		math.abs(r.X) + math.abs(u.X) + math.abs(b.X),
		math.abs(r.Y) + math.abs(u.Y) + math.abs(b.Y),
		math.abs(r.Z) + math.abs(u.Z) + math.abs(b.Z)
	)
	return cf.Position - e, cf.Position + e
end

local function partsIn(inst: Instance): { BasePart }
	local list: { BasePart } = {}
	if inst:IsA("BasePart") then
		table.insert(list, inst)
	end
	for _, d in inst:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(list, d)
		end
	end
	return list
end

-- The props in a tile: its parts and models, looking through any Folders.
local function propsIn(container: Instance): { PVInstance }
	local list: { PVInstance } = {}
	for _, child in container:GetChildren() do
		if child:IsA("PVInstance") then
			table.insert(list, child)
		elseif child:IsA("Folder") then
			for _, p in propsIn(child) do
				table.insert(list, p)
			end
		end
	end
	return list
end

local function isTileModel(inst: Instance): boolean
	return inst:IsA("Model") and (inst.Name == "Tile" or string.sub(inst.Name, 1, 5) == "Tile_")
end

-- The tile a prop sits in directly (through Folders), if any.
local function tileOf(inst: Instance): Instance?
	local parent = inst.Parent
	while parent and parent:IsA("Folder") and parent:GetAttribute(OPEN_MARK) ~= true do
		parent = parent.Parent
	end
	if parent and isTileModel(parent) then
		return parent
	end
	return nil
end

-- The background rules: anchored, never collides or blocks raycasts, no shadows.
local function applyRules(inst: Instance): number
	local changed = 0
	for _, p in partsIn(inst) do
		if not p.Anchored or p.CanCollide or p.CanQuery or p.CanTouch or p.CastShadow then
			p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
			changed += 1
		end
	end
	return changed
end

local function withUndo(name: string, fn: () -> ())
	if RunService:IsRunning() then
		log("ERROR", "Stop the playtest first; the kit edits the saved place.")
		return
	end
	local id = ChangeHistoryService:TryBeginRecording(name)
	if not id then
		log("ERROR", "Studio is busy recording another change. Try again in a moment.")
		return
	end
	local ok, err = pcall(fn)
	ChangeHistoryService:FinishRecording(id,
		if ok then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel)
	if not ok then
		log("ERROR", tostring(err))
	end
end

local function refreshStatus()
	if statusLabel then
		local theme = openTheme()
		statusLabel.Text = if theme then `Editing: {theme.Name}` else "No theme open"
	end
end

------------------------------------------------------------------ guides
local function makeGuidePart(parent: Instance, name: string, size: Vector3, cf: CFrame, colour: Color3, transparency: number): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = colour
	p.Transparency = transparency
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow, p.Locked = true, false, false, false, false, true
	p.Parent = parent
	return p
end

local function label(part: BasePart, text: string, face: Enum.NormalId, pixelsPerStud: number, width: number)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = pixelsPerStud
	gui.LightInfluence = 0
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(width, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.GothamBold
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0.4
	t.Text = text
	t.Parent = gui
	gui.Parent = part
end

local function ghostOf(tile: Model, offsetX: number, parent: Instance)
	local ghost = tile:Clone()
	ghost.Name = `Ghost_{tile.Name}`
	for _, d in ghost:GetDescendants() do
		if d:IsA("LuaSourceContainer") then
			d.Parent = nil -- never let a copied script run
		end
	end
	for _, p in partsIn(ghost) do
		p.Transparency = 0.55 + 0.45 * p.Transparency
		p.Anchored, p.Locked, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, true, false, false, false, false
	end
	ghost:PivotTo(tile:GetPivot() + Vector3.new(offsetX, 0, 0))
	ghost.Parent = parent
end

local function refreshGuides()
	local kit = requireShared("BackgroundKit")
	local studio = studioFolder(false)
	local theme = openTheme()
	if not kit or not studio or not theme then
		return
	end
	local old = studio:FindFirstChild(GUIDES)
	if old then
		old.Parent = nil -- not Destroy(): Destroy can't be undone
	end
	local guides = Instance.new("Folder")
	guides.Name = GUIDES
	local origin = trainOrigin()
	local pz = planeZ()
	local groundY = origin.Y - 3 -- TrainStart sits at the coupling height, 3 above the ground
	-- Depth bands: where each slot's content belongs.
	for _, slot in kit.SLOT_ORDER do
		local spec = kit.SLOTS[slot]
		if slot ~= "Ground" then
			local depth = spec.zNear - spec.zFar
			local band = makeGuidePart(guides, `Band_{slot}`, Vector3.new(GHOST_SPAN + 300, 0.1, depth),
				CFrame.new(origin.X + GHOST_SPAN / 2, groundY + 0.06, pz + (spec.zNear + spec.zFar) / 2), spec.colour, 0.8)
			label(band, `{string.upper(slot)}  ·  Z {spec.zFar} to {spec.zNear}  ·  tile {spec.tileLength}`, Enum.NormalId.Top, 2, 0.3)
		end
	end
	for _, layer in layersOf(theme, kit) do
		local length = layer:GetAttribute("TileLength")
		local slot = layer:GetAttribute("Slot")
		local spec = if type(slot) == "string" then kit.SLOTS[slot] else nil
		local variants = variantsOf(layer)
		if type(length) == "number" and length > 0 and #variants > 0 then
			local tile = variants[1]
			-- Ghost copies either side, to judge seams and repetition.
			for k = -1, math.ceil(GHOST_SPAN / length) do
				if k ~= 0 then
					ghostOf(tile, k * length, guides)
				end
			end
			-- Seam posts where one copy ends and the next starts.
			if spec then
				local h = POST_HEIGHT[slot :: string] or 10
				local tileX = tile:GetPivot().X
				for k = -1, math.ceil(GHOST_SPAN / length) + 1 do
					makeGuidePart(guides, `Seam_{layer.Name}`, Vector3.new(0.3, h, 0.3),
						CFrame.new(tileX + k * length, groundY + h / 2, pz + (spec.zNear + spec.zFar) / 2), spec.colour, 0.3)
				end
			end
			-- Name tags over variants (they sit left of the train, outside the ghosts).
			for i = 2, #variants do
				local v = variants[i]
				local pivot = v:GetPivot()
				local sign = makeGuidePart(guides, `Label_{v.Name}`, Vector3.new(math.min(length, 60), 6, 0.2),
					CFrame.new(pivot.X + length / 2, groundY + 40, pivot.Z), Color3.fromRGB(30, 34, 42), 0.2)
				label(sign, `{layer.Name} / {v.Name}`, Enum.NormalId.Back, 20, 1)
			end
		end
	end
	guides.Parent = studio
end

------------------------------------------------------------------ actions
local function placeTiles(theme: Folder, kit: any)
	local origin = trainOrigin()
	for _, layer in layersOf(theme, kit) do
		local length = layer:GetAttribute("TileLength")
		if type(length) == "number" and length > 0 then
			for i, tile in variantsOf(layer) do
				local pivot = tile:GetPivot()
				-- The main tile starts at the train; variants line up to the left, past the ghost.
				local x = if i == 1 then origin.X else origin.X - (i * (length + 20))
				tile:PivotTo(CFrame.new(x, pivot.Y, pivot.Z) * pivot.Rotation)
			end
		end
	end
end

local validate: (theme: Instance) -> (number, number)

local function closeTheme()
	local theme = openTheme()
	local bg = backgrounds()
	if not theme then
		log("INFO", "No theme is open.")
		return
	end
	if not bg then
		log("ERROR", "ReplicatedStorage.Assets.Backgrounds is missing.")
		return
	end
	validate(theme)
	local studio = studioFolder(false)
	local guides = studio and studio:FindFirstChild(GUIDES)
	if guides then
		guides.Parent = nil -- not Destroy(): Destroy can't be undone
	end
	theme:SetAttribute(OPEN_MARK, nil)
	theme.Parent = bg
	if studio and #studio:GetChildren() == 0 then
		studio.Parent = nil
	end
	log("OK", `Put {theme.Name} back in ReplicatedStorage.Assets.Backgrounds. Save the place to keep it.`)
end

local function editTheme(name: string)
	local kit = requireShared("BackgroundKit")
	local bg = backgrounds()
	if not kit or not bg then
		log("ERROR", "Needs ReplicatedStorage.Shared.BackgroundKit and ReplicatedStorage.Assets.Backgrounds.")
		return
	end
	local current = openTheme()
	if current and current.Name == name then
		refreshGuides()
		log("INFO", `{name} is already open.`)
		return
	end
	local theme = bg:FindFirstChild(name)
	if not theme or not theme:IsA("Folder") then
		log("ERROR", `No theme called "{name}". Type an existing one, or use New theme.`)
		return
	end
	if current then
		closeTheme()
	end
	theme:SetAttribute(OPEN_MARK, true)
	theme.Parent = studioFolder(true)
	placeTiles(theme, kit)
	refreshGuides()
	Selection:Set({ theme })
	log("OK", `Opened {name} next to the train. The solid copy of each tile is the real one; ghosts show the repeats.`)
end

local function makeLayer(theme: Instance, slot: string, kit: any): Model
	local spec = kit.SLOTS[slot]
	local layer = Instance.new("Model")
	layer.Name = slot
	layer:SetAttribute("Slot", slot)
	layer:SetAttribute("TileLength", spec.tileLength)
	layer:SetAttribute("Tiles", kit.minTiles(spec.tileLength, -spec.zFar)) -- bands are relative to the plane
	local origin = trainOrigin()
	local tile = Instance.new("Model")
	tile.Name = "Tile"
	tile.WorldPivot = CFrame.new(origin.X, origin.Y - 3, planeZ()) -- left end, on the ground
	tile.Parent = layer
	layer.Parent = theme
	return layer
end

local function newTheme(name: string)
	local kit = requireShared("BackgroundKit")
	local bg = backgrounds()
	if not kit or not bg then
		log("ERROR", "Needs ReplicatedStorage.Shared.BackgroundKit and ReplicatedStorage.Assets.Backgrounds.")
		return
	end
	if not string.match(name, "^%u%w*$") then
		log("ERROR", "Theme names are PascalCase, letters and digits only (e.g. Ninjas).")
		return
	end
	if bg:FindFirstChild(name) or (openTheme() and (openTheme() :: Folder).Name == name) then
		log("ERROR", `{name} already exists. Use Edit.`)
		return
	end
	local theme = Instance.new("Folder")
	theme.Name = name
	for _, slot in kit.SLOT_ORDER do
		makeLayer(theme, slot, kit)
	end
	theme.Parent = bg
	log("OK", `Created {name} with the six standard layers (empty tiles).`)
	editTheme(name)
end

local function addSelection(slot: string)
	local kit = requireShared("BackgroundKit")
	local theme = openTheme()
	if not kit or not theme then
		log("ERROR", "Open a theme first (Edit).")
		return
	end
	local spec = kit.SLOTS[slot]
	local layer = layerForSlot(theme, slot) or makeLayer(theme, slot, kit)
	local tile = layer:FindFirstChild("Tile")
	local length = layer:GetAttribute("TileLength")
	if not tile or not tile:IsA("Model") or type(length) ~= "number" then
		log("ERROR", `{layer.Name} needs a Tile model and a TileLength attribute.`)
		return
	end
	local tileModel = tile :: Model
	local studio = studioFolder(false)
	local guides = studio and studio:FindFirstChild(GUIDES)
	local map = Workspace:FindFirstChild("Map")
	local selected = Selection:Get()
	-- Only whole props being built in the workspace; never templates, the map, tiles or
	-- pieces inside another prop.
	local chosen: { PVInstance } = {}
	for _, item in selected do
		local why: string? = nil
		if not item:IsA("PVInstance") then
			why = "isn't a part or model"
		elseif not item:IsDescendantOf(Workspace) then
			why = "isn't in Workspace (templates and other themes are left alone)"
		elseif map and item:IsDescendantOf(map) then
			why = "is part of the game map"
		elseif guides and item:IsDescendantOf(guides) then
			why = "is an editor guide"
		elseif isTileModel(item) or item.Parent == theme then
			why = "is a tile or a layer itself"
		elseif item:IsDescendantOf(theme) then
			local owner = tileOf(item)
			if not owner then
				why = "is inside a prop; select the whole prop"
			elseif owner.Parent == layer and owner ~= tileModel then
				why = `is in the variant {owner.Name}; move it there by hand`
			end
		end
		if not why then
			for _, other in selected do
				if other ~= item and item:IsDescendantOf(other) then
					why = "is inside another selected item"
					break
				end
			end
		end
		if why then
			log("INFO", `Skipped {item.Name}: it {why}.`)
		else
			table.insert(chosen, item :: PVInstance)
		end
	end
	if #chosen == 0 then
		log("INFO", "Select the props you've built, then pick a layer.")
		return
	end
	local pz = planeZ()
	local tileX = tileModel:GetPivot().X
	for _, pv in chosen do
		local pivot = pv:GetPivot()
		local x = tileX + (pivot.X - tileX) % length -- dropped over a ghost? it wraps into the tile
		local z = math.clamp(pivot.Z, pz + spec.zFar, pz + spec.zNear)
		pv:PivotTo(CFrame.new(x, pivot.Y, z) * pivot.Rotation)
		pv.Parent = tileModel
		applyRules(pv)
		if math.abs(x - pivot.X) > TOL then
			log("INFO", `{pv.Name} moved {string.format("%.0f", x - pivot.X)} studs along X into the real tile.`)
		end
		if math.abs(z - pivot.Z) > TOL then
			log("INFO", `{pv.Name} moved into the {slot} band (Z {spec.zFar} to {spec.zNear}).`)
		end
		local lo, hi = boxOf(pv)
		if lo and hi and (lo.X < tileX - TOL or hi.X > tileX + length + TOL) then
			log("WARN", `{pv.Name} crosses the tile's end, so it will be cut off or doubled at the seam. Move it, or split it.`)
		end
	end
	Selection:Set(chosen)
	refreshGuides()
	log("OK", `Added {#chosen} item(s) to {layer.Name}.`)
end

local function fixParts()
	local theme = openTheme()
	if not theme then
		log("ERROR", "Open a theme first (Edit).")
		return
	end
	local changed = 0
	for _, layer in theme:GetChildren() do
		for _, tile in variantsOf(layer) do
			changed += applyRules(tile)
		end
	end
	log("OK", `Fixed {changed} part(s): anchored, no collision, query, touch or shadows.`)
end

validate = function(theme: Instance): (number, number)
	local kit = requireShared("BackgroundKit")
	if not kit then
		log("ERROR", "ReplicatedStorage.Shared.BackgroundKit is missing.")
		return 1, 0
	end
	local errors, warnings = 0, 0
	local function report(level: string, text: string)
		if level == "ERROR" then
			errors += 1
		elseif level == "WARN" then
			warnings += 1
		end
		log(level, text)
	end
	local pz = planeZ()
	local layers = layersOf(theme, kit)
	if #layers == 0 then
		report("ERROR", `{theme.Name} has no layer Models.`)
	end
	local seen: { [string]: boolean } = {}
	for _, layer in layers do
		local slot = layer:GetAttribute("Slot")
		local length = layer:GetAttribute("TileLength")
		local tiles = layer:GetAttribute("Tiles")
		local spec = if type(slot) == "string" then kit.SLOTS[slot] else nil
		local tag = if type(slot) == "string" then `{layer.Name} ({slot})` else layer.Name
		if type(slot) ~= "string" then
			report("WARN", `{tag}: no Slot attribute, so its depth band can't be checked. Set Slot to Foreground, Track, Ground, Near, Mid or Far.`)
		elseif not spec then
			report("ERROR", `{tag}: "{slot}" isn't a slot.`)
		elseif seen[slot] then
			report("INFO", `{tag}: a second {slot} layer. That's allowed; check you meant it.`)
		end
		if type(slot) == "string" then
			seen[slot] = true
		end
		if type(length) ~= "number" or length <= 0 or type(tiles) ~= "number" or tiles < 1 then
			report("ERROR", `{tag}: needs TileLength and Tiles attributes.`)
			continue
		end
		local variants = variantsOf(layer)
		if #variants == 0 or variants[1].Name ~= "Tile" then
			report("ERROR", `{tag}: needs a Model named Tile.`)
			continue
		end
		local deepest = -math.huge
		local partCount, scripts, defaults = 0, 0, 0
		for _, tile in variants do
			local pivot = tile:GetPivot()
			if not pivot.Rotation:FuzzyEq(CFrame.identity, 1e-3) then
				report("WARN", `{tag}/{tile.Name}: the pivot is rotated. Keep it unrotated so X runs along the track.`)
			end
			if tile ~= variants[1] then
				local every, weight = tile:GetAttribute("Every"), tile:GetAttribute("Weight")
				if every ~= nil and (type(every) ~= "number" or every < 2) then
					report("WARN", `{tag}/{tile.Name}: Every should be a whole number of 2 or more.`)
				end
				if weight ~= nil and (type(weight) ~= "number" or weight <= 0) then
					report("WARN", `{tag}/{tile.Name}: Weight should be above 0.`)
				end
			end
			if #tile:GetChildren() == 0 then
				report("INFO", `{tag}/{tile.Name}: empty (fine if this layer isn't used yet).`)
			end
			for _, d in tile:GetDescendants() do
				if d:IsA("LuaSourceContainer") then
					scripts += 1
					report("ERROR", `{d:GetFullName()}: scripts don't belong in background tiles. Remove it.`)
				elseif d:IsA("BasePart") then
					partCount += 1
					if DEFAULT_NAMES[d.Name] then
						defaults += 1
					end
				elseif d:IsA("Model") and DEFAULT_NAMES[d.Name] then
					defaults += 1
				end
			end
			local bad = 0
			for _, p in partsIn(tile) do
				if not p.Anchored or p.CanCollide or p.CanQuery or p.CanTouch or p.CastShadow then
					bad += 1
				end
			end
			if bad > 0 then
				report("WARN", `{tag}/{tile.Name}: {bad} part(s) not anchored or still colliding, blocking shots or casting shadows. Use Fix part settings.`)
			end
			for _, child in propsIn(tile) do
				local lo, hi = boxOf(child)
				if lo and hi then
					deepest = math.max(deepest, pz - lo.Z)
					local x0, x1 = lo.X - pivot.X, hi.X - pivot.X
					if child:GetAttribute("Continuous") == true then
						if x0 > TOL or x1 < length - TOL then
							report("WARN", `{tag}/{tile.Name}/{child.Name}: marked Continuous but runs {string.format("%.1f", x0)} to {string.format("%.1f", x1)}, not 0 to {length}, so there's a gap at the seam.`)
						end
					end
					if x0 < -TOL or x1 > length + TOL then
						report("WARN", `{tag}/{tile.Name}/{child.Name}: crosses the tile's end ({string.format("%.1f", x0)} to {string.format("%.1f", x1)}; the tile is 0 to {length}). It will be cut off or doubled at the seam.`)
					end
					if spec then
						local zLo, zHi = lo.Z - pz, hi.Z - pz
						if zLo < spec.zFar - 2 or zHi > spec.zNear + 2 then
							report("WARN", `{tag}/{tile.Name}/{child.Name}: sits at Z {string.format("%.0f", zLo)} to {string.format("%.0f", zHi)}, outside the {slot} band ({spec.zFar} to {spec.zNear}).`)
						end
						if spec.maxHeight and hi.Y - pivot.Y > spec.maxHeight + TOL then
							report("WARN", `{tag}/{tile.Name}/{child.Name}: taller than {spec.maxHeight} studs, so it shows above the couplers between cars.`)
						end
					end
				end
			end
		end
		if deepest > -math.huge then
			local need = kit.minTiles(length, deepest)
			if tiles < need then
				report("ERROR", `{tag}: Tiles is {tiles}, but content reaches {string.format("%.0f", deepest)} studs deep, so wide phones need at least {need} or scenery pops in at the screen edge. Set Tiles to {need}.`)
			elseif tiles > need + 2 then
				report("INFO", `{tag}: Tiles could be {need} (it's {tiles}); fewer copies, fewer parts.`)
			end
			local onScreen = math.ceil(2 * kit.halfVisibleWidth(deepest) / length) + 1
			report("INFO", `{tag}: {length} × {tiles}, {partCount} part(s) in its tile(s), about {partCount // #variants * onScreen} on screen at once. Triangle budget for the slot: {if spec then spec.trianglesVisible else "?"} on screen.`)
		end
		if defaults > 0 then
			report("INFO", `{tag}: {defaults} item(s) still have default names (Part, Model…). Name them so they're easy to find.`)
		end
	end
	log(if errors > 0 then "ERROR" elseif warnings > 0 then "WARN" else "OK",
		`Checked {theme.Name}: {errors} error(s), {warnings} warning(s).`)
	return errors, warnings
end

local function gameView()
	local kit = requireShared("BackgroundKit")
	local constants = requireShared("Constants")
	local camera = Workspace.CurrentCamera
	if not kit or not camera then
		return
	end
	local size = camera.ViewportSize
	local distance = kit.cameraDistance(size.X / math.max(size.Y, 1))
	local origin = trainOrigin()
	local x = camera.CFrame.Position.X
	if math.abs(x - (origin.X + 100)) > 300 then
		x = origin.X + 100
	end
	local y = if constants and type(constants.CAMERA_HEIGHT) == "number" then constants.CAMERA_HEIGHT else 13
	local pz = planeZ()
	camera.FieldOfView = if constants and type(constants.CAMERA_FOV) == "number" then constants.CAMERA_FOV else 40
	camera.CFrame = CFrame.lookAt(Vector3.new(x, y, pz + distance), Vector3.new(x, y, pz))
	camera.Focus = CFrame.new(x, y, pz)
	log("INFO", "Game camera view. Pan along X with the arrow keys or A/D; Free view puts the FOV back.")
end

local function freeView()
	local camera = Workspace.CurrentCamera
	if camera then
		camera.FieldOfView = 70
	end
end

------------------------------------------------------------------ panel UI
local toolbar = plugin:CreateToolbar("Train Mayhem")
local button = toolbar:CreateButton("BackgroundKit", "Build and check background layers", "", "Background Kit")
button.ClickableWhenViewportHidden = true

local widget = plugin:CreateDockWidgetPluginGui("TrainMayhemBackgroundKit",
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 320, 560, 260, 320))
widget.Title = "Background Kit"
button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

local studioTheme = (settings() :: any).Studio.Theme
local function colour(name: string): Color3
	return studioTheme:GetColor((Enum.StudioStyleGuideColor :: any)[name])
end

local root = Instance.new("ScrollingFrame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = colour("MainBackground")
root.BorderSizePixel = 0
root.AutomaticCanvasSize = Enum.AutomaticSize.Y
root.CanvasSize = UDim2.new()
root.ScrollBarThickness = 6
root.Parent = widget
local pad = Instance.new("UIPadding")
pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10)
pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
pad.Parent = root
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = root

local order = 0
local function nextOrder(): number
	order += 1
	return order
end

local function heading(text: string)
	local t = Instance.new("TextLabel")
	t.LayoutOrder = nextOrder()
	t.Size = UDim2.new(1, 0, 0, 22)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.SourceSansBold
	t.TextSize = 15
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextColor3 = colour("MainText")
	t.Text = text
	t.Parent = root
end

local function grid(columns: number): Frame
	local f = Instance.new("Frame")
	f.LayoutOrder = nextOrder()
	f.Size = UDim2.new(1, 0, 0, 0)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.BackgroundTransparency = 1
	local g = Instance.new("UIGridLayout")
	g.CellSize = UDim2.new(1 / columns, -4, 0, 28)
	g.CellPadding = UDim2.fromOffset(4, 4)
	g.SortOrder = Enum.SortOrder.LayoutOrder
	g.Parent = f
	f.Parent = root
	return f
end

local function makeButton(parent: Instance, text: string, onClick: () -> ())
	local b = Instance.new("TextButton")
	b.Text = text
	b.Font = Enum.Font.SourceSansSemibold
	b.TextSize = 14
	b.TextColor3 = colour("ButtonText")
	b.BackgroundColor3 = colour("Button")
	b.BorderColor3 = colour("ButtonBorder")
	b.AutoButtonColor = true
	b.Parent = parent
	b.MouseButton1Click:Connect(onClick)
end

heading("Theme")
local nameBox = Instance.new("TextBox")
nameBox.LayoutOrder = nextOrder()
nameBox.Size = UDim2.new(1, 0, 0, 28)
nameBox.Font = Enum.Font.SourceSans
nameBox.TextSize = 15
nameBox.PlaceholderText = "Theme name, e.g. WildWest"
nameBox.Text = "WildWest"
nameBox.ClearTextOnFocus = false
nameBox.TextColor3 = colour("MainText")
nameBox.PlaceholderColor3 = colour("DimmedText")
nameBox.BackgroundColor3 = colour("InputFieldBackground")
nameBox.BorderColor3 = colour("InputFieldBorder")
nameBox.Parent = root

local themeRow = grid(3)
makeButton(themeRow, "Edit", function()
	withUndo("Background Kit: edit theme", function()
		editTheme(nameBox.Text)
	end)
	refreshStatus()
end)
makeButton(themeRow, "New theme", function()
	withUndo("Background Kit: new theme", function()
		newTheme(nameBox.Text)
	end)
	refreshStatus()
end)
makeButton(themeRow, "Done", function()
	withUndo("Background Kit: done", closeTheme)
	refreshStatus()
end)

local status = Instance.new("TextLabel")
status.LayoutOrder = nextOrder()
status.Size = UDim2.new(1, 0, 0, 18)
status.BackgroundTransparency = 1
status.Font = Enum.Font.SourceSansItalic
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = colour("DimmedText")
status.Parent = root
statusLabel = status

heading("View")
local viewRow = grid(3)
makeButton(viewRow, "Game camera", gameView)
makeButton(viewRow, "Free view", freeView)
makeButton(viewRow, "Refresh ghosts", function()
	withUndo("Background Kit: refresh ghosts", refreshGuides)
end)

heading("Add selection to layer")
local slotRow = grid(3)
for _, slot in { "Foreground", "Track", "Ground", "Near", "Mid", "Far" } do
	makeButton(slotRow, slot, function()
		withUndo(`Background Kit: add to {slot}`, function()
			addSelection(slot)
		end)
	end)
end

heading("Check")
local checkRow = grid(3)
makeButton(checkRow, "Validate", function()
	clearLog()
	local theme = openTheme()
	local bg = backgrounds()
	local target = theme or (bg and bg:FindFirstChild(nameBox.Text))
	if target then
		validate(target)
	else
		log("ERROR", `No theme called "{nameBox.Text}".`)
	end
end)
makeButton(checkRow, "Fix part settings", function()
	withUndo("Background Kit: fix part settings", fixParts)
end)
makeButton(checkRow, "Clear log", clearLog)

local out = Instance.new("TextLabel")
out.LayoutOrder = nextOrder()
out.Size = UDim2.new(1, 0, 0, 0)
out.AutomaticSize = Enum.AutomaticSize.Y
out.BackgroundTransparency = 1
out.RichText = true
out.TextWrapped = true
out.Font = Enum.Font.Code
out.TextSize = 13
out.TextXAlignment = Enum.TextXAlignment.Left
out.TextYAlignment = Enum.TextYAlignment.Top
out.TextColor3 = colour("MainText")
out.Text = ""
out.Parent = root
outputLabel = out

ChangeHistoryService.OnUndo:Connect(refreshStatus)
ChangeHistoryService.OnRedo:Connect(refreshStatus)
refreshStatus()
```

## §5 Wild West migration (`execute_luau`, Edit datamodel)
```lua
-- Background Kit: give the Wild West greybox layers their standard slots (Edit datamodel).
-- Idempotent: it only sets what's missing, and prints every change. Run it after the new
-- ParallaxController is in: with its centred copies, the existing Tiles counts are enough.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:FindFirstChild("Assets")
local backgrounds = assets and assets:FindFirstChild("Backgrounds")
local theme = backgrounds and backgrounds:FindFirstChild("WildWest")
assert(theme, "ReplicatedStorage.Assets.Backgrounds.WildWest not found")

local SLOT = { Foreground = "Foreground", Track = "Track", Desert = "Ground", Scrub = "Near", Mesas = "Far" }

for name, slot in SLOT do
	local layer = theme:FindFirstChild(name)
	if not layer then
		warn(`missing layer {name}`)
		continue
	end
	if layer:GetAttribute("Slot") ~= slot then
		layer:SetAttribute("Slot", slot)
		print(`{name}: Slot = {slot}`)
	end
end
print("Done. Now mark the rails and the ground slab Continuous = true, then run Validate in the Background Kit panel.")
```

## §6 Verify
1. **Plugin:** the panel opens; **Edit** `WildWest` puts the layers next to the train with
   ghosts either side, coloured depth bands and seam posts. **Game camera** looks like the
   game. **Done** puts everything back and leaves no `BackgroundStudio` folder.
2. **Validate** on Wild West reports no errors after the migration.
3. **Add selection:** a part dropped over a ghost lands at the same spot in the real tile;
   one placed at the wrong depth snaps into the band; one crossing a tile end gets a
   warning. Ctrl+Z undoes it.
4. **Playtest:** the background scrolls as before, with no console errors; `Workspace.Background`
   holds the same number of tiles as before. Check the screen edges at a wide phone size
   in the device emulator: nothing pops in.
5. **Variants:** duplicate the Scrub `Tile` as `Tile_Test`, change it visibly, give it
   `Weight` 1. In a playtest both appear, and the same stretch shows the same tile if the
   camera goes back. Then try `Every = 4` and check it appears on every 4th tile. Delete it.
6. **Safety net:** leave a theme open (no **Done**) and press Play: the background still
   works, and the server prints that it moved the theme back. After stopping, the theme is
   still open in the edit place, as left.
7. **Phone:** in the device emulator at a wide phone size, no gaps at the screen edges.

## Review (2026-10-16)
A read-only code review found, and these drafts now fix:
- **Undo could detach a whole theme** after Done or Edit, because `Destroy()` can't be
  undone; the plugin now only re-parents.
- **Add selection could rearrange things silently**: whole tiles, parts inside a selected
  model, templates in `ReplicatedStorage` and map pieces. It now filters to whole props in
  the Workspace and logs what it skips and every X wrap.
- Running when Studio couldn't start an undo recording; Validate missing props inside
  Folders; overlapping theme loads; any Folder being treated as the open theme (the open
  theme is now marked with a `BackgroundKitTheme` attribute, and the server only moves
  marked folders); Edit closing the current theme for a name that doesn't exist; ghosts
  copying scripts; the status line after undo; the plugin loading in playtests.
- **Performance:** one `BulkMoveTo` per frame instead of a `PivotTo` per tile.
- **Fewer copies:** centring the copies on the camera covers both edges with one fewer
  copy per layer.

Left as known limits: screens wider than 21:9 (clamp the camera's aspect if they matter),
and two set-pieces on the same tile (the first by name wins).

## Roblox export notes
- Plugins cache `require`, so **reload the plugin** (or restart Studio) after editing
  `Shared.BackgroundKit`.
- The plugin edits the saved place, wrapped in undo recordings. Save before using it the
  first time.
- Scripts can't read a mesh's triangle count; check budgets in Blender.

Related: [[Background Kit]] · [[ParallaxController]] · [[0011-background-kit]] · [[Techniques]]
