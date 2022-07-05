local layersutil = require "terrain/layersutil"
local maputil = require "maputil"
local vec2 = require "vec2"
local tu = require "texutil"

function data() 

return {
	id = "ulloc_temperate",
	name = _("Ultima Loca"),
	desc = _("Mixed forest vegetation, high mountains with snow"),
	mapColoring = {
		-- texture = {
			-- levels = { -100.0, 130.0, 260.0, 370.0, 450.0, 500.0 },
			-- fileName = "terrain/level_colors.tga",
		-- },
		ambientColor = maputil.MakeColor{ 205, 219, 255 },
		sunColor = maputil.MakeColor{ 255, 245, 240 },
	},
	groundTextures = {
		waterGround = "water_ground.lua",
		waterShore = "water_shore.lua",
		farmland = "farmland.lua",
		farmlandBorder = "farmland_border.lua"
	},
	skirt = {
		colorTex = tu.makeTextureMipmapClampVertical("terrain/skirt_color.dds", false),
		detailTex = tu.makeTextureMipmapRepeat("terrain/skirt_detail.dds", false),
		waterTex = tu.makeTextureMipmapClamp("terrain/water_skirt.dds", false)
	},
	vehicleSet = "europe",
	order = 1,
	updateFn = function(params)
		local result = { 
			layers = layersutil.Layer.new(),
		}
		local heightmap = "heightmap"
		local mkTemp = layersutil.TempMaker.new()
		-- mkTemp.doDebug = true
		
		-- #################
		-- #### CONFIG
		-- Greener grass
		local layer2_BaseRiverDistanceMin = 10
		local layer2_BaseRiverDistanceMax = 200 -- max: 256
		local layer2_NoiseStrength = 1.4
		--local layer2_AmbientLevelsFrom = { 100, 200 } -- 0 to 255
		--local layer2_AmbientLevelsTo = { 0.6, 1.0}
		local layer2_AmbientLevelsFrom = { 15, 100 } -- 0 to 255
		local layer2_AmbientLevelsTo = { 0.7, 1.0}
		-- Dark grass
		-- Brown grass
		--local layer4_AmbientLevelsFrom = { 180, 248 } -- 0 to 255
		--local layer4_AmbientLevelsTo = { 0.9, 0}
		local layer4_AmbientLevelsFrom = { 200, 250 } -- 0 to 255
		local layer4_AmbientLevelsTo = { 0.9, 0.1}
		-- Stone cliffs
		
		-- Gravel beach
		local layerBeach_maxDistance = 80
		local layerBeach_gravelToStoneRatio = 0.4
		local layerBeach_gain = 0.9
		-- Level 2: cliff
		--local level2_CliffCutoff = { 0.8, 0.9 }
		local level2_CliffCutoff = { 0.7, 1.2 }

		-- #################
		-- #### PREPARE
		local distanceMap = mkTemp:Get()
		result.layers:Distance(heightmap, distanceMap, params.waterLevel)
		
		local ambientMap = mkTemp:Get()
		result.layers:AmbientOcclusion(heightmap, ambientMap, 14)
		
		-- #################
		-- #### Layer 2 - greenest grass
		
		local layer2Map = mkTemp:Get()
		result.layers:Map(distanceMap, layer2Map, { layer2_BaseRiverDistanceMin, layer2_BaseRiverDistanceMax }, { -1, 0}, true)
		
		local temp1Map = mkTemp:Get()
		result.layers:Map(ambientMap, temp1Map, layer2_AmbientLevelsFrom, layer2_AmbientLevelsTo, true)
		
		local noiseMap = mkTemp:Get()
		result.layers:PerlinNoise(noiseMap, {})
		result.layers:Map(noiseMap, noiseMap, {-1, 1}, {0, layer2_NoiseStrength}, true)
		
		local layer3Map = mkTemp:Get()
		result.layers:Mul(temp1Map, noiseMap, layer3Map)
		
		result.layers:Add(layer2Map, layer3Map, layer2Map)
		
		-- #################
		-- #### Layer 3 - dark grass
		do
			local temp2Map = mkTemp:Get()
			--result.layers:Pwlerp(heightmap, temp2Map, { 0, 30, 60, 90, 120 }, { 0, 0, 0.6, 0, 0})
			result.layers:Pwlerp(heightmap, temp2Map, { 643, 857, 1179, 1329 } , { 0.5, 1, 0.5, 0 })
			result.layers:Mul(temp2Map, temp1Map, temp1Map)
			temp2Map = mkTemp:Restore(temp2Map)
		end
		
		result.layers:Mul(temp1Map, noiseMap, layer3Map)
		temp1Map = mkTemp:Restore(temp1Map)
		noiseMap = mkTemp:Restore(noiseMap)
		
		-- #################
		-- #### Layer 4 - brown grass
		local layer4Map = mkTemp:Get()
		result.layers:Map(ambientMap, layer4Map, layer4_AmbientLevelsFrom, layer4_AmbientLevelsTo, false)
		--ambientMap = mkTemp:Restore(ambientMap)
		
		do
			local temp1Map = mkTemp:Get()
			--result.layers:Pwlerp(heightmap, temp1Map, { -10, -5, 5, 50, 150 }, { 0, 0, 1, 0, 0})
			result.layers:Pwlerp(heightmap, temp1Map, { 1071, 1179, 1286, 1393, 1500 }, { 0.5, 0.8, 1, 0.8, 0.5})
			result.layers:Mul(layer4Map, temp1Map, layer4Map)
			temp1Map = mkTemp:Restore(temp1Map)
		end
		
		-- Optional step
		result.layers:Pwlerp(layer4Map, layer4Map, {0, 0.1, 0.3, 1.0}, {0, 0, 1.0, 1.0})
		
		-- #################
		-- #### SLOPES
		local layer5Map, layer5bMap
		do
			local temp1Map = mkTemp:Get()
			--result.layers:Map(distanceMap, temp1Map, { 150, 250 }, { 0, 1}, true)
			result.layers:Map(distanceMap, temp1Map, { 550, 550 }, { 0.7, 1 }, true)

			result.layers:Mul(layer4Map, temp1Map, layer4Map)
			
			result.layers:Grad(heightmap, temp1Map, 3)
			
			layer5Map = mkTemp:Get()
			--result.layers:Map(temp1Map, layer5Map, level2_CliffCutoff, { 0, 1}, true)
			result.layers:Map(temp1Map, layer5Map, level2_CliffCutoff, { 0, 0.7}, true)

			layer5bMap = mkTemp:Get()
			--result.layers:Map(temp1Map, layer5bMap, level2_CliffCutoff, { 0.0, 0.9}, true)
			result.layers:Map(temp1Map, layer5bMap, level2_CliffCutoff, { 0.0, 0.8}, true)
			temp1Map = mkTemp:Restore(temp1Map)
		end
		
		do
			local temp1Map = mkTemp:Get()
			result.layers:Laplace(heightmap, temp1Map)
			
			--result.layers:Map(temp1Map, temp1Map, {0.2, 1.2}, { 0.5, 0.9}, true)
			result.layers:Map(temp1Map, temp1Map, {0.2, 0.8}, { 0.5, 0.7}, true)

			result.layers:Mul(layer5bMap, temp1Map, layer5bMap)
			temp1Map = mkTemp:Restore(temp1Map)
		end
		
		-- #################
		-- #### Beach layer - gravel stone			
		local layer6Map = mkTemp:Get()
		result.layers:Map(distanceMap, layer6Map, { 0, layerBeach_maxDistance }, { 2.3, 0}, true)
		distanceMap = mkTemp:Restore(distanceMap)
		
		do
			local noiseMap = mkTemp:Get()
			result.layers:RidgedNoise(noiseMap, { octaves = 3, lacunarity = 10.5, frequency = 1.0 / 1000.0, gain = layerBeach_gain})
			result.layers:Map(noiseMap, noiseMap, { 0.2, 0.8 }, { -2.3, 0}, true)
			result.layers:Add(layer6Map, noiseMap, layer6Map)
			mkTemp:Restore(noiseMap)
		end
			
		local layer7Map = mkTemp:Get()
		result.layers:Map(layer6Map, layer7Map, { 0.0, 1.0 }, { 0.0, layerBeach_gravelToStoneRatio}, true)
		
		-- #################
		-- #### River bed
		local layer8Map = mkTemp:Get()
		--result.layers:Map(heightmap, layer8Map, { params.waterLevel-15.0, params.waterLevel-1.0 }, { 1.0, 0.0}, true)
		result.layers:Map(heightmap, layer8Map, { 0-15.0, 0-1.0 }, { 1.0, 0.0}, true)

		-- #################
		-- #### Layer 9 - Snow caps
		local layer9Map = mkTemp:Get()
		result.layers:Map(heightmap, layer9Map, { 1693 , 1700 } , { 0.5, 1 }, true)
		ambientMap = mkTemp:Restore(ambientMap)

		do
			local temp1Map = mkTemp:Get()
			result.layers:Pwlerp(heightmap, temp1Map, { 1629, 1771, 1800 }, { 0, 0.8, 1})
			result.layers:Mul(layer9Map, temp1Map, layer9Map)
			temp1Map = mkTemp:Restore(temp1Map)
		end
		-- #################
		-- #### Layer 10 - Scree under Snow
		local layer10Map = mkTemp:Get()
		result.layers:Map(heightmap, layer10Map, { 1571 , 1679 } , { 0.5, 1 }, true)

		do
			local temp1Map = mkTemp:Get()
			result.layers:Pwlerp(heightmap, temp1Map, { 1057, 1271, 1379, 1700 }, { 0, 0.5, 0.8, 1})
			result.layers:Mul(layer10Map, temp1Map, layer10Map)
			temp1Map = mkTemp:Restore(temp1Map)
		end

		-- #################
		-- #### Layer 11 - Alpine Grass
		local layer11Map = mkTemp:Get()
		result.layers:Map(heightmap, layer11Map, { 843 , 1057, 1379, 1529 } , { 0.5, 1, 0.5, 0 }, true)

		do
			local temp1Map = mkTemp:Get()
			result.layers:Pwlerp(heightmap, temp1Map, { 736, 843, 1057, 1271, 1414 }, { 0, 0.8, 1, 0.8, 0.3})
			result.layers:Mul(layer11Map, temp1Map, layer11Map)
			temp1Map = mkTemp:Restore(temp1Map)
		end

		-- #################
		-- #### MIX
		result.mixingLayer = {
			backgroundMaterial = "grass_light_green.lua",
			layers = {
				-- Standard grass
				{
					map = layer2Map,
					dither = true,
					material = "grass_green.lua",
				},
				{
					map = layer4Map,
					dither = true,
					material = "grass_brown.lua",
				},
				{
					map = layer11Map,
					dither = true,
					material = "grass_alpine.lua",
				},
				{
					map = layer3Map,
					dither = true,
					material = "grass_dark_green.lua",
				},
				{
					map = layer10Map,
					dither = true,
					material = "scree.lua",
				},
				{
					map = layer9Map,
					dither = true,
					material = "snow_01.lua",
				},
				-- Slope rocks
				{
					map = layer5Map,
					dither = true,
					material = "rock.lua",
				},
				{
					map = layer5bMap,
					dither = true,
					material = "scree.lua",
				},
				
				-- Beach materials
				{
					map = layer6Map,
					dither = true,
					material = "gravel_01.lua",
				},
				{
					map = layer7Map,
					dither = true,
					material = "scree.lua",
				},
				
				-- River materials
				{
					map = layer8Map,
					dither = true,
					material = "river_bed.lua",
				},
			}
		}
		
		mkTemp:RestoreAll(result.mixingLayer)
		mkTemp:Finish()
		
		--maputil.PrintGraph(result)
		return result
	end
}

end
