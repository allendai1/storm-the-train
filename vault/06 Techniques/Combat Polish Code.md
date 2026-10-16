---
tags: [technique, studio, luau, combat, game-feel, slice]
status: planned
updated: 2026-10-16
---
# Combat Polish Code

## When to use
Step F2 of the [[Feel and Look (Slice)]], implementing [[Combat Polish]]. This is **draft
reference code, written in a cloud session without Studio, and it hasn't been run.** Most
items change scripts that already exist in Studio, which this session can't read. So the
draft is:
- **new, self-contained helper modules** (§2–§6) that hold the rules, and
- **hook points** (§7) that say where each existing service calls them.

`script_read` every script before editing it, and adapt the hooks to the real code. Once
it's built, update the system notes ([[CombatService]], [[EnemyService]], [[SpawnService]],
[[SquadService]], [[EffectsController]], [[CameraController]]), and stop editing this page.

**Already built, so it isn't redone:**
- the Six-Shooter already fires `TellTime` 0.5 s into its wind-up, with a random 2.5–4 s
  interval,
- Dynamite Dan already keeps `KeepDistance`,
- `CombatService.knockback(enemy, velocity)` already exists (the Session 11 stun fix), and
  the spin and explosion pushes reuse it.

## Steps
1. **Run the setup script** (§1) in the Edit datamodel. It's idempotent, adds the new
   attributes and greybox effect templates, and never overwrites a value that's already
   set.
2. **Add the constants** (§2) to `ReplicatedStorage.Shared.Constants`.
3. **Create the modules:**
   - `ServerScriptService.Server.Util.CombatFeel` (§3), `.EnemyPerception` (§4),
     `.EnemyFlinch` (§5) and `.SpawnPlacement` (§6),
   - `ReplicatedStorage.Shared.CameraLead` (§6b),
   - `StarterPlayer.StarterPlayerScripts.Client.Controllers.FeelEffects` (§6c).
4. **Make the hook edits** (§7), one service at a time, playtesting after each (§8).

### §1 Setup script (Edit datamodel, idempotent)
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local changed = 0
local function default(inst: Instance, name: string, value: any)
	if inst:GetAttribute(name) == nil then
		inst:SetAttribute(name, value)
		changed += 1
		print(`Set {inst:GetFullName()}.{name} = {value}`)
	end
end

-- Enemies: flinch cooldowns (0 = never flinches) and the Six-Shooter's minimum range.
local enemies = ServerStorage:WaitForChild("Assets"):WaitForChild("Enemies"):WaitForChild("WildWest")
for _, name in { "BandanaBandit", "RodeoKid", "SixShooter", "DynamiteDan" } do
	local template = enemies:FindFirstChild(name)
	if template then
		default(template, "FlinchCooldown", 0.75)
	end
end
local bart = enemies:FindFirstChild("BigBart")
if bart then
	default(bart, "FlinchCooldown", 1.5)
	-- The one deliberate overwrite: only the old built value 36 is changed (decided 2026-10-16:
	-- 2.5x walk = 26.7). A hand-tuned value is left alone.
	if bart:GetAttribute("ChargeSpeed") == 36 then
		bart:SetAttribute("ChargeSpeed", 26.7)
		changed += 1
		print("BigBart.ChargeSpeed 36 -> 26.7")
	end
end
local shooter = enemies:FindFirstChild("SixShooter")
if shooter then
	default(shooter, "MinRange", 6)
end

-- Weapons: which muzzle-flash template each one spawns, and the rocket's explosion push.
local weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
local flashFor = {
	ServiceRifle = "MuzzleFlashRifle",
	PocketRocket = "MuzzleFlashRocket",
	Scattergun = "MuzzleFlashScattergun",
	CrowdPleaser = "MuzzleFlashRifle",
}
for weaponName, flash in flashFor do
	local weapon = weapons:FindFirstChild(weaponName)
	if weapon then
		default(weapon, "MuzzleFlash", flash)
	end
end
local rocket = weapons:FindFirstChild("PocketRocket")
if rocket then
	default(rocket, "ExplosionPush", 17)
end

-- Greybox flash templates (cosmetic, client-cloned). Their LookVector is the shot direction.
local effects = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects")
local function flashTemplate(name: string, size: Vector3, color: Color3)
	if effects:FindFirstChild(name) then
		return
	end
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Block -- not Ball: balls force a uniform size
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Parent = effects
	changed += 1
	print("Created", part:GetFullName())
end
local WARM = Color3.fromHex("#FFF2B3") -- player-projectile colour (Art Direction)
-- Long axis on Z: after CFrame.lookAt the shot runs along the part's -Z (LookVector).
flashTemplate("MuzzleFlashRifle", Vector3.new(0.6, 0.6, 1.4), WARM)
flashTemplate("MuzzleFlashScattergun", Vector3.new(1.3, 1.3, 2.4), WARM)
flashTemplate("MuzzleFlashRocket", Vector3.new(1.6, 1.6, 1.8), Color3.fromHex("#FFC24A"))

