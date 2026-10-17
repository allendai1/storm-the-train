EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 180, -- was 220
	ENEMY_WEIGHT			= 2,

	ENEMY_BOUNDINGBOX_X		= 40,
	ENEMY_BOUNDINGBOX_Y		= 112,

	ENEMY_SPAWN_COST		= 15,

	SHIELD_HEALTH			= 90, -- was 125
	SHIELD_OFFSET			= 30,

	SHIELD_SIZE_W			= 10,
	SHIELD_SIZE_H			= 74,

	SHIELD_GIB_TYPE			= 1,
	ENEMY_DAMAGE_TIMER 		= 0.75,

	ENEMY_FREEZE_SCALAR		= 0.6,

	ENEMY_DEATH_SOUND		= "SOUND_ROBOT_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_ROBOT_GIB",
}

EffectData =
{
	EE_DEFAULT_HIT = EFFECT_ROBOT_BLOOD_SPLAT,
	EE_DEFAULT_GIB = EFFECT_ROBOT_EXPLOSION_V1,
	EE_BALL_GIB = EFFECT_ROBOT_EXPLOSION_V1,
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "MEDIUM_MELEE",
	ENEMY_SECONDARY_WEAPON	= "MEDIUM_BEAM",
}

EnemyType = "SHIELD_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.keyBox =
{
	mesh_box = "graham_char_oriental_key_box.png",
}

ArchetypeSetup.blueprint =
{
	mesh_blueprint = "robot_2_blueprint.png",
}

--Primary with shield
ArchetypeSetup[1] =
{
	archetypeFile		= "robot_7.cm",

	anims =
	{
		IDLE				= {"r_idle_shield_1"},
		RUN					= {"r_walk_shield_1"},
		JUMP				= {"r_jump_1"},
		ATTACK				= {"r_attack_1"},
		CELEBRATE_A			= {"r_celebrate_a_1"},
		CELEBRATE_B			= {"r_celebrate_b_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},
	},

	meshs =
	{
		weapon_shield_r_hand	= "robot_6_shield.png",

		mesh_robot_6_head		= "robot_6_head.png",
		mesh_robot_6_body		= "robot_6_body.png",
		mesh_robot_6_l_arm		= "robot_6_l_arm.png",
		mesh_robot_6_r_arm		= "robot_6_r_arm.png",
		mesh_robot_6_l_hand		= "robot_6_l_hand.png",
		mesh_robot_6_r_hand		= "robot_6_r_hand.png",
		mesh_robot_6_l_leg		= "robot_6_l_leg.png",
		mesh_robot_6_r_leg		= "robot_6_r_leg.png",
	},
	
	spinTexture			= nil,
}

--Secondary with shield
ArchetypeSetup[2] =
{
	archetypeFile		= "robot_7.cm",

	anims =
	{
		IDLE			= {"r_idle_shield_1"},
		RUN				= {"r_walk_shield_1"},
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_attack_range_shield_1"},

		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},
	},

	meshs =
	{
		weapon_shield_r_hand	= "robot_6_shield.png",

		mesh_robot_6_head		= "robot_6_head.png",
		mesh_robot_6_body		= "robot_6_body.png",
		mesh_robot_6_l_arm		= "robot_6_l_arm.png",
		mesh_robot_6_r_arm		= "robot_6_r_arm.png",
		mesh_robot_6_l_hand		= "robot_6_l_hand.png",
		mesh_robot_6_r_hand		= "robot_6_r_hand.png",
		mesh_robot_6_l_leg		= "robot_6_l_leg.png",
		mesh_robot_6_r_leg		= "robot_6_r_leg.png",
	},

	spinTexture			= nil,
}

--Primary without shield
ArchetypeSetup[3] =
{
	archetypeFile		= "robot_7.cm",

	anims =
	{
		IDLE			= {"r_idle_1"},
		RUN				= {"r_walk_1"},
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_attack_1"},

		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},
	},

	meshs =
	{
		mesh_robot_6_head		= "robot_6_head.png",
		mesh_robot_6_body		= "robot_6_body.png",
		mesh_robot_6_l_arm		= "robot_6_l_arm.png",
		mesh_robot_6_r_arm		= "robot_6_r_arm.png",
		mesh_robot_6_l_hand		= "robot_6_l_hand.png",
		mesh_robot_6_r_hand		= "robot_6_r_hand.png",
		mesh_robot_6_l_leg		= "robot_6_l_leg.png",
		mesh_robot_6_r_leg		= "robot_6_r_leg.png",
	},

	spinTexture			= nil,
}

--secondary without shield
ArchetypeSetup[4] =
{
	archetypeFile		= "robot_7.cm",

	anims =
	{
		IDLE			= {"r_idle_1"},
		RUN				= {"r_walk_1"},
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_attack_range_1"},
		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},
	},

	meshs =
	{
		mesh_robot_6_head		= "robot_6_head.png",
		mesh_robot_6_body		= "robot_6_body.png",
		mesh_robot_6_l_arm		= "robot_6_l_arm.png",
		mesh_robot_6_r_arm		= "robot_6_r_arm.png",
		mesh_robot_6_l_hand		= "robot_6_l_hand.png",
		mesh_robot_6_r_hand		= "robot_6_r_hand.png",
		mesh_robot_6_l_leg		= "robot_6_l_leg.png",
		mesh_robot_6_r_leg		= "robot_6_r_leg.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_robot_cog_2.png", repCount = 1},
		{ textureName = "gibs_robot_cog_1.png", repCount = 1},
		{ textureName = "gibs_robot_pneumatic_1.png", repCount = 2},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_robot_6_head.png",	offset = 50, 	force = 2},
		{ textureName = "gibs_robot_6_body.png", 	offset = 50, 	force = 2,	repCount = 1},
		{ textureName = "gibs_robot_6_hand.png", 	offset = 50, 	force = 2,	repCount = 2},
	}
}
