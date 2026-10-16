EnemySetup =
{
	ENEMY_HEALTH			= 550,	--was 650 prior to 1.2
	ENEMY_MOVESPEED			= 180,
	ENEMY_WEIGHT			= 2.8,	--was 2.5 prior to 1.2

	ENEMY_BOUNDINGBOX_X		= 40,
	ENEMY_BOUNDINGBOX_Y		= 140,

	ENEMY_SPAWN_COST		= 40,

	SHIELD_HEALTH			= 250,	--was 400 prior to 1.2

	SHIELD_OFFSET			= 12,

	SHIELD_SIZE_W			= 10,
	SHIELD_SIZE_H			= 90,

	SHIELD_GIB_TYPE			= 2,

	ENEMY_BEAM_LEAP_MIN		= 0.5,
	ENEMY_BEAM_LEAP_MAX		= 1.5,

	ENEMY_BLIND_DISTANCE  	= 400, --was 250 prior to 1.2

	ENEMY_FREEZE_SCALAR		= 0.3,

	ENEMY_BOSS_SOUND_TAUNT	= "SOUND_BOSS_TAUNT_ORIENTAL_1",
	ENEMY_BOSS_SOUND_DIE	= "SOUND_BOSS_DIE_ORIENTAL_1",

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",

	ENEMY_TAUNT				= "NINJA_TAUNT",
}

EffectData =
{
	EE_FIRE_DOT = EFFECT_ON_FIRE_BOSS,
	EE_FROZEN_DOT = EFFECT_FREEZE_FIELD_BOSS,
	EE_POISON_DOT = EFFECT_POISONED_BOSS,
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "ORIENTAL_BOSS_MELEE",
	ENEMY_SECONDARY_WEAPON	= "NINJA_BOMB",
	ENEMY_LEAP_WEAPON		= "BOSS_LEAP_ATTACK",
}

EnemyType = "SHIELD_BOSS"

ArchetypeSetup = {}

ArchetypeSetup[1] =		-- Melee with Shield
{
	archetypeFile		= "ninja_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_darndao_1"},
		RUN				= {"n_run_darndao_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_darndao_1", "n_attack_darndao_2", "n_attack_darndao_3", "n_attack_katanapair_2"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

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
		weapon_shield_r_hand	= "n_shield_h_ninja_1.png",
		weapon_darndao_l_hand	= "n_weapon_darndao.png",

		mesh_head		= "n_heavy_head_2.png",
		mesh_body		= "n_heavy_body_2.png",
		mesh_l_arm		= "n_heavy_l_arm_2.png",
		mesh_r_arm		= "n_heavy_r_arm_2.png",
		mesh_l_hand		= "n_heavy_l_hand_2.png",
		mesh_r_hand		= "n_heavy_r_hand_2.png",
		mesh_l_leg		= "n_heavy_l_leg_2.png",
		mesh_r_leg		= "n_heavy_r_leg_2.png",
		
		mesh_n_heavy_2_basket		= "n_heavy_2_basket.png",
	},

	spinTexture			= nil,
}


ArchetypeSetup[2] =		-- Ranged with Shield
{
	archetypeFile		= "ninja_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_dim_1"},
		RUN				= {"n_run_katanapair_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_range_2"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		--SWAP_WEAPON_A	= {"n_stow_a_darndao_1"},
		--SWAP_WEAPON_B	= {"n_stow_b_darndao_1"},

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
		weapon_shield_r_hand	= "n_shield_h_ninja_1.png",
		--weapon_darndao_l_hand	= "n_weapon_darndao.png",

		mesh_head		= "n_heavy_head_2.png",
		mesh_body		= "n_heavy_body_2.png",
		mesh_l_arm		= "n_heavy_l_arm_2.png",
		mesh_r_arm		= "n_heavy_r_arm_2.png",
		mesh_l_hand		= "n_heavy_l_hand_2.png",
		mesh_r_hand		= "n_heavy_r_hand_2.png",
		mesh_l_leg		= "n_heavy_l_leg_2.png",
		mesh_r_leg		= "n_heavy_r_leg_2.png",
		
		mesh_n_heavy_2_basket		= "n_heavy_2_basket.png",
	},
	spinTexture			= nil,
}


ArchetypeSetup[3] =		-- Melee no Shield
{
	archetypeFile		= "ninja_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_dim_1"},
		RUN				= {"n_run_katanapair_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_darndao_1", "n_attack_dim_1", "n_attack_katanapair_3"},

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
		weapon_darndao_l_hand	= "n_weapon_darndao.png",

		mesh_head		= "n_heavy_head_2.png",
		mesh_body		= "n_heavy_body_2.png",
		mesh_l_arm		= "n_heavy_l_arm_2.png",
		mesh_r_arm		= "n_heavy_r_arm_2.png",
		mesh_l_hand		= "n_heavy_l_hand_2.png",
		mesh_r_hand		= "n_heavy_r_hand_2.png",
		mesh_l_leg		= "n_heavy_l_leg_2.png",
		mesh_r_leg		= "n_heavy_r_leg_2.png",
		
		mesh_n_heavy_2_basket		= "n_heavy_2_basket.png",
	},
	spinTexture			= nil,
}


ArchetypeSetup[4] =		-- Ranged no Shield
{
	archetypeFile		= "ninja_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_darndao_1"},
		RUN				= {"n_run_katanapair_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_range_1"},

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
		weapon_darndao_l_hand	= "n_weapon_darndao.png",

		mesh_head		= "n_heavy_head_2.png",
		mesh_body		= "n_heavy_body_2.png",
		mesh_l_arm		= "n_heavy_l_arm_2.png",
		mesh_r_arm		= "n_heavy_r_arm_2.png",
		mesh_l_hand		= "n_heavy_l_hand_2.png",
		mesh_r_hand		= "n_heavy_r_hand_2.png",
		mesh_l_leg		= "n_heavy_l_leg_2.png",
		mesh_r_leg		= "n_heavy_r_leg_2.png",
		
		mesh_n_heavy_2_basket		= "n_heavy_2_basket.png",
	},
	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_generic_flesh_1.png", repCount = 2},
		{ textureName = "gibs_generic_flesh_3.png", repCount = 2},
		{ textureName = "gibs_generic_bone_1.png", repCount = 3},
		
	},

	uniqueGibs =
	{
		{ textureName = "gibs_heavy_skull_1.png",			offset = 50, 	force = 4,	reCount = 1},
		{ textureName = "gibs_ninja_heavy_mask_9.png",		offset = 50, 	force = 3,	reCount = 1},
		{ textureName = "gibs_ninja_heavy_helmet_9.png",	offset = 50, 	force = 4,	reCount = 1},
		{ textureName = "gibs_ninja_heavy_arm_9.png",		offset = 30, 	force = 2,	reCount = 1},
		{ textureName = "gibs_ninja_heavy_body_9.png",		offset = 20, 	force = 2,	reCount = 1},
	}
}