--====================
-- a few optimisations
--====================
local _min,_max = math.min,math.max

--====================
-- ensure the seed is set once at the start
--====================
math.randomseed(os.time())
for i=1, 10 do
	math.random()
end

--====================
-- local, persistent data
--====================
local index = {}
local nextID = 1

local specials = {}
local specialsPrevRefresh = 0

local function isValidItem(item)
	return	not item.special and 
			not item.deprecated and
			item.category ~= nil
end

local function isValidUnlockItem(item)
	local validUnlockCategories = {
		[1] = true,	-- IC_WEAPUP
		[6]	= true,	-- IC_TDUP
		[11] = true, -- IC_EVENT
	}

	return isValidItem(item) and 
			item.levels ~= nil and
			validUnlockCategories[item.category] and
			item.levelUnlocked < item.numLevels
end

--====================
-- generic accessors
--====================
local function findItem(uid)
	local item = index[uid]
	if not item then
		print("Cannot find item", uid)
	end
	return item
end

local function getFieldFromItem(item, field, level)
	if not item then return end

	-- first, look in the base of the item, then check the levels
	if item[field] then
		return item[field]
	end

	if item.numLevels then
		level = level or _min(item.levelOwned+1,item.numLevels)	
		for t = level,1,-1 do	
			local val = item.levels[t][field]
			if val then 
				return val 
			end
		end
	end
end

--====================
-- load the raw data
--====================
local chunk = loadfile("DB/db.lua")
local db = chunk()

for _,item in ipairs(db) do
	assert(index[item.__id]==nil)
	index[item.__id] = item
	item.levelOwned = 0
	item.levelUnlocked = 0

	if item.levels then
		item.numLevels = #item.levels
	end
end

local function buyItem(item, level)
	if item.special then
		level = item.levelId
		item = findItem(item.itemId)
	end

	local newLevelOwned
	if level then
		newLevelOwned = _max(level, item.levelOwned)
	else
		newLevelOwned = item.levelOwned + 1
	end

	item.levelOwned = newLevelOwned
	item.levelUnlocked = _max(item.levelUnlocked, newLevelOwned)
end

local function unlockItem(item, level)
	item.levelUnlocked = _max(item.levelUnlocked, level)
	local price = getFieldFromItem(item, "price", level)
	if price == 0  then
		buyItem(item, level)
	end
end

--============================
-- set prices from the backend
--============================

local priceTiers = 
{
	free = {price=0, currency=0},

	char_low = {price=80, currency=1},
	char_med = {price=100, currency=1},
	char_high = {price=150, currency=1},

	item_lev1 = {price=1000, currency=0},
	item_lev2 = {price=1400, currency=0},
	item_lev3 = {price=2000, currency=0},
	item_lev4 = {price=3000, currency=0},
	item_lev5 = {price=4400, currency=0},
	item_lev6 = {price=6200, currency=0},
	item_lev7 = {price=8400, currency=0},
	item_lev8 = {price=11000, currency=0},
	item_lev9 = {price=14000, currency=0},

	cons_coins_1 = {price=4, currency=1},
	cons_coins_2 = {price=6, currency=1},
	
	cons_gems_1 = {price=800, currency=0},
	cons_gems_2 = {price=1600, currency=0},
	
	cons_score_1 = {price=1, currency=1},
	cons_score_2 = {price=2, currency=1},
	
	cons_mayhem_1 = {price=500, currency=0},
	cons_mayhem_2 = {price=800, currency=0},
	
	cons_damage_1 = {price=400, currency=0},
	cons_damage_2 = {price=2, currency=1},
	cons_damage_3 = {price=4, currency=1},
	
	cons_health_1 = {price=2, currency=1},
	cons_health_2 = {price=4, currency=1},
	
	cons_magnet_1 = {price=4, currency=1},
}

function GOAT.db.setPriceTier(tier, price, currency)
	local t = priceTiers[tier]
	if t and price > 0 and (currency == 0 or currency == 1) then
		t.price = price
		t.currency = currency
	end
