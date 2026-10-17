EnemySetup =
{
	ENEMY_HEALTH				= 35,
	ENEMY_MOVESPEED				= 90, -- was 160
	ENEMY_WEIGHT				= 1,

	ENEMY_BOUNDINGBOX_X			= 20,
	ENEMY_BOUNDINGBOX_Y			= 76,

	ENEMY_SPAWN_COST			= 2,
	ENEMY_DAMAGE_TIMER 			= 0.5,

	UNDEAD_REVIVE_PROBABILITY	= 70,	-- % chance 1 - 100
	UNDEAD_DEAD_TIME			= 2,
		
	ENEMY_FREEZE_SCALAR			= 1,
	ENEMY_FLEE_ON_FIRE			= 1, -- true

	ENEMY_DEATH_SOUND			= "SOUND_SKELETON_DEATH",
	ENEMY_GIB_SOUND				= "SOUND_SKELETON_GIB",
}

EffectData =
{
	EE_DEFAULT_HIT = EFFECT_SKELETON_HIT,

	EE_DEFAULT_GIB = EFFECT_SKELETON_HIT,
	EE_BALL_GIB = EFFECT_SKELETON_HIT,
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "LIGHT_MELEE",
}

EnemyType = "UNDEAD_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.blueprint =
{
	mesh_blueprint = "vampire_2_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "skeleton_light.cm",

	anims =
	{
		IDLE			= {"n_idle_katana_1"},
		RUN				= {"n_run_sai_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_katana_1", "n_attack_katana_2", "n_attack_katana_3"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {"n_stow_a_katana_1"},
		SWAP_WEAPON_B	= {"n_stow_b_katana_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		SPIN 			= {"n_spin_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_katana_1"},

		REVIVE			= {"s_revive_1"},

		ON_FIRE			= {"n_run_fire"},
	},

	meshs =
	{
		weapon_r_hand_1	= "skeleton_light_sword_1.png",

		mesh_head		= "skeleton_light_head_1.png",
		mesh_body		= "skeleton_light_body_1.png",
		mesh_l_arm		= "skeleton_light_l_arm_1.png",
		mesh_r_arm		= "skeleton_light_r_arm_1.png",
		mesh_l_hand		= "skeleton_light_l_hand_1.png",
		mesh_r_hand		= "skeleton_light_r_hand_1.png",
		mesh_l_leg		= "skeleton_light_l_leg_1.png",
		mesh_r_leg		= "skeleton_light_r_leg_1.png",
	},

	spinTexture			= "enemy_ninja_spin.png",
}

GibSetup =
{
	genericGibs =
	{

		{ textureName = "gibs_generic_bone_1.png",		repCount = 3},
		{ textureName = "skeleton_light_sword_1.png",	repCount = 1},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_skeleton_skull.png",		offset = 40, 	force = 2,		repCount = 1},
		{ textureName = "gibs_skeleton_jaw.png",		offset = 40, 	force = 0.5,	repCount = 1},	
		{ textureName = "gibs_skeleton_ribcage.png",	offset = 20, 	force = 0.5,	repCount = 1},
	}
	
}