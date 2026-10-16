return
{
-- Bob 
  {
    __id=31, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    ownInstructions="CHAR_OWN_INSTRUCTIONS_BOB",
    levels={
      {
        name="CHAR_NAME_BOB", -- Barracks name
        desc="CHAR_DESC_BOB", -- Barracks description
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "bob", -- chr_<modelAffix>
      textureAffix = "bob", -- used for finding textures
      speechAffix = "BOB", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 16, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 16, fireLocator = "xform_r_hand", fireOffset = {101, 15}}, -- sticky rifle
          { wepItemID = 8, fireLocator = "xform_r_hand", fireOffset = {101, 15}}, -- plasma cannon
       },
      gadgets = {196614,131078,851974,6}, -- removed these 524294, 196614, 262150,
      params =  
       {
        CHARACTER_BOUNDINGBOX_X = 26,
        CHARACTER_BOUNDINGBOX_Y = 110,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 118,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2.2,
        CHARACTER_JUMP_SCALE = 1.2,
      },
      gibSetup =
      {
        { textureName = "gibs_bob_1.png", offset = 50, force = 3, unique = true },
        { textureName = "gibs_bob_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_bob_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_bob_4.png", offset = 10, repCount = 2, unique = true },
        { textureName = "gibs_bob_5.png", offset = 10, repCount = 3, unique = true },
      },
      challenges =
      {
        {mode = 1, target = 5, difficulty = 0}, -- Oriental
        {mode = 5, target = 500}, --JETPACK
        {mode = 3, target = 6, difficulty = 1}, -- Future
        {mode = 4, target = 800}, --CDW
        {mode = 2, target = 7, difficulty = 2}, -- Horror
      },
      abilities =
      {
        {abilityID=100, level=8},
        {abilityID=101, level=5},
        {abilityID=102, level=9},
        {abilityID=103, level=9},
        {abilityID=104, level=3},
        {abilityID=105, level=3},
        {abilityID=106, level=3},
      },
    },
  },
-- Graham
  {
    __id=512,
    tab = 2,
    category=0,
    serialisable=true,
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_GRAHAM", -- Barracks name
        desc="CHAR_DESC_GRAHAM", -- Barracks description
        priceTier="free",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "graham",
      textureAffix = "graham",
      speechAffix = "GRAHAM",
      defaultWeapon = 524801,
      weapons = { 
        { wepItemID = 524801, fireLocator = "xform_r_hand", fireOffset = {90, 12}}, -- Dual Rifles
        { wepItemID = 590337, fireLocator = "xform_l_hand", fireOffset = {40, 9}}, -- Rocket Launcher
      },
      gadgets = { 196614, 131078, 6,},
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_graham_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_graham_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_graham_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_graham_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 2, target = 5, difficulty = 0}, -- Horror
        {mode = 4, target = 500}, --CDW
        {mode = 3, target = 6, difficulty = 1}, -- Future
        {mode = 5, target = 500}, --JETPACK
        {mode = 1, target = 7, difficulty = 2}, -- Oriental
      },
      abilities =
      {
        {abilityID=100, level=5},
        {abilityID=101, level=7},
        {abilityID=102, level=4},
      },
    },
  },
-- Mason
  {
    __id=768,
    tab = 2,
    category=0,
    serialisable=true,
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_MASON", -- Barracks name
    		priceTier = "char_low",
        desc="CHAR_DESC_MASON", -- Barracks description
        icon="ui_icon_guss.png",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "mason",
      textureAffix = "mason",
      speechAffix = "MASON",
      defaultWeapon = 525057,
      weapons = {
        { wepItemID = 525057, fireLocator = "xform_r_hand", fireOffset = {75, 9}}, -- Shotgun
        { wepItemID = 590593, fireLocator = "xform_r_hand", fireOffset = {75, -9}}, -- Minigun
      },
      gadgets = { 262150, 851974, 6, },
      weaponFireLocators = { "xform_l_hand", "xform_r_hand" },
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 25,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 110,
        CHARACTER_FORCEFIELD_R = 60,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_mason_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_mason_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_mason_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_mason_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 1, target = 5, difficulty = 0}, -- Oriental
        {mode = 5, target = 500}, --JETPACK
        {mode = 3, target = 6, difficulty = 1}, -- Future
        {mode = 4, target = 800}, --CDW
        {mode = 2, target = 7, difficulty = 2}, -- Horror
      },
      abilities =
      {
        {abilityID=100, level=7},
        {abilityID=101, level=4},
        {abilityID=102, level=6},
        {abilityID=114, level=4},
      },
    },
  },
-- Carrera
  {
    __id=1024,
    tab = 2,
    category=0,
    serialisable=true,
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_CARRERA", -- Barracks name
        desc="CHAR_DESC_CARRERA", -- Barracks description
    		priceTier = "char_low",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "carrera",
      textureAffix = "carrera",
      speechAffix = "CARRERA",
      defaultWeapon = 525313,
      weapons = {
        { wepItemID = 525313, fireLocator = "xform_r_hand", fireOffset = {60, 10}}, -- Uzi
        { wepItemID = 590849, fireLocator = "xform_r_hand", fireOffset = {50, 7}}, -- Poison gun
      },
      gadgets = { 327686, 786438, 6, },
      weaponFireLocators = { "xform_l_hand", "xform_r_hand" },
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_carrera_1.png", offset = 42, force = 2, unique = true },
        { textureName = "gibs_carrera_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_carrera_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_carrera_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1},
        { textureName = "gibs_generic_heart_1.png", repCount = 1},
      },
      challenges =
      {
        {mode = 2, target = 5, difficulty = 0}, -- Horror
        {mode = 4, target = 500}, --CDW
        {mode = 3, target = 6, difficulty = 1}, -- Future
        {mode = 5, target = 500}, --JETPACK
        {mode = 1, target = 7, difficulty = 1}, -- Oriental
      },
      abilities =
      {
        {abilityID=100, level=3},
        {abilityID=101, level=10},
        {abilityID=102, level=3},
        {abilityID=111, level=1},
      },
    },
  },
-- Dino Graham 
  {
    __id=20, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_DINOGRAHAM", -- Barracks name
        desc="CHAR_DESC_DINOGRAHAM", -- Barracks description
        priceTier = "char_med",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "graham_dino", -- chr_<modelAffix>
      textureAffix = "dinoGraham", -- used for finding textures
      speechAffix = "DINO_GRAHAM", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 721665, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 721665, fireLocator = "xform_r_hand", fireOffset = {53, 5}}, -- Flamethrower
          { wepItemID = 590849, fireLocator = "xform_r_hand", fireOffset = {50, 7}}, -- Poison gun
       },
      gadgets = { 524294, 196614, 262150, },
      params =  
       {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_dinoGraham_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_graham_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_graham_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_graham_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 1, target = 5, difficulty = 0}, -- Oriental
        {mode = 5, target = 500}, --JETPACK
        {mode = 3, target = 6, difficulty = 1}, -- Future
        {mode = 4, target = 800}, --CDW
        {mode = 2, target = 7, difficulty = 2}, -- Horror
      },
      abilities =
      {
        {abilityID=100, level=5},
        {abilityID=101, level=7},
        {abilityID=102, level=7},
        {abilityID=106, level=4},
        {abilityID=105, level=-4},
      },
    },
  },
-- Kitty Mason 
  {
    __id=21, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_KITTYMASON", -- Barracks name
        desc="CHAR_DESC_KITTYMASON", -- Barracks description
        priceTier = "char_med",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "mason_kitty", -- chr_<modelAffix>
      textureAffix = "kittyMason", -- used for finding textures
      speechAffix = "KITTY_MASON", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 28, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 28, fireLocator = "xform_r_hand", fireOffset = {70, 12}}, -- Rifle
          { wepItemID = 656129, fireLocator = "xform_r_hand", fireOffset = {10, 14}}, -- Chainsaw
      },
      gadgets = { 917510, 131078, 851974, },
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_kittyMason_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_mason_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_mason_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_mason_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 5, target = 400}, --JETPACK
        {mode = 3, target = 5, difficulty = 0}, -- Future
        {mode = 2, target = 5, difficulty = 1}, -- Horror
        {mode = 1, target = 5, difficulty = 1}, -- Oriental
        {mode = 5, target = 600}, --JETPACK
      },
      abilities =
      {
        {abilityID=100, level=7},
        {abilityID=101, level=4},
        {abilityID=102, level=9},
        {abilityID=104, level=4},
        {abilityID=106, level=-4},
      },
    },
  },
