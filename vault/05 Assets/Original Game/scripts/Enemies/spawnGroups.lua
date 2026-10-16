--[[
------------------
Spawn group data
	SPAWN_ENABLE_TIME		= The time a spawn group is active for
	SPAWN_WAVE_TIME			= The time between spawn group waves

	SPAWN_WAVE_START_MIN	= The min cost spend at the start
	SPAWN_WAVE_START_MAX	= The max cost spend at the start

	SPAWN_WAVE_END_MIN		= The min cost spend at the end
	SPAWN_WAVE_END_MAX		= The max cost spend at the end

	SPAWN_CAP_START			= The total amount of cost allowed on the train at start
	SPAWN_CAP_END			= The total amount of cost allowed on the train at end

	NEXT_GROUP				= The next active group after this one becomes inactive
	CHILD_GROUPS			= A group that is also active at the time of this spawn group

	ENEMY_ID 				= Enemies to be spawned, theese IDs are mapped in spawnLoader AND ARE NOT THE VALUES USED IN LUA!!


Theese flags will overide the ENEMY_ID list, the value must be between 1 - 3.
All 3 mid enemies are ordered randomly 1 - 3 and the number represents the ordered mid enemy.
The enemies are randomised @ SpawnData::Reset()

	SPAWN_FLAG_SINGLE_MID = Only the mid enemy corresponding to the value will spawn.
	SPAWN_FLAG_PREV_MID = All the mid enmies up to and including the value will spawn.
--]]

------------------
-- Global

SPAWN_GROUP_BOSS 		= {}
SPAWN_GROUP_KEYHOLDER	= {}
SPAWN_GROUP_BOSSSPAWN	= {}

----------------------------
-- NORMAL SPAWNING
--------------------------------------------------- INTRO GROUP