-- The dynamite fuse spark that FeelEffects blinks.
local dynamite = effects:FindFirstChild("Dynamite")
if dynamite and not dynamite:FindFirstChild("FuseSpark", true) then
	local spark = Instance.new("Part")
	spark.Name = "FuseSpark"
	spark.Shape = Enum.PartType.Ball
	spark.Size = Vector3.new(0.35, 0.35, 0.35)
	spark.Color = Color3.fromHex("#FFC24A")
	spark.Material = Enum.Material.Neon
	spark.CanCollide = false
	spark.CanQuery = false
	spark.CanTouch = false
	spark.Massless = true
	local anchor = if dynamite:IsA("BasePart") then dynamite else dynamite:FindFirstChildWhichIsA("BasePart", true)
	if anchor then
		-- Tip of the stick: a Roblox Cylinder's axis is X, a Block's long axis is usually Y.
		local tip = if anchor:IsA("Part") and anchor.Shape == Enum.PartType.Cylinder
			then CFrame.new(anchor.Size.X / 2 + 0.2, 0, 0)
			else CFrame.new(0, anchor.Size.Y / 2 + 0.2, 0)
		spark.CFrame = anchor.CFrame * tip
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = anchor
		weld.Part1 = spark
		weld.Parent = spark
		spark.Parent = dynamite
		changed += 1
		print("Added FuseSpark to", dynamite:GetFullName())
	end
end

print(`Combat Polish setup: {changed} change(s)`)
```
Check that the Dynamite template is a part or model, and that the `FuseSpark` sits at the
tip. Move it by hand if not.

### §2 Constants (add to `ReplicatedStorage.Shared.Constants`)
```lua
	-- Combat Polish (Feel and Look slice). First guesses from the decompiled original.
	FLINCH_TIME = 0.2, -- s an enemy pauses on a gun-hit flinch
	FLINCH_COOLDOWN_DEFAULT = 0.75, -- when a template has no FlinchCooldown
	FLINCH_COOLDOWN_JITTER_MIN = 0.8,
	FLINCH_COOLDOWN_JITTER_MAX = 1.2,
	ATTACK_JITTER = 0.3, -- +/- fraction on enemy melee intervals (never player guns)
	ENEMY_FIRE_GRACE = 4, -- s after spawning before an enemy may shoot or throw
	SHOT_TELL_MIN = 0.5,
	SHOT_TELL_MAX = 0.6,
	PERCEPTION_AGGRO_TIME = 6, -- s an enemy keeps tracking a player who hit it
	PERCEPTION_OVERHEAD_DX = 4, -- studs: closer than this in X and above the head = jumping over
	PERCEPTION_LOST_MIN = 0.6, -- s an enemy walks on after losing its target, before turning round
	PERCEPTION_LOST_MAX = 1.2,
	SPAWN_EDGE_MARGIN = 3, -- studs past the camera half-width
	SPAWN_BEHIND_CHANCE = 1 / 3,
	SPAWN_ADVANCE_WINDOW = 3, -- s
	SPAWN_ADVANCE_SAMPLE = 0.25, -- s between advance-tracker samples (its own fixed tick)
	SPAWN_ADVANCE_MIN = 4, -- studs the squad's front must move forward in that window
	SPAWN_SPREAD_MIN = 3, -- studs between enemies in one wave
	SPAWN_SPREAD_MAX = 10,
	PLAYER_IFRAMES = 0.3,
	REVIVE_GRACE = 3,
	REVIVE_PUSH_RADIUS = 10,
	REVIVE_PUSH_SPEED = 40, -- sideways only (no lift), so enemies aren't flung off the train
	SPIN_MAX_TIME = 1.5, -- s: server cap on one spin, so a hovering client can't keep a damage aura
	SPIN_POP_PER_LEVEL = 6.7, -- studs/s of sideways and upward push per spin level
	EXPLOSION_PUSH = 17, -- studs/s when the weapon has no ExplosionPush
	EXPLOSION_UP_SCALE = 1.3,
	EXPLOSION_MIN_LIFT = 0.25, -- our addition: every blast lifts a little, even from above
	DYNAMITE_LAUNCH_ANGLE = 28, -- degrees; steeper angles are tried if the target is too high
	DYNAMITE_THROWER_VELOCITY = 0.2,
	CAMERA_LEAD_MOVING = 17,
	CAMERA_LEAD_RATE = 7.3, -- studs/s the lead slides at
	CAMERA_MOVE_THRESHOLD = 1, -- studs/s of X speed that counts as moving
	MUZZLE_FLASH_TIME = 0.06,
	FUSE_BLINK_FACTOR = 0.2, -- blink period = remaining fuse x this
	FUSE_BLINK_MIN = 0.02,
