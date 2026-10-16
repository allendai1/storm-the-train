EnemySetup =
{
	ENEMY_HEALTH			= 600, --was 800 prior to 1.2
	ENEMY_MOVESPEED			= 250,
	ENEMY_WEIGHT			= 2.8,	--was 2.5 prior to 1.2

	ENEMY_BOUNDINGBOX_X		= 40,
	ENEMY_BOUNDINGBOX_Y		= 140,

	ENEMY_SPAWN_COST		= 40,
	
	ENEMY_BEAM_LEAP_MIN		= 0.5,
	ENEMY_BEAM_LEAP_MAX		= 1.5,

	ENEMY_BLIND_DISTANCE	= 400, --was 250 prior to 1.2

	ENEMY_FREEZE_SCALAR		= 0.3,

	ENEMY_BOSS_SOUND_TAUNT	= "SOUND_BOSS_TAUNT_HORROR_1",
	ENEMY_BOSS_SOUND_ATTACK	= "SOUND_BOSS_ATTACK_HORROR_1",
	ENEMY_BOSS_SOUND_DIE	= "SOUND_BOSS_DIE_HORROR_1",

	ENEMY_DEATH_SOUND		= "SOUND_SKELETON_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_SKELETON_GIB",

	ENEMY_TAUNT				= "SKELETON_TAUNT",
}

EffectData =
{
	EE_DEFAULT_HIT = EFFECT_SKELETON_HIT,
	EE_DEFAULT_GIB = EFFECT_SKELETON_HIT,
	EE_BALL_GIB = EFFECT_SKELETON_HIT,
	EE_FIRE_DOT = EFFECT_ON_FIRE_BOSS,
	EE_FROZEN_DOT = EFFECT_FREEZE_FIELD_BOSS,
	EE_POISON_DOT = EFFECT_POISONED_BOSS,
}


WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "HORROR_BOSS_MELEE",
	ENEMY_LEAP_WEAPON		= "BOSS_LEAP_ATTACK",
}

EnemyType = "SPAWN_BOSS"

ArchetypeSetup = {}
ArchetypeSetup[1] =
{
	archetypeFile		= "skeleton_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_katanapair_1"},
		RUN				= {"n_run_katanapair_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_darndao_1", "n_attack_katanapair_1"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},
		
		TAUNT			= {"n_taunt_darndao_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_darndao_1"},
		
		LEAP			= {"n_attack_leap_a_1"},
		LEAP_ATTACK		= {"n_attack_leap_b_1"},
	},

	meshs =
	{
		weapon_sword_l_hand		= "skeleton_heavy_sword_1.png",

		mesh_head		= "skeleton_heavy_head_1.png",
		mesh_body		= "skeleton_heavy_body_1.png",
		mesh_l_arm		= "skeleton_heavy_l_arm_1.png",
		mesh_r_arm		= "skeleton_heavy_r_arm_1.png",
		mesh_l_hand		= "skeleton_heavy_l_hand_1.png",
		mesh_r_hand		= "skeleton_heavy_r_hand_1.png",
		mesh_l_leg		= "skeleton_heavy_l_leg_1.png",
		mesh_r_leg		= "skeleton_heavy_r_leg_1.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_skeleton_king_bone.png", repCount = 4},
		{ textureName = "gibs_skeleton_king_hand.png", repCount = 2},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_skeleton_king_skull.png",		offset = 70, 	force = 4,		repCount = 1},
		{ textureName = "gibs_skeleton_king_jaw.png",		offset = 70, 	force = 1,		repCount = 1},
		{ textureName = "skeleton_heavy_sword_1.png",		offset = 40, 	force = 2,		repCount = 1},
	}
}