SPAWN_GROUP_NORMAL = 
{
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 15,
			SPAWN_WAVE_TIME			= 0.6,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 3,
			SPAWN_WAVE_START_MAX	= 3,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 4,
			SPAWN_WAVE_END_MAX		= 4,

			-- CAP RANGE
			SPAWN_CAP_START			= 3,
			SPAWN_CAP_END			= 6,
		},
		
		ENEMY_ID	 				= {0},
	},

	--------------------------------------------------- Grp 1 - 15
	-- Introduction of second mob, groups are split for even distribution of enemies
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 30,
			SPAWN_WAVE_TIME			= 2.6,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 3,
			SPAWN_WAVE_START_MAX	= 3,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 4,
			SPAWN_WAVE_END_MAX		= 4,

			-- CAP RANGE
			SPAWN_CAP_START			= 4,
			SPAWN_CAP_END			= 5,
		},
		
		ENEMY_ID	 				= {0},

		SIBLING_NODE = 
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 3,
		
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 3,
				SPAWN_WAVE_START_MAX	= 3,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 3,
				SPAWN_WAVE_END_MAX		= 3,

				-- CAP RANGE
				SPAWN_CAP_START			= 3,
				SPAWN_CAP_END			= 3,
			},
			
			ENEMY_ID	 				= {1},
		},
	},

	--------------------------------------------------- Grp 2 - 45
	-- Combination of the first two enemies into one group to allow a more random outcome, introduction of the third enemy.
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 30,
			SPAWN_WAVE_TIME			= 2.5,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 4,
			SPAWN_WAVE_START_MAX	= 4,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 4,
			SPAWN_WAVE_END_MAX		= 5,

			-- CAP RANGE
			SPAWN_CAP_START			= 5,
			SPAWN_CAP_END			= 6,
		},

		ENEMY_ID	 				= {0, 1},
		
		SIBLING_NODE = 
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 2.8,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 4,
				SPAWN_WAVE_START_MAX	= 4,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 4,
				SPAWN_WAVE_END_MAX		= 4,

				-- CAP RANGE
				SPAWN_CAP_START			= 5,
				SPAWN_CAP_END			= 5,
			},
			
			ENEMY_ID	 				= {2},
		},
	},

	--------------------------------------------------- Grp 3 - 75
	-- Introduction of the fourth enemy, ramp slows down drastically
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 45,
			SPAWN_WAVE_TIME			= 2.5,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 4,
			SPAWN_WAVE_START_MAX	= 5,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 6,
			SPAWN_WAVE_END_MAX		= 8,

			-- CAP RANGE
			SPAWN_CAP_START			= 6,
			SPAWN_CAP_END			= 8,
		},
		
		ENEMY_ID	 				= {0, 1, 2},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 2.4,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 4,
				SPAWN_WAVE_START_MAX	= 4,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 4,
				SPAWN_WAVE_END_MAX		= 4,

				-- CAP RANGE
				SPAWN_CAP_START			= 4,
				SPAWN_CAP_END			= 4,
			},
			
			ENEMY_ID	 				= {3},
		}
	},

	--------------------------------------------------- Grp 4 - 120
	-- Introduction to medium enemies, light enemies stop spawning
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 1,
			SPAWN_WAVE_TIME			= 0.1,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 17,
			SPAWN_CAP_END			= 17,

			-- Spawn FLAGS
			SPAWN_FLAG_SINGLE_MID	= 1,
		},
	},

	--------------------------------------------------- Grp 5 - 130
	-- Single wave after 1st mid kill
	{	
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 15,
			SPAWN_WAVE_TIME			= 1.8,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 3,
			SPAWN_WAVE_START_MAX	= 7,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 3,
			SPAWN_WAVE_END_MAX		= 7,

			-- CAP RANGE
			SPAWN_CAP_START			= 9,
			SPAWN_CAP_END			= 9,
		},
		
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

	--------------------------------------------------- Grp 6 - 145
	-- Gradual ramp of light enemies with irregular spawning  of mids
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 40,
			SPAWN_WAVE_TIME			= 5,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 17,
			SPAWN_CAP_END			= 17,

			-- Spawn FLAGS
			SPAWN_FLAG_PREV_MID		= 1,
		},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 0.8,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 2,
				SPAWN_WAVE_START_MAX	= 4,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 5,
				SPAWN_WAVE_END_MAX		= 8,

				-- CAP RANGE
				SPAWN_CAP_START			= 5,
				SPAWN_CAP_END			= 8,
			},
			
			ENEMY_ID	 				= {0, 1, 2, 3},
		},
	},

	--------------------------------------------------- Grp 8 - 185
	-- Introduction to a new medium enemy, light enemies stop spawning
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 1,
			SPAWN_WAVE_TIME			= 0.1,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 18,
			SPAWN_CAP_END			= 18,

			-- Spawn FLAGS
			SPAWN_FLAG_SINGLE_MID	= 2,
		},
	},

	--------------------------------------------------- Grp 9 - 200
	-- Single wave after 1st mid kill
	{	
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 15,
			SPAWN_WAVE_TIME			= 1.5,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 5,
			SPAWN_WAVE_START_MAX	= 8,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 5,
			SPAWN_WAVE_END_MAX		= 8,

			-- CAP RANGE
			SPAWN_CAP_START			= 6,
			SPAWN_CAP_END			= 10,
		},
		
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

	--------------------------------------------------- Grp 10 - 215
	-- Gradual ramp of light enemies with irregular spawning of mids
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 40,
			SPAWN_WAVE_TIME			= 8,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 18,
			SPAWN_CAP_END			= 18,

			-- Spawn FLAGS
			SPAWN_FLAG_PREV_MID		= 2,
		},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 0.7,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 6,
				SPAWN_WAVE_START_MAX	= 9,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 9,
				SPAWN_WAVE_END_MAX		= 13,

				-- CAP RANGE
				SPAWN_CAP_START			= 10,
				SPAWN_CAP_END			= 15,
			},
			
			ENEMY_ID	 				= {0, 1, 2, 3},
		},
	},

	--------------------------------------------------- Grp 11 - 255
	-- Introduction to a new medium enemy, light enemies stop spawning
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 1,
			SPAWN_WAVE_TIME			= 0.1,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 18,
			SPAWN_CAP_END			= 18,

			-- Spawn FLAGS
			SPAWN_FLAG_SINGLE_MID	= 3,
		},
	},

	--------------------------------------------------- Grp 12 - 270
	-- Gradual ramp of light enemies with irregular spawning of mids
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 60,
			SPAWN_WAVE_TIME			= 5,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 40,

			-- CAP RANGE
			SPAWN_CAP_START			= 36,
			SPAWN_CAP_END			= 40,

			-- Spawn FLAGS
			SPAWN_FLAG_PREV_MID		= 3,
		},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 1.7,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 2,
				SPAWN_WAVE_START_MAX	= 4,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 3,
				SPAWN_WAVE_END_MAX		= 6,

				-- CAP RANGE
				SPAWN_CAP_START			= 6,
				SPAWN_CAP_END			= 8,
			},
			
			ENEMY_ID	 				= {0, 1, 2, 3},
		},
	},

	--------------------------------------------------- Grp 13 - 330
	-- Tons of light enemies for a short burst
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 20,
			SPAWN_WAVE_TIME			= 0.8,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 4,
			SPAWN_WAVE_START_MAX	= 8,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 8,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 12,
			SPAWN_CAP_END			= 22,
		},
		
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

	--------------------------------------------------- Grp 14 - 350
	-- Similar to grp 12 but with much faster spawning and smaller waves means enemies won't stay dead long
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 150,
			SPAWN_WAVE_TIME			= 3.25,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 25,
			SPAWN_CAP_END			= 40,

			-- Spawn FLAGS
			SPAWN_FLAG_PREV_MID		= 3,
		},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 1,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 3,
				SPAWN_WAVE_START_MAX	= 4.5,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 3,
				SPAWN_WAVE_END_MAX		= 4.5,

				-- CAP RANGE
				SPAWN_CAP_START			= 8,
				SPAWN_CAP_END			= 12,
			},
			
			ENEMY_ID	 				= {0, 1, 2, 3},
		},
	},

	--------------------------------------------------- Grp 15 - 475
	-- Even shorter respawn times and starts from enemy amounts of grp 14
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 250,
			SPAWN_WAVE_TIME			= 3,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 35,
			SPAWN_CAP_END			= 60,

			-- Spawn FLAGS
			SPAWN_FLAG_PREV_MID		= 3,
		},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 0.8,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 2,
				SPAWN_WAVE_START_MAX	= 4,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 3,
				SPAWN_WAVE_END_MAX		= 5,

				-- CAP RANGE
				SPAWN_CAP_START			= 6,
				SPAWN_CAP_END			= 10,
			},
			
			ENEMY_ID	 				= {0, 1, 2, 3},
		},
 	},

 	--------------------------------------------------- Grp 15 - 475
	-- Even shorter respawn times and starts from enemy amounts of grp 14
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 250,
			SPAWN_WAVE_TIME			= 2.5,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 16,
			SPAWN_WAVE_START_MAX	= 16,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 16,
			SPAWN_WAVE_END_MAX		= 16,

			-- CAP RANGE
			SPAWN_CAP_START			= 60,
			SPAWN_CAP_END			= 60,

			-- Spawn FLAGS
			SPAWN_FLAG_PREV_MID		= 3,
		},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 0.8,
			
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 3,
				SPAWN_WAVE_START_MAX	= 5,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 3,
				SPAWN_WAVE_END_MAX		= 5,

				-- CAP RANGE
				SPAWN_CAP_START			= 10,
				SPAWN_CAP_END			= 20,
			},
			
			ENEMY_ID	 				= {0, 1, 2, 3},
		},
 	},

 	-- 675
}