```

### §3 `Server.Util.CombatFeel` (ModuleScript)
```lua
--!strict
-- Pure helpers for the Combat Polish rules: jitter, telegraphs, invulnerability, knockback
-- vectors and the lobbed-throw solver. The only state is player/enemy attributes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants") :: ModuleScript)

local CombatFeel = {}
local rng = Random.new()

local function now(): number
	return workspace:GetServerTimeNow()
end

-- Enemy attack intervals x (1 +/- ATTACK_JITTER), so a crowd doesn't attack in sync.
function CombatFeel.jitter(interval: number): number
	return interval * rng:NextNumber(1 - Constants.ATTACK_JITTER, 1 + Constants.ATTACK_JITTER)
end

-- How long a ranged enemy winds up before the shot leaves.
function CombatFeel.tellTime(): number
	return rng:NextNumber(Constants.SHOT_TELL_MIN, Constants.SHOT_TELL_MAX)
end

-- False during an enemy's first ENEMY_FIRE_GRACE seconds (EnemyService sets SpawnedAt).
function CombatFeel.canFireYet(enemy: Model): boolean
	local spawnedAt = enemy:GetAttribute("SpawnedAt")
	return typeof(spawnedAt) ~= "number" or now() - spawnedAt >= Constants.ENEMY_FIRE_GRACE
end

-- Invulnerability (hit i-frames, revive grace) as server time in a replicated attribute.
function CombatFeel.isInvulnerable(player: Player): boolean
	local untilTime = player:GetAttribute("InvulnerableUntil")
	return typeof(untilTime) == "number" and now() < untilTime
end

function CombatFeel.grantInvulnerability(player: Player, seconds: number)
	local target = now() + seconds
	local current = player:GetAttribute("InvulnerableUntil")
	if typeof(current) ~= "number" or current < target then
		player:SetAttribute("InvulnerableUntil", target)
	end
end

-- Explosion knockback: radial from the blast on the Z = 0 plane, upward part x EXPLOSION_UP_SCALE.
function CombatFeel.explosionVelocity(center: Vector3, target: Vector3, speed: number): Vector3
	local offset = Vector3.new(target.X - center.X, target.Y - center.Y, 0)
	local direction = if offset.Magnitude > 0.05 then offset.Unit else Vector3.new(0, 1, 0)
	local lift = math.max(direction.Y, Constants.EXPLOSION_MIN_LIFT)
	return Vector3.new(direction.X * speed, lift * speed * Constants.EXPLOSION_UP_SCALE, 0)
end

-- A sideways-only push away from `center` (the revive shove): no lift, so nobody leaves the train.
function CombatFeel.radialVelocity(center: Vector3, target: Vector3, speed: number): Vector3
	local side = if target.X >= center.X then 1 else -1
	return Vector3.new(side * speed, 0, 0)
end

-- Spin knockback: equal sideways (away from the spinner) and upward push, F = per-level x level.
function CombatFeel.spinVelocity(spinner: Vector3, target: Vector3, spinLevel: number): Vector3
	local force = Constants.SPIN_POP_PER_LEVEL * spinLevel
	local side = if target.X >= spinner.X then 1 else -1
	return Vector3.new(side * force, force, 0)
end

-- Lobbed throw: the launch velocity that would land on `to` from `from` under `gravity` (studs/s^2),
-- on the lowest workable arc starting at DYNAMITE_LAUNCH_ANGLE, PLUS a share of the thrower's own X
-- velocity added afterwards. So a moving thrower overshoots by about that share x flight time, as
-- in the original. nil = unreachable.
function CombatFeel.lobVelocity(from: Vector3, to: Vector3, gravity: number, throwerVelocity: Vector3): Vector3?
	local dx = to.X - from.X
	local dy = to.Y - from.Y
	local distance = math.abs(dx)
	local side = if dx >= 0 then 1 else -1
	local inherit = throwerVelocity.X * Constants.DYNAMITE_THROWER_VELOCITY
	for angle = Constants.DYNAMITE_LAUNCH_ANGLE, 70, 6 do
		local theta = math.rad(angle)
		local denominator = 2 * math.cos(theta) ^ 2 * (distance * math.tan(theta) - dy)
		if denominator > 0 then
			local speed = math.sqrt(gravity * distance * distance / denominator)
			return Vector3.new(side * speed * math.cos(theta) + inherit, speed * math.sin(theta), 0)
		end
	end
	return nil
end

