EnemySetup =
{
	ENEMY_HEALTH			= 700, --was 1300 prior to 1.2
	ENEMY_MOVESPEED			= 225,
	ENEMY_WEIGHT			= 2.8, --was 2.5 prior to 1.2

	ENEMY_BOUNDINGBOX_X		= 50,
	ENEMY_BOUNDINGBOX_Y		= 185,

	ENEMY_SPAWN_COST		= 40,
	
	ENEMY_BEAM_LEAP_MIN		= 0.5,
	ENEMY_BEAM_LEAP_MAX		= 1.5,

	ENEMY_BLIND_DISTANCE	= 400, --was 250 prior to 1.2

	ENEMY_FREEZE_SCALAR		= 0.3,

	ENEMY_BOSS_SOUND_TAUNT	= "SOUND_BOSS_TAUNT_FUTURE_2",
	ENEMY_BOSS_SOUND_ATTACK	= "SOUND_BOSS_ATTACK_FUTURE_2",
	ENEMY_BOSS_SOUND_DIE	= "SOUND_BOSS_DIE_FUTURE_2",

	ENEMY_DEATH_SOUND		= "SOUND_ROBOT_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_ROBOT_GIB",

	ENEMY_TAUNT				= "ROBOT_TAUNT",
}

EffectData =
{
	EE_DEFAULT_HIT = EFFECT_ROBOT_BLOOD_SPLAT,
	EE_DEFAULT_GIB = EFFECT_ROBOT_EXPLOSION_V1,
	EE_BALL_GIB = EFFECT_ROBOT_EXPLOSION_V1,
	EE_FIRE_DOT = EFFECT_ON_FIRE_BOSS,
	EE_FROZEN_DOT = EFFECT_FREEZE_FIELD_BOSS,
	EE_POISON_DOT = EFFECT_POISONED_BOSS,
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "FUTURE_BOSS_MELEE",
	ENEMY_LEAP_WEAPON		= "FUTURE_LEAP_ATTACK",
}

EnemyType = "FUTURE_SPAWN_BOSS"

ArchetypeSetup = {}
ArchetypeSetup[1] =
{
	archetypeFile		= "robot_8.cm",

	anims =
	{
		IDLE			= {"r_idle_1"},
		RUN				= {"r_walk_1"},
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_attack_1", "r_attack_2"},
		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},
		
		TAUNT			= {"r_taunt_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},
		
		LEAP			= {"r_attack_leap_a_1"},
		LEAP_ATTACK		= {"r_attack_leap_b_1"},
		
		BEHAVIOUR		= {"r_throw_1", "r_throw_2"},
	},

	meshs =
	{
		mesh_robot_8_body		= "robot_8_body.png",
		mesh_robot_8_l_upperarm	= "robot_8_l_upperarm.png",
		mesh_robot_8_r_upperarm	= "robot_8_r_upperarm.png",
		mesh_robot_8_l_forearm	= "robot_8_l_forearm.png",
		mesh_robot_8_r_forearm	= "robot_8_r_forearm.png",
		mesh_robot_8_l_leg		= "robot_8_l_leg.png",
		mesh_robot_8_r_leg		= "robot_8_r_leg.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{

		{ textureName = "gibs_robot_pneumatic_2.png", repCount = 2},
		{ textureName = "gibs_robot_cog_1.png", repCount = 3},

	},

	uniqueGibs =
	{
		{ textureName = "gibs_robot_8_head.png",		offset = 80, 	force = 4		},
		{ textureName = "gibs_robot_8_body.png",		offset = 60, 	force = 12		},
		{ textureName = "gibs_robot_8_foot.png",		offset = 0, 	force = 0.5, repCount = 2	},
		{ textureName = "gibs_robot_8_leg.png",			offset = 20, 	force = 3,	 repCount = 2	},
		{ textureName = "gibs_robot_8_arm.png",			offset = 40, 	force = 6,	 repCount = 2	},
		{ textureName = "gibs_robot_10_head.png",		offset = 80,	force = 3,	 repCount = 3   },
	}
}