Environments = Environments or {}
setmetatable(Environments, {__index=_G})

-- this can be used for conversion between textual and numeric representations of environment
Environments.remap = {}
Environments.remap["oriental"] = 1
Environments.remap["horror"] = 2
Environments.remap["future"] = 3

Skies = {}
Skies["SKY_XMAS1"] = GOAT.TerrainManager.SKY_XMAS1
Skies["SKY_XMAS2"] = GOAT.TerrainManager.SKY_XMAS2
Skies["SKY_XMAS3"] = GOAT.TerrainManager.SKY_XMAS3
Skies["SKY_ORIENTAL"] = GOAT.TerrainManager.SKY_ORIENTAL
Skies["SKY_ORIENTAL_NEW"] = GOAT.TerrainManager.SKY_ORIENTAL_NEW
Skies["SKY_FUTURE"] = GOAT.TerrainManager.SKY_FUTURE
Skies["SKY_FUTURE_NEW"] = GOAT.TerrainManager.SKY_FUTURE_NEW
Skies["SKY_HORROR"] = GOAT.TerrainManager.SKY_HORROR
Skies["SKY_HORROR_NEW"] = GOAT.TerrainManager.SKY_HORROR_NEW

-- function to add an environment to the list
local function AddEnvironment(name)
	local idx = #Environments + 1
	Environments[idx] = {}
	
	local chunk = assert(loadfile(name..".lua"));
	if chunk then
		setfenv(chunk, Environments[idx]);
		chunk();
	end
end

-- function to map a function to each furniture group
local function MapFurnitureGroup(fn)
	for _,env in ipairs(Environments) do
		for _,fg in pairs(env.furn) do
			fn(fg)
		end
	end
end

-- add all the environments here
AddEnvironment("oriental")
AddEnvironment("horror")
AddEnvironment("future")

-- count how many pieces of furniture in total and allocate space
local furnitureCount = 0
MapFurnitureGroup(function(fg)
	for _,f in ipairs(fg) do
		furnitureCount = furnitureCount + 1
	end
end)
GOAT.TerrainManager:SetNumFurniture(furnitureCount)

-- iterate over each furniture group and register the furniture pieces
-- we're also going to need to know the offset of each furniture group into the big array
-- so iterate over each group and set a value on it to indicate its offset and size
-- also, while we're at it, sum the weights
local arrayOffset = 0;
MapFurnitureGroup(function(fg)
	fg.arrayOffset = arrayOffset
	local count = 0
	local totalWeight = 0
	for _,f in ipairs(fg) do
		GOAT.TerrainManager:SetFurniture(arrayOffset+count, f[1], f.weight or 1, f.min or 0, f.max or 0, f.scale or 1)
		count = count + 1
		totalWeight = totalWeight + (f.weight or 1)
	end
	fg.totalWeight = totalWeight
	fg.arrayCount = count
	arrayOffset = arrayOffset + count
end)


local regionCount = 0
for _,env in ipairs(Environments) do
	regionCount = regionCount + #env.reg
end
GOAT.TerrainManager:SetNumRegions(regionCount)

-- iterate over the regions to set up their furniture pointers
-- also, for each group, work out its offset and size in the global region list

arrayOffset = 0
regionCount = 0
for _,env in ipairs(Environments) do
	local arrayCount = 0
	env.arrayOffset = arrayOffset
	for _,reg in ipairs(env.reg) do
		GOAT.TerrainManager:SetRegionSky(regionCount, Skies[reg.sky])
		for i,v in pairs(reg.layers) do
		 	GOAT.TerrainManager:SetRegionLayerEntry(regionCount, i-1, v.arrayOffset, v.arrayCount, v.totalWeight)
		end
		for i, v in ipairs(reg.layerSetup) do
			GOAT.TerrainManager:SetRegionLayerPos(regionCount, i-1, v.minY, v.maxY or v.minY)
		end
		regionCount = regionCount + 1
		arrayCount = arrayCount + 1
	end
	env.arrayCount = arrayCount
	arrayOffset = arrayOffset + arrayCount
end

--finally, register the environments
for idx, env in ipairs(Environments) do
	GOAT.TerrainManager:SetEnvironmentEntry(idx-1, env.arrayOffset, env.arrayCount)
end