-- Carrera Bear 
  {
    __id=22, -- has to be unique
    tab = 2,
    category=0, -- Not used
    itemCol=0, -- Color in the shop (enum)
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_CARRERABEAR", -- Barracks name
        desc="CHAR_DESC_CARRERABEAR", -- Barracks description
        priceTier = "char_med",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "carrera_bear", -- chr_<modelAffix>
      textureAffix = "carrera_bear", -- used for finding textures
      speechAffix = "CARRERA_BEAR", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 655873, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 655873, fireLocator = "xform_r_hand", fireOffset = {66, 9}}, -- Railgun
          { wepItemID = 656385, fireLocator = "xform_r_hand", fireOffset = {65, 12}}, -- Dual pistols
      },
      gadgets = { 983046, 262150, 786438, },
      damageModifiers = { ENV_ORIENTAL = 0.8, ENV_HORROR = 1, ENV_FUTURE = 1.2 }, -- 1.5 50% more damage inflicted
      defenceModifiers = { ENV_ORIENTAL = 1, ENV_HORROR = 1, ENV_FUTURE = 1 }, -- 1.5 = 50% more damage taken
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_carreraBear_1.png", offset = 42, force = 2, unique = true },
        { textureName = "gibs_carrera_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_carrera_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_carrera_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 2, target = 5, difficulty = 0}, -- Horror
        {mode = 4, target = 500}, --CDW
        {mode = 1, target = 6, difficulty = 1}, -- Oriental
        {mode = 4, target = 800}, --CDW
        {mode = 3, target = 7, difficulty = 2}, -- Future
      },
      abilities =
      {
        {abilityID=100, level=3},
        {abilityID=101, level=10},
        {abilityID=102, level=5},
        {abilityID=105, level=4},
        {abilityID=104, level=-4},
      },
    },
  },
-- Dead Zed (+10 damage to Ninjas, +40% shield against the undead)
  {
    __id=24, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_DEADZED", -- Barracks name
        desc="CHAR_DESC_DEADZED", -- Barracks description
        priceTier = "char_med",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "deadZed", -- chr_<modelAffix>
      textureAffix = "deadZed", -- used for finding textures
      speechAffix = "DEAD_ZED", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 27, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 27, fireLocator = "xform_r_hand", fireOffset = {59, 14}}, -- Pistol
          { wepItemID = 525313, fireLocator = "xform_r_hand", fireOffset = {60, 12}}, -- Uzi
      },
      gadgets = { 851974, }, 
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 0.9,
      },
      gibSetup =
      {
        { textureName = "gibs_deadZed_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_zombie_bone_1.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_zombie_bone_2.png", offset = 0, repCount = 2, unique = true },
        --{ textureName = "gibs_graham_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_zombie_meat.png", repCount = 1 },
        --{ textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 5, target = 400}, --JETPACK
        {mode = 3, target = 5, difficulty = 0}, -- Future
        {mode = 2, target = 5, difficulty = 1}, -- Horror
        {mode = 1, target = 5, difficulty = 1}, -- Oriental
        {mode = 5, target = 600}, --JETPACK
      },
      abilities =
      {
        {abilityID=100, level=9},
        {abilityID=101, level=1},
        {abilityID=102, level=2},
        {abilityID=114, level=5},
        {abilityID=112, level=3},
        {abilityID=107, level=4},
      },
    },
  },
-- Hal 
  {
    __id=30, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_HAL", -- shop title
        desc="CHAR_DESC_HAL", -- Barracks description
        icon="ui_icon_graham.png", -- shop icon
        priceTier = "char_high",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "hal", -- chr_<modelAffix>
      textureAffix = "hal", -- used for finding textures
      speechAffix = "HAL", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 29, -- THe weapon they start the game with, (They must own it)
      weapons = { 
        { wepItemID = 29, fireLocator = "xform_r_hand", fireOffset = {84, 12}}, -- Dual Uzi
        { wepItemID = 525057, fireLocator = "xform_r_hand", fireOffset = {75, 4}}, -- Shotgun
      },
      gadgets = { 917510, 131078, 262150, 6, }, -- {Suit melee,  Melee, defender, Air strike,}
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_hal_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_mason_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_mason_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_mason_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 2, target = 5, difficulty = 0}, -- Horror
        {mode = 4, target = 500}, --CDW
        {mode = 1, target = 6, difficulty = 1}, -- Oriental
        {mode = 4, target = 800}, --CDW
        {mode = 3, target = 7, difficulty = 2}, -- Future
      },
      abilities =
      {
        {abilityID=100, level=4},
        {abilityID=101, level=6},
        {abilityID=102, level=5},
        {abilityID=106, level=4},
        {abilityID=109, level=4},
        {abilityID=112, level=1},
      },

    },
  },
-- Cowgirl (+20% damage to undead)
  {
    __id=23, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_WONDER", -- Barracks name
        desc="CHAR_DESC_WONDER", -- Barracks description
        priceTier = "char_high",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "cowgirl", -- chr_<modelAffix>
      textureAffix = "cowgirl", -- used for finding textures
      speechAffix = "COWGIRL", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 28, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 28, fireLocator = "xform_r_hand", fireOffset = {77, 11}}, -- Rifle
          { wepItemID = 656385, fireLocator = "xform_r_hand", fireOffset = {65, 12}}, -- Dual pistols
      },
      gadgets = { 262150, 196614, 786438, 327686}, -- {Defender, Turret, Healer drone, smasher drone}
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_cowgirl_1.png", offset = 42, force = 2, unique = true },
        { textureName = "gibs_carrera_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_carrera_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_carrera_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 1, target = 5, difficulty = 0}, -- Oriental
        {mode = 5, target = 500}, --JETPACK
        {mode = 3, target = 6, difficulty = 1}, -- Future
        {mode = 4, target = 800}, --CDW
        {mode = 2, target = 7, difficulty = 2}, -- Horror
      },
      abilities =
      {
        {abilityID=100, level=3},
        {abilityID=101, level=7},
        {abilityID=102, level=2},
        {abilityID=104, level=6},
        {abilityID=107, level=4},
        {abilityID=110, level=1},
      },
    },
  },
-- Wei (-20% mayhem rate, +20% damage to robots)
  {
    __id=26, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_WEI", -- Barracks name
        desc="CHAR_DESC_WEI", -- Barracks description
        priceTier = "char_high",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "wei", -- chr_<modelAffix>
      textureAffix = "wei", -- used for finding textures
      speechAffix = "WEI", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 590337, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 590337, fireLocator = "xform_l_hand", fireOffset = {48, 9}}, -- Rocket Launcher
          { wepItemID = 721921, fireLocator = "xform_r_hand", fireOffset = {48, 4}}, -- Lightning gun
      },
      gadgets = { 983046, 917510, 524294, 196614, 131078, }, -- {Suit heal, Suit melee,  Suit damage, turret, melee}
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 1.8,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_wei_1.png", offset = 42, force = 2, unique = true },
        { textureName = "gibs_carrera_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_carrera_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_carrera_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 5, target = 400}, --JETPACK
        {mode = 3, target = 5, difficulty = 0}, -- Future
        {mode = 2, target = 5, difficulty = 1}, -- Horror
        {mode = 1, target = 5, difficulty = 1}, -- Oriental
        {mode = 5, target = 600}, --JETPACK
      },
      abilities =
      {
        {abilityID=100, level=7},
        {abilityID=101, level=6},
        {abilityID=102, level=9},
        {abilityID=105, level=6},
        {abilityID=108, level=3},
        {abilityID=103, level=-6},
      },
    },
  },
-- Razor 
  {
    __id=25, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_RAZOR", -- Barracks name
        desc="CHAR_DESC_RAZOR", -- Barracks description
        priceTier = "char_high",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "rogue", -- chr_<modelAffix>
      textureAffix = "rogue", -- used for finding textures
      speechAffix = "ROGUE", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 721409, -- THe weapon they start the game with, (They must own it)
      weapons = { 
          { wepItemID = 721409, fireLocator = "xform_r_hand", fireOffset = {60, 8}}, -- Sticky bomb
          { wepItemID = 721665, fireLocator = "xform_r_hand", fireOffset = {53, 8}}, -- Flamethrower
      },
      gadgets = { 524294, 196614, 851974, 6, }, -- {Suit damage, Turret,  Freeze,  Air strike,}
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      mayhemOnDamage = { rate = 1 }, -- Mayhem gained is equal to damage taken in % multiplied by the rate. 
      speedWithMayhem = { 350, 450 }, -- <0%, 100%>of mayhem + overrides CHARACTER_SPEED.
      gibSetup =
      {
        { textureName = "gibs_rogue_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_graham_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_graham_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_graham_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 2, target = 5, difficulty = 0}, -- Horror
        {mode = 4, target = 500}, --CDW
        {mode = 3, target = 6, difficulty = 1}, -- Future
        {mode = 5, target = 500}, --JETPACK
        {mode = 1, target = 7, difficulty = 2}, -- Oriental
      },
      abilities =
      {
        {abilityID=100, level=6},
        {abilityID=101, level=4},
        {abilityID=102, level=6},
        {abilityID=114, level=5},
        {abilityID=113, level=4},
      },
    },
  },