----------------------------
-- BOSSES

SPAWN_GROUP_BOSS[1] = 
{
	ENEMY_ID	 			= {7,8},
}

----------------------------
-- SPAWN_GROUP_BOSS_EXTRA
SPAWN_GROUP_BOSS_EXTRA = 
{
	{
		SPAWN_DATA = 
		{
			SPAWN_WAVE_TIME			= 10,
		
			-- SPAWN RANGE
			SPAWN_WAVE_START_MIN	= 2,
			SPAWN_WAVE_START_MAX	= 3,

			-- SPAWM CAP AMOUNT
			SPAWN_CAP_START 		= 4;
		},
		ENEMY_ID	 				= {0, 1},
	},

	{
		SPAWN_DATA = 
		{
			SPAWN_WAVE_TIME			= 8,
		
			-- SPAWN RANGE
			SPAWN_WAVE_START_MIN	= 3,
			SPAWN_WAVE_START_MAX	= 5,

			-- SPAWM CAP AMOUNT
			SPAWN_CAP_START 		= 6;
		},

		ENEMY_ID	 				= {0, 1, 2, 3},
	},
}

----------------------------
-- KEY HOLDER SPAWNING
SPAWN_GROUP_KEYHOLDER[1] =
{
	ENEMY_ID	 			= {4, 5, 6},
}

----------------------------
-- BOSS ENEMY SPAWNING
SPAWN_GROUP_BOSSSPAWN[1] =
{
	ENEMY_ID	 			= {9},
}

----------------------------
-- ESE DATA
-- !! >> DO NOT USE ON NORMAL SPAWNER << !!

SPAWN_GROUP_SURVIVAL =
{
-- Grp 0
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.6,		-- Enemies spawn 1 at time at this rate
		-- wave size
			SPAWN_WAVE_START_MIN	= 3,		-- Number of enemies till next wave

		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 0,	-- any difficulty above this number will skip this node
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1},	-- Enemies that will spawn
	},

-- Grp 1
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.4,		-- Enemies spawn 1 at time at this rate
		-- wave size
			SPAWN_WAVE_START_MIN	= 3,		-- Number of enemies till next wave

		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1},	-- Enemies that will spawn
	},

