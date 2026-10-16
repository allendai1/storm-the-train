EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 170, -- was 210
	ENEMY_WEIGHT			= 2,

	ENEMY_BOUNDINGBOX_X		= 30,
	ENEMY_BOUNDINGBOX_Y		= 112,

	ENEMY_SPAWN_COST		= 15,

	AGILE_SPINJUMPTIME		= 2.8, -- was 2.25
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
}

EnemyType = "AGILE_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.keyBox =
{
	mesh_box = "graham_char_oriental_key_box.png",
}
ArchetypeSetup.blueprint =
{
	mesh_blueprint = "robot_1_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "robot_5.cm",

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

		SPIN 			= {"r_spin_1"},
	},

	meshs =
	{
		mesh_robot_7_head		= "robot_7_head.png",
		mesh_robot_7_body		= "robot_7_body.png",
		mesh_robot_7_l_arm		= "robot_7_l_arm.png",
		mesh_robot_7_r_arm		= "robot_7_r_arm.png",
		mesh_robot_7_l_hand		= "robot_7_l_hand.png",
		mesh_robot_7_r_hand		= "robot_7_r_hand.png",
		mesh_robot_7_l_leg		= "robot_7_l_leg.png",
		mesh_robot_7_r_leg		= "robot_7_r_leg.png",
	},
	
	spinTexture			= nil,
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
		{ textureName = "gibs_robot_7_head.png",	offset = 50, 	force = 2},
		{ textureName = "gibs_robot_7_body.png", 	offset = 20, 	force = 1,	repCount = 1},
		{ textureName = "gibs_robot_7_leg.png", 	offset = 10, 	force = 1,	repCount = 2},
	}
}
