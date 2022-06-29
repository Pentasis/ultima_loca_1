local mapgenutil = require "terrain/ulloc_mapgenutil"
local temperateassetsgen = require "terrain/ulloc_temperateassetsgen"
local layersutil = require "terrain/ulloc_layersutil"
local maputil = require "maputil"

function data()

	return {
		climate = "temperate.clima.lua",
		order = 0,
		name = _("Ultima Loca Temperate"),
		params = {
			{
				key = "ulloc_terrain_ratio",
				name = _("Mountain-Flatland Ratio"),
				values = { "100% Flatland", "", "", "", "" , "", "", "", "", "" , "100% Mountains" },
				defaultIndex = 5,
				uiType = "SLIDER",
			},
			{
				key = "ulloc_mountain_height",
				name = _("Mountains Height"),
				values = { "Hills", "", "", "", "" , "", "", "", "", "" , "Alpine" },
				defaultIndex = 5,
				uiType = "SLIDER",
			},
			{
				key = "ulloc_rivers",
				name = _("Amount of rivers"),
				values = { "None", "", "", "", "" , "", "", "", "", "" , "Delta" },
				defaultIndex = 5,
				uiType = "SLIDER",
			},
			{
				key = "ulloc_river_width",
				name = _("River width"),
				values = { "Normal", "", "", "", "" , "", "", "", "", "" , "Wide" },
				defaultIndex = 0,
				uiType = "SLIDER",
			},
			{
				key = "ulloc_lakes",
				name = _("Lakes"),
				values = { "None", "", "", "", "" , "", "", "", "", "" , "A lot" },
				defaultIndex = 5,
				uiType = "SLIDER",
			},
			{
				key = "ulloc_tree_density",
				name = _("Number of trees"),
				values = { "None", "", "", "", "" , "", "", "", "", "" , "Dense forests" },
				defaultIndex = 5,
				uiType = "SLIDER",
			},
			{
				key = "ulloc_treeline",
				name = _("Treeline"),
				values = { "None", "High", "Medium", "Low" },
				defaultIndex = 2,
				uiType = "BUTTON",
			},
			{
				key = "ulloc_snowtops",
				name = _("Snowtops"),
				values = { "None", "High", "Medium", "Low" },
				defaultIndex = 1,
				uiType = "BUTTON",
			},
			{
				key = "ulloc_rocks",
				name = _("Rocks"),
				values = { "No", "Yes" },
				defaultIndex = 1,
				uiType = "BUTTON",
			},
			{
				key = "ulloc_coastline",
				name = _("Coastline"),
				values = { "No", "Yes" },
				defaultIndex = 1,
				uiType = "BUTTON",
			},
		},
		updateFn = function(params)
			--local sameSeed = math.random(1, 100000000)
			math.randomseed(math.random(1, 100000000))

			local result = {
				parallelFactor = 32,
				heightmapLayer = "HM",
				layers = layersutil.Layer.new(),
			}

			local mkTemp = layersutil.TempMaker.new()

			-- ================================================================== --
			-- Mountains
			local MOUNTAIN_HEIGHT_MIN = 128
			local MOUNTAIN_HEIGHT_MAX = 1024
			local MOUNTAIN_HEIGHT_STEP = (MOUNTAIN_HEIGHT_MAX - MOUNTAIN_HEIGHT_MIN) / 10

			local mountain_ratio = params.ulloc_terrain_ratio / 10
			local hilliness = params.ulloc_mountain_height / 10
			local mountain_peak_height = MOUNTAIN_HEIGHT_MIN + (MOUNTAIN_HEIGHT_STEP * params.ulloc_mountain_height)
			local lake_probability = params.ulloc_lakes / 10
			local river_probability = params.ulloc_rivers / 10
			local river_width_factor = math.sqrt(params.ulloc_river_width + 1) * 10
			local humidity = params.ulloc_tree_density / 10
			local treeline = MOUNTAIN_HEIGHT_MAX - (MOUNTAIN_HEIGHT_MIN * params.ulloc_treeline * 1) -- TODO: determine fact in-game
			local snowline = MOUNTAIN_HEIGHT_MAX - (MOUNTAIN_HEIGHT_MIN * params.ulloc_snowtops * 1)

			local do_rocks = params.ulloc_rocks == 1
			local do_coastline = params.ulloc_coastline == 1

			-- ================================================================== --
			-- Rivers
			if params.ulloc_terrain_ratio > 0 then

			end

		end
	}

end
