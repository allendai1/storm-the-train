furn = 
{ -- ORIENTAL 1 and 2
	b4_1 =
	{
		{"oriental_b4_mountains_1.png", scale=2},
		{"oriental_b4_mountains_2.png", scale=2},
	},

	b3_1 =
	{
		{"oriental_b3_ricefields_1.png", scale=2},
		{"oriental_b3_ricefields_2.png", scale=2},
	},

	b2_1 =
	{
		{"oriental_1_b1_rail_2.png", scale=2.5, min=10, max=30}, 
		{"oriental_1_b1_rail_3.png", scale=2.5, min=600*2, max=1024*2, weight=3}, 
		{"oriental_1_b1_rail_4.png", scale=2.5, min=600*2, max=1024*2, weight=3}, 
		{"oriental_1_b1_rail_5.png", scale=2.5, min=120*2, max=512*2, weight=3},
	},
	
	b1_1 =
	{
		{"oriental_b1_crops_1.png"},
	},

	t_1 =
	{
		{"oriental_tracks.png"},
	},

	f1_1 =
	{
		{"oriental_f1_fields_1.png"},
	},

	f2_1 =
	{
		{"oriental_f2_fields_1.png", scale=2},
		{"oriental_f2_fields_2.png", scale=2},
	},

	b4_2 =
	{
		{"oriental_2_b4_city_1.png", scale=2},  
		{"oriental_2_b4_city_2.png", scale=2},
		{"oriental_2_b4_city_3.png", scale=2},
		{"oriental_2_b4_city_4.png", scale=2},
		{"oriental_2_b4_city_5.png", scale=2},
		{"oriental_2_b4_city_6.png", scale=2},
	},

	b3_2 =
	{
		{"oriental_2_b3_lantern_set_1.png", scale=1.5},
		{"oriental_2_b3_lantern_set_1.png", scale=1.75},
		{"oriental_2_b3_lantern_set_1.png", scale=1.25},
	},

	b2_2 =
	{
		{"oriental_2_b2_city_1.png", scale=2},  
		{"oriental_2_b2_city_2.png", scale=2},
		{"oriental_2_b2_city_3.png", scale=2},
		{"oriental_2_b2_city_4.png", scale=2},
		{"oriental_2_b2_city_5.png", scale=2},
		{"oriental_2_b2_city_6.png", scale=2},
		{"oriental_2_b2_city_7.png", scale=2},
		{"oriental_2_b2_city_8.png", scale=2},

	},
	
	b1_2 =
	{ 
		{"oriental_2_b1_rail_1.png", scale=2, weight=6}, 
		{"oriental_2_b1_rail_2.png", scale=2.5}, 
		{"oriental_2_b1_rail_3.png", scale=2.5}, 
		{"oriental_2_b1_rail_4.png", scale=2.5}, 
		{"oriental_2_b1_rail_5.png", scale=2.5}, 
	},

	t_2 =
	{
		{"oriental_2_f_tracks.png"},  
	},

	f1_2 =
	{
		--{"oriental_2_f1_signs_1.png", scale=2}, 
		{"oriental_2_f1_signs_2.png", scale=2},
		{"oriental_2_f1_signs_3.png", scale=2},
	},

	f2_2 =
	{
		{"oriental_2_f2_signs_1.png", scale=2, min = 3500*2, max = 5000*2},  
		{"oriental_2_f2_signs_2.png", scale=2, min = 3500*2, max = 5000*2},
	},
	
}

