EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 180, -- was 220
	ENEMY_WEIGHT			= 2,

	ENEMY_BOUNDINGBOX_X		= 36,
	ENEMY_BOUNDINGBOX_Y		= 85,

	ENEMY_SPAWN_COST		= 15,

	SHIELD_HEALTH			= 90, -- was 125
	SHIELD_OFFSET			= 16,

	SHIELD_SIZE_W			= 10,
	SHIELD_SIZE_H			= 64,

	SHIELD_GIB_TYPE			= 0,

	ENEMY_DAMAGE_TIMER 		= 0.75,

	ENEMY_FREEZE_SCALAR		= 0.6,

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "MEDIUM_MELEE",
	ENEMY_SECONDARY_WEAPON	= "MEDIUM_FIREBALL",
}

EnemyType = "SHIELD_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.keyBox =
{
	mesh_box = "graham_char_oriental_key_box.png",
}

ArchetypeSetup.blueprint = 
{
	mesh_blueprint = "ninja_4_blueprint.png",
}

--Primary with shield
ArchetypeSetup[1] =
{
	archetypeFile		= "ninja_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_bigkatana_1"},
		RUN				= {"n_run_bigkatana_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_bigkatana_1", "n_attack_bigkatana_2", "n_attack_bigkatana_3"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {"n_stow_a_bigkatana_1"},
		SWAP_WEAPON_B	= {"n_stow_b_bigkatana_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_bigkatana_1"},
	},

	meshs =
	{
		weapon_shield_r_hand	= "n_shield_m_ninja_1.png",
		weapon_katana_l_hand	= "n_weapon_katana.png",

		mesh_head		= "n_middle_head_3.png",
		mesh_body		= "n_middle_body_3.png",
		mesh_l_arm		= "n_middle_l_arm_3.png",
		mesh_r_arm		= "n_middle_r_arm_3.png",
		mesh_l_hand		= "n_middle_l_hand_3.png",
		mesh_r_hand		= "n_middle_r_hand_3.png",
		mesh_l_leg		= "n_middle_l_leg_3.png",
		mesh_r_leg		= "n_middle_r_leg_3.png",
	},

	spinTexture			= nil,
}

--Secondary with shield
ArchetypeSetup[2] =
{
	archetypeFile		= "ninja_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_bigkatana_1"},
		RUN				= {"n_run_bigkatana_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_range_2"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {"n_stow_a_bigkatana_1"},
		SWAP_WEAPON_B	= {"n_stow_b_bigkatana_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_bigkatana_1"},
	},

	meshs =
	{
		weapon_shield_r_hand	= "n_shield_m_ninja_1.png",

		mesh_head		= "n_middle_head_3.png",
		mesh_body		= "n_middle_body_3.png",
		mesh_l_arm		= "n_middle_l_arm_3.png",
		mesh_r_arm		= "n_middle_r_arm_3.png",
		mesh_l_hand		= "n_middle_l_hand_3.png",
		mesh_r_hand		= "n_middle_r_hand_3.png",
		mesh_l_leg		= "n_middle_l_leg_3.png",
		mesh_r_leg		= "n_middle_r_leg_3.png",
	},

	spinTexture			= nil,
}

--Primary without shield
ArchetypeSetup[3] =
{
	archetypeFile		= "ninja_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_balisong_1"},
		RUN				= {"n_run_balisong_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_balisong_1", "n_attack_bigkatana_1", "n_attack_balisong_3"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		--SWAP_WEAPON_A	= {"n_stow_a_bigkatana_1"},
		--SWAP_WEAPON_B	= {"n_stow_b_bigkatana_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_bigkatana_1"},
	},

	meshs =
	{
		weapon_katana_l_hand	= "n_weapon_katana.png",

		mesh_head			= "n_middle_head_3.png",
		mesh_body			= "n_middle_body_3.png",
		mesh_l_arm			= "n_middle_l_arm_3.png",
		mesh_r_arm			= "n_middle_r_arm_3.png",
		mesh_l_hand			= "n_middle_l_hand_3.png",
		mesh_r_hand			= "n_middle_r_hand_3.png",
		mesh_l_leg			= "n_middle_l_leg_3.png",
		mesh_r_leg			= "n_middle_r_leg_3.png",
	},

	spinTexture			= nil,
}

--secondary without shield
ArchetypeSetup[4] =
{
	archetypeFile		= "ninja_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_balisong_1"},
		RUN				= {"n_run_balisong_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_range_1"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		--SWAP_WEAPON_A	= {"n_stow_a_bigkatana_1"},
		--SWAP_WEAPON_B	= {"n_stow_b_bigkatana_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_bigkatana_1"},
	},

	meshs =
	{
		weapon_katana_l_hand	= "n_weapon_katana.png",
		
		mesh_head			= "n_middle_head_3.png",
		mesh_body			= "n_middle_body_3.png",
		mesh_l_arm			= "n_middle_l_arm_3.png",
		mesh_r_arm			= "n_middle_r_arm_3.png",
		mesh_l_hand			= "n_middle_l_hand_3.png",
		mesh_r_hand			= "n_middle_r_hand_3.png",
		mesh_l_leg			= "n_middle_l_leg_3.png",
		mesh_r_leg			= "n_middle_r_leg_3.png",
	},

	spinTexture			= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_generic_flesh_1.png", repCount = 2},
		{ textureName = "gibs_generic_flesh_2.png", repCount = 2},
		{ textureName = "gibs_generic_flesh_3.png", repCount = 2},
		{ textureName = "gibs_generic_heart_1.png", repCount = 1},
		{ textureName = "gibs_generic_bone_1.png",	repCount = 3},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_generic_skull_1.png",		offset = 50, 	force = 3,		repCount = 1},
		{ textureName = "gibs_generic_brain_1.png",		offset = 50, 	force = 2,		repCount = 1},
		{ textureName = "gibs_ninja_mid_body_7.png",	offset = 30, 	force = 2,		repCount = 1},
		{ textureName = "gibs_ninja_mid_limb_7.png",	offset = 20, 	force = 1,		repCount = 2},
		{ textureName = "n_weapon_katana.png",			offset = 20, 	force = 2,		repCount = 1},
	}
}
