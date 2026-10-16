EnemySetup =
{
	ENEMY_HEALTH			= 25,
	ENEMY_MOVESPEED			= 140, -- was 225,
	ENEMY_WEIGHT			= 1,

	ENEMY_BOUNDINGBOX_X		= 20,
	ENEMY_BOUNDINGBOX_Y		= 76,

	ENEMY_SPAWN_COST		= 3,

	ENEMY_FREEZE_SCALAR		= 1,
	ENEMY_FLEE_ON_FIRE		= 1, -- true

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
	
	ENEMY_MISSION_HANDLE	= "EMH_YELLOW_NINJA",
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "LIGHT_MELEE",
}

EnemyType = "NORMAL_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.blueprint =
{
	mesh_blueprint = "ninja_1_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "ninja_light.cm",

	anims =
	{
		IDLE			= {"n_idle_sai"},
		RUN				= {"n_run_sai_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_sai_1", "n_attack_sai_2", "n_attack_sai_3"},
		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_sai_1"},
		
		REVIVE			= {"n_idle_sai"},

		ON_FIRE			= {"n_run_fire"},
	},

	meshs =
	{
		weapon_r_hand_2		= "n_weapon_sai.png",
		weapon_l_hand_2		= "n_weapon_sai.png",

		mesh_head			= "n_light_head_1.png",
		mesh_body			= "n_light_body_1.png",
		mesh_l_arm			= "n_light_l_arm_1.png",
		mesh_r_arm			= "n_light_r_arm_1.png",
		mesh_l_hand			= "n_light_l_hand_1.png",
		mesh_r_hand			= "n_light_r_hand_1.png",
		mesh_l_leg			= "n_light_l_leg_1.png",
		mesh_r_leg			= "n_light_r_leg_1.png",
	},

	spinTexture				= "enemy_ninja_spin.png",
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_generic_flesh_1.png", repCount = 2},
		{ textureName = "gibs_generic_flesh_2.png", repCount = 2},
		{ textureName = "gibs_generic_flesh_3.png", repCount = 2},
		{ textureName = "gibs_generic_heart_1.png", repCount = 1},
		{ textureName = "gibs_generic_bone_1.png", repCount = 3},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_generic_skull_1.png",		offset = 40, 	force = 2,		repCount = 1},
		{ textureName = "gibs_generic_brain_1.png",		offset = 40, 	force = 1,		repCount = 1},
		{ textureName = "gibs_ninja_body_1.png",		offset = 20, 	force = 1,		repCount = 1},
		{ textureName = "gibs_ninja_1.png",				offset = 20, 	force = 1,		repCount = 2},
		{ textureName = "n_weapon_sai.png",				offset = 20, 	force = 1,		repCount = 2},
	}
}