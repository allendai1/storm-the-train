EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 160, -- was 200
	ENEMY_WEIGHT			= 2,

	ENEMY_BOUNDINGBOX_X		= 36,
	ENEMY_BOUNDINGBOX_Y		= 100,

	ENEMY_SPAWN_COST		= 15,

	BERSERK_HEALTH			= 30, -- was 50
	BERSERK_DIST			= 512,
	BERSERK_OFFSET_X	 	= 15,
	BERSERK_OFFSET_Y		= 25,
	BERSERK_SIZE_W		 	= 60,
	BERSERK_SIZE_H			= 17,
	BERSERK_EFFECT			= "EFFECT_FRENZY_1", -- For more effects remember to add them to script bind (Enemy Data: line 169)

	ENEMY_DAMAGE_TIMER 		= 0.75,

	ENEMY_FREEZE_SCALAR		= 0.6,

	ENEMY_DEATH_SOUND		= "SOUND_ROBOT_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_ROBOT_GIB",
}

EffectData =
{
	EE_DEFAULT_HIT = EFFECT_ROBOT_HIT_V1,
	EE_DEFAULT_GIB = EFFECT_ROBOT_EXPLOSION_V1,
	EE_BALL_GIB = EFFECT_ROBOT_EXPLOSION_V1,
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "MEDIUM_MELEE",
}

EnemyType = "BERSERKER_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.keyBox =
{
	mesh_box = "graham_char_oriental_key_box.png",
}

ArchetypeSetup.blueprint =
{
	mesh_blueprint = "robot_2_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "robot_6.cm",

	anims =
	{
		IDLE			= {"r_idle_1"},
		RUN				= {"r_walk_1"},
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_attack_1"},
		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},
		
		BEHAVIOUR		= {"r_berserker_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},
	},

	meshs =
	{
		mesh_robot_5_head		= "robot_5_head.png",
		mesh_robot_5_body		= "robot_5_body.png",
		mesh_robot_5_l_arm		= "robot_5_l_arm.png",
		mesh_robot_5_r_arm		= "robot_5_r_arm.png",
		mesh_robot_5_l_hand		= "robot_5_l_hand.png",
		mesh_robot_5_r_hand		= "robot_5_r_hand.png",
		mesh_robot_5_l_foot		= "robot_5_l_foot.png",
		mesh_robot_5_r_foot		= "robot_5_r_foot.png",
	},
	
	spinTexture			= nil,
}

ArchetypeSetup[2] =
{
	archetypeFile		= "robot_6.cm",

	anims =
	{
		IDLE			= {"r_idle_1"},
		RUN				= {"r_run_berserker_1"},
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_attack_1"},
		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},
		
		BEHAVIOUR		= {"r_berserker_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},
	},

	meshs =
	{
		mesh_robot_5_head		= "robot_5_head.png",
		mesh_robot_5_body		= "robot_5_body.png",
		mesh_robot_5_l_arm		= "robot_5_l_arm.png",
		mesh_robot_5_r_arm		= "robot_5_r_arm.png",
		mesh_robot_5_l_hand		= "robot_5_l_hand.png",
		mesh_robot_5_r_hand		= "robot_5_r_hand.png",
		mesh_robot_5_l_foot		= "robot_5_l_foot.png",
		mesh_robot_5_r_foot		= "robot_5_r_foot.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_robot_pneumatic_1.png", repCount = 1},
		{ textureName = "gibs_robot_cog_2.png", repCount = 1},
		{ textureName = "gibs_robot_cog_1.png", repCount = 1},

	},

	uniqueGibs =
	{
		{ textureName = "gibs_robot_5_head.png",	offset = 50, 	force = 2 },
		{ textureName = "robot_5_l_arm.png", 		offset = 40, 	force = 1,	 repCount = 2},
		{ textureName = "gibs_robot_5_body.png",	offset = 20, 	force = 1,	 repCount = 1},
	}
}