end

function GOAT.db.setPrices()
	for _,item in ipairs(db) do
		if isValidItem(item) and item.levels then
			for _,v in ipairs(item.levels) do
				if v.priceTier then
					local pT = priceTiers[v.priceTier]
					v.price = pT.price
					v.currency = pT.currency
				end
			end
		end
	end
end

--============================
--============================

function GOAT.db.itemCreate(id)
	if not id then
	while index[nextID] do
		nextID = nextID + 1
	end
		id = nextID
	end

	local newItem = {__id = id}
	db[#db+1] = newItem
	index[newItem.__id] = newItem

	nextID = nextID + 1
	return newItem.__id
end

function GOAT.db.ownedCharacterUpgradeQuery()
	local res = {}

	for _,item in ipairs(db) do
		-- see if it's a character
		if item.category == 0 and isValidItem(item) and item.levelOwned>0 then
			-- check character's weapons
			for _, w in ipairs(item.characterData.weapons) do
				local wep = findItem(w.wepItemID)
				if wep.levelUnlocked > wep.levelOwned then
					res[#res+1] = item.__id
					break
				end
			end
			-- if there are no weapon upgrades check gadgets
			if res[#res] ~= item.__id then
				for _, g in ipairs(item.characterData.gadgets) do
					local gad = findItem(g)
					if gad.levelUnlocked > gad.levelOwned then
						res[#res+1] = item.__id
						break
					end
				end
			end
		end
	end
	return res
end

function GOAT.db.fieldQuery(field1, val1, field2, val2)
	local res = {}
	for _,item in ipairs(db) do
		if not item.deprecated and not (item.enabled==false) then
			if item[field1] == val1 then
				if not field2 or item[field2] == val2 then
					res[#res+1] = item.__id
				end
			end
		end
	end
	return res
end

function GOAT.db.tabQuery(tab)
	local res = {}
	for _,item in ipairs(db) do
		if not item.deprecated and item.tab == tab and not (item.enabled==false) then
			res[#res+1] = item.__id
		end
	end
	return res
end

function GOAT.db.unlockItems(numToUnlock)
	local res = {}
	numToUnlock = math.min(numToUnlock, GOAT.db.remainingUnlocks())

	for _=1, numToUnlock do

		local _owned = {}
		local _unowned = {}
		local _lowestLevel = math.huge

		local function insertItem(itemID, owned)
			local item = findItem(itemID)
			if isValidUnlockItem(item) then
				_lowestLevel = math.min(_lowestLevel, item.levelUnlocked)

				if owned then
					_owned[itemID] = itemID
					_unowned[itemID] = nil
				else
					if not _owned[itemID] then
						_unowned[itemID] = itemID
					end
				end
			end
		end

		local function extractItems(_ch, owned)
			for _, w in ipairs(_ch.characterData.weapons) do
				insertItem(w.wepItemID, owned)
			end
			for _, g in ipairs(_ch.characterData.gadgets) do
				insertItem(g, owned)
			end
		end

		for _,item in ipairs(db) do
			-- see if it's a character
			if item.category == 0 and isValidItem(item) then
				extractItems(item, item.levelOwned>0)
			end
		end

		local _ownedBucket = {{}, {}, {}}
		local _unownedBucket = {{}, {}, {}}

		local function makeBuckets(src, dest)
			for _,itemID in pairs(src) do
				local item = findItem(itemID)
				local diff = item.levelUnlocked - _lowestLevel
				if diff < 3 then -- ignore anything more than 3 away from the base
					table.insert(dest[diff+1], itemID)
				end
			end
		end

		makeBuckets(_owned, _ownedBucket)
		makeBuckets(_unowned, _unownedBucket)

		local bucketRemap = {}
		local probTotal = 0

		local function addEntry(b, p)
			--print('adding bucket with '..(#b)..' elements')
			if #b>0 then
				bucketRemap[#bucketRemap+1] = {bucket=b, prob=p}
				probTotal = probTotal + p
				return true
			end
		end

		if not addEntry(_ownedBucket[1], 1000) then
			addEntry(_ownedBucket[2], 500)
			addEntry(_ownedBucket[3], 100)
			addEntry(_unownedBucket[1], 500)
			addEntry(_unownedBucket[2], 100)
			addEntry(_unownedBucket[3], 50)
		end

		local entry
		local i = 0
		local r = math.random(1, probTotal)
		while r > 0 do
			i = i + 1
			r = r - bucketRemap[i].prob
		end

		local bucket = bucketRemap[i].bucket
		entry = bucket[math.random(1, #bucket)]

		local item = findItem(entry)
		print("UNLOCKING ->", entry, (_owned[entry] and "owned") or "not owned", item.levelUnlocked, item.numLevels)
		unlockItem(item, item.levelUnlocked+1)
		res[#res+1] = {item=entry, level=item.levelUnlocked}
	end

	return res
end

function GOAT.db.remainingUnlocks()
	local count = 0
	for _, item in pairs(db) do
		if isValidUnlockItem(item) then
			count = count + (item.numLevels - item.levelUnlocked)
		end
	end

	return count
end

function GOAT.db.serialiseQuery()
	local res = {}
	for _,item in ipairs(db) do
		if item.serialisable then
			res[#res+1] = item
		end
	end
	return res
end

function GOAT.db.itemValidate(uid)
	local item = findItem(uid)
	return item ~= nil
end

function GOAT.db.itemSet(uid, field, val)
	local item = findItem(uid)
	item[field] = val
	return item.serialisable
end

function GOAT.db.itemBuy(uid, level)
	local item = findItem(uid)
	buyItem(item)
end

function GOAT.db.itemGet(uid, field)
	local item = findItem(uid)
	local val = getFieldFromItem(item, field)
	-- print("DB: Looking up "..uid.."."..field.." => "..tostring(val))
	return val
end

function GOAT.db.countTotalExpenditure()
	local ret = {coins=0, gems=0}
	for _,item in ipairs(db) do
		if item.levelOwned then
			if (item.numLevels or item.deprecated) and not item.special then
				for lev=1,item.levelOwned do

					local level = lev
					-- deal with old 'obsolete' items
					if item.deprecated and item.numLevels < level then
						level = item.numLevels
					end
					local price = getFieldFromItem(item, "price", level)
					local currency = getFieldFromItem(item, "currency", level)
					if price then
						if currency == 0 then
							ret.coins = ret.coins + price		
							print("reimbursing item "..item.__id.." for "..price.." coins")
						elseif currency == 1 then
							ret.gems = ret.gems + price
							print("reimbursing item "..item.__id.." for "..price.." gems")
						end
					end
				end
			end
		end
	end
	return ret.coins, ret.gems
end

function GOAT.db.patchProfile(_version, numBlueprints)
	-- patch the blueprint stuff
	if _version < 8 then
		for _,item in ipairs(db) do
			if item.levels and item.unlockOrder then
				-- default it to the owned level
				local _unlocked = item.levelOwned
				for level=1,item.numLevels do
					local unlockOrder = getFieldFromItem(item, "unlockOrder", level)
					if unlockOrder <= numBlueprints then
						_unlocked = _max(_unlocked, level)
					end
				end

				item.levelUnlocked = _unlocked
			end
		end
	end

	-- patch the gadget and gadgetU stuff
	if _version < 10 then
		for _,item in ipairs(db) do
			if item.gadgetSuccessor then
				if item.levelOwned > 0  or item.levelUnlocked > 0 then
					local successor = findItem(item.gadgetSuccessor)
					local lOwned = _max(successor.levelOwned, item.levelOwned+1)
					local lUnlocked = _max(successor.levelUnlocked, item.levelUnlocked+1)
					print('patching item',successor.__id,"levelOwned from",successor.levelOwned,"to",lOwned)
					print('patching item',successor.__id,"levelUnlocked from",successor.levelUnlocked,"to",lUnlocked)
					successor.levelOwned = lOwned
					successor.levelUnlocked = lUnlocked
				end
			end
		end
	end
end

function GOAT.db.postSerialise()
	print('Calling PostSerialise')
	for _,item in ipairs(db) do
		if isValidUnlockItem(item) or item.category == 0 then
			for level=1,item.numLevels do
				local price = getFieldFromItem(item, "price", level)
				local startUnlocked = item.levels[level].startUnlocked

				-- Unlock start items
				if startUnlocked then
					unlockItem(item, level)
				end

				-- Buy free items
				if item.levelUnlocked >= level and price == 0 then
					buyItem(item, level)
				end
			end
		end
	end
end

function GOAT.db.countDeprecatedExpenditure()
	local coins = 0
	local gems = 0

	for _,item in ipairs(db) do

		if item.deprecated then
			for i=1, item.levelOwned do
				local currency = getFieldFromItem(item, "currency", level)
				local price = getFieldFromItem(item, "price", level)

				if currency == 0 then
					coins = coins+price
				elseif currency == 1 then
					gems = gems+price
				else
					error("Unknown currency")
				end
			end
			item.levelOwned=0
		end
	end

	return coins, gems
end

function GOAT.db.resetDeprecated()
	local dirty = false

	for _,item in ipairs(db) do
		if item.deprecated and item.levelOwned then
			dirty = true
			item.levelOwned = 0
		end
	end

	return dirty
end

function GOAT.db.resetToDefault(includeIAPs)
	specials = {}
	specialsPrevRefresh = 0

	for _,item in ipairs(db) do
		if not item.special and (includeIAPs or not item.iapName) then
			item.levelOwned = 0
			item.levelUnlocked = 0
		end
	end
end


------=====================================
------ Specials stuff - needs rationalising
------=====================================
function GOAT.db.specialsQuery(refreshInterval, coinToGemRatio, lockedMod, unlockedMod)
	---------------------------------------------
	-- Random functions, (This code isn't mine!)
	-- Should this be moved to some other location?
	-- https://www.taygeta.com/random/gaussian.html
	-- http://opentibia.net/topic/109869-code-for-generating-random-numbers-in-normal-distribution/

	local function internal_rand_normal()
		local x1, x2, w, y1, y2
		repeat 
			x1 = 2 * math.random() - 1
			x2 = 2 * math.random() - 1
			w = x1*x1+x2*x2
		until (w < 1)
	 
		w = math.sqrt((-2*math.log(w))/w)
		y1 = x1*w
		y2 = x2*w
		return y1,y2
	end
	 
	local function rand_normal(min, max, variance, strict_min, strict_max)
		local average=(min+max)/2
		if variance==nil then variance=2.4 end --2.4 because it means that 98,36% from all values will be between min and max

		local escala=(max-average)/variance 
		local x=escala*internal_rand_normal()+average

		if strict_min~=nil then
			x=math.max(x,strict_min)
		end
		if strict_max~=nil then
			x=math.min(x,strict_max)
		end
		return(x)
	end

	local function selectNewSpecials()
		---------------------------------------------
		-- Remove all the existing specials
		specials = {}

		---------------------------------------------
		-- Valid categories fo specials
		local validCategories = {
			[1] = true,	-- IC_WEAPUP
			[6]	= true,	-- IC_TDUP
			[11] = true, -- IC_EVENT
		}

		---------------------------------------------
		-- Tweaks for modifying selection and price
		-- TODO: Theese will need to come from the server

		local selection =
		{
			{ min=0.0, max=0.2, },
			{ min=0.2, max=0.4, },
			{ min=0.4, max=1.0, },
		}

		---------------------------------------------
		-- Create an array of available specials
		local availableSpecials = {}

		for _, item in pairs(db) do
			if not item.deprecated and validCategories[item.category] and not item.special then
				local price = 0

				for level=(item.levelOwned+1) or 1, item.numLevels do
					---------------------------------------------
					-- Calculate price, Incremental
					local p = getFieldFromItem(item, "price", level)
					local c = getFieldFromItem(item, "currency", level)
					local l = level > item.levelUnlocked

					if c == 0 then -- If coins, convert to gems
						p = p/coinToGemRatio
					end

					if l then
						p = p*lockedMod
					else
						p = p*unlockedMod
					end

					price = price + math.ceil(p)

					---------------------------------------------
					-- If locked add an entry

					if l then
						local specialEntry = {}
						specialEntry.itemId = item.__id
						specialEntry.levelId = level
						specialEntry.currency = 1
						specialEntry.price = price
						availableSpecials[#availableSpecials+1] = specialEntry
					end

					---------------------------------------------
				end
			end
		end

		---------------------------------------------
		-- Sort the table by price

		table.sort(availableSpecials, function(s1, s2)
			return s1.price < s2.price
		end)

		---------------------------------------------
		-- Select an item to sell
		-- When an item is select all other upgrade levels of the item are removed

		for _, sel in pairs(selection) do
			local n = #availableSpecials

			if n > 0 then
				---------------------------------------------
				-- Select a new item using normal distributed random

				local r = rand_normal(sel.min*n, sel.max*n, 2.4, sel.min*n, sel.max*n)
				r = math.floor(r+0.5)
				r = math.max(r, 1)
				r = math.min(r, n)

				local entry = availableSpecials[r]
				GOAT.db.specialsItemCreate(entry.itemId, entry.levelId, entry.currency, entry.price)

				---------------------------------------------
				-- Copy the availableSpecials without any varition of the new special item

				local _availableSpecials = {}
				for _, specialEntry in ipairs(availableSpecials) do
					if specialEntry.itemId ~= entry.itemId then
						_availableSpecials[#_availableSpecials+1] = specialEntry
					end
				end
				availableSpecials = _availableSpecials

				---------------------------------------------
			end
		end
	end

	local dirty = false

	local nextRefresh = GOAT.db.specialsGetRefreshCountdown(refreshInterval)
	print("refreshing specials", nextRefresh)
	if  nextRefresh <= 0 then
		specialsPrevRefresh = os.time()
		selectNewSpecials()
		dirty = true
	end
	
	return dirty, specials
end

function GOAT.db.specialsItemCreate(itemId, levelId, currency, price)
	specials[#specials+1] = GOAT.db.itemCreate()

	local newItem = findItem(specials[#specials])
	newItem.itemId = itemId
	newItem.levelId = levelId
	newItem.currency = currency
	newItem.price = price
	newItem.serialisable = false
	newItem.special = true
	newItem.tab = 0

	setmetatable(newItem, 
	{
		__index = function(tbl, key)
			return getFieldFromItem(findItem(tbl.itemId), key)
		end,

		__newindex = function(t, k, v)
			print(t, k, v)
			error("Don't modify specials ")
		end,
	})
end

function GOAT.db.specialsSetPrevRefresh(t)
	specialsPrevRefresh = t
end

function GOAT.db.specialsGetPrevRefresh()
	return specialsPrevRefresh
end

function GOAT.db.specialsGetRefreshCountdown(refreshInterval)
	if specialsPrevRefresh > os.time() then
		return 0
	end
	local nextRefresh = specialsPrevRefresh + refreshInterval
	return nextRefresh - os.time()
end

function GOAT.db.consumablesQuery(numOffered)
	local res = {}
	local allCons ={}
	for _,item in ipairs(db) do
		if not item.deprecated and item.category == 17 then
			allCons[#allCons+1] = item
		end
	end

	while #res < numOffered do
		local r = math.random(#allCons)
		local chosen = allCons[r]
		local temp = {}
		for _, item in pairs(allCons) do
			if item.levels[1].title ~= chosen.levels[1].title then
				temp[#temp+1] = item
			end
		end
		allCons = temp
		res[#res+1] = chosen.__id
	end
	return res
end
