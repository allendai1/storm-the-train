EnemySetup =
{
	ENEMY_HEALTH			= 30,
	ENEMY_MOVESPEED			= 160, -- was 205,
	ENEMY_WEIGHT			= 1,

	ENEMY_BOUNDINGBOX_X		= 20,
	ENEMY_BOUNDINGBOX_Y		= 76,

	ENEMY_SPAWN_COST		= 3,

	ENEMY_FREEZE_SCALAR		= 1,
	ENEMY_FLEE_ON_FIRE		= 1, -- true

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "FIREWORK",
	ENEMY_DEATH_WEAPON		= "FIREWORK_DEATH",	
}

EnemyType = "COWARD_ENEMY"

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
		IDLE			= {"n_idle_kama_1"},
		RUN				= {"n_run_sai_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_range_2"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_sai_1"},

		ON_FIRE			= {"n_run_fire"},
	},

	meshs =
	{
		mesh_head		= "n_light_head_4.png",
		mesh_body		= "n_light_body_4.png",
		mesh_back_fireworks	= "n_light_back_fireworks.png",
		mesh_l_arm		= "n_light_l_arm_4.png",
		mesh_r_arm		= "n_light_r_arm_4.png",
		mesh_l_hand		= "n_light_l_hand_4.png",
		mesh_r_hand		= "n_light_r_hand_4.png",
		mesh_l_leg		= "n_light_l_leg_4.png",
		mesh_r_leg		= "n_light_r_leg_4.png",
		mesh_back_fireworks = "n_light_back_fireworks.png";
	},

	spinTexture			= "enemy_ninja_spin.png",
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
		{ textureName = "gibs_ninja_body_3.png",		offset = 20, 	force = 1,		repCount = 1},
		{ textureName = "gibs_ninja_3.png",				offset = 20, 	force = 1,		repCount = 2},
		{ textureName = "n_weapon_sai.png",				offset = 10, 	force = 1,		repCount = 1},
	}
}