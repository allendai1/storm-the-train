EnemySetup =
{
	ENEMY_HEALTH			= 25,
	ENEMY_MOVESPEED			= 200,
	ENEMY_WEIGHT			= 1,

	ENEMY_BOUNDINGBOX_X		= 20,
	ENEMY_BOUNDINGBOX_Y		= 76,

	ENEMY_SPAWN_COST		= 0.1,

	ENEMY_FREEZE_SCALAR		= 1,

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
}

EnemyType = "HOSTAGE_NEUTRAL"

ArchetypeSetup = {}
ArchetypeSetup[1] =
{
	archetypeFile		= "hostage_1.cm",

	anims =
	{
		IDLE			= {"hostage_idle"},
		RUN				= {"hostage_run_1"},
		JUMP			= {"hostage_jump_1"},

		CELEBRATE_A		= {"hostage_celebrate_a_1"},
		CELEBRATE_B		= {"hostage_celebrate_a_1"},


		DEATH_A			= {"hostage_die_a_1"},
		DEATH_B			= {"hostage_die_b_1"},
	},

	meshs =
	{
		mesh_head			= "hostage_head_1.png",
		mesh_body			= "hostage_body_1.png",
		mesh_l_arm			= "hostage_l_arm_1.png",
		mesh_r_arm			= "hostage_r_arm_1.png",
		mesh_l_hand			= "hostage_l_hand_1.png",
		mesh_r_hand			= "hostage_r_hand_1.png",
		mesh_l_leg			= "hostage_l_leg_1.png",
		mesh_r_leg			= "hostage_r_leg_1.png",
	},

	spinTexture				= nil,
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_generic_flesh_1.png", repCount = 2},
		{ textureName = "gibs_generic_flesh_2.png", repCount = 2},
		{ textureName = "gibs_generic_flesh_3.png", repCount = 2},
		{ textureName = "gibs_generic_heart_1.png", repCount = 1},
		{ textureName = "gibs_generic_bone_1.png", repCount = 2},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_generic_skull_1.png"},
		{ textureName = "gibs_generic_brain_1.png"},
	},
}
