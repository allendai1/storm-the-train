--------------------------------------
-- Global
spawnGroups = {}

local spawnGroupCount	= 0
local enemyIDcount		= 0

--------------------------------------
-- Spawn ID bindings
-- These have to be in order! (0 - x)

Spawn_ID = {}
Spawn_ID[0]  = "_1"
Spawn_ID[1]  = "_2"
Spawn_ID[2]  = "_3"
Spawn_ID[3]  = "_4"
Spawn_ID[4]  = "_5"
Spawn_ID[5]  = "_6"
Spawn_ID[6]  = "_7"
Spawn_ID[7]  = "_8"
Spawn_ID[8]  = "_9"
Spawn_ID[9] = "_10"

SPAWN_PREFIX = {}
SPAWN_PREFIX[GOAT.SpawnData.ENV_ORIENTAL]	= "ninja"
SPAWN_PREFIX[GOAT.SpawnData.ENV_HORROR]		= "horror"
SPAWN_PREFIX[GOAT.SpawnData.ENV_FUTURE]		= "future"


--------------------------------------
-- Functions

local function _iter(fn)
	for spawnType, spawnGroupList in pairs(spawnGroups) do
		for groupID, spawnGroup in ipairs(spawnGroupList) do
			local sg = spawnGroup
			while sg do
				fn(spawnGroupList, groupID, sg, sg==spawnGroup)
				sg = sg.SIBLING_NODE
			end
		end
	end
end

local function LoadSpawnGroups()
	local chunk = assert(loadfile("Enemies/spawnGroups.lua"))
	setfenv(chunk, spawnGroups)
	chunk()
end

local function CountSpawnGroups()
	_iter(	function(spawnGroupList, groupID, sg, isRoot) 
				spawnGroupCount = spawnGroupCount + 1
				if sg.ENEMY_ID then
					enemyIDcount = enemyIDcount + #sg.ENEMY_ID
				end		
			end)
end

local function ReserveMemory()
	GOAT.SpawnData:ReserveMemory(spawnGroupCount, enemyIDcount , #Spawn_ID+1)
end

local function InitSpawnIDs()
	for env, prefix in pairs(SPAWN_PREFIX) do
		for i = 0, #Spawn_ID do
			GOAT.SpawnData:SetSpawnIDEnemy(env, i, prefix..Spawn_ID[i])
		end
	end
end

local function InitSpawnGroups()
	local arrayOffset = 0
	_iter(	
		function(spawnGroupList, groupID, sg, isRoot)
			if(sg.SPAWN_DATA) then
				for dataType, value in pairs(sg.SPAWN_DATA) do
					GOAT.SpawnData:SetSpawnGroupData(arrayOffset, GOAT.SpawnData[dataType], value)
				end
			end
			if sg.ENEMY_ID then
				for i, spawnID in ipairs(sg.ENEMY_ID) do
					GOAT.SpawnData:AddSpawnGroupEnemyID(arrayOffset, spawnID)
				end
			end
			sg.arrayOffset = arrayOffset
			arrayOffset = arrayOffset + 1
		end)
end

local function InitSpawnGroupDependencies()
	_iter(	
		function(spawnGroupList, groupID, sg, isRoot)
			if isRoot and spawnGroupList[groupID+1] then
				GOAT.SpawnData:SetSpawnGroupNext(sg.arrayOffset, spawnGroupList[groupID+1].arrayOffset)
			end
			
			if sg.SIBLING_NODE then
				GOAT.SpawnData:SetSpawnGroupChild(sg.arrayOffset, sg.SIBLING_NODE.arrayOffset)
			end	
		end)
end 

local function SetRootSpawnGroups()
	for spawnType, spawnGroupList in pairs(spawnGroups) do
		GOAT.SpawnData:SetRootGroup(spawnGroupList[1].arrayOffset, GOAT.SpawnData[spawnType])
	end
end

-----------------------------------
-- Main

LoadSpawnGroups()
CountSpawnGroups()
ReserveMemory()
InitSpawnIDs()

InitSpawnGroups()
InitSpawnGroupDependencies()
SetRootSpawnGroups()
