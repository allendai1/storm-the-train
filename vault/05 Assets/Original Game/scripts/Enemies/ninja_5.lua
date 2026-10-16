EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 170, -- was 210
	ENEMY_WEIGHT			= 1.6,

	ENEMY_BOUNDINGBOX_X		= 25,
	ENEMY_BOUNDINGBOX_Y		= 80,

	ENEMY_SPAWN_COST		= 15,

	AGILE_SPINJUMPTIME		= 2.8, -- was 2.25

	ENEMY_DAMAGE_TIMER 		= 0.75,

	ENEMY_FREEZE_SCALAR		= 0.6,

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
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
	mesh_blueprint = "ninja_1_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "ninja_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_balisong_1"},
		RUN				= {"n_run_balisong_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_balisong_1", "n_attack_balisong_2", "n_attack_balisong_3"},

		SPIN 			= {"n_spin_1"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_balisong_1"},
	},

	meshs =
	{
		weapon_balisong_r_hand	= "n_weapon_balisong.png",
		weapon_balisong_l_hand	= "n_weapon_balisong.png",

		mesh_head			= "n_middle_head_1.png",
		mesh_body			= "n_middle_body_1.png",
		mesh_l_arm			= "n_middle_l_arm_1.png",
		mesh_r_arm			= "n_middle_r_arm_1.png",
		mesh_l_hand			= "n_middle_l_hand_1.png",
		mesh_r_hand			= "n_middle_r_hand_1.png",
		mesh_l_leg			= "n_middle_l_leg_1.png",
		mesh_r_leg			= "n_middle_r_leg_1.png",
	},

	spinTexture			= "enemy_ninja_spin.png",
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_generic_flesh_1.png",  repCount = 2},
		{ textureName = "gibs_generic_flesh_2.png",  repCount = 2},
		{ textureName = "gibs_generic_flesh_3.png",  repCount = 2},
		{ textureName = "gibs_generic_heart_1.png",  repCount = 1},
		{ textureName = "gibs_generic_bone_1.png",	 repCount = 3},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_generic_skull_1.png",		offset = 50, 	force = 3,		repCount = 1},
		{ textureName = "gibs_generic_brain_1.png",		offset = 50, 	force = 2,		repCount = 1},
		{ textureName = "gibs_ninja_mid_body_5.png",	offset = 30, 	force = 2,		repCount = 1},
		{ textureName = "n_weapon_balisong.png",		offset = 20, 	force = 2,		repCount = 2},
		{ textureName = "gibs_ninja_mid_foot_5.png",	offset = 0, 	force = 2,		repCount = 2},
	}
}