-- Bingo bango (+20% damage on Oriental)
  {
    __id=18, -- has to be unique
    tab = 2,
    category=0, -- Not used
    serialisable=true, -- Purchase is saved
    allowInChallenge=1,
    levels={
      {
        name="CHAR_NAME_BINGOBANGO", -- Barracks name
        desc="CHAR_DESC_BINGOBANGO", -- Barracks description
        priceTier = "char_high",
        startUnlocked=true,
      },
    },
    characterData={
      modelAffix = "bingoBango", -- chr_<modelAffix>
      textureAffix = "bingo", -- used for finding textures
      speechAffix = "BINGO", -- LOOKUP in locale file PLAYER_SPEECH
      defaultWeapon = 29, -- THe weapon they start the game with, (They must own it)
      weapons = { 
        { wepItemID = 29, fireLocator = "xform_r_hand", fireOffset = {74, 12}}, -- Dual Uzi
        { wepItemID = 721409, fireLocator = "xform_r_hand", fireOffset = {60, 8}}, -- Sticky bomb
      },
      gadgets = { 851974, 262150, 131078, 6, }, -- {Freeze,  Defender,  Melee, Air strike,}
      params = 
      {
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      gibSetup =
      {
        { textureName = "gibs_bingoBango_1.png", offset = 50, force = 2, unique = true },
        { textureName = "gibs_graham_2.png", offset = 20, repCount = 2, unique = true },
        { textureName = "gibs_graham_3.png", offset = 0, repCount = 2, unique = true },
        { textureName = "gibs_graham_4.png", offset = 10, repCount = 2, unique = true },

        { textureName = "gibs_generic_eye_1.png", repCount = 1 },
        { textureName = "gibs_generic_heart_1.png", repCount = 1 },
      },
      challenges =
      {
        {mode = 2, target = 5, difficulty = 0}, -- Horror
        {mode = 4, target = 500}, --CDW
        {mode = 1, target = 6, difficulty = 1}, -- Oriental
        {mode = 4, target = 800}, --CDW
        {mode = 3, target = 7, difficulty = 2}, -- Future
      },
      abilities =
      {
        {abilityID=100, level=7},
        {abilityID=101, level=3},
        {abilityID=102, level=4},
        {abilityID=103, level=6},
        {abilityID=111, level=2},
        {abilityID=109, level=-4},
      },
    },
  },
-- Damage mech
  {
    __id=524294,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 6,
    levels={
      {
        icon="ui_icon_mayhem.png",
        shortName="GADGET_SN_DAMAGE_MECH_SUIT",
        title="GADGET_DAMAGE_MECH_SUIT",
        gadgetIcon="ui_icon_gadget_suit_mayhem.png",
        itemCol=1,
        startUnlocked=true,
        priceTier="free",
        duration = 15,
      },
      {
        priceTier="item_lev1",
        duration = 16.3,
      },
      {
        priceTier="item_lev2",
        duration = 17.6,
      },
      {
        priceTier="item_lev3",
        duration = 18.9,
      },
      {
        priceTier="item_lev4",
        duration = 20.2,
      },
      {
        priceTier="item_lev5",
        duration = 21.5,
      },
      {
        priceTier="item_lev6",
        duration = 22.8,
      },
      {
        priceTier="item_lev7",
        duration = 24.1,
      },
      {
        priceTier="item_lev8",
        duration = 25.4,
      },
      {
        priceTier="item_lev9",
        duration = 26.7,
      },
    },
    characterData={
      modelAffix = "mechDamage",
      textureAffix = "mechDamage",
      characterType = "CHARACTER_MECH_DAMAGE",
      spinWepDef = "DAMAGE_MECH_SPIN",
      mayhemWepDef = "DAMAGE_MECH_SPIN_GUN",
      params = 
      {
        CHARACTER_RESILIENCE = 1.00,
        CHARACTER_SPEED = 500,
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 2,
        CHARACTER_JUMP_SCALE = 1,
      },
      mechWeapon={ wepMgrDef = "DAMAGE_MECH_GUN", fireLocator = "xform_r_hand", fireOffset = {0, 70}},
    },
  },
-- Defence mech
  {
    __id=917510,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 7,
    levels={
      {
        icon="ui_icon_suit_defence.png",
        title="GADGET_MELEE_MECH_SUIT",
        shortName="GADGET_SN_MELEE_MECH_SUIT",
        gadgetIcon="ui_icon_gadget_suit_defence.png",
        itemCol=1,
        startUnlocked=true,
        priceTier="free",
        duration = 15,
      },
      {
        priceTier="item_lev1",
        duration = 16.3,
      },
      {
        priceTier="item_lev2",
        duration = 17.6,
      },
      {
        priceTier="item_lev3",
        duration = 18.9,
      },
      {
        priceTier="item_lev4",
        duration = 20.2,
      },
      {
        priceTier="item_lev5",
        duration = 21.5,
      },
      {
        priceTier="item_lev6",
        duration = 22.8,
      },
      {
        priceTier="item_lev7",
        duration = 24.1,
      },
      {
        priceTier="item_lev8",
        duration = 25.4,
      },
      {
        priceTier="item_lev9",
        duration = 26.7,
      },
    },
    characterData={
      modelAffix = "mechDefence",
      textureAffix = "mechDefence",
      characterType = "CHARACTER_MECH_DEFENSE",
      spinWepDef = "DEFENCE_MECH_SPIN",
      params = 
      {
        CHARACTER_RESILIENCE = 1.00,
        CHARACTER_SPEED = 350,
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 3.5,
        CHARACTER_JUMP_SCALE = 1.25,
      },
      mechWeapon={
        wepMgrDef = "DEFENCE_MECH_GUN",
        fireLocator = "xform_r_hand",
        fireOffset = {0, 0},
        meshList=
        {
         { meshName = "mesh_chr_saw_r", textureName = "wpn_saw.png" },
         { meshName = "mesh_chr_saw_l", textureName = "wpn_saw.png" },
        },
        progAnim=
        {
          { xformName = "xform_chr_saw_l", rotSpeed = -14 },
          { xformName = "xform_chr_saw_r", rotSpeed = -14 },
        },
      },
    },
  },
-- Heal mech
  {
    __id=983046,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 8,
    levels={
      {
        icon="ui_icon_suit_healer.png",
        title="GADGET_SN_HEAL_MECH_SUIT",
        shortName="GADGET_SN_HEAL_MECH_SUIT",
        gadgetIcon="ui_icon_gadget_suit_healer.png",
        itemCol=1,
        startUnlocked=true,
        priceTier="free",
        duration = 15,
      },
      {
        priceTier="item_lev1",
        duration = 16.3,
      },
      {
        priceTier="item_lev2",
        duration = 17.6,
      },
      {
        priceTier="item_lev3",
        duration = 18.9,
      },
      {
        priceTier="item_lev4",
        duration = 20.2,
      },
      {
        priceTier="item_lev5",
        duration = 21.5,
      },
      {
        priceTier="item_lev6",
        duration = 22.8,
      },
      {
        priceTier="item_lev7",
        duration = 24.1,
      },
      {
        priceTier="item_lev8",
        duration = 25.4,
      },
      {
        priceTier="item_lev9",
        duration = 26.7,
      },
    },
    characterData={
      modelAffix = "mechHeal",
      textureAffix = "mechHeal",
      characterType = "CHARACTER_MECH_HEAL",
      spinWepDef = "HEAL_MECH_SPIN",
      mayhemWepDef = "HEAL_MECH_SPIN_GUN",
      params = 
      {
        CHARACTER_RESILIENCE = 1,
        CHARACTER_SPEED = 450,
        CHARACTER_BOUNDINGBOX_X = 20,
        CHARACTER_BOUNDINGBOX_Y = 90,
        CHARACTER_PICKUP_BOUNDINGBOX_X = 35,
        CHARACTER_PICKUP_BOUNDINGBOX_Y = 112,
        CHARACTER_FORCEFIELD_R = 55,
        CHARACTER_GRAVITY_SCALE = 3,
        CHARACTER_JUMP_SCALE = 1.25,
      },
      mechWeapon={ wepMgrDef = "HEAL_MECH_GUN", fireLocator = "xform_r_hand", fireOffset = {0, 70}},
    },
  },
-- Rifle
  {
    __id=28,
    tab=3,
    category=1,
    serialisable=true,
    levels=
    {
      {
        title="WEAPON_RIFLE",
        icon="ui_icon_wpn_singleRifle.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData=
    {
      wepMgrDef = "RIFLE",
      animID = "RIFLE",
      meshList = 
      {
        { meshName = "mesh_wpn_singleRifle", textureName = "wpn_singleRifle" },
      },
    },
  },
-- Dual Rifles
  {
    __id=524801,
    tab=3,
    category=1,
    serialisable=true,
    levels=
    {
      {
        title="WEAPON_DUALRIFLES",
        icon="ui_icon_wpn_rifle.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData=
    {
      wepMgrDef = "DUALRIFLES",
      animID = "DUALRIFLES",
      meshList = 
      {
        { meshName = "mesh_wpn_dualRifles_r", textureName = "wpn_rifle" },
        { meshName = "mesh_wpn_dualRifles_l", textureName = "wpn_rifle" },
      },
    },
  },
-- Rocket Launcher
  {
    __id=590337,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_ROCKETLAUNCHER",
        icon="ui_icon_wpn_rocketLauncher.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData=
    {
      wepMgrDef = "ROCKETLAUNCHER",
      animID = "ROCKETLAUNCHER",
      meshList = 
      {
       { meshName = "mesh_wpn_rocketLauncher", textureName = "wpn_rocketLauncher" },
      },
    },
  },
-- Railgun
  {
    __id=655873,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_RAILGUN",
        icon="ui_icon_wpn_railgun.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData=
    {
      wepMgrDef = "RAILGUN",
      animID = "RAILGUN",
      meshList = 
      {
        { meshName = "mesh_wpn_railgun", textureName = "wpn_railgun" },
      },
    },
  },
-- Sticky bomb
  {
    __id=721409,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_STICKYBOMB",
        icon="ui_icon_wpn_stickyBomb.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "STICKYBOMB",
      animID = "STICKYBOMB",
      meshList = 
      {
       { meshName = "mesh_wpn_stickyBomb", textureName = "wpn_stickyBomb" },
      },
    },
  },
-- Shotgun
  {
    __id=525057,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_SHOTGUN",
        icon="ui_icon_wpn_shotgun.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "SHOTGUN",
      animID = "SHOTGUN",
      meshList = 
      {
        { meshName = "mesh_wpn_shotgun", textureName = "wpn_shotgun" },
      },
    },
  },
-- Minigun
  {
    __id=590593,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_MINIGUN",
        icon="ui_icon_wpn_minigun.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "MINIGUN",
      animID = "MINIGUN",
      meshList = 
      {
        { meshName = "mesh_wpn_minigun", textureName = "wpn_minigun" },
      },
    },
  },
-- Chainsaw
  {
    __id=656129,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_GEARSOFGORE",
        icon="ui_icon_wpn_gears.png",
        itemCol=0,
        startUnlocked=true,
        priceTier="free",
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "CHAINSAW",
      animID = "CHAINSAW",
      meshList = 
      {
        { meshName = "mesh_wpn_gears_body", textureName = "wpn_gears_body" },
        { meshName = "mesh_wpn_big_gear", textureName = "wpn_big_gear" },
        { meshName = "mesh_wpn_medium_gear", textureName = "wpn_medium_gear" },
        { meshName = "mesh_wpn_gears_bar_1", textureName = "wpn_gears_bar" },
        { meshName = "mesh_wpn_gears_bar_2", textureName = "wpn_gears_bar" },
        { meshName = "mesh_wpn_gears_bar_3", textureName = "wpn_gears_bar" },
        { meshName = "mesh_wpn_small_gear_1", textureName = "wpn_small_gear" },
        { meshName = "mesh_wpn_small_gear_2", textureName = "wpn_small_gear" },
        { meshName = "mesh_wpn_small_gear_3", textureName = "wpn_small_gear" },
      },
      progAnim=
      {
        { xformName = "xform_wpn_big_gear", rotSpeed = 6 },
        { xformName = "xform_wpn_medium_gear", rotSpeed = -9 },
        { xformName = "xform_wpn_small_gear_1", rotSpeed = 24 },
        { xformName = "xform_wpn_small_gear_2", rotSpeed = 24 },
        { xformName = "xform_wpn_small_gear_3", rotSpeed = 24 },
      },
    },
  },
-- Flamethrower
  {
    __id=721665,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_HEATRAY",
        icon="ui_icon_wpn_flamethrower.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "FLAMETHROWER",
      animID = "FLAMETHROWER",
      meshList = 
      {
        { meshName = "mesh_wpn_flamethrower", textureName = "wpn_flamethrower" },
      },
    },
  },
