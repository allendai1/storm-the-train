EnemySetup =
{
	ENEMY_HEALTH			= 600, --was 800 prior to 1.2
	ENEMY_MOVESPEED			= 155,
	ENEMY_WEIGHT			= 2.8,	--was 2.5 prior to 1.2

	ENEMY_BOUNDINGBOX_X		= 35,
	ENEMY_BOUNDINGBOX_Y		= 140,

	ENEMY_SPAWN_COST		= 40,

	TELEPORT_INTERVAL_MIN	= 4,
	TELEPORT_INTERVAL_MAX	= 7,

	HOVER_INTERVAL_MIN		= 5,
	HOVER_INTERVAL_MAX		= 8,

	TELEPORT_TIME 			= 0.8,
	TELEPORT_RECOVER_TIME	= 0.3,

	ENEMY_BLIND_DISTANCE	= 400, --was 250 prior to 1.2

	ENEMY_FREEZE_SCALAR		= 0.3,

	ENEMY_BOSS_SOUND_TAUNT	= "SOUND_BOSS_TAUNT_HORROR_2",
	ENEMY_BOSS_SOUND_ATTACK	= "SOUND_BOSS_ATTACK_HORROR_2",
	ENEMY_BOSS_SOUND_DIE	= "SOUND_BOSS_DIE_HORROR_2",

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",

	ENEMY_TAUNT				= "VAMPIRE_TAUNT",
}

EffectData =
{
	EE_FIRE_DOT = EFFECT_ON_FIRE_BOSS,
	EE_FROZEN_DOT = EFFECT_FREEZE_FIELD_BOSS,
	EE_POISON_DOT = EFFECT_POISONED_BOSS,
}


WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "HORROR_BOSS_MELEE",
	ENEMY_SECONDARY_WEAPON	= "BOSS_STAKE",
}

EnemyType = "TELEPORT_BOSS"

ArchetypeSetup = {}
ArchetypeSetup[1] =
{
	archetypeFile		= "vampire_heavy.cm",

	anims =
	{
		IDLE			= {"n_idle_katanapair_1"},
		RUN				= {"n_run_katanapair_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_katanapair_1", "n_attack_katanapair_2", "n_attack_darndao_2"},
		
		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		BEHAVIOUR		= {"n_berserker_1"},
		
		TAUNT			= {"n_taunt_1"},
		
		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_katanapair_1"},
	},

	meshs =
	{
		weapon_stake_r_hand_1	= "vampire_heavy_stake_1.png",
		weapon_stake_l_hand_1	= "vampire_heavy_stake_1.png",

		mesh_head		= "vampire_heavy_head_1.png",
		mesh_body		= "vampire_heavy_body_1.png",
		mesh_l_arm		= "vampire_heavy_l_arm_1.png",
		mesh_r_arm		= "vampire_heavy_r_arm_1.png",
		mesh_l_hand		= "vampire_heavy_l_hand_1.png",
		mesh_r_hand		= "vampire_heavy_r_hand_1.png",
		mesh_l_leg		= "vampire_heavy_l_leg_1.png",
		mesh_r_leg		= "vampire_heavy_r_leg_1.png",
	},

	spinTexture			= nil,
}

ArchetypeSetup[2] =		-- Ben, I've treated this as the in the air Vampire. It has the new anims for idle and attack.
{
	archetypeFile		= "vampire_heavy.cm",

	anims =
	{
		IDLE			= {"hover_1"},
		RUN				= {"n_run_berserker_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"hover_throw_1"},
		
		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_2"},
		DEATH_B			= {"n_die_b_2"},

		BEHAVIOUR		= {"n_frenzy_1"},
		
		TAUNT			= {"n_taunt_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_katanapair_1"},
	},

	meshs =
	{
		weapon_stake_r_hand_1	= "vampire_heavy_stake_1.png",
		weapon_stake_l_hand_1	= "vampire_heavy_stake_1.png",

		mesh_head		= "vampire_heavy_head_1.png",
		mesh_body		= "vampire_heavy_body_1.png",
		mesh_l_arm		= "vampire_heavy_l_arm_1.png",
		mesh_r_arm		= "vampire_heavy_r_arm_1.png",
		mesh_l_hand		= "vampire_heavy_l_hand_1.png",
		mesh_r_hand		= "vampire_heavy_r_hand_1.png",
		mesh_l_leg		= "vampire_heavy_l_leg_1.png",
		mesh_r_leg		= "vampire_heavy_r_leg_1.png",
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
		{ textureName = "gibs_vampire_head.png",			offset = 50, 	force = 4,	 },
		{ textureName = "vampire_heavy_stake_1.png",		offset = 50, 	force = 2,		repCount = 1},
	}
}