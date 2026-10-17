EnemySetup =
{
	ENEMY_HEALTH			= 160,
	ENEMY_MOVESPEED			= 160, -- was 200
	ENEMY_WEIGHT			= 2,

	ENEMY_BOUNDINGBOX_X		= 36,
	ENEMY_BOUNDINGBOX_Y		= 95,

	ENEMY_SPAWN_COST		= 15,

	BERSERK_HEALTH			= 30, -- was 50
	BERSERK_DIST			= 512,
	BERSERK_OFFSET_X	 	= 15,
	BERSERK_OFFSET_Y		= 25,
	BERSERK_SIZE_W		 	= 60,
	BERSERK_SIZE_H			= 17,
	BERSERK_EFFECT			= "EFFECT_FRENZY_1", -- For more effects remember to add them to script bind (Enemy Data: line 169)

	ENEMY_DAMAGE_TIMER 		= 0.75,

	ENEMY_FREEZE_SCALAR		= 0.6,

	ENEMY_DEATH_SOUND		= "SOUND_LIVING_DEATH",
	ENEMY_GIB_SOUND			= "SOUND_FLESH_GIB",
	
	ENEMY_MISSION_HANDLE	= "EMH_WOLFMAN",
}

WeaponData = 
{
	ENEMY_PRIMARY_WEAPON	= "MEDIUM_MELEE",
}

EnemyType = "BERSERKER_ENEMY"

ArchetypeSetup = {}
ArchetypeSetup.keyBox =
{
	mesh_box = "graham_char_oriental_key_box.png",
}

ArchetypeSetup.blueprint = 
{
	mesh_blueprint = "wolf_blueprint.png",
}

ArchetypeSetup[1] =
{
	archetypeFile		= "wolfman_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_butterfly_1"},
		RUN				= {"n_run_butterfly_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_butterfly_1", "n_attack_butterfly_2", "n_attack_butterfly_3"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},
		
		BEHAVIOUR		= {"n_berserker_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_butterfly_1"},
	},

	meshs =
	{
		--mesh_hat_1			= "wolfman_middle_hat_1.png", --Halloween
		mesh_head			= "wolfman_middle_head_1.png",
		mesh_body			= "wolfman_middle_body_1.png",
		mesh_l_arm			= "wolfman_middle_l_arm_1.png",
		mesh_r_arm			= "wolfman_middle_r_arm_1.png",
		mesh_l_hand			= "wolfman_middle_l_hand_1.png",
		mesh_r_hand			= "wolfman_middle_r_hand_1.png",
		mesh_l_leg			= "wolfman_middle_l_leg_1.png",
		mesh_r_leg			= "wolfman_middle_r_leg_1.png",
	},

	spinTexture			= nil,
}

ArchetypeSetup[2] =
{
	archetypeFile		= "wolfman_medium.cm",

	anims =
	{
		IDLE			= {"n_idle_butterfly_1"},
		RUN				= {"n_run_berserker_1"},
		JUMP			= {"n_jump_1"},
		ATTACK			= {"n_attack_butterfly_1", "n_attack_butterfly_2", "n_attack_butterfly_3"},

		CELEBRATE_A		= {"n_celebrate_a_1"},
		CELEBRATE_B		= {"n_celebrate_b_1"},

		SWAP_WEAPON_A	= {},
		SWAP_WEAPON_B	= {},
		
		BEHAVIOUR		= {"n_berserker_1"},

		DEATH_A			= {"n_die_a_1"},
		DEATH_B			= {"n_die_b_1"},

		DAMAGE_BEAM		= {"n_damage_beam_1"},
		DAMAGE_GUN		= {"n_damage_butterfly_1"},
	},

	meshs =
	{
		--mesh_hat_1			= "wolfman_middle_hat_1.png", --halloween
		mesh_head			= "wolfman_middle_head_1.png",
		mesh_body			= "wolfman_middle_body_1.png",
		mesh_l_arm			= "wolfman_middle_l_arm_1.png",
		mesh_r_arm			= "wolfman_middle_r_arm_1.png",
		mesh_l_hand			= "wolfman_middle_l_hand_1.png",
		mesh_r_hand			= "wolfman_middle_r_hand_1.png",
		mesh_l_leg			= "wolfman_middle_l_leg_1.png",
		mesh_r_leg			= "wolfman_middle_r_leg_1.png",
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
		{ textureName = "gibs_ninja_mid_leg_6.png", repCount = 2},
	},

	uniqueGibs =
	{
		{ textureName = "gibs_generic_skull_1.png",		offset = 50, 	force = 2,		repCount = 1},
		{ textureName = "gibs_wolfman_hand_1.png",		offset = 30, 	force = 0.5,	repCount = 1},
		{ textureName = "gibs_wolfman_hand_2.png",		offset = 30, 	force = 0.5,	repCount = 1},
	}
}
