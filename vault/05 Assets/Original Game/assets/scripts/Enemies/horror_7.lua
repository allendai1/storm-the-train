EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 180, -- was 190
	ENEMY_WEIGHT			= 2,

	ENEMY_BOUNDINGBOX_X		= 36,
	ENEMY_BOUNDINGBOX_Y		= 85,

	ENEMY_SPAWN_COST		= 15,

	SHIELD_HEALTH			= 90, -- was 125 -- this isn't used!
	SHIELD_OFFSET			= 16,

	SHIELD_SIZE_W			= 10,
	SHIELD_SIZE_H			= 64,
	
	ENEMY_DAMAGE_TIMER 		= 0.75,

	ENEMY_FREEZE_SCALAR		= 0.6,

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "MEDIUM_MELEE",
	ENEMY_SECONDARY_WEAPON	= "MEDIUM_STAKE",
}

EnemyType = "NORMAL_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.keyBox =
{
	mesh_box = "graham_char_oriental_key_box.png",
}

ArchetypeSetup.blueprint = 
{
	mesh_blueprint = "vampire_2_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "vampire_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_bigkatana_1"},
		RUN				= {"n_run_butterfly_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_bigkatana_2", "n_attack_bigkatana_3"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_bigkatana_1"},
	},

	meshs =
	{
		weapon_stake_r_hand_1	= "vampire_medium_stake_1.png",
		weapon_stake_l_hand_1	= "vampire_medium_stake_1.png",

		--mesh_hat			= "vampire_middle_hat_1.png", -- Halloween
		mesh_head			= "vampire_middle_head_2.png",
		mesh_body			= "vampire_middle_body_2.png",
		mesh_l_arm			= "vampire_middle_l_arm_2.png",
		mesh_r_arm			= "vampire_middle_r_arm_2.png",
		mesh_l_hand			= "vampire_middle_l_hand_2.png",
		mesh_r_hand			= "vampire_middle_r_hand_2.png",
		mesh_l_leg			= "vampire_middle_l_leg_2.png",
		mesh_r_leg			= "vampire_middle_r_leg_2.png",
	},

	spinTexture			= nil,
}

ArchetypeSetup[2] =
{
	archetypeFile		= "vampire_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_bigkatana_1"},
		RUN				= {"n_run_butterfly_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_bigkatana_1"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_bigkatana_1"},
	},

	meshs =
	{
		weapon_stake_r_hand_1	= "vampire_medium_stake_1.png",
		weapon_stake_l_hand_1	= "vampire_medium_stake_1.png",

		--mesh_hat			= "vampire_middle_hat_1.png", -- Halloween
		mesh_head			= "vampire_middle_head_2.png",
		mesh_body			= "vampire_middle_body_2.png",
		mesh_l_arm			= "vampire_middle_l_arm_2.png",
		mesh_r_arm			= "vampire_middle_r_arm_2.png",
		mesh_l_hand			= "vampire_middle_l_hand_2.png",
		mesh_r_hand			= "vampire_middle_r_hand_2.png",
		mesh_l_leg			= "vampire_middle_l_leg_2.png",
		mesh_r_leg			= "vampire_middle_r_leg_2.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{

		{ textureName = "gibs_generic_flesh_3.png", repCount = 2},
		{ textureName = "gibs_generic_heart_1.png", repCount = 1},
		{ textureName = "gibs_generic_bone_1.png", repCount = 3},
		{ textureName = "vampire_medium_stake_1.png", repCount = 2},
		{ textureName = "gibs_ninja_3.png", repCount = 2},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_vampire_skull.png",		offset = 50, 	force = 2,		repCount = 1},
		{ textureName = "gibs_vampire_body_1.png",		offset = 30, 	force = 1,		repCount = 1},
		{ textureName = "gibs_vampire_arm_1.png",		offset = 40, 	force = 1,		repCount = 2},
	}
}