-- Uzi
  {
    __id=525313,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_UZI",
        icon="ui_icon_wpn_uzi.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },

    characterData =
    {
      wepMgrDef = "UZI",
      animID = "UZI",
      meshList = {
        { meshName = "mesh_wpn_uzi", textureName = "wpn_uzi" },
      },
    },
  },
-- Dual Uzi
  {
    __id=29,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_DUALUZI",
        icon="ui_icon_wpn_dualUzi.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },

    characterData =
    {
      wepMgrDef = "DUALUZI",
      animID = "DUALUZI",
      meshList = {
        { meshName = "mesh_wpn_dualUzi_l", textureName = "wpn_dualUzi" },
        { meshName = "mesh_wpn_dualUzi_r", textureName = "wpn_dualUzi" },
      },
    },
  },
-- Poison gun
  {
    __id=590849,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_POISONGUN",
        icon="ui_icon_wpn_poisonGun.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "POISON",
      animID = "POISON",
      meshList={
        { meshName = "mesh_wpn_poisonGun", textureName = "wpn_poisonGun" },
      },
    },
  },
-- Pistol
  {
    __id=27,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_PISTOL",
        icon="ui_icon_wpn_pistol.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "PISTOL",
      animID = "PISTOL",
      meshList={
        { meshName = "mesh_wpn_pistol", textureName = "wpn_pistol" },
      },
    },
  },
-- Dual pistols
  {
    __id=656385,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_DUALPISTOLS",
        icon="ui_icon_wpn_revolver.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "DUALPISTOLS",
      animID = "DUALPISTOLS",
      meshList={
        { meshName = "mesh_wpn_dualRevolver_r", textureName = "wpn_revolver" },
        { meshName = "mesh_wpn_dualRevolver_l", textureName = "wpn_revolver" },
      },
    },
  },
-- Lightning gun
  {
    __id=721921,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_LIGHTNINGGUN",
        icon="ui_icon_wpn_lightningGun.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "LIGHTNINGGUN",
      animID = "LIGHTNINGGUN",
      meshList={
        { meshName = "mesh_wpn_lightningGun", textureName = "wpn_lightningGun" },
      },
    },
  },

-- Plasma Cannon
  {
    __id=8,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_PLASMA_CANNON",
        icon="ui_icon_wpn_plasmaCannon.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData=
    {
      wepMgrDef = "PLASMA_CANNON",
      animID = "PLASMA_CANNON",
      meshList = 
      {
       { meshName = "mesh_wpn_plasmaCannon", textureName = "wpn_plasmaCannon" },
      },
    },
  },

-- Sticky Rifle
  {
    __id=16,
    tab=3,
    category=1,
    serialisable=true,
    levels={
      {
        title="WEAPON_STICKYRIFLE",
        icon="ui_icon_wpn_stickyRifle.png",
        itemCol=0,
        priceTier="free",
        startUnlocked=true,
      },
      {
        priceTier="item_lev1",
      },
      {
        priceTier="item_lev2",
      },
      {
        priceTier="item_lev3",
      },
      {
        priceTier="item_lev4",
      },
      {
        priceTier="item_lev5",
      },
      {
        priceTier="item_lev6",
      },      
      {
        priceTier="item_lev7",
      },
      {
        priceTier="item_lev8",
      },
      {
        priceTier="item_lev9",
      },
    },
    characterData =
    {
      wepMgrDef = "STICKYRIFLE",
      animID = "STICKYRIFLE",
      meshList = 
      {
       { meshName = "mesh_wpn_stickyRifle", textureName = "wpn_stickyRifle" },
      },
    },
  },


-- Turret drone
  {
    __id=196614,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 0,
    levels={
      {
        icon="ui_icon_drone_turret.png",
        title="GADGET_DRONE_TURRET",
        shortName="GADGET_SN_DRONE_TURRET",
        gadgetIcon="ui_icon_gadget_turret.png",
        itemCol=1,
        priceTier="free",
        startUnlocked=true,        
        wepDef = "DRONE_TURRET_1",
        duration = 30,
      },
      {
        priceTier="item_lev1",
        duration = 33,
      },
      {
        priceTier="item_lev2",
        wepDef = "DRONE_TURRET_2",
        duration = 36,
      },
      {
        priceTier="item_lev3",
        duration = 39,
      },
      {
        priceTier="item_lev4",
        wepDef = "DRONE_TURRET_3",
        duration = 42,
      },
      {
        priceTier="item_lev5",
        duration = 45,
      },
      {
        priceTier="item_lev6",
        wepDef = "DRONE_TURRET_4",
        duration = 48,
      },
      {
        priceTier="item_lev7",
        duration = 51,
      },
      {
        priceTier="item_lev8",
        wepDef = "DRONE_TURRET_5",
        duration = 54,
      },
      {
        priceTier="item_lev9",
        duration = 57,
      },
    },
  },
-- Melee Drone
  {
    __id=131078,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 1,
    levels={
      {
        icon="ui_icon_drone_melee.png",
        title="GADGET_DRONE_MELEE",
        shortName="GADGET_SN_DRONE_MELEE",
        gadgetIcon="ui_icon_gadget_melee.png",
        itemCol=1,
        priceTier="free",
        startUnlocked=true,
        wepDef = "DRONE_MELEE_1",
        duration = 30,
      },
      {
        priceTier="item_lev1",
        duration = 33,
      },
      {
        priceTier="item_lev2",
        wepDef = "DRONE_MELEE_2",
        duration = 36,
      },
      {
        priceTier="item_lev3",
        duration = 39,
      },
      {
        priceTier="item_lev4",
        wepDef = "DRONE_MELEE_3",
        duration = 41,
      },
      {
        priceTier="item_lev5",
        duration = 44,
      },
      {
        priceTier="item_lev6",
        wepDef = "DRONE_MELEE_4",
        duration = 47,
      },
      {
        priceTier="item_lev7",
        duration = 50,
      },
      {
        priceTier="item_lev8",
        wepDef = "DRONE_MELEE_5",
        duration = 53,
      },
      {
        priceTier="item_lev9",
        duration = 56,
      },
    },
  },