-- Grp 2
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,		-- Enemies spawn 1 at time at this rate
		-- wave size
			SPAWN_WAVE_START_MIN	= 4,		-- Number of enemies till next wave

		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2},	-- Enemies that will spawn
	},


-- Grp 3
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.4,
		-- wave size
			SPAWN_WAVE_START_MIN	= 4,

		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 0,	-- any difficulty above this number will skip this node	
	},

-- Grp 4
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 5,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node		

		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

-- Grp 5
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 6,

		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node		

		},
	-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

-- Grp 6
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 4,

		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 0,	-- any difficulty above this number will skip this node

		},
	-- Spawn ID
		ENEMY_ID	 				= {2, 3},
	},

-- Grp 7
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 2,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node

		},
	-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 0.11,

			-- wave size
				SPAWN_WAVE_START_MIN	= 1,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 8
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.75,
		-- wave size
			SPAWN_WAVE_START_MIN	= 5,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node

		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 1.5,
			-- wave size
				SPAWN_WAVE_START_MIN	= 1,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 9
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 1.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 2,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node

		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 1.5,
			-- wave size
				SPAWN_WAVE_START_MIN	= 2,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 10
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.2,
		-- wave size
			SPAWN_WAVE_START_MIN	= 1,

		-- Boss group, only one wave will spawn
			SPAWN_FLAG_BOSS 		= 1,

		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node

		},
		-- Spawn ID
		ENEMY_ID	 			= {7, 8},
	},

-- Grp 11
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 1.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 3,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node

		},

		ENEMY_ID	 				= {4, 5, 6},
	},


-- Grp 12
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 1,
		-- wave size
			SPAWN_WAVE_START_MIN	= 6,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 2,
			-- wave size
				SPAWN_WAVE_START_MIN	= 2,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 13
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 2.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 3,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node

		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 2.5,
			-- wave size
				SPAWN_WAVE_START_MIN	= 3,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 14
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.6,
		-- wave size
			SPAWN_WAVE_START_MIN	= 13,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},


-- Grp 15
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.4,
		-- wave size
			SPAWN_WAVE_START_MIN	= 8,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node

		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 1,
			-- wave size
				SPAWN_WAVE_START_MIN	= 2,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 16
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 13,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

-- Grp 17
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 1,
		-- wave size
			SPAWN_WAVE_START_MIN	= 10,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 1,	-- any difficulty above this number will skip this node
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 2,
			-- wave size
				SPAWN_WAVE_START_MIN	= 3,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 18
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.75,
		-- wave size
			SPAWN_WAVE_START_MIN	= 20,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

-- Grp 19
	{
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 2,
		-- wave size
			SPAWN_WAVE_START_MIN	= 6,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node
		},
		ENEMY_ID	 				= {4, 5, 6},
	},

-- Grp 20
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 2.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 2,
		-- Boss group, only one wave will spawn
			SPAWN_FLAG_BOSS 		= 1,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 			= {7, 8},
	},

-- Grp 21
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 1,
		-- wave size
			SPAWN_WAVE_START_MIN	= 16,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 3,
			-- wave size
				SPAWN_WAVE_START_MIN	= 5,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 22
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.66,
		-- wave size
			SPAWN_WAVE_START_MIN	= 12,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 2,
			-- wave size
				SPAWN_WAVE_START_MIN	= 4,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 23
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.3,
		-- wave size
			SPAWN_WAVE_START_MIN	= 25,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

-- Grp 24
	{
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 1.6,
		-- wave size
			SPAWN_WAVE_START_MIN	= 8,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		ENEMY_ID	 				= {4, 5, 6},
	},

-- Grp 25
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 20,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 2.5,
			-- wave size
				SPAWN_WAVE_START_MIN	= 5,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},	

-- Grp 26
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 3,
		-- wave size
			SPAWN_WAVE_START_MIN	= 2,
		-- Boss group, only one wave will spawn
			SPAWN_FLAG_BOSS 		= 1,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 			= {7, 8},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 2.5,
			-- wave size
				SPAWN_WAVE_START_MIN	= 10,
			},
			-- Spawn ID
			ENEMY_ID	 				= {0, 1, 2, 3},
		},
	},

-- Grp 27
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.7,
		-- wave size
			SPAWN_WAVE_START_MIN	= 30,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 1.4,
			-- wave size
				SPAWN_WAVE_START_MIN	= 15,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 28
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.4,
		-- wave size
			SPAWN_WAVE_START_MIN	= 40,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