return CombatFeel
```

### §4 `Server.Util.EnemyPerception` (ModuleScript)
```lua
--!strict
-- Who an enemy can see (Combat Polish, from the original's Enemy AI): players in front of it, or
-- ones who hit it recently. A player jumping over it is lost, so it walks on past.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants") :: ModuleScript)

local EnemyPerception = {}

local function rootOf(model: Model?): BasePart?
	if model == nil then
		return nil
	end
	local part = model:FindFirstChild("HumanoidRootPart")
	return if part and part:IsA("BasePart") then part else nil
end

-- CombatService.damageEnemy calls this whenever a player damages an enemy.
function EnemyPerception.noteHit(enemy: Model, by: Player)
	enemy:SetAttribute(`Aggro_{by.UserId}`, workspace:GetServerTimeNow() + Constants.PERCEPTION_AGGRO_TIME)
end

function EnemyPerception.canSee(enemy: Model, player: Player): boolean
	local enemyRoot = rootOf(enemy)
	local playerRoot = rootOf(player.Character)
	if enemyRoot == nil or playerRoot == nil then
		return false
	end
	local dx = playerRoot.Position.X - enemyRoot.Position.X
	local heightAttr = enemy:GetAttribute("HitboxHeight")
	local height = if typeof(heightAttr) == "number" then heightAttr else 6
	local headY = enemyRoot.Position.Y + height / 2
	if math.abs(dx) < Constants.PERCEPTION_OVERHEAD_DX and playerRoot.Position.Y > headY then
		return false -- jumping over it
	end
	local aggro = enemy:GetAttribute(`Aggro_{player.UserId}`)
	if typeof(aggro) == "number" and workspace:GetServerTimeNow() < aggro then
		return true
	end
	return dx * enemyRoot.CFrame.LookVector.X > 0 -- in front
end

-- The nearest visible candidate. Keeps `current` while it's still visible, so targets don't flicker.
function EnemyPerception.selectTarget(enemy: Model, candidates: { Player }, current: Player?): Player?
	if current ~= nil and table.find(candidates, current) ~= nil and EnemyPerception.canSee(enemy, current) then
		return current
	end
	local enemyRoot = rootOf(enemy)
	if enemyRoot == nil then
		return nil
	end
	local best: Player? = nil
	local bestDistance = math.huge
	for _, player in candidates do
		local playerRoot = rootOf(player.Character)
		if playerRoot and EnemyPerception.canSee(enemy, player) then
			local distance = math.abs(playerRoot.Position.X - enemyRoot.Position.X)
			if distance < bestDistance then
				best = player
				bestDistance = distance
			end
		end
	end
	return best
end

-- How long a target-less enemy keeps walking before turning round (our addition, so it re-finds you).
function EnemyPerception.lostWalkTime(rng: Random): number
	return rng:NextNumber(Constants.PERCEPTION_LOST_MIN, Constants.PERCEPTION_LOST_MAX)
end

return EnemyPerception
```

### §5 `Server.Util.EnemyFlinch` (ModuleScript)
```lua
--!strict
-- The gun-hit flinch with a cooldown (Combat Polish), from the original's Enemy::HandleDamageAnim:
-- never mid-attack, then no new flinch for 0.8-1.2 x FlinchCooldown. FlinchCooldown 0 = never.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants") :: ModuleScript)

local EnemyFlinch = {}
local rng = Random.new()
local tracks: { [Model]: AnimationTrack } = {} -- strong; cleared on Destroying (weak keys on Instances aren't reliable)

local function playHitReact(enemy: Model)
	local track = tracks[enemy]
	if track == nil then
		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		local animations = enemy:FindFirstChild("Animations")
		local hitReact = animations and animations:FindFirstChild("HitReact")
		if animator == nil or hitReact == nil or not hitReact:IsA("Animation") then
			return -- no animation yet (F5 adds it); the movement pause still reads
		end
		local loaded = animator:LoadAnimation(hitReact)
		loaded.Priority = Enum.AnimationPriority.Action
		tracks[enemy] = loaded
		track = loaded
		enemy.Destroying:Once(function()
			local cached = tracks[enemy]
			tracks[enemy] = nil
			if cached then
				cached:Destroy()
			end
		end)
	end
	if track then
		track:Play(0.05)
	end
end

-- Call for a gun hit only (not splash, not the spin). Returns true if it flinched.
function EnemyFlinch.onGunHit(enemy: Model): boolean
	local t = workspace:GetServerTimeNow()
	if enemy:GetAttribute("Attacking") == true then
		return false -- never mid-attack: EnemyService sets Attacking during wind-ups and attacks
	end
	local stunned = enemy:GetAttribute("StunnedUntil")
	if typeof(stunned) == "number" and t < stunned then
		return false
	end
	local nextAt = enemy:GetAttribute("NextFlinchAt")
	if typeof(nextAt) == "number" and t < nextAt then
		return false
	end
	local cooldownAttr = enemy:GetAttribute("FlinchCooldown")
	local cooldown = if typeof(cooldownAttr) == "number" then cooldownAttr else Constants.FLINCH_COOLDOWN_DEFAULT
	if cooldown <= 0 then
		return false
	end
	local jitter = rng:NextNumber(Constants.FLINCH_COOLDOWN_JITTER_MIN, Constants.FLINCH_COOLDOWN_JITTER_MAX)
	enemy:SetAttribute("FlinchUntil", t + Constants.FLINCH_TIME)
	enemy:SetAttribute("NextFlinchAt", t + Constants.FLINCH_TIME + cooldown * jitter)
	playHitReact(enemy)
	return true
end

-- EnemyService's AI tick: a flinching enemy doesn't move or start attacks.
function EnemyFlinch.isFlinching(enemy: Model): boolean
	local untilTime = enemy:GetAttribute("FlinchUntil")
	return typeof(untilTime) == "number" and workspace:GetServerTimeNow() < untilTime
end

return EnemyFlinch
```

### §6 `Server.Util.SpawnPlacement` (ModuleScript)
```lua
--!strict
-- Where new enemies appear (Combat Polish): just off-screen ahead of the squad; behind only on a
-- 1-in-3 roll while the squad isn't advancing. +X is forward (caboose -> engine).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants") :: ModuleScript)

local SpawnPlacement = {}

-- points: candidate EnemySpawn positions; playerXs: the X of every player who isn't BledOut
-- (downed players still see their area). Returns a position or nil.
function SpawnPlacement.choose(points: { Vector3 }, playerXs: { number }, advancing: boolean, rng: Random): Vector3?
	if #points == 0 or #playerXs == 0 then
		return nil
	end
	local front, back = -math.huge, math.huge
	for _, x in playerXs do
		front = math.max(front, x)
		back = math.min(back, x)
	end
	-- The camera can be centred CAMERA_LEAD_MOVING ahead of a running player, so clear that too.
	local edge = Constants.CAMERA_WIDTH_STUDS / 2 + Constants.CAMERA_LEAD_MOVING + Constants.SPAWN_EDGE_MARGIN
	local ahead: { Vector3 } = {}
	local behind: { Vector3 } = {}
	for _, point in points do
		local offScreen = true
		for _, x in playerXs do
			if math.abs(point.X - x) < edge then
				offScreen = false
				break
			end
		end
		if offScreen then
			if point.X > front then
				table.insert(ahead, point)
			elseif point.X < back then
				table.insert(behind, point)
			end
		end
	end
	local useBehind = (#behind > 0 and not advancing and rng:NextNumber() < Constants.SPAWN_BEHIND_CHANCE) or #ahead == 0
	local pool = if useBehind then behind else ahead
	if #pool == 0 then
		return nil
	end
	local anchorX = if useBehind then back else front
	table.sort(pool, function(a, b)
		return math.abs(a.X - anchorX) < math.abs(b.X - anchorX)
	end)
	return pool[1] -- the nearest off-screen point, so enemies walk into view rather than appear far off
end

-- Positions for a whole wave, spread away from the squad with a running 3-10 stud offset.
function SpawnPlacement.spread(position: Vector3, count: number, awayX: number, rng: Random): { Vector3 }
	local out = { position }
	local offset = 0
	for _ = 2, count do
		offset += rng:NextNumber(Constants.SPAWN_SPREAD_MIN, Constants.SPAWN_SPREAD_MAX)
		table.insert(out, position + Vector3.new(awayX * offset, 0, 0))
	end
	return out
end

-- Tracks whether the squad's front is moving forward. Sample it on its own fixed
-- SPAWN_ADVANCE_SAMPLE tick (not the wave tick, which is 2 s or more), and make a new
-- tracker in every SpawnService.begin().
export type AdvanceTracker = { samples: { { t: number, x: number } } }

function SpawnPlacement.newTracker(): AdvanceTracker
	return { samples = {} }
end

function SpawnPlacement.update(tracker: AdvanceTracker, frontX: number, t: number)
	table.insert(tracker.samples, { t = t, x = frontX })
	-- Keep the oldest sample that still spans the whole window.
	while #tracker.samples > 2 and t - tracker.samples[2].t >= Constants.SPAWN_ADVANCE_WINDOW do
		table.remove(tracker.samples, 1)
	end
end

function SpawnPlacement.isAdvancing(tracker: AdvanceTracker): boolean
	local samples = tracker.samples
	if #samples < 2 or samples[#samples].t - samples[1].t < Constants.SPAWN_ADVANCE_WINDOW then
		return true -- not enough history yet
	end
	return samples[#samples].x - samples[1].x >= Constants.SPAWN_ADVANCE_MIN
end

return SpawnPlacement
```

### §6b `ReplicatedStorage.Shared.CameraLead` (ModuleScript)
```lua
--!strict
-- The moving camera lead (Combat Polish): lead ahead only while moving, slide across when
-- turning, recentre when stopped. CameraController adds the result to the root's X.
local Constants = require(script.Parent:WaitForChild("Constants") :: ModuleScript)

local CameraLead = {}

function CameraLead.step(current: number, velocityX: number, dt: number): number
	local target = 0
	if math.abs(velocityX) >= Constants.CAMERA_MOVE_THRESHOLD then
		target = if velocityX > 0 then Constants.CAMERA_LEAD_MOVING else -Constants.CAMERA_LEAD_MOVING
	end
	local maxStep = Constants.CAMERA_LEAD_RATE * dt
	return current + math.clamp(target - current, -maxStep, maxStep)
end

return CameraLead
```

### §6c `Client.Controllers.FeelEffects` (ModuleScript)
```lua
--!strict
-- Cosmetic Combat Polish effects: muzzle flashes and the dynamite fuse blink. EffectsController
-- calls these from its record handlers. Client-only; nothing here affects gameplay.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants") :: ModuleScript)
local Types = require(Shared:WaitForChild("Types") :: ModuleScript)

local FeelEffects = {}
FeelEffects.Modes = { "Run" } :: { Types.Mode }

local function effectsFolder(): Instance
	return workspace:FindFirstChild("Effects") or workspace
end

-- A flash template from Assets.Effects at `position`, its LookVector along the shot (+/-X).
function FeelEffects.muzzleFlash(templateName: string, position: Vector3, directionX: number)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local effects = assets and assets:FindFirstChild("Effects")
	local template = effects and effects:FindFirstChild(templateName)
	if template == nil or not (template:IsA("BasePart") or template:IsA("Model")) then
		return
	end
	local flash = template:Clone()
	local frame = CFrame.lookAt(position, position + Vector3.new(if directionX >= 0 then 1 else -1, 0, 0))
	if flash:IsA("Model") then
		flash:PivotTo(frame)
	elseif flash:IsA("BasePart") then
		flash.CFrame = frame
	end
	flash.Parent = effectsFolder()
	task.delay(Constants.MUZZLE_FLASH_TIME, function()
		flash:Destroy()
	end)
end

-- Blink a dynamite clone's FuseSpark faster and faster until explodesAt (server time).
function FeelEffects.fuseBlink(dynamite: Instance, explodesAt: number)
	local spark = dynamite:FindFirstChild("FuseSpark", true)
	if spark == nil or not spark:IsA("BasePart") then
		return
	end
	task.spawn(function()
		local lit = true
		while dynamite.Parent ~= nil do
			local remaining = explodesAt - workspace:GetServerTimeNow()
			if remaining <= 0 then
				break
			end
			lit = not lit
			spark.Transparency = if lit then 0 else 1
			task.wait(math.max(remaining * Constants.FUSE_BLINK_FACTOR, Constants.FUSE_BLINK_MIN))
		end
	end)
end

return FeelEffects
```

### §7 Hook points (adapt to the live scripts)
**[[CombatService]]:**
- **`damageEnemy(enemy, amount, by)`:** if `by`, call `EnemyPerception.noteHit(enemy, by)`.
- **Gun hits** (the rifle hitscan and each Scattergun pellet, but **not** splash or spin):
  after `damageEnemy`, call `EnemyFlinch.onGunHit(enemy)`.
- **Muzzle flash:**
  - on each shot, read the weapon's `MuzzleFlash` attribute and queue a new effect record
    `M`: `x, y, dirX, template`, at the Muzzle point,
  - the Scattergun sends one `M` per shot, not per pellet,
  - the Pocket Rocket sends it when it launches.
- **Splash damage** (the rocket, Dan's dynamite, and later GadgetService's stomp and Air
  Strike): for each enemy in the radius, call
  `CombatService.knockback(enemy, CombatFeel.explosionVelocity(center, enemyRoot.Position, push))`,
  where `push` is the weapon's `ExplosionPush` or `EXPLOSION_PUSH`.
- **`damagePlayer(player, raw)`:**
  - `if CombatFeel.isInvulnerable(player) then return end` at the top,
  - `CombatFeel.grantInvulnerability(player, Constants.PLAYER_IFRAMES)` after the damage
    is applied.
  - This covers every source, gap falls included.
- **The spin, "until landing"** (it replaces the one-shot spin hit):
  - **reject `RequestSpin` while `state.spinning`**, so a request can't reset the hit list,
  - when a `RequestSpin` is accepted: `state.spinning = true`, `state.spinHits = {}`,
    `state.spinStarted = now`, and the Player attribute `Spinning = true`,
  - every Heartbeat, for each spinning player:
    - **end the spin** (`spinning = false`, `Spinning = false`) if any of these is true:
      - it's grounded (the same probe as the spin validation),
      - the root is nil or Health ≤ 0,
      - `now − spinStarted > SPIN_MAX_TIME` (1.5 s). The client owns its physics, so
        this cap stops a hover exploit turning the spin into a permanent damage aura,
    - otherwise, for each enemy hitbox within the character's `SpinRadius` that isn't in
      `spinHits`:
      - `damageEnemy(enemy, SpinDamage, player)` (source "Spin"),
      - `knockback(enemy, CombatFeel.spinVelocity(root.Position, enemyRoot.Position, SpinLevel))`,
      - mark it hit.

      Read `SpinDamage`, `SpinRadius` and `SpinLevel` from the character's attributes
      ([[AgentService]]: Max 6 / 5 / 4, Brick 9 / 6 / 6). Fall back to the `SPIN_*`
      constants.
  - **the gun pauses:** the fire loop skips shots while `state.spinning`. `state.fire` is
    untouched, so holding fire resumes on landing. **On landing, set
    `nextShot = math.max(nextShot, now)`** so the cadence doesn't fire a backlog of
    skipped shots at once.
  - Keep sending the `S` record at the spin start (the ring visual).

**[[EnemyService]]:**
- **`spawn`:** `enemy:SetAttribute("SpawnedAt", workspace:GetServerTimeNow())`.
- **The AI tick, at the top:** `if EnemyFlinch.isFlinching(enemy) then` → no movement and no
  new attack this tick.
- **Targeting:** replace "nearest living player" with
  `EnemyPerception.selectTarget(enemy, livingPlayers, state.target)`.
  - With no target, keep walking in the facing direction for
    `EnemyPerception.lostWalkTime(rng)`, then turn round (patrol). Turn at carriage ends
    and gaps, as the probes already do.
  - **Keep the target while turned away on purpose:** whenever an enemy starts a back-off
    (Lobber `KeepDistance`, Shooter `MinRange`), a leap or a charge at its target, call
    `EnemyPerception.noteHit(enemy, target)` to refresh its aggro. `Humanoid:Move` turns
    it to face where it walks, so otherwise it would lose the target and oscillate.
- **`Attacking`:** set `enemy:SetAttribute("Attacking", true)` during every wind-up (the
  Shooter's tell, Bart's wind-up and charge, the melee swing) and back to `false` after.
- **Attack-cadence jitter:**
  - the Shooter's and Lobber's random 2.5–4 s intervals already give the spread the spec
    asks for; keep them,
  - **our addition:** melee `nextAttack = now + CombatFeel.jitter(AttackInterval)`, so
    crowds don't swing in sync either. Drop it if it feels mushy.
- **Shooter:**
  - fire only if `CombatFeel.canFireYet(enemy)`,
  - use `CombatFeel.tellTime()` instead of the fixed `TellTime`,
  - back away while closer than `MinRange` (reuse the Lobber's keep-distance movement),
  - the random 2.5–4 s interval stays.
- **Lobber:**
  - throw only if `CombatFeel.canFireYet(enemy)`,
  - the throw velocity becomes
    `CombatFeel.lobVelocity(handPos, targetFeet, DYNAMITE_GRAVITY, enemyRoot.AssemblyLinearVelocity)`,
    replacing the fixed 0.9 s arc. Skip the throw if it returns nil,
  - add `explodesAt` (server time) to the dynamite's **landing** `R` correction (the fuse
    starts on landing, so the time isn't known at the throw),
  - **when thrown dynamite explodes, damage enemies in the radius too**
    (`CombatService.damageEnemy(enemy, Damage, nil)`, source "Hazard", so no player gets
    the credit), plus the pop-up knockback above.
- **Charger:** `ChargeSpeed` is now 26.7 (the setup script sets it). `Attacking` stays
  true through the wind-up and the charge.

**[[SpawnService]]:**
- **The tracker:**
  - make a new `SpawnPlacement.newTracker()` in every `begin()`,
  - sample it on its **own fixed `SPAWN_ADVANCE_SAMPLE` (0.25 s) tick**:
    `SpawnPlacement.update(tracker, frontX, now)`, where frontX is the largest X of the
    players who aren't `BledOut`.
- **Choosing a point:**
  - call `SpawnPlacement.choose(enemySpawnPositions, playerXs, SpawnPlacement.isAdvancing(tracker), rng)`,
    with playerXs from every player who isn't `BledOut`. This replaces the 20-stud minimum
    rule,
  - the off-screen edge is now about 55 studs (35 half-view + 17 lead + 3), so **widen
    the candidate filter** from "within one carriage of a player" to **two carriages**, or
    `choose` may find no point and return nil (spawn nothing that tick).
- **A whole wave:** `SpawnPlacement.spread(position, count, awayX, rng)` returns all the
  positions, with a running 3–10 stud offset. Check that each is still on a
  `WalkSurface` (drop to the nearest roof if not).

**[[SquadService]]:**
- When a revive completes:
  - `CombatFeel.grantInvulnerability(target, Constants.REVIVE_GRACE)`,
  - for every enemy within `REVIVE_PUSH_RADIUS` of the target:
    `CombatService.knockback(enemy, CombatFeel.radialVelocity(targetRoot.Position, enemyRoot.Position, Constants.REVIVE_PUSH_SPEED))`.
    That's sideways only, 40 studs/s, so pushed enemies stay on the train. A fall takes the
    "removed, no ragdoll" path, which would skip drops such as the thief's bag.

**[[EffectsController]]:**
- **`M` records:** `FeelEffects.muzzleFlash(template, Vector3.new(x, y, 0), dirX)`.
- **Dynamite `R` records with `explodesAt`:** call `FeelEffects.fuseBlink(clone, explodesAt)`
  **once per clone**. Mark the clone (e.g. its `Blinking` attribute) so a repeated record
  doesn't start a second loop.

**[[CameraController]]:** keep a `lead` number (starting at 0). Every frame:
`lead = CameraLead.step(lead, root.AssemblyLinearVelocity.X, dt)`, then use `root.X + lead`
instead of `root.X + CAMERA_LEAD × facing`. The existing smoothing stays.

**[[InputController]]:** no change to the spin input. While the Player attribute
`Spinning` is true, the client can show the spin pose and hide the gun (F3).

**Reviewed 2026-10-16** by a read-only code review. Fixed:
- off-screen spawns ignoring the camera lead,
- the advance tracker never seeing the squad stop,
- an uncapped spin (a hover exploit) and re-spin resets,
- the per-agent spin values,
- a fire backlog on landing,
- perception oscillating while backing off,
- the revive shove flinging enemies off the train,
- the hit-react track cache,
- the flash shapes, the fuse-spark position, the wave spread, and the dynamite fuse
  timing and double blink.

## §8 Verify (one item at a time)
1. **Flinch:**
   - rifle a Bandana Bandit: it stops for about 0.2 s on the first hit,
   - further hits inside about 0.75 s don't flinch it,
   - it never flinches during Bart's wind-up or charge, or a Shooter's tell,
   - with `FlinchCooldown` 0 it never flinches.
2. **Muzzle flashes:** each weapon shows its flash at the muzzle, facing the shot. The
   Scattergun shows one per shot. Nothing is left in `workspace.Effects`.
3. **Jitter and telegraphs:**
   - spawn 4 Bandits together: their swings drift apart,
   - a Six-Shooter never fires in its first 4 s, and fires 0.5–0.6 s after its "!".
4. **Perception:**
   - approach a Bandit from behind without shooting: it doesn't react,
   - shoot it: it turns and comes,
   - jump over it: it walks on, then turns round after about 1 s.
5. **Spawning:**
   - enemies appear just past the screen edge ahead, never on screen (check at 16:9 and
     on a phone),
   - standing still for 3 s+ sometimes spawns one behind,
   - running flat out, nothing pops in at the leading screen edge (the lead is included).
6. **Dynamite:**
   - it lands at your feet on a low arc whether you're near or far, on a higher roof or a
     lower one,
   - the fuse blinks faster to the end,
   - the blast knocks bandits up and can knock them out (no score for you).
7. **i-frames:** stand in a crowd: damage arrives in ≥ 0.3 s steps, never several hits at
   once.
8. **Spin:**
   - the spin hits each enemy once while you're airborne, popping them up and away (about
     27 studs/s for Max, 40 for Brick, using their own SpinDamage and SpinRadius),
   - the gun stops until you land, then resumes at its normal cadence, with no burst of
     stored shots,
   - a second `RequestSpin` mid-spin is refused,
   - a spin never lasts longer than 1.5 s,
   - the spin validation still rejects grounded spins.
9. **Revive grace:** a revived player can't be hurt for 3 s. Nearby enemies are shoved
   sideways and stay on the train.
10. **Camera:**
    - running, the view leads about 17 studs ahead,
    - turning, it slides across in about 2 s,
    - stopping, it recentres,
    - no jitter when tapping back and forth. Tune `CAMERA_LEAD_MOVING` and `CAMERA_LEAD_RATE`
      against the 70-stud view.
11. **Big Bart:** the charge runs at 26.7 studs/s. Max outruns it; Brick doesn't. The
    stagger still works.
12. **Console:** no errors, and no new strikes in [[Guard]] logs.

Related: [[Combat Polish]] · [[Feel and Look (Slice)]] · [[CombatService]] · [[EnemyService]] · [[SpawnService]] · [[SquadService]] · [[EffectsController]] · [[CameraController]]