-- Freeze Drone
  {
    __id=851974,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 2,
    levels={
      {
        icon="ui_icon_drone_freeze.png",
        title="GADGET_DRONE_FREEZE",
        shortName="GADGET_SN_DRONE_FREEZE",
        gadgetIcon="ui_icon_gadget_freeze.png",
        itemCol=1,
        priceTier="free",
        startUnlocked=true,
        wepDef = "DRONE_FREEZE_1",
        duration = 36,
      },
      {
        priceTier="item_lev1",
        duration = 39,
      },
      {
        priceTier="item_lev2",
        wepDef = "DRONE_FREEZE_2",
        duration = 42,
      },
      {
        priceTier="item_lev3",
        duration = 45,
      },
      {
        priceTier="item_lev4",
        wepDef = "DRONE_FREEZE_3",
        duration = 48,
      },
      {
        priceTier="item_lev5",
        duration = 41,
      },
      {
        priceTier="item_lev6",
        wepDef = "DRONE_FREEZE_4",
        duration = 54,
      },
      {
        priceTier="item_lev7",
        duration = 57,
      },
      {
        priceTier="item_lev8",
        wepDef = "DRONE_FREEZE_5",
        duration = 60,
      },
      {
        priceTier="item_lev9",
        duration = 63,
      },
    },
  },
-- Defender drone
  {
    __id=262150,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 3,
    levels={
      {
        icon="ui_icon_drone_defender.png",
        title="GADGET_DRONE_DEFENDER",
        shortName="GADGET_SN_DRONE_DEFENDER",
        gadgetIcon="ui_icon_gadget_defender.png",
        itemCol=1,
        priceTier="free",
        startUnlocked=true,
        duration = 51,
      },
      {
        priceTier="item_lev1",
        duration = 55,
      },
      {
        priceTier="item_lev2",
        duration = 59,
      },
      {
        priceTier="item_lev3",
        duration = 63,
      },
      {
        priceTier="item_lev4",
        duration = 67,
      },
      {
        priceTier="item_lev5",
        duration = 71,
      },
      {
        priceTier="item_lev6",
        duration = 75,
      },
      {
        priceTier="item_lev7",
        duration = 79,
      },
      {
        priceTier="item_lev8",
        duration = 83,
      },
      {
        priceTier="item_lev9",
        duration = 87,
      },
    },
  },
-- Smasher Drone
  {
    __id=327686,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 4,
    levels={
      {
        icon="ui_icon_drone_smasher.png",
        title="GADGET_DRONE_SMASHER",
        shortName="GADGET_SN_DRONE_SMASHER",
        gadgetIcon="ui_icon_gadget_smasher.png",
        itemCol=1,
        priceTier="free",
        startUnlocked=true,
        duration = 10,
      },
      {
        priceTier="item_lev1",
        duration = 11,
      },
      {
        priceTier="item_lev2",
        duration = 12,
      },
      {
        priceTier="item_lev3",
        duration = 13,
      },
      {
        priceTier="item_lev4",
        duration = 14,
      },
      {
        priceTier="item_lev5",
        duration = 15,
      },
      {
        priceTier="item_lev6",
        duration = 16,
      },
      {
        priceTier="item_lev7",
        duration = 17,
      },
      {
        priceTier="item_lev8",
        duration = 18,
      },
      {
        priceTier="item_lev9",
        duration = 19,
      },
    },
  },
-- Healer Drone
  {
    __id=786438,
    tab=1,
    category=6,
    serialisable=true,
    gadgetType = 5,
    levels={
      {
        icon="ui_icon_drone_healer.png",
        shortName="GADGET_SN_DRONE_HEALER",
        title="GADGET_DRONE_HEALER",
        gadgetIcon="ui_icon_gadget_healer.png",
        itemCol=1,
        priceTier="free",
        startUnlocked=true,
        duration = 15,
      },
      {
        priceTier="item_lev1",
        duration = 16.5,
      },
      {
        priceTier="item_lev2",
        duration = 18,
      },
      {
        priceTier="item_lev3",
        duration = 19.5,
      },
      {
        priceTier="item_lev4",
        duration = 21,
      },
      {
        priceTier="item_lev5",
        duration = 22.5,
      },
      {
        priceTier="item_lev6",
        duration = 24,
      },
      {
        priceTier="item_lev7",
        duration = 25.5,
      },
      {
        priceTier="item_lev8",
        duration = 27,
      },
      {
        priceTier="item_lev9",
        duration = 28.5,
      },
    },
  },
-- Airstrike
  {
    __id=6,
    tab=0,
    category=6,
    serialisable=true,
    gadgetType = 9,
    itemCol=3,
    levels={
      {
        icon="ui_icon_strike.png",
        shortName="GADGET_SN_AIR_STRIKE",
        title="GADGET_AIR_STRIKE",
        gadgetIcon="ui_icon_gadget_strike.png",
        itemCol=3,
        priceTier="free",
        startUnlocked=true,
      },
    },
  },
-- Consumables
  {
      __id=1,
      category=17,
      levels={
      {
        consCat=5,
        icon="ui_icon_booster_score.png",
        modifier=2,
        title="CONSUMABLE_SCORE",
        iconString="CONSUMABLE_TIMES_TWO",
        infoString="CONSUMABLE_SCORE_DESC",
        startUnlocked=true,
        priceTier="cons_score_1",
      },
    },
  },
  {
    __id=2,
    category=17,
    levels={
      {
        consCat=5,
        icon="ui_icon_booster_score.png",
        modifier=3,
        title="CONSUMABLE_SCORE",
        iconString="CONSUMABLE_TIMES_THREE",
        infoString="CONSUMABLE_SCORE_DESC",
        startUnlocked=true,
        priceTier="cons_score_2",
      },
    },
  },
  {
    __id=3,
    category=17,
    levels={
      {
        consCat=3,
        icon="ui_icon_booster_mayhem.png",
        modifier=2,
        title="CONSUMABLE_MAYHEM",
        iconString="CONSUMABLE_TIMES_TWO",
        infoString="CONSUMABLE_MAYHEM_DESC",
        startUnlocked=true,
        priceTier="cons_mayhem_1",
      },
    },
  },
  {
    __id=4,
    category=17,
    levels={
      {
        consCat=3,
        icon="ui_icon_booster_mayhem.png",
        modifier=3,
        title="CONSUMABLE_MAYHEM",
        iconString="CONSUMABLE_TIMES_THREE",
        infoString="CONSUMABLE_MAYHEM_DESC",
        startUnlocked=true,
        priceTier="cons_mayhem_2",
      },
    },
  },
  {
    __id=5,
    category=17,
    levels={
      {
        consCat=2,
        icon="ui_icon_booster_coins.png",
        modifier=2,
        title="CONSUMABLE_COIN",
        iconString="CONSUMABLE_TIMES_TWO",
        infoString="CONSUMABLE_COINS_DESC",
        startUnlocked=true,
        priceTier="cons_coins_1",
      },
    },
  },
  {
    __id=7,
    category=17,
    levels={
      {
        consCat=2,
        icon="ui_icon_booster_coins.png",
        modifier=3,
        title="CONSUMABLE_COIN",
        iconString="CONSUMABLE_TIMES_THREE",
         infoString="CONSUMABLE_COINS_DESC",
        startUnlocked=true,
        priceTier="cons_coins_2",
      },
    },
  },
  -- {
  --   __id=8,
  --   category=17,
  --   levels={
  --     {
  --       consCat=2,
  --       icon="ui_icon_booster_coins.png",
  --       modifier=4,
  --       title="CONSUMABLE_COIN",
  --       iconString="CONSUMABLE_TIMES_FOUR",
  --       startUnlocked=true,
  --       priceTier="cons_coins_3",
  --     },
  --   },
  -- },
  {
    __id=9,
    category=17,
    levels={
      {
        consCat=4,
        icon="ui_icon_booster_damage.png",
        modifier=1.25,
        title="CONSUMABLE_DAMAGE",
        iconString="CONSUMABLE_TWENTYFIVE_PERCENT",
        infoString="CONSUMABLE_DAMAGE_DESC",
        startUnlocked=true,
        priceTier="cons_damage_1",
      },
    },
  },
  {
    __id=10,
    category=17,
    levels={
      {
        consCat=4,
        icon="ui_icon_booster_damage.png",
        modifier=1.5,
        title="CONSUMABLE_DAMAGE",
        iconString="CONSUMABLE_FIFTY_PERCENT",
        infoString="CONSUMABLE_DAMAGE_DESC",
        startUnlocked=true,
        priceTier="cons_damage_2",
      },
    },
  },
  {
    __id=11,
    category=17,
    levels={
      {
        consCat=4,
        icon="ui_icon_booster_damage.png",
        modifier=2,
        title="CONSUMABLE_DAMAGE",
        iconString="CONSUMABLE_ONEHUNDRED_PERCENT",
        infoString="CONSUMABLE_DAMAGE_DESC",
        startUnlocked=true,
        priceTier="cons_damage_3",
      },
    },
  },
  {
    __id=12,
    category=17,
    levels={
      {
        consCat=1,
        icon="ui_icon_booster_health.png",
        modifier=0.67,
        title="CONSUMABLE_HEALTH",
        iconString="CONSUMABLE_FIFTY_PERCENT",
        infoString="CONSUMABLE_HEALTH_DESC",
        startUnlocked=true,
        priceTier="cons_health_1",
      },
    },
  },
  {
    __id=13,
    category=17,
    levels={
      {
        consCat=1,
        icon="ui_icon_booster_health.png",
        modifier=0.5,
        title="CONSUMABLE_HEALTH",
        iconString="CONSUMABLE_ONEHUNDRED_PERCENT",
        infoString="CONSUMABLE_HEALTH_DESC",
        startUnlocked=true,
        priceTier="cons_health_2",
      },
    },
  },
  {
    __id=14,
    category=17,
    levels={
      {
        consCat=6,
        icon="ui_icon_booster_gems.png",
        modifier=2,
        title="CONSUMABLE_GEMS",
        iconString="CONSUMABLE_TIMES_TWO",
        infoString="CONSUMABLE_GEMS_DESC",
        startUnlocked=true,
        priceTier="cons_gems_1",
      },
    },
  },
  {
    __id=15,
    category=17,
    levels={
      {
        consCat=6,
        icon="ui_icon_booster_gems.png",
        modifier=3,
        title="CONSUMABLE_GEMS",
        iconString="CONSUMABLE_TIMES_THREE",
        infoString="CONSUMABLE_GEMS_DESC",
        startUnlocked=true,
        priceTier="cons_gems_2",
      },
    },
  },
  -- {
  --   __id=16,
  --   category=17,
  --   levels={
  --     {
  --       consCat=6,
  --       icon="ui_icon_booster_gems.png",
  --       modifier=4,
  --       title="CONSUMABLE_GEMS",
  --       iconString="CONSUMABLE_TIMES_FOUR",
  --       startUnlocked=true,
  --       priceTier="cons_gems_3",
  --     },
  --   },
  -- },
  {
    __id=17,
    category=17,
    levels={
      {
        consCat=0,
        title="CONSUMABLE_MAGNET",
        icon="ui_icon_booster_coin_magnet.png",
        infoString="CONSUMABLE_MAGENT_DESC",
        startUnlocked=true,
        priceTier="cons_magnet_1",
      },
    },
  },
