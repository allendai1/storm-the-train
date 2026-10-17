EnemySetup =
{
	ENEMY_HEALTH			= 30,
	ENEMY_MOVESPEED			= 150, -- was 225,
	ENEMY_WEIGHT			= 1,

	ENEMY_BOUNDINGBOX_X		= 20,
	ENEMY_BOUNDINGBOX_Y		= 84,

	ENEMY_SPAWN_COST		= 3,
	
	ENEMY_FREEZE_SCALAR		= 1,
	ENEMY_FLEE_ON_FIRE		= 1, -- true

	ENEMY_DEATH_SOUND		= "SOUND_ROBOT_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_ROBOT_GIB",
	
	ENEMY_MISSION_HANDLE	= "EMH_HOVERING_ROBOT",
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

EnemyType = "HOVER_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.blueprint =
{
	mesh_blueprint = "robot_1_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "robot_2.cm",


	anims =
	{
		IDLE			= {"r_idle_hover_1"},
		RUN				= {"r_walk_hover_1"},
		JUMP			= {"r_jump_hover_1"},
		ATTACK			= {"r_attack_hover_1"},
		CELEBRATE_A		= {"r_celebrate_a_hover_1"},
		CELEBRATE_B		= {"r_celebrate_b_hover_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"r_die_a_hover_1"},
		DEATH_B			= {"r_die_b_hover_1"},

		SPIN 			= {"r_idle_hover_1"},

		DAMAGE_BEAM		= {"r_damage_beam_hover_1"},
		DAMAGE_GUN		= {"r_damage_hover_1"},

		ON_FIRE			= {"n_run_fire"},
	},


	meshs =
	{
		mesh_robot_3_head		= "robot_3_head.png",
		mesh_robot_3_body		= "robot_3_body.png",
		mesh_robot_3_l_arm		= "robot_3_l_arm.png",
		mesh_robot_3_r_arm		= "robot_3_r_arm.png",
		mesh_robot_3_hoverbar	= "robot_3_hoverbar.png",
		mesh_robot_3_hoverbar1	= "robot_3_hoverbar.png",
	},

	spinTexture			= "enemy_ninja_spin.png",
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
		{ textureName = "gibs_robot_3_head.png",	offset = 50, 	force = 2 },
		{ textureName = "robot_3_l_arm.png", 	    offset = 20,	force = 1, repCount = 2},
	}
}
