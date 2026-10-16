EnemySetup =
{
	ENEMY_HEALTH				= 20,
	ENEMY_MOVESPEED				= 110, -- was200,
	ENEMY_WEIGHT				= 1,

	ENEMY_BOUNDINGBOX_X			= 30,
	ENEMY_BOUNDINGBOX_Y			= 86,

	ENEMY_SPAWN_COST			= 1.7,
	
	ENEMY_FREEZE_SCALAR			= 1,
	ENEMY_FLEE_ON_FIRE			= 1, -- true

	ENEMY_DEATH_SOUND			= "SOUND_ROBOT_DEATH",
	ENEMY_GIB_SOUND				= "SOUND_ROBOT_GIB",
}

EffectData =
{
	EE_DEFAULT_HIT = EFFECT_ROBOT_HIT_V1,
	EE_DEFAULT_GIB = EFFECT_ROBOT_EXPLOSION_V1,
	EE_BALL_GIB = EFFECT_ROBOT_EXPLOSION_V1,
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "LIGHT_MELEE",
}

EnemyType = "NORMAL_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.blueprint =
{
	mesh_blueprint = "robot_1_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "robot_1.cm",

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

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},

		REVIVE			= {"r_revive_1"},

		ON_FIRE			= {"n_run_fire"},
	},

	meshs =
	{
		mesh_robot_1_antenna 	= "robot_1_antenna.png",
		mesh_robot_1_head		= "robot_1_head.png",
		mesh_robot_1_body		= "robot_1_body.png",
		mesh_robot_1_l_arm		= "robot_1_l_arm.png",
		mesh_robot_1_r_arm		= "robot_1_r_arm.png",
		mesh_robot_1_l_hand		= "robot_1_l_hand.png",
		mesh_robot_1_r_hand		= "robot_1_r_hand.png",
		mesh_robot_1_l_leg		= "robot_1_l_leg.png",
		mesh_robot_1_r_leg		= "robot_1_r_leg.png",
	},

	spinTexture				= "enemy_ninja_spin.png",
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "robot_1_l_hand.png", repCount = 1},
		{ textureName = "gibs_robot_cog_1.png", repCount = 1},
		{ textureName = "gibs_robot_pneumatic_1.png", repCount = 1},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_robot_1_head.png",	offset = 50, 	force = 3 },
		{ textureName = "robot_1_l_arm.png",		offset = 40, 	force = 2,   repCount = 2},
		{ textureName = "gibs_robot_1_body.png",    offset = 20, 	force = 2 },
	}
}