------------
-- Resilience
  {
    __id=100,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_resilience.png",
    info_postive = "CHAR_ABILITY_RESILLENCE",

    levels=
    {
      { resillence = 1.00 }, -- 1
      { resillence = 0.88 }, -- 2
      { resillence = 0.76 }, -- 3
      { resillence = 0.64 }, -- 4
      { resillence = 0.52 }, -- 5
      { resillence = 0.40 }, -- 6
      { resillence = 0.28 }, -- 7
      { resillence = 0.24 }, -- 8
      { resillence = 0.20 }, -- 9
      { resillence = 0.16 }, -- 10
    },
  },
-- Speed
  {
    __id=101,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_speed.png",
    info_postive = "CHAR_ABILITY_SPEED",

    levels=
    {
      { speed = 275 }, -- 1
      { speed = 300 }, -- 2
      { speed = 325 }, -- 3
      { speed = 350 }, -- 4
      { speed = 375 }, -- 5
      { speed = 400 }, -- 6
      { speed = 425 }, -- 7
      { speed = 450 }, -- 8
      { speed = 475 }, -- 9
      { speed = 500 }, -- 10
    },
  },
-- Spin
  {
    __id=102,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_spin.png",
    info_postive = "CHAR_ABILITY_SPIN",

    levels=
    {
      { spinID = 1  }, -- 1
      { spinID = 2  }, -- 2
      { spinID = 3  }, -- 3
      { spinID = 4  }, -- 4
      { spinID = 5  }, -- 5
      { spinID = 6  }, -- 6
      { spinID = 7  }, -- 7
      { spinID = 8  }, -- 8
      { spinID = 9  }, -- 9
      { spinID = 10 }, -- 10
    },
  },
-- Mayhem
  {
    __id=103,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_mayhem.png",
    info_postive = "CHAR_ABILITY_MAYHEM",
    info_negative = "CHAR_ABILITY_MAYHEM_NEGATIVE",

    levels=
    {
      [1] = { mayhemMod = 1.10 }, -- 1
      [2] = { mayhemMod = 1.20 }, -- 2
      [3] = { mayhemMod = 1.30 }, -- 3
      [4] = { mayhemMod = 1.40 }, -- 4
      [5] = { mayhemMod = 1.50 }, -- 5
      [6] = { mayhemMod = 1.55 }, -- 6
      [7] = { mayhemMod = 1.60 }, -- 7
      [8] = { mayhemMod = 1.65 }, -- 8
      [9] = { mayhemMod = 1.70 }, -- 9
      [10] = { mayhemMod = 1.75 }, -- 10
      [-1] = { mayhemMod = 0.90 }, -- -1
      [-2] = { mayhemMod = 0.80 }, -- -2
      [-3] = { mayhemMod = 0.70 }, -- -3
      [-4] = { mayhemMod = 0.60 }, -- -4
      [-5] = { mayhemMod = 0.50 }, -- -5
      [-6] = { mayhemMod = 0.45 }, -- -6
      [-7] = { mayhemMod = 0.40 }, -- -7
      [-8] = { mayhemMod = 0.35 }, -- -8
      [-9] = { mayhemMod = 0.30 }, -- -9
      [-10] = { mayhemMod = 0.25 }, -- -10
    },
  },
-- Horror dmg
  {
    __id=104,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_zombies.png",
    info_postive = "CHAR_ABILITY_DMG_HORROR",
    info_negative = "CHAR_ABILITY_DMG_HORROR_NEGATIVE",

    levels=
    {
      [1] = { horror_dmg = 1.10 }, -- 1
      [2] = { horror_dmg = 1.20 }, -- 2
      [3] = { horror_dmg = 1.30 }, -- 3
      [4] = { horror_dmg = 1.40 }, -- 4
      [5] = { horror_dmg = 1.50 }, -- 5
      [6] = { horror_dmg = 1.55 }, -- 6
      [7] = { horror_dmg = 1.60 }, -- 7
      [8] = { horror_dmg = 1.65 }, -- 8
      [9] = { horror_dmg = 1.70 }, -- 9
      [10] = { horror_dmg = 1.75 }, -- 10
      [-1] = { horror_dmg = 0.90 }, -- -1
      [-2] = { horror_dmg = 0.80 }, -- -2
      [-3] = { horror_dmg = 0.70 }, -- -3
      [-4] = { horror_dmg = 0.60 }, -- -4
      [-5] = { horror_dmg = 0.50 }, -- -5
      [-6] = { horror_dmg = 0.45 }, -- -6
      [-7] = { horror_dmg = 0.40 }, -- -7
      [-8] = { horror_dmg = 0.35 }, -- -8
      [-9] = { horror_dmg = 0.30 }, -- -9
      [-10] = { horror_dmg = 0.25 }, -- -10
    },
  },
-- Future dmg
  {
    __id=105,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_robots.png",
    info_postive = "CHAR_ABILITY_DMG_FUTURE",
    info_negative = "CHAR_ABILITY_DMG_FUTURE_NEGATIVE",

    levels=
    {
      [1] = { future_dmg = 1.10 }, -- 1
      [2] = { future_dmg = 1.20 }, -- 2
      [3] = { future_dmg = 1.30 }, -- 3
      [4] = { future_dmg = 1.40 }, -- 4
      [5] = { future_dmg = 1.50 }, -- 5
      [6] = { future_dmg = 1.55 }, -- 6
      [7] = { future_dmg = 1.60 }, -- 7
      [8] = { future_dmg = 1.65 }, -- 8
      [9] = { future_dmg = 1.70 }, -- 9
      [10] = { future_dmg = 1.75 }, -- 10
      [-1] = { future_dmg = 0.90 }, -- -1
      [-2] = { future_dmg = 0.80 }, -- -2
      [-3] = { future_dmg = 0.70 }, -- -3
      [-4] = { future_dmg = 0.60 }, -- -4
      [-5] = { future_dmg = 0.50 }, -- -5
      [-6] = { future_dmg = 0.45 }, -- -6
      [-7] = { future_dmg = 0.40 }, -- -7
      [-8] = { future_dmg = 0.35 }, -- -8
      [-9] = { future_dmg = 0.30 }, -- -9
      [-10] = { future_dmg = 0.25 }, -- -10
    },
  },
-- Oriental dmg
  {
    __id=106,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_ninjas.png",
    info_postive = "CHAR_ABILITY_DMG_ORIENTAL",
    info_negative = "CHAR_ABILITY_DMG_ORIENTAL_NEGATIVE",

    levels=
    {
      [1] = { oriental_dmg = 1.10 }, -- 1
      [2] = { oriental_dmg = 1.20 }, -- 2
      [3] = { oriental_dmg = 1.30 }, -- 3
      [4] = { oriental_dmg = 1.40 }, -- 4
      [5] = { oriental_dmg = 1.50 }, -- 5
      [6] = { oriental_dmg = 1.55 }, -- 6
      [7] = { oriental_dmg = 1.60 }, -- 7
      [8] = { oriental_dmg = 1.65 }, -- 8
      [9] = { oriental_dmg = 1.70 }, -- 9
      [10] = { oriental_dmg = 1.75 }, -- 10
      [-1] = { oriental_dmg = 0.90 }, -- -1
      [-2] = { oriental_dmg = 0.80 }, -- -2
      [-3] = { oriental_dmg = 0.70 }, -- -3
      [-4] = { oriental_dmg = 0.60 }, -- -4
      [-5] = { oriental_dmg = 0.50 }, -- -5
      [-6] = { oriental_dmg = 0.45 }, -- -6
      [-7] = { oriental_dmg = 0.40 }, -- -7
      [-8] = { oriental_dmg = 0.35 }, -- -8
      [-9] = { oriental_dmg = 0.30 }, -- -9
      [-10] = { oriental_dmg = 0.25 }, -- -10
    },
  },
