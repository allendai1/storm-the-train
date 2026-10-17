-----------------------------------------
-- Global

Enemies = {}

local enemyCount = 0
local archetypeCount = 0
local animCount = 0

local enemyArrayOffset = 0
local archetypeArrayOffset = 0
local animArrayOffset = 0

--------------------------------------
-- Functions

local function InitGibSetup(GibSetup)
	GOAT.EnemyData:CreateCharacterGibSet(enemyArrayOffset)
	for idx, uniqueGib in ipairs(GibSetup.uniqueGibs) do
		GOAT.EnemyData:InitNewActiveGibDef(uniqueGib.textureName, uniqueGib.repCount or 1, uniqueGib.offset or 0, uniqueGib.force or 1)
		GOAT.EnemyData:AddActiveGibDefToActiveCharacterGibSet_unique()
	end

	for idx, genericGib in ipairs(GibSetup.genericGibs) do
		GOAT.EnemyData:InitNewActiveGibDef(genericGib.textureName, genericGib.repCount or 1, genericGib.offset or 0, genericGib.force or 1)
		GOAT.EnemyData:AddActiveGibDefToActiveCharacterGibSet_generic()
	end
end

local  function InitAnimArray( enemyName, animEnum, animArray )
	for i, v in ipairs(animArray) do
		GOAT.EnemyData:InitAnim(enemyName, archetypeArrayOffset, animArrayOffset, v, animEnum)
		animArrayOffset = animArrayOffset + 1
	end
end

local  function InitArchetype(enemyName, archetypeSetup)
	GOAT.EnemyData:InitArchetypeDef(enemyArrayOffset, archetypeArrayOffset, archetypeSetup.archetypeFile, archetypeSetup.spinTexture)

	for anim, animArray in pairs(archetypeSetup.anims) do
		assert(GOAT.EnemyData["ANIM_"..anim], "Enemy: " .. enemyName .. "bad anim: " .. anim)
		InitAnimArray(enemyName, GOAT.EnemyData["ANIM_"..anim], animArray)
	end

	for mesh, texture in pairs(archetypeSetup.meshs) do
		GOAT.EnemyData:InitMesh(archetypeArrayOffset, mesh, texture)
	end
end

