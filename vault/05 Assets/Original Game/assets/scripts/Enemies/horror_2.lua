EnemySetup =
{
	ENEMY_HEALTH				= 40,
	ENEMY_MOVESPEED				= 110, -- was 200
	ENEMY_WEIGHT				= 1.4,

	ENEMY_BOUNDINGBOX_X			= 20,
	ENEMY_BOUNDINGBOX_Y			= 76,

	ENEMY_SPAWN_COST			= 1.7,
	ENEMY_DAMAGE_TIMER 			= 1,

	UNDEAD_REVIVE_PROBABILITY	= 75,	-- % chance 1 - 100
	UNDEAD_DEAD_TIME			= 1.5,
		
	ENEMY_FREEZE_SCALAR			= 1,
	ENEMY_FLEE_ON_FIRE			= 1, -- true

	ENEMY_DEATH_SOUND			= "SOUND_ZOMBIE_DEATH",
	ENEMY_GIB_SOUND				= "SOUND_FLESH_GIB",
	
	ENEMY_MISSION_HANDLE		= "EMH_ZOMBIE",
}

EffectData =
{
	EE_DEFAULT_HIT = EFFECT_DAMAGE_GREEN_BLOOD,

	EE_DEFAULT_GIB = EFFECT_GIB_GREEN_BLOOD,
	EE_BALL_GIB = EFFECT_GIB_GREEN_BALL,
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
	archetypeFile		= "zombie_light.cm",

	anims =
	{
		IDLE			= {"z_idle_1"},
		RUN				= {"z_walk_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"z_attack_1"},

		CELEBRATE_A		= {"z_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		SPIN 			= {"n_spin_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"z_damage_1"},

		REVIVE			= {"z_revive_1"},


		ON_FIRE			= {"n_run_fire"},
	},


	meshs =
	{
	--	weapon_r_hand_3		= "n_weapon_kama.png",
	--	weapon_l_hand_3		= "n_weapon_kama.png",

		mesh_head		= "zombie_light_head_2.png",
		mesh_body		= "zombie_light_body_2.png",
		mesh_l_arm		= "zombie_light_l_arm_2.png",
		mesh_r_arm		= "zombie_light_r_arm_2.png",
		mesh_l_hand		= "zombie_light_l_hand_2.png",
		mesh_r_hand		= "zombie_light_r_hand_2.png",
		mesh_l_leg		= "zombie_light_l_leg_2.png",
		mesh_r_leg		= "zombie_light_r_leg_2.png",
	},

	spinTexture			= "enemy_ninja_spin.png",
}

GibSetup =
{
	genericGibs =
	{
		{ textureName = "gibs_zombie_meat.png", repCount = 2},
		{ textureName = "gibs_zombie_bone_1.png", repCount = 2},
		{ textureName = "gibs_zombie_bone_2.png", repCount = 1},
		{ textureName = "gibs_zombie_arm.png", repCount = 1},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_zombie_skull.png",		offset = 40, 	force = 2 },
		{ textureName = "gibs_zombie_brain.png",		offset = 40, 	force = 2 },
	}
}
