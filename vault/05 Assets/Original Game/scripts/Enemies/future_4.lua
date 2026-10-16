EnemySetup =
{
	ENEMY_HEALTH				= 18,
	ENEMY_MOVESPEED				= 130, -- was 200,
	ENEMY_WEIGHT				= 1,

	ENEMY_BOUNDINGBOX_X			= 30,
	ENEMY_BOUNDINGBOX_Y			= 86,

	ENEMY_SPAWN_COST			= 3,
	
	ENEMY_FREEZE_SCALAR			= 1,

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
	ENEMY_PRIMARY_WEAPON	= "SUICIDE",
	ENEMY_DEATH_WEAPON		= "SUICIDE",
}

EnemyType = "SUICIDE_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.blueprint =
{
	mesh_blueprint = "robot_2_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "robot_4.cm",

	anims =
	{
		IDLE			= {"r_idle_1"},
		RUN				= {"r_walk_1"},
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_attack_1"},
		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		BEHAVIOUR		= {"r_suicide_1", "r_suicide_2"}, -- Suicide leap

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},

		REVIVE			= {"r_revive_1"},

		ON_FIRE			= {"n_run_fire"},
	},

	meshs =
	{
		mesh_robot_2_antenna 	= "robot_2_antenna.png",
		mesh_robot_2_head		= "robot_2_head.png",
		mesh_robot_2_body		= "robot_2_body.png",
		mesh_robot_2_l_arm		= "robot_2_l_arm.png",
		mesh_robot_2_r_arm		= "robot_2_r_arm.png",
		mesh_robot_2_l_hand		= "robot_2_l_hand.png",
		mesh_robot_2_r_hand		= "robot_2_r_hand.png",
		mesh_robot_2_l_leg		= "robot_2_l_leg.png",
		mesh_robot_2_r_leg		= "robot_2_r_leg.png",
		
		mesh_robot_2_bomb_front		= "robot_2_bomb_front.png",
		mesh_robot_2_bomb_back		= "robot_2_bomb_back.png",
	},

	spinTexture				= "enemy_ninja_spin.png",
}

GibSetup =
{
	genericGibs =
	{

		{ textureName = "gibs_robot_cog_2.png", repCount = 1},
		{ textureName = "gibs_robot_cog_1.png", repCount = 1},
		{ textureName = "gibs_robot_pneumatic_1.png", repCount = 1},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_robot_2_head.png",	offset = 50, 	force = 2 },
		{ textureName = "robot_2_l_arm.png", 		offset = 20, 	force = 1, repCount = 2},
		{ textureName = "robot_2_l_hand.png", 		offset = 20, 	force = 1, repCount = 2},
		{ textureName = "robot_2_l_leg.png", 		offset = 10, 	force = 1, repCount = 1},
	}
}