-- Horror def
  {
    __id=107,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_zombie_resistance.png",
    info_postive = "CHAR_ABILITY_DEF_HORROR",
    info_negative = "CHAR_ABILITY_DEF_HORROR_NEGATIVE",

    levels=
    {
      [1] = { horror_def = 0.90 }, -- -1
      [2] = { horror_def = 0.80 }, -- -2
      [3] = { horror_def = 0.70 }, -- -3
      [4] = { horror_def = 0.60 }, -- -4
      [5] = { horror_def = 0.50 }, -- -5
      [6] = { horror_def = 0.45 }, -- -6
      [7] = { horror_def = 0.40 }, -- -7
      [8] = { horror_def = 0.35 }, -- -8
      [9] = { horror_def = 0.30 }, -- -9
      [10] = { horror_def = 0.25 }, -- -10
      [-1] = { horror_def = 1.10 }, -- 1
      [-2] = { horror_def = 1.20 }, -- 2
      [-3] = { horror_def = 1.30 }, -- 3
      [-4] = { horror_def = 1.40 }, -- 4
      [-5] = { horror_def = 1.50 }, -- 5
      [-6] = { horror_def = 1.55 }, -- 6
      [-7] = { horror_def = 1.60 }, -- 7
      [-8] = { horror_def = 1.65 }, -- 8
      [-9] = { horror_def = 1.70 }, -- 9
      [-10] = { horror_def = 1.75 }, -- 10
    },
  },
-- Future def
  {
    __id=108,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_robot_resistance.png",
    info_postive = "CHAR_ABILITY_DEF_FUTURE",
    info_negative = "CHAR_ABILITY_DEF_FUTURE_NEGATIVE",

    levels=
    {
      [1] = { future_def = 0.90 }, -- -1
      [2] = { future_def = 0.80 }, -- -2
      [3] = { future_def = 0.70 }, -- -3
      [4] = { future_def = 0.60 }, -- -4
      [5] = { future_def = 0.50 }, -- -5
      [6] = { future_def = 0.45 }, -- -6
      [7] = { future_def = 0.40 }, -- -7
      [8] = { future_def = 0.35 }, -- -8
      [9] = { future_def = 0.30 }, -- -9
      [10] = { future_def = 0.25 }, -- -10
      [-1] = { future_def = 1.10 }, -- 1
      [-2] = { future_def = 1.20 }, -- 2
      [-3] = { future_def = 1.30 }, -- 3
      [-4] = { future_def = 1.40 }, -- 4
      [-5] = { future_def = 1.50 }, -- 5
      [-6] = { future_def = 1.55 }, -- 6
      [-7] = { future_def = 1.60 }, -- 7
      [-8] = { future_def = 1.65 }, -- 8
      [-9] = { future_def = 1.70 }, -- 9
      [-10] = { future_def = 1.75 }, -- 10
    },
  },
-- Oriental def
  {
    __id=109,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_ninja_resistance.png",
    info_postive = "CHAR_ABILITY_DEF_ORIENTAL",
    info_negative = "CHAR_ABILITY_DEF_ORIENTAL_NEGATIVE",

    levels=
    {
      [1] = { oriental_def = 0.90 }, -- -1
      [2] = { oriental_def = 0.80 }, -- -2
      [3] = { oriental_def = 0.70 }, -- -3
      [4] = { oriental_def = 0.60 }, -- -4
      [5] = { oriental_def = 0.50 }, -- -5
      [6] = { oriental_def = 0.45 }, -- -6
      [7] = { oriental_def = 0.40 }, -- -7
      [8] = { oriental_def = 0.35 }, -- -8
      [9] = { oriental_def = 0.30 }, -- -9
      [10] = { oriental_def = 0.25 }, -- -10
      [-1] = { oriental_def = 1.10 }, -- 1
      [-2] = { oriental_def = 1.20 }, -- 2
      [-3] = { oriental_def = 1.30 }, -- 3
      [-4] = { oriental_def = 1.40 }, -- 4
      [-5] = { oriental_def = 1.50 }, -- 5
      [-6] = { oriental_def = 1.55 }, -- 6
      [-7] = { oriental_def = 1.60 }, -- 7
      [-8] = { oriental_def = 1.65 }, -- 8
      [-9] = { oriental_def = 1.70 }, -- 9
      [-10] = { oriental_def = 1.75 }, -- 10
    },
  },
-- Health time
  {
    __id=110,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_health_time.png",
    info_postive = "CHAR_ABILITY_HEAL_TIME",

    levels=
    {
      { heal_time = 0.025 }, -- 1
      { heal_time = 0.050 }, -- 2
      { heal_time = 0.075 }, -- 3
      { heal_time = 0.100 }, -- 4
      { heal_time = 0.125 }, -- 5
      { heal_time = 0.150 }, -- 6
      { heal_time = 0.175 }, -- 7
      { heal_time = 0.200 }, -- 8
      { heal_time = 0.225 }, -- 9
      { heal_time = 0.250 }, -- 10
    },
  },
-- Health on kills
  {
    __id=111,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_health_kills.png",
    info_postive = "CHAR_ABILITY_HEAL_KILL",

    levels=
    {
      { heal_kill = 0.05 }, -- 1
      { heal_kill = 0.10 }, -- 2
      { heal_kill = 0.15 }, -- 3
      { heal_kill = 0.20 }, -- 4
      { heal_kill = 0.25 }, -- 5
      { heal_kill = 0.30 }, -- 6
      { heal_kill = 0.35 }, -- 7
      { heal_kill = 0.40 }, -- 8
      { heal_kill = 0.45 }, -- 9
      { heal_kill = 0.50 }, -- 10
    },
  },
-- Heal on full mayhem
  {
    __id=112,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_mayhem_health.png",
    info_postive = "CHAR_ABILITY_HEAL_FULL_MAYHEM",

    levels=
    {
      { heal_fullMayhem = 0.05 }, -- 1
      { heal_fullMayhem = 0.10 }, -- 2
      { heal_fullMayhem = 0.15 }, -- 3
      { heal_fullMayhem = 0.20 }, -- 4
      { heal_fullMayhem = 0.25 }, -- 5
      { heal_fullMayhem = 0.30 }, -- 6
      { heal_fullMayhem = 0.35 }, -- 7
      { heal_fullMayhem = 0.40 }, -- 8
      { heal_fullMayhem = 0.45 }, -- 9
      { heal_fullMayhem = 0.50 }, -- 10
    },
  },
-- Speed increase as mayhem increase
  {
    __id=113,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_mayhem_speed.png",
    info_postive = "CHAR_ABILITY_SPEED_MAYHEM",

    levels=
    {
      { speed_mayhem = 1.1 }, -- 1
      { speed_mayhem = 1.2 }, -- 2
      { speed_mayhem = 1.3 }, -- 3
      { speed_mayhem = 1.4 }, -- 4
      { speed_mayhem = 1.5 }, -- 5
      { speed_mayhem = 1.6 }, -- 6
      { speed_mayhem = 1.7 }, -- 7
      { speed_mayhem = 1.8 }, -- 8
      { speed_mayhem = 1.9 }, -- 9
      { speed_mayhem = 2.0 }, -- 10
    },
  },
-- Get mayhem on dmg
  {
    __id=114,
    category=18, -- IC_CHAR_ABIL
    icon = "ui_char_ability_icon_mayhem_damage.png",
    info_postive = "CHAR_ABILITY_MAYHEM_DAMAGE",

    levels=
    {
      { mayhem_dmg = 0.2 }, -- 1
      { mayhem_dmg = 0.4 }, -- 2
      { mayhem_dmg = 0.6 }, -- 3
      { mayhem_dmg = 0.8 }, -- 4
      { mayhem_dmg = 1.0 }, -- 5
      { mayhem_dmg = 1.2 }, -- 6
      { mayhem_dmg = 1.4 }, -- 7
      { mayhem_dmg = 1.6 }, -- 8
      { mayhem_dmg = 1.8 }, -- 9
      { mayhem_dmg = 2.0 }, -- 10
    },
  },
  {
		__id=32,		-- allCharacters IAP
		tab = 5, 		--gems
		category = 20,
    serialisable = true,
    icon = "ui_icon_buy_characters.png",
    itemCol = 4,
    title = "LIMITED TIME OFFER!",
    desc = "UNLOCK ALL PLAYABLE CHARACTERS FOR ONE AMAZING PRICE. AWESOME!",
  },
