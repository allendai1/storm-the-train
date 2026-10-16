EnemySetup =
{
	ENEMY_HEALTH			= 700,	--was 1100 prior to 1.2
	ENEMY_MOVESPEED			= 250,
	ENEMY_WEIGHT			= 2.8,	--was 2.5 prior to 1.2

	ENEMY_BOUNDINGBOX_X		= 40,
	ENEMY_BOUNDINGBOX_Y		= 180,

	ENEMY_SPAWN_COST		= 40,

	BERSERK_HEALTH			= 100,
	BERSERK_DIST			= 512,
	BERSERK_OFFSET_X	 	= 15,
	BERSERK_OFFSET_Y		= 35,
	BERSERK_SIZE_W		 	= 90,
	BERSERK_SIZE_H			= 45,
	BERSERK_EFFECT			= "EFFECT_FRENZY_1", -- For more effects remember to add them to script bind (Enemy Data: line 169)

	ENEMY_BLIND_DISTANCE	= 400, --was 250 prior to 1.2

	ENEMY_FREEZE_SCALAR		= 0.3,

	ENEMY_BOSS_SOUND_TAUNT	= "SOUND_BOSS_TAUNT_FUTURE_1",
	ENEMY_BOSS_SOUND_ATTACK	= "SOUND_BOSS_ATTACK_FUTURE_1",
	ENEMY_BOSS_SOUND_DIE	= "SOUND_BOSS_DIE_FUTURE_1",

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
	ENEMY_SECONDARY_WEAPON	= "FUTURE_BOSS_MEGAGUN",
}

EnemyType = "BERSERKER_BOSS" 

ArchetypeSetup = {}
ArchetypeSetup[1] =
{
	archetypeFile		= "robot_9.cm",

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
		
		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},

		BEHAVIOUR		= {"r_berserker_1"},			-- this plays to indicates the start of the run
		TAUNT			= {"r_taunt_1"},
	},

	meshs =
	{
		mesh_robot_9_body		= "robot_9_body.png",
		mesh_robot_9_l_arm		= "robot_9_l_arm.png",
		mesh_robot_9_r_arm		= "robot_9_r_arm.png",
		mesh_robot_9_l_leg		= "robot_9_l_leg.png",
		mesh_robot_9_r_leg		= "robot_9_r_leg.png",
	},

	spinTexture			= nil,
}

ArchetypeSetup[2] =
{
	archetypeFile		= "robot_9.cm",

	anims =
	{
		IDLE			= {"r_idle_1"},			
		RUN				= {"r_run_berserker_1"},		-- plays as he berserks
		JUMP			= {"r_jump_1"},
		ATTACK			= {"r_range_1"},				-- Ranged Attack
		CELEBRATE_A		= {"r_celebrate_a_1"},
		CELEBRATE_B		= {"r_celebrate_b_1"},

		DEATH_A			= {"r_die_a_1"},
		DEATH_B			= {"r_die_b_1"},
		
		TAUNT			= {"r_idle_1"},

		DAMAGE_BEAM		= {"r_damage_beam_1"},
		DAMAGE_GUN		= {"r_damage_1"},

		BEHAVIOUR		= {"r_berserker_1"},			-- this plays to indicates the start of the run
		TAUNT			= {"r_idle_1"},
	},

	meshs =
	{
		mesh_robot_9_body		= "robot_9_body.png",
		mesh_robot_9_l_arm		= "robot_9_l_arm.png",
		mesh_robot_9_r_arm		= "robot_9_r_arm.png",
		mesh_robot_9_l_leg		= "robot_9_l_leg.png",
		mesh_robot_9_r_leg		= "robot_9_r_leg.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_robot_pneumatic_1.png", repCount = 1},
		{ textureName = "gibs_robot_pneumatic_2.png", repCount = 1},
		{ textureName = "gibs_robot_cog_1.png", repCount = 1},

	},

	uniqueGibs =
	{
		{ textureName = "gibs_robot_9_head.png",	offset = 80, 	force = 4},
		{ textureName = "gibs_robot_9_gun.png",		offset = 40, 	force = 6},
		{ textureName = "gibs_robot_9_body.png",	offset = 60, 	force = 12},

	}
}