-- =============== NEW ORIENTAL END =====================
-- Oriental Sky linkage and furniture layout.
reg =
{	
	{
		sky = "SKY_ORIENTAL",
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
		sky = "SKY_ORIENTAL_NEW",
		layers = {furn.b4_2, furn.b3_2, furn.b2_2, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		layerSetup =
		{
			{minY=620},	-- B4
			{minY=325, maxY=400}, -- B3
			{minY=620, maxY=720}, -- B2
			{minY=600, maxY=600}, -- B1
			{minY=683}, -- T
			{minY=768}, -- F1
			{minY=400, maxY=768}, -- F2
		}
	},
}

--[[furn = 
{ -- CHRISTMAS 1 and 2
	b4_1 =
	{
		{"christmas_b4_mountains_1.png", scale=2},
		{"christmas_b4_mountains_2.png", scale=2},
	},

	b3_1 =
	{
		{"christmas_b3_town_1.png", scale=1.5},
		{"christmas_b3_town_2.png", scale=1.5},
	},

	b2_1 =
	{
		{"christmas_b2_1.png", scale=2, min=10, max=30, weight=3}, 
		{"christmas_b2_2.png", scale=2, min=600*2, max=1024*2, weight=2}, 
		{"christmas_b2_2.png", scale=1.8, min=600*2, max=1024*2, weight=2}, 
		{"christmas_b2_3.png", scale=1.5, min=600*2, max=1024*2, weight=1}, 
	},
	
	b1_1 =
	{
		{"christmas_b1_crops_1.png"},
	},

	t_1 =
	{
		{"christmas_tracks.png"},
	},

	f1_1 =
	{
		{"christmas_f1_1.png"},
	},

	f2_1 =
	{
		{"christmas_f2_1.png", scale=2},
		{"christmas_f2_2.png", scale=2},
	},

	-- =============== 2nd env ===============

	b4_2 =
	{
		{"oriental_2_b4_city_1.png", scale=2},  
		{"oriental_2_b4_city_2.png", scale=2},
		{"oriental_2_b4_city_3.png", scale=2},
		{"oriental_2_b4_city_4.png", scale=2},
		{"oriental_2_b4_city_5.png", scale=2},
		{"oriental_2_b4_city_6.png", scale=2},
	},

	b3_2 =
	{
		{"oriental_2_b3_lantern_set_1.png", scale=1.5},
		{"oriental_2_b3_lantern_set_1.png", scale=1.75},
		{"oriental_2_b3_lantern_set_1.png", scale=1.25},
	},

	b2_2 =
	{
		{"oriental_2_b2_city_1.png", scale=2},  
		{"oriental_2_b2_city_2.png", scale=2},
		{"oriental_2_b2_city_3.png", scale=2},
		{"oriental_2_b2_city_4.png", scale=2},
		{"oriental_2_b2_city_5.png", scale=2},
		{"oriental_2_b2_city_6.png", scale=2},
		{"oriental_2_b2_city_7.png", scale=2},
		{"oriental_2_b2_city_8.png", scale=2},

	},
	
	b1_2 =
	{ 
		{"oriental_2_b1_rail_1.png", scale=2, weight=6}, 
		{"oriental_2_b1_rail_2.png", scale=2.5}, 
		{"oriental_2_b1_rail_3.png", scale=2.5}, 
		{"oriental_2_b1_rail_4.png", scale=2.5}, 
		{"oriental_2_b1_rail_5.png", scale=2.5}, 
	},

	t_2 =
	{
		{"oriental_2_f_tracks.png"},  
	},

	f1_2 =
	{
		--{"oriental_2_f1_signs_1.png", scale=2}, 
		{"oriental_2_f1_signs_2.png", scale=2},
		{"oriental_2_f1_signs_3.png", scale=2},
	},

	f2_2 =
	{
		{"oriental_2_f2_signs_1.png", scale=2, min = 3500*2, max = 5000*2},  
		{"oriental_2_f2_signs_2.png", scale=2, min = 3500*2, max = 5000*2},
	},
}

-- =============== NEW ORIENTAL END ===================== 

reg =
{	
	{
		sky = "SKY_XMAS1",
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
		sky = "SKY_ORIENTAL_NEW",
		layers = {furn.b4_2, furn.b3_2, furn.b2_2, furn.b1_2, furn.t_2, furn.f1_2, furn.f2_2},
		layerSetup =
		{
			{minY=620},	-- B4
			{minY=325, maxY=400}, -- B3
			{minY=620, maxY=720}, -- B2
			{minY=600, maxY=600}, -- B1
			{minY=683}, -- T
			{minY=768}, -- F1
			{minY=400, maxY=768}, -- F2
		}
	},
}
]]





