EnemySetup =
{
	ENEMY_HEALTH			= 600,	--was 800 prior to 1.2
	ENEMY_MOVESPEED			= 250,
	ENEMY_WEIGHT			= 2.5,	--was 2.5 prior to 1.2

	ENEMY_BOUNDINGBOX_X		= 35,
	ENEMY_BOUNDINGBOX_Y		= 140,

	ENEMY_SPAWN_COST		= 40,

	BERSERK_HEALTH			= 100,
	BERSERK_DIST			= 512,
	BERSERK_OFFSET_X	 	= 15,
	BERSERK_OFFSET_Y		= 35,
	BERSERK_SIZE_W		 	= 90,
	BERSERK_SIZE_H			= 20,
	BERSERK_EFFECT			= "EFFECT_FRENZY_1", -- For more effects remember to add them to script bind (Enemy Data: line 169)

	ENEMY_BLIND_DISTANCE	= 400, --was 250 prior to 1.2

	ENEMY_FREEZE_SCALAR		= 0.3,

	ENEMY_BOSS_SOUND_TAUNT	= "SOUND_BOSS_TAUNT_ORIENTAL_2",
	ENEMY_BOSS_SOUND_ATTACK	= "SOUND_BOSS_ATTACK_ORIENTAL_2",
	ENEMY_BOSS_SOUND_DIE	= "SOUND_BOSS_DIE_ORIENTAL_2",

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
	ENEMY_LEAP_WEAPON		= "BOSS_LEAP_ATTACK",
}

EnemyType = "BERSERKER_BOSS"

ArchetypeSetup = {}
ArchetypeSetup[1] =
{
	archetypeFile		= "ninja_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_katanapair_1"},
		RUN				= {"n_run_katanapair_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_katanapair_1", "n_attack_katanapair_2", "n_attack_katanapair_3", "n_attack_darndao_2"},
		
		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		BEHAVIOUR		= {"n_berserker_1"},
		
		TAUNT			= {"n_taunt_2"},
		
		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_katanapair_1"},

		LEAP			= {"n_attack_leap_a_1"},
		LEAP_ATTACK		= {"n_attack_leap_b_2"},
	},

	meshs =
	{
		weapon_katana_r_hand	= "n_weapon_katana.png",
		weapon_katana_l_hand	= "n_weapon_katana.png",

		mesh_head		= "n_heavy_head_1.png",
		mesh_body		= "n_heavy_body_1.png",
		mesh_l_arm		= "n_heavy_l_arm_1.png",
		mesh_r_arm		= "n_heavy_r_arm_1.png",
		mesh_l_hand		= "n_heavy_l_hand_1.png",
		mesh_r_hand		= "n_heavy_r_hand_1.png",
		mesh_l_leg		= "n_heavy_l_leg_1.png",
		mesh_r_leg		= "n_heavy_r_leg_1.png",
	},

	spinTexture			= nil,
}

ArchetypeSetup[2] =
{
	archetypeFile		= "ninja_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_katanapair_1"},
		RUN				= {"n_run_berserker_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_katanapair_1", "n_attack_katanapair_2", "n_attack_katanapair_3", "n_attack_darndao_2"},
		
		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_2"},
		DEATH_B			= {"n_die_b_2"},

		BEHAVIOUR		= {"n_frenzy_1"},
		
		TAUNT			= {"n_taunt_2"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_katanapair_1"},

		LEAP			= {"n_attack_leap_a_1"},
		LEAP_ATTACK		= {"n_attack_leap_b_2"},
	},

	meshs =
	{
		weapon_katana_r_hand	= "n_weapon_katana.png",
		weapon_katana_l_hand	= "n_weapon_katana.png",

		mesh_head		= "n_heavy_head_1.png",
		mesh_body		= "n_heavy_body_1.png",
		mesh_l_arm		= "n_heavy_l_arm_1.png",
		mesh_r_arm		= "n_heavy_r_arm_1.png",
		mesh_l_hand		= "n_heavy_l_hand_1.png",
		mesh_r_hand		= "n_heavy_r_hand_1.png",
		mesh_l_leg		= "n_heavy_l_leg_1.png",
		mesh_r_leg		= "n_heavy_r_leg_1.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_generic_flesh_1.png",		repCount = 2 },
		{ textureName = "gibs_generic_flesh_3.png",		repCount = 2 },
		{ textureName = "gibs_generic_bone_1.png",		repCount = 3 },
	},

	uniqueGibs =
	{
		{ textureName = "gibs_heavy_skull_1.png",		offset = 50, 	force = 4		},
		{ textureName = "gibs_generic_brain_1.png",		offset = 55,  	force = 1.5		},
		{ textureName = "gibs_ninja_heavy_body_8.png",	offset = 10,	force = 2		},
		{ textureName = "gibs_ninja_heavy_arm_8.png",	offset = 10						},
		{ textureName = "gibs_ninja_heavy_leg_8.png",	offset = 0						},
		{ textureName = "n_weapon_katana.png", 			offset = 15,	force = 3,	repCount = 2   },
	}
}