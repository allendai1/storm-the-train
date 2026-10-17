furn = 
{
	b4_1 =
	{
		{"horror_b4_hills_1.png", scale=2},
		{"horror_b4_hills_2.png", scale=2},
	},

	b3_1 =
	{
		{"horror_b3_hills_1.png", scale=2},
		{"horror_b3_hills_2.png", scale=2, weight=2},
	},
	
	b1_1 =
	{
		{"horror_b1_fence_1.png"},
	},

	t_1 =
	{
		{"horror_h_tracks.png"},
	},

	f1_1 =
	{
		{"horror_f1_graves_1.png"},
	},

	f2_1 =
	{
		{"horror_f2_graves_1.png", scale=2},
		{"horror_f2_graves_2.png", scale=2},
	},



	b4_2 =
	{
		{"horror_2_b4_1.png", scale=3},
		{"horror_2_b4_2.png", scale=3},
		{"horror_2_b4_3.png", scale=3},
		{"horror_2_b4_4.png", scale=3},
		{"horror_2_b4_5.png", scale=3},
		{"horror_2_b4_6.png", scale=3},
		{"horror_2_b4_7.png", scale=3},
		{"horror_2_b4_8.png", scale=3, weight=5},

	},

	b3_2 =
	{
		{"horror_2_b3_1.png", scale=2.5, min=400, max=700},
		{"horror_2_b3_2.png", scale=2.5, min=400, max=700},
		{"horror_2_b3_3.png", scale=2.5, min=400, max=700},
	},

	b2_2 =
	{
		{"horror_2_b2_1.png", scale=1.25},
		{"horror_2_b2_2.png", scale=1.25},
		{"horror_2_b2_3.png", scale=1.25},
		{"horror_2_b2_4.png", scale=1.25},
		{"horror_2_b2_4.png", scale=1.25},
	},
	
	b1_2 =
	{
		{"horror_2_b1_1.png", scale=2},
		{"horror_2_b1_2.png", scale=2},
		{"horror_2_b1_3.png", scale=2},
		{"horror_2_b1_4.png", scale=2},
		{"horror_2_b1_5.png", scale=2},
		{"horror_2_b1_6.png", scale=2},
		{"horror_2_b1_7.png", scale=2},
		{"horror_2_b1_8.png", scale=2},
	},

	t_2 =
	{
		{"horror_2_tracks.png"},
	},

	f1_2 =
	{
		{"horror_2_f1_1.png", scale=4.5},
		{"horror_2_f1_2.png", scale=4.5},
		{"horror_2_f1_3.png", scale=4.5},
	},

	f2_2 =
	{
		{"horror_2_f2_1.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_2.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_3.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_5.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_6.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_5.png", scale=4, min=700, max=1500},
		{"horror_2_f2_6.png", scale=4, min=700, max=1500},
	},
}