local function InitEnemies()
	for enemyName, enemy in pairs(Enemies) do
		----------------------
		-- Enemy Data
		GOAT.EnemyData:SetEnemyDefName(enemyArrayOffset, enemyName)

		for dataName, value in pairs(enemy.EnemySetup) do
			assert(GOAT.EnemyData[dataName], "Enemy " .. enemyName .. " has bad data name" .. dataName)

			if(type(value) == "number") then
		 		GOAT.EnemyData:SetEnemyDefData(enemyArrayOffset, GOAT.EnemyData[dataName], value)
		 	elseif(type(value) == "string") then
		 		assert(GOAT.EnemyData[value], "Unknown data value: " .. value)
		 		GOAT.EnemyData:SetEnemyDefData(enemyArrayOffset, GOAT.EnemyData[dataName], GOAT.EnemyData[value])
		 	else
		 		assert(false, "Unhandled data type")
		 	end
		end 

		GOAT.EnemyData:SetEnemyDefBehaviorType(enemyArrayOffset, GOAT.EnemyData[enemy.EnemyType])

		if(enemy.WeaponData) then
			for wepType, wepName in pairs(enemy.WeaponData) do
			 	GOAT.EnemyData:SetEnemyDefWeapon(enemyArrayOffset, GOAT.EnemyData[wepType], wepName)
			end
		end

		----------------------
		-- Archetype/s Data

		-- Add base here
		for id, archetype in ipairs(enemy.ArchetypeSetup) do
			InitArchetype(enemyName, archetype)
			archetypeArrayOffset = archetypeArrayOffset + 1
		end

		GOAT.EnemyData:SetEnemyDefData(enemyArrayOffset, GOAT.EnemyData["ENEMY_BASE_ARCHETYPES"], #enemy.ArchetypeSetup)

		-- add blueprints here
		if enemy.ArchetypeSetup.blueprint then
			for id, archetype in ipairs(enemy.ArchetypeSetup) do
				InitArchetype(enemyName, archetype)

				for mesh, texture in pairs(enemy.ArchetypeSetup.blueprint) do
					GOAT.EnemyData:InitMesh(archetypeArrayOffset, mesh, texture)
				end

				archetypeArrayOffset = archetypeArrayOffset + 1
			end
		end

		-- Add keys here
		if enemy.ArchetypeSetup.keyBox then
			for id, archetype in ipairs(enemy.ArchetypeSetup) do
				InitArchetype(enemyName, archetype)

				for mesh, texture in pairs(enemy.ArchetypeSetup.keyBox) do
					GOAT.EnemyData:InitMesh(archetypeArrayOffset, mesh, texture)
				end

				archetypeArrayOffset = archetypeArrayOffset + 1
			end
		end

		----------------------
		-- Gib Data
		InitGibSetup(enemy.GibSetup)

		----------------------
		-- Effect Data
		if enemy.EffectData then
			for dataName, value in pairs(enemy.EffectData) do
		 		GOAT.EnemyData:SetEnemyDefEffect(enemyArrayOffset, GOAT.EnemyData[dataName], value)
			end
		end

		enemyArrayOffset = enemyArrayOffset + 1
	end
end

local function ReserveMemory()
	GOAT.EnemyData:ReserveEnemyDefMemory(enemyCount, archetypeCount, animCount)
end

local function CountEnemies()
	for fileName, enemy in pairs(Enemies) do
		-- archetype and anim count
		local archetypeCountForEnemy = 0
		local animCountForEnemy = 0

		for idx, archetype in ipairs(enemy.ArchetypeSetup) do
			archetypeCountForEnemy = archetypeCountForEnemy + 1
			for animID, animList in pairs(archetype.anims) do
				animCountForEnemy = animCountForEnemy + #animList
			end
		end

		-- Base
		archetypeCount = archetypeCount + archetypeCountForEnemy
		animCount = animCount + animCountForEnemy

		-- Keybox
		if enemy.ArchetypeSetup.keyBox then 
			archetypeCount = archetypeCount + archetypeCountForEnemy
			animCount = animCount + animCountForEnemy
		end

		-- Blueprint
		if enemy.ArchetypeSetup.blueprint then
			archetypeCount = archetypeCount + archetypeCountForEnemy
			animCount = animCount + animCountForEnemy
		end

		-- enemy count
		enemyCount = enemyCount + 1
	end
end

local allowedVariables = 
{	WeaponData = true, 
	EnemySetup = true, 
	EnemyType = true,
	ArchetypeSetup = true,
	GibSetup = true,
	EffectData = true,
}

local __STRICT = false

local function AddEnemy(enemyName)
	local fileName = "Enemies/"..enemyName..".lua"
	local chunk, err = loadfile(fileName)

	if chunk then
		Enemies[enemyName] = {}

		setmetatable(Enemies[enemyName], {
			__index = function(t, n)
				if __STRICT then
					if GOAT.EnemyData[n] then
						return GOAT.EnemyData[n]
					else
						error("Undefined variable "..n) 
					end
				else
					return rawget(t, n)
				end
			end,

			__newindex = function(t, n, v)
				if 	not __STRICT or allowedVariables[n] then
					rawset(t,n,v)
				else
					error("Undefined variable "..n) 
				end
			end
			})
		
		setfenv(chunk, Enemies[enemyName])
		__STRICT = true
		chunk()
		__STRICT = false
	elseif err then
		print("Enemy Name: " .. enemyName)
		error(err)
	end
end

local function LoadEnemiesOfType(eType)
	
	AddEnemy(eType.."_1");
	AddEnemy(eType.."_2");
	AddEnemy(eType.."_3");
	AddEnemy(eType.."_4");
	AddEnemy(eType.."_5");
	AddEnemy(eType.."_6");
	AddEnemy(eType.."_7");
	AddEnemy(eType.."_8");
	AddEnemy(eType.."_9");
	AddEnemy(eType.."_10");
end

-----------------------------------
-- Main
LoadEnemiesOfType("ninja")
LoadEnemiesOfType("horror")
LoadEnemiesOfType("future")

AddEnemy("npc_1");

CountEnemies()
ReserveMemory()
InitEnemies()
