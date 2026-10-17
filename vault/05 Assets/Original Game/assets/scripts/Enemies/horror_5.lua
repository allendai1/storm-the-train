EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 170, -- was 200
	ENEMY_WEIGHT			= 2,

	ENEMY_BOUNDINGBOX_X		= 25,
	ENEMY_BOUNDINGBOX_Y		= 80,

	ENEMY_SPAWN_COST		= 15,

	TELEPORT_INTERVAL_MIN	= 3,
	TELEPORT_INTERVAL_MAX	= 6, 

	TELEPORT_TIME 			= 0.8,
	TELEPORT_RECOVER_TIME	= 0.4,

	ENEMY_DAMAGE_TIMER 		= 0.75,

	ENEMY_FREEZE_SCALAR		= 0.6,

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
}



WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "MEDIUM_MELEE",
}

EnemyType = "TELEPORT_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.keyBox =
{
	mesh_box = "graham_char_oriental_key_box.png",
}

ArchetypeSetup.blueprint =
{
	mesh_blueprint = "vampire_1_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "vampire_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_balisong_1"},
		RUN				= {"n_run_balisong_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_balisong_1", "n_attack_balisong_2", "n_attack_balisong_3"},

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
		weapon_stake_r_hand_1	= "vampire_medium_stake_1.png",
		weapon_stake_l_hand_1	= "vampire_medium_stake_1.png",

		--mesh_hat			= "vampire_middle_hat_2.png", -- Halloween
		mesh_head			= "vampire_middle_head_1.png",
		mesh_body			= "vampire_middle_body_1.png",
		mesh_l_arm			= "vampire_middle_l_arm_1.png",
		mesh_r_arm			= "vampire_middle_r_arm_1.png",
		mesh_l_hand			= "vampire_middle_l_hand_1.png",
		mesh_r_hand			= "vampire_middle_r_hand_1.png",
		mesh_l_leg			= "vampire_middle_l_leg_1.png",
		mesh_r_leg			= "vampire_middle_r_leg_1.png",
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
		{ textureName = "gibs_vampire_body.png",		offset = 30, 	force = 1,		repCount = 1},
		{ textureName = "gibs_vampire_arm.png",			offset = 40, 	force = 1,		repCount = 2},
	}
}
