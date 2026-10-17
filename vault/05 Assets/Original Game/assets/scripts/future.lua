furn = 
{
	b4_1 =
	{
		{"future_b4_city_1.png", scale=2},  
		{"future_b4_city_2.png", scale=2},
		{"future_b4_city_3.png", scale=2},
		{"future_b4_city_4.png", scale=2},
		{"future_b4_city_5.png", scale=2},
		{"future_b4_city_6.png", scale=2},
		{"future_b4_city_7.png", scale=2},    
		{"future_b4_city_8.png", scale=2}, 
		{"future_b4_city_9.png", scale=2},
		{"future_b4_city_10.png", scale=2},
		{"future_b4_city_11.png", scale=2},
	},

	b3_1 =
	{
		{"future_b3_city_1.png", scale=2},
		{"future_b3_city_2.png", scale=2},
		{"future_b3_city_3.png", scale=2},
		{"future_b3_city_4.png", scale=2},
		{"future_b3_city_5.png", scale=2},
		{"future_b3_city_6.png", scale=2},
		{"future_b3_city_7.png", scale=2},
		{"future_b3_city_8.png", scale=2},
		{"future_b3_city_9.png", scale=2},
		{"future_b3_city_10.png", scale=2},
		{"future_b3_city_11.png", scale=2},   
		{"future_b3_city_12.png", scale=2},
		{"future_b3_city_13.png", scale=2},
	},
	
	b1_1 =
	{
		{"future_b1_rail_1.png"},
	
	},

	t_1 =
	{
		{"future_f_tracks.png"},
	},
	
	f1_1 =
	{
		{"future_f1_signs_1.png", scale=2},
		{"future_f1_signs_2.png", scale=2},
		{"future_f1_signs_3.png", scale=2},
		{"future_f1_signs_3.png", scale=2},
	},

	f2_1 =
	{
		{"future_f2_signs_1.png", scale=2, min = 512, max = 1024},
		{"future_f2_signs_2.png", scale=2, min = 512, max = 1024},
		{"future_f2_signs_3.png", scale=2, min = 512, max = 1024},
	},




	b4_2 =
	{
		{"future_2_b4_city_1.png", scale=1.5},  
		{"future_2_b4_city_2.png", scale=1.5},
		{"future_2_b4_city_3.png", scale=1.5},
		{"future_2_b4_city_4.png", scale=1.5},
		{"future_2_b4_city_5.png", scale=1.5},
		{"future_2_b4_city_6.png", scale=1.5},
	},

	b3_2 =
	{
		{"future_2_b3_city_1.png",  scale=1.5, min=10, max=100}, 
		{"future_2_b3_city_2.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_3.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_4.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_5.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_6.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_7.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_9.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_10.png", scale=1.5, min=10, max=100},
		--{"future_2_b3_city_8.png",  scale=1.5}, removed to pack onto a single atlas
	},
	
	b1_2 =
	{
		{"future_2_b1_rail_1.png", scale=1.5, weight = 5},
		{"future_2_b1_rail_2.png", scale=1.5}, 
		{"future_2_b1_rail_3.png", scale=1.5}, 
		{"future_2_b1_rail_4.png", scale=1.5}, 
		{"future_2_b1_rail_5.png", scale=1.5}, 
	},

	t_2 =
	{
		{"future_2_f_tracks.png"},  
	},

	f1_2 =
	{
		{"future_2_f1_signs_1.png", scale=2},  

	},

	f2_2 =
	{
		{"future_2_f2_signs_1.png", scale=3},  
	},
}

-- ============= Future 1 ================
reg =
{
	{
		sky = "SKY_FUTURE",

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
		layers = {furn.b4_1, furn.b3_1, nil, furn.b1_1, furn.t_1, furn.f1_1, furn.f2_1},
	},

	-- ============= Future 2 ================
	{
		sky = "SKY_FUTURE_NEW",
		layerSetup =
		{
			{minY=620},	-- B4xc
			{minY=620, maxY=720}, -- B3
			{minY=768}, -- B2
			{minY=600, maxY=600}, -- B1
			{minY=683}, -- T
			{minY=744}, -- F1
			{minY=768}, -- F2
		},
		layers = {furn.b4_2, furn.b3_2, nil, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		--layers = {furn.b4_2, furn.b3_2, nil, furn.b1_2, furn.t_2, furn.f1_2, nil},

	},
}

--[[furn = 
{ -- CHRISTMAS 1 and 2
	b4_1 =
	{
		{"christmas3_b4_mountains_1.png", scale=2},
		{"christmas3_b4_mountains_2.png", scale=2},
	},

	b3_1 =
	{
		{"christmas3_b3_town_1.png", scale=1.5},
		{"christmas3_b3_town_2.png", scale=1.5},
	},

	b2_1 =
	{
		{"christmas3_b2_1.png", scale=2, min=10, max=30, weight=3}, 
		{"christmas3_b2_2.png", scale=2, min=600*2, max=1024*2, weight=2}, 
		{"christmas3_b2_2.png", scale=1.8, min=600*2, max=1024*2, weight=2}, 
		{"christmas3_b2_3.png", scale=1.5, min=600*2, max=1024*2, weight=1}, 
	},
	
	b1_1 =
	{
		{"christmas3_b1_crops_1.png"},
	},

	t_1 =
	{
		{"christmas3_tracks.png"},
	},

	f1_1 =
	{
		{"christmas3_f1_1.png"},
	},

	f2_1 =
	{
		{"christmas3_f2_1.png", scale=2},
		{"christmas3_f2_2.png", scale=2},
	},

	-- =============== 2nd env ===============

	b4_2 =
	{
		{"future_2_b4_city_1.png", scale=1.5},  
		{"future_2_b4_city_2.png", scale=1.5},
		{"future_2_b4_city_3.png", scale=1.5},
		{"future_2_b4_city_4.png", scale=1.5},
		{"future_2_b4_city_5.png", scale=1.5},
		{"future_2_b4_city_6.png", scale=1.5},
	},

	b3_2 =
	{
		{"future_2_b3_city_1.png",  scale=1.5, min=10, max=100}, 
		{"future_2_b3_city_2.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_3.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_4.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_5.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_6.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_7.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_9.png",  scale=1.5, min=10, max=100},
		{"future_2_b3_city_10.png", scale=1.5, min=10, max=100},
		--{"future_2_b3_city_8.png",  scale=1.5}, removed to pack onto a single atlas
	},
	
	b1_2 =
	{
		{"future_2_b1_rail_1.png", scale=1.5, weight = 5},
		{"future_2_b1_rail_2.png", scale=1.5}, 
		{"future_2_b1_rail_3.png", scale=1.5}, 
		{"future_2_b1_rail_4.png", scale=1.5}, 
		{"future_2_b1_rail_5.png", scale=1.5}, 
	},

	t_2 =
	{
		{"future_2_f_tracks.png"},  
	},

	f1_2 =
	{
		{"future_2_f1_signs_1.png", scale=2},  

	},

	f2_2 =
	{
		{"future_2_f2_signs_1.png", scale=3},  
	},
}

-- =============== NEW ORIENTAL END ===================== 

reg =
{	
	{
		sky = "SKY_XMAS3",
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
		sky = "SKY_FUTURE_NEW",
		layers = {furn.b4_2, furn.b3_2, nil, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		layerSetup =
		{
			{minY=620},	-- B4xc
			{minY=620, maxY=720}, -- B3
			{minY=768}, -- B2
			{minY=600, maxY=600}, -- B1
			{minY=683}, -- T
			{minY=744}, -- F1
			{minY=768}, -- F2
		},
	},
}
]]