-- ============= horror 1 ===================
reg =
{
	{
		sky = "SKY_HORROR",
		layers = {furn.b4_1, furn.b3_1, nil, furn.b1_1, furn.t_1, furn.f1_1, furn.f2_1},
		layerSetup =
		{
			{minY=552},	-- B4
			{minY=621}, -- B3
			{minY=768}, -- B2
			{minY=621, maxY=621}, -- B1
			{minY=683}, -- T
			{minY=768}, -- F1
			{minY=768}, -- F2
		},
	},

-- ============= horror 2 ===================
	{
		sky = "SKY_HORROR_NEW",
		layers = {furn.b4_2, furn.b3_2, furn.b2_2, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		--layers = {nil, furn.b3_2, nil, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		layerSetup =
		{
			{minY=600},	-- B4
			{minY=480}, -- B3
			{minY=600}, -- B2
			{minY=620, maxY=620}, -- B1
			{minY=683}, -- T
			{minY=768}, -- F1
			{minY=768}, -- F2

		},
	},
}

--[[furn = 
{ -- CHRISTMAS 1 and 2
	b4_1 =
	{
		{"christmas2_b4_mountains_1.png", scale=2},
		{"christmas2_b4_mountains_2.png", scale=2},
	},

	b3_1 =
	{
		{"christmas2_b3_town_1.png", scale=1.5},
		{"christmas2_b3_town_2.png", scale=1.5},
	},

	b2_1 =
	{
		{"christmas2_b2_1.png", scale=2, min=10, max=30, weight=3}, 
		{"christmas2_b2_2.png", scale=2, min=600*2, max=1024*2, weight=2}, 
		{"christmas2_b2_2.png", scale=1.8, min=600*2, max=1024*2, weight=2}, 
		{"christmas2_b2_3.png", scale=1.5, min=600*2, max=1024*2, weight=1}, 
	},
	
	b1_1 =
	{
		{"christmas2_b1_crops_1.png"},
	},

	t_1 =
	{
		{"christmas2_tracks.png"},
	},

	f1_1 =
	{
		{"christmas2_f1_1.png"},
	},

	f2_1 =
	{
		{"christmas2_f2_1.png", scale=2},
		{"christmas2_f2_2.png", scale=2},
	},

	-- =============== 2nd env ===============

	b4_2 =
	{
		{"horror_2_b4_1.png", scale=3},
		{"horror_2_b4_2.png", scale=3},
		{"horror_2_b4_3.png", scale=3},
		{"horror_2_b4_4.png", scale=3},
		{"horror_2_b4_5.png", scale=3},
		{"horror_2_b4_6.png", scale=3},
		{"horror_2_b4_7.png", scale=3},
		{"horror_2_b4_8.png", scale=3, weight=5},

	},

	b3_2 =
	{
		{"horror_2_b3_1.png", scale=2.5, min=400, max=700},
		{"horror_2_b3_2.png", scale=2.5, min=400, max=700},
		{"horror_2_b3_3.png", scale=2.5, min=400, max=700},
	},

	b2_2 =
	{
		{"horror_2_b2_1.png", scale=1.25},
		{"horror_2_b2_2.png", scale=1.25},
		{"horror_2_b2_3.png", scale=1.25},
		{"horror_2_b2_4.png", scale=1.25},
		{"horror_2_b2_4.png", scale=1.25},
	},
	
	b1_2 =
	{
		{"horror_2_b1_1.png", scale=2},
		{"horror_2_b1_2.png", scale=2},
		{"horror_2_b1_3.png", scale=2},
		{"horror_2_b1_4.png", scale=2},
		{"horror_2_b1_5.png", scale=2},
		{"horror_2_b1_6.png", scale=2},
		{"horror_2_b1_7.png", scale=2},
		{"horror_2_b1_8.png", scale=2},
	},

	t_2 =
	{
		{"horror_2_tracks.png"},
	},

	f1_2 =
	{
		{"horror_2_f1_1.png", scale=4.5},
		{"horror_2_f1_2.png", scale=4.5},
		{"horror_2_f1_3.png", scale=4.5},
	},

	f2_2 =
	{
		{"horror_2_f2_1.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_2.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_3.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_5.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_6.png", scale=3.5, min=700, max=1500},
		{"horror_2_f2_5.png", scale=4, min=700, max=1500},
		{"horror_2_f2_6.png", scale=4, min=700, max=1500},
	},
}

-- =============== NEW ORIENTAL END ===================== 

reg =
{	
	{
		sky = "SKY_XMAS2",
		layers = {furn.b4_1, furn.b3_1, furn.b2_1, furn.b1_1, furn.t_1, furn.f1_1, furn.f2_1},
		layerSetup =
		{
			{minY=552},	-- B4
			{minY=621}, -- B3
			{minY=610}, -- B2
			{minY=621, maxY=621}, -- B1
			{minY=683}, -- T
			{minY=768}, -- F1
			{minY=768}, -- F2
		}
	},
	{
		sky = "SKY_HORROR_NEW",
		layers = {furn.b4_2, furn.b3_2, furn.b2_2, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		--layers = {nil, furn.b3_2, nil, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		layerSetup =
		{
			{minY=600},	-- B4
			{minY=480}, -- B3
			{minY=600}, -- B2
			{minY=620, maxY=620}, -- B1
			{minY=683}, -- T
			{minY=768}, -- F1
			{minY=768}, -- F2

		},
	},
}
]]