-- Grp 29
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.6,
		-- wave size
			SPAWN_WAVE_START_MIN	= 20,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 0.8,
			-- wave size
				SPAWN_WAVE_START_MIN	= 15,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 30
	{
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.6,
		-- wave size
			SPAWN_WAVE_START_MIN	= 20,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		ENEMY_ID	 				= {4, 5, 6},
	},

-- Grp 31
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 2,
		-- wave size
			SPAWN_WAVE_START_MIN	= 2,
		-- Boss group, only one wave will spawn
			SPAWN_FLAG_BOSS 		= 1,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 			= {7, 8 },

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 1,
			-- wave size
				SPAWN_WAVE_START_MIN	= 30,
			},
			-- Spawn ID
			ENEMY_ID	 				= {0, 1, 2, 3},


			SIBLING_NODE =
			{
				SPAWN_DATA = 
				{
				-- Wave time
					SPAWN_WAVE_TIME			= 3,
				-- wave size
					SPAWN_WAVE_START_MIN	= 10,
				},
				-- Spawn ID
				ENEMY_ID	 				= {4, 5, 6},
			},
		},
	},

-- Grp 32
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.5,
		-- wave size
			SPAWN_WAVE_START_MIN	= 40,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 1,
			-- wave size
				SPAWN_WAVE_START_MIN	= 20,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 33
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.2,
		-- wave size
			SPAWN_WAVE_START_MIN	= 50,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},
	},

-- Grp 34
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.3,
		-- wave size
			SPAWN_WAVE_START_MIN	= 30,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 0.7,
			-- wave size
				SPAWN_WAVE_START_MIN	= 20,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},

-- Grp 35
	{
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.4,
		-- wave size
			SPAWN_WAVE_START_MIN	= 30,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		ENEMY_ID	 				= {4, 5, 6},
	},

-- Grp 36
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 0.3,
		-- wave size
			SPAWN_WAVE_START_MIN	= 30,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 				= {0, 1, 2, 3},

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 0.7,
			-- wave size
				SPAWN_WAVE_START_MIN	= 20,
			},

			ENEMY_ID	 				= {4, 5, 6},
		},
	},	

-- Grp 37
	{	
		SPAWN_DATA = 
		{
		-- Wave time
			SPAWN_WAVE_TIME			= 2,
		-- wave size
			SPAWN_WAVE_START_MIN	= 3,
		-- Boss group, only one wave will spawn
			SPAWN_FLAG_BOSS 		= 1,
		-- Difficulty
			SPAWN_FLAG_ESE_DIFFICULTY	= 2,	-- any difficulty above this number will skip this node	
		},
		-- Spawn ID
		ENEMY_ID	 			= {7, 8 },

		SIBLING_NODE =
		{
			SPAWN_DATA = 
			{
			-- Wave time
				SPAWN_WAVE_TIME			= 0.7,
			-- wave size
				SPAWN_WAVE_START_MIN	= 50,
			},
			-- Spawn ID
			ENEMY_ID	 				= {0, 1, 2, 3},


			SIBLING_NODE =
			{
				SPAWN_DATA = 
				{
				-- Wave time
					SPAWN_WAVE_TIME			= 2,
				-- wave size
					SPAWN_WAVE_START_MIN	= 20,
				},
				-- Spawn ID
				ENEMY_ID	 				= {4, 5, 6},
			},
		},
	},
}

SPAWN_GROUP_TIME_CHALLENGE =
{
	{
		SPAWN_DATA = 
		{
			SPAWN_ENABLE_TIME		= 60,
			SPAWN_WAVE_TIME			= 0.1,
		
			-- START RANGE
			SPAWN_WAVE_START_MIN	= 3,
			SPAWN_WAVE_START_MAX	= 5,

			-- END RANGE
			SPAWN_WAVE_END_MIN		= 5,
			SPAWN_WAVE_END_MAX		= 10,

			-- CAP RANGE
			SPAWN_CAP_START			= 6,
			SPAWN_CAP_END			= 14,
		},
		
		ENEMY_ID	 				= {0,1,2,3},

		SIBLING_NODE = 
		{
			SPAWN_DATA = 
			{
				SPAWN_WAVE_TIME			= 0.1,
		
				-- START RANGE
				SPAWN_WAVE_START_MIN	= 15,
				SPAWN_WAVE_START_MAX	= 15,

				-- END RANGE
				SPAWN_WAVE_END_MIN		= 30,
				SPAWN_WAVE_END_MAX		= 30,

				-- CAP RANGE
				SPAWN_CAP_START			= 20,
				SPAWN_CAP_END			= 50,
			},
			
			ENEMY_ID	 				= {4,5,6},
		},
	},
}