------------------------------------------------
  {
    __id=19,
    deprecated = true,
    levels={
      {
      	currency=0,
        price=100,
      },
    }
  },
  {
    deprecated=true,
    __id=197122,
    levels={
      {
        currency=0,
        price=500,
      },
      {
        price=1000,
      },
      {
        price=1500,
      },
      {
        price=2000,
      },
      {
        price=2500,
      },
      {
        price=3000,
      },
      {
        price=3500,
      },
      {
        price=4000,
      },
      {
        price=4500,
      },
    },
  },
  {
    deprecated=true,
    __id=66050,
    levels={
      {
        currency=0,
        price=2000,
      },
      {
        price=3000,
      },
      {
        price=4000,
      },
      {
        price=5000,
      },
    },
  },
  {
    deprecated=true,
    __id=131586,
    levels={
      {
        currency=0,
        price=2000,
      },
      {
        price=3000,
      },
      {
        price=4000,
      },
      {
        price=5000,
      },
    },
  },
  {
    deprecated=true,
    __id=524,
    levels={
      {
        currency=0,
        price=3000,
      },
      {
        price=9000,
      },
      {
        price=18000,
      },
    },
  },
  {
    deprecated=true,
    __id=515,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66051,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=516,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66052,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=517,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66053,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=197378,
    levels={
      {
        currency=0,
        price=500,
      },
      {
        price=1000,
      },
      {
        price=1500,
      },
      {
        price=2000,
      },
      {
        price=2500,
      },
      {
        price=3000,
      },
      {
        price=3500,
      },
      {
        price=4000,
      },
      {
        price=4500,
      },
    },
  },
  {
    deprecated=true,
    __id=66306,
    levels={
      {
        currency=0,
        price=2000,
      },
      {
        price=3000,
      },
      {
        price=4000,
      },
      {
        price=5000,
      },
    },
  },
  {
    deprecated=true,
    __id=131842,
    levels={
      {
        currency=0,
        price=2000,
      },
      {
        price=3000,
      },
      {
        price=4000,
      },
      {
        price=5000,
      },
    },
  },
  {
    deprecated=true,
    __id=780,
    levels={
      {
        currency=0,
        price=3000,
      },
      {
        price=9000,
      },
      {
        price=18000,
      },
    },
  },
  {
    deprecated=true,
    __id=771,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66307,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=772,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66308,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=773,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66309,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=197634,
    levels={
      {
        currency=0,
        price=500,
      },
      {
        price=1000,
      },
      {
        price=1500,
      },
      {
        price=2000,
      },
      {
        price=2500,
      },
      {
        price=3000,
      },
      {
        price=3500,
      },
      {
        price=4000,
      },
      {
        price=4500,
      },
    },
  },
  {
    deprecated=true,
    __id=66562,
    levels={
      {
        currency=0,
        price=2000,
      },
      {
        price=3000,
      },
      {
        price=4000,
      },
      {
        price=5000,
      },
    },
  },
  {
    deprecated=true,
    __id=132098,
    levels={
      {
        currency=0,
        price=2000,
      },
      {
        price=3000,
      },
      {
        price=4000,
      },
      {
        price=5000,
      },
    },
  },
  {
    deprecated=true,
    __id=1036,
    levels={
      {
        currency=0,
        price=3000,
      },
      {
        price=9000,
      },
      {
        price=18000,
      },
    },
  },
  {
    deprecated=true,
    __id=1027,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66563,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=1028,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66564,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=1029,
    levels={
      {
        currency=0,
        price=0,
      },
    },
  },
  {
    deprecated=true,
    __id=66565,
    levels={
      {
        currency=0,
        price=1000,
      },
    },
  },
  {
    deprecated=true,
    __id=514,
  	levels={
  		{
        currency=0,
        price=500,
      },
    },
  },
  {
    levels={
      {
        currency=0,
        price=1000,
      },
    },
    deprecated=true,
    __id=16777730,
  },
  {
    levels={
      {
        currency=0,
        price=1500,
      },
    },
    deprecated=true,
    __id=33554944,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50332160,
  },
  {
    levels={
      {
        currency=0,
        price=2500,
      },
    },
    deprecated=true,
    __id=67109376,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=83886592,
  },
  {
    levels={
      {
        currency=0,
        price=3500,
      },
    },
    deprecated=true,
    __id=100663808,
  },
  {
    levels={
      {
        currency=0,
        price=4000,
      },
    },
    deprecated=true,
    __id=117441024,
  },
  {
    levels={
      {
        currency=0,
        price=4500,
      },
    },
    deprecated=true,
    __id=134218240,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    deprecated=true,
    __id=66049,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    deprecated=true,
    __id=131585,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=197121,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=262657,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=328193,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=393729,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=459265,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16843264,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16908800,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16974336,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17039872,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17105408,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17170944,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17236480,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33620480,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33686016,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33751552,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33817088,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33882624,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33948160,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=34013696,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50397696,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50463232,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50528768,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50594304,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50659840,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50725376,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50790912,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67174912,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67240448,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67305984,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67371520,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67437056,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67502592,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67568128,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=83952128,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84017664,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84083200,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84148736,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84214272,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84279808,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84345344,
  },
  {
    levels={
      {
        currency=0,
        price=500,
      },
    },
    deprecated=true,
    __id=770,
  },
  {
    levels={
      {
        currency=0,
        price=1000,
      },
    },
    deprecated=true,
    __id=16777986,
  },
  {
    levels={
      {
        currency=0,
        price=1500,
      },
    },
    deprecated=true,
    __id=33555200,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50332416,
  },
  {
    levels={
      {
        currency=0,
        price=2500,
      },
    },
    deprecated=true,
    __id=67109632,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=83886848,
  },
  {
    levels={
      {
        currency=0,
        price=3500,
      },
    },
    deprecated=true,
    __id=100664064,
  },
  {
    levels={
      {
        currency=0,
        price=4000,
      },
    },
    deprecated=true,
    __id=117441280,
  },
  {
    levels={
      {
        currency=0,
        price=4500,
      },
    },
    deprecated=true,
    __id=134218496,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    deprecated=true,
    __id=66305,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    deprecated=true,
    __id=131841,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=197377,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=262913,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=328449,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=393985,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=459521,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16843520,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16909056,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16974592,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17040128,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17105664,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17171200,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17236736,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33620736,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33686272,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33751808,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33817344,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33882880,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33948416,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=34013952,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50397952,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50463488,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50529024,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50594560,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50660096,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50725632,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50791168,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67175168,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67240704,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67306240,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67371776,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67437312,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67502848,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67568384,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=83952384,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84017920,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84083456,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84148992,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84214528,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84280064,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84345600,
  },
  {
    levels={
      {
        currency=0,
        price=500,
      },
    },
    deprecated=true,
    __id=1026,
  },
  {
    levels={
      {
        currency=0,
        price=1000,
      },
    },
    deprecated=true,
    __id=16778242,
  },
  {
    levels={
      {
        currency=0,
        price=1500,
      },
    },
    deprecated=true,
    __id=33555456,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50332672,
  },
  {
    levels={
      {
        currency=0,
        price=2500,
      },
    },
    deprecated=true,
    __id=67109888,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=83887104,
  },
  {
    levels={
      {
        currency=0,
        price=3500,
      },
    },
    deprecated=true,
    __id=100664320,
  },
  {
    levels={
      {
        currency=0,
        price=4000,
      },
    },
    deprecated=true,
    __id=117441536,
  },
  {
    levels={
      {
        currency=0,
        price=4500,
      },
    },
    deprecated=true,
    __id=134218752,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    deprecated=true,
    __id=66561,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    deprecated=true,
    __id=132097,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=197633,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=263169,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=328705,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=394241,
  },
  {
    levels={
      {
        currency=0,
        price=800,
      },
    },
    deprecated=true,
    __id=459777,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16843776,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16909312,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=16974848,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17040384,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17105920,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17171456,
  },
  {
    levels={
      {
        currency=0,
        price=1200,
      },
    },
    deprecated=true,
    __id=17236992,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33620992,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33686528,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33752064,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33817600,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33883136,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=33948672,
  },
  {
    levels={
      {
        currency=0,
        price=1600,
      },
    },
    deprecated=true,
    __id=34014208,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50398208,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50463744,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50529280,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50594816,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50660352,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50725888,
  },
  {
    levels={
      {
        currency=0,
        price=2000,
      },
    },
    deprecated=true,
    __id=50791424,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67175424,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67240960,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67306496,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67372032,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67437568,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67503104,
  },
  {
    levels={
      {
        currency=0,
        price=2400,
      },
    },
    deprecated=true,
    __id=67568640,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=83952640,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84018176,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84083712,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84149248,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84214784,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84280320,
  },
  {
    levels={
      {
        currency=0,
        price=3000,
      },
    },
    deprecated=true,
    __id=84345856,
  },
  {
    levels={
      {
        currency=0,
        price=250,
      },
    },
    deprecated=true,
    __id=458758,
  },
  {
    levels={
      {
        currency=0,
        price=250,
      },
    },
    deprecated=true,
    __id=589830,
  },
  {
    levels={
      {
        currency=0,
        price=250,
      },
    },
    deprecated=true,
    __id=655366,
  },
  {
    levels={
      {
        currency=0,
        price=250,
      },
    },
    deprecated=true,
    __id=720902,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=196614,
    __id=131335,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=131078,
    __id=65799,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=524294,
    __id=262407,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=262150,
    __id=263,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=851974,
    __id=524551,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=917510,
    __id=327943,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=327686,
    __id=196871,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=786438,
    __id=459015,
    deprecated=true,
  },
  {
    levels={
      {
        currency=0,
        price=0,
      },
    },
    gadgetSuccessor=983046,
    __id=393479,
    deprecated=true,
  },
-- CDW Upgrade
  {
    __id=267,
    deprecated=true,
    tab=1,
    category=11,
    serialisable=true,
    levels={
      {
        price=100,
        startUnlocked=true,
        itemCol=3,
        currency=1,
      },
    },
  },
-- Jetpack Upgrade
  {
    __id=65803,
    tab=1,
    category=11,
    serialisable=true,
    deprecated=true,
    levels={
      {
        price=100,
        startUnlocked=true,
        itemCol=3,
        currency=1,
      },
    },
  },
}
