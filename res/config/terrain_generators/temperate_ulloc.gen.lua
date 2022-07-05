local mapgenutil = require "terrain/ulloc_mapgenutil"
local temperateassetsgen = require "terrain/ulloc_temperateassetsgen"
local layersutil = require "terrain/layersutil"
local maputil = require "maputil"
local climate = require "ultima_loca/climate_snow"

local RIVER_WIDTH = { 8, 6, 4, 2, 0, 0.8, 0.7, 0.6, 0.4, 0.2, 0.1 }

function data()

  return {
    climate = "temperate.clima.lua",
    order = 0,
    name = _("Ultima Loca Temperate"),
    params = {
      {
        key = "ulloc_terrain_ratio",
        name = _("Mountain Density"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
      },
      {
        key = "ulloc_mountain_height",
        name = _("Mountains Height"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
      },
      {
        key = "ulloc_rivers",
        name = _("Amount of rivers"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
      },
      {
        key = "ulloc_river_width",
        name = _("River width"),
        values = { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
      },
      {
        key = "ulloc_rand_river",
        name = _("Random river widths?"),
        values = { "No", "Yes" },
        defaultIndex = 0,
        uiType = "BUTTON",
      },
      {
        key = "ulloc_river_lakes",
        name = _("Lakes in rivers?"),
        values = { "No", "Yes" },
        defaultIndex = 1,
        uiType = "BUTTON",
      },
      {
        key = "ulloc_lakes",
        name = _("Scattered Lakes"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
        tooltip = "Lakes that are not connected to a river.",
      },
      {
        key = "ulloc_tree_density",
        name = _("Number of forests"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
        tooltip = "Trees along mountains are only marginally affected by this, except when set to 0.",
      },
      {
        key = "ulloc_treeline",
        name = _("Treeline"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
      },
      --{
      --  key = "ulloc_snowtops",
      --  name = _("Snowtops"),
      --  values = { "None", "High", "Medium", "Low" },
      --  defaultIndex = 1,
      --  uiType = "BUTTON",
      --},
      {
        key = "ulloc_rocks",
        name = _("Scattered Rocks?"),
        values = { "No", "Yes" },
        defaultIndex = 1,
        uiType = "BUTTON",
        tooltip = "Rocks will still be placed on riverbanks.",
      },
      --{
      --  key = "ulloc_coast",
      --  name = _("Sea or Ocean Coastline?"),
      --  values = { "No", "Yes" },
      --  defaultIndex = 0,
      --  uiType = "BUTTON",
      --},
    },
    updateFn = function(params)
      math.randomseed(math.random(1, 100000000))

      --if params.ulloc_snowtops > 0 then
      --  addModifier("loadClimate", climate.snowTops)
      --end

      local result = {
        parallelFactor = 32,
        heightmapLayer = "HM",
        layers = layersutil.Layer.new(),
      }

      -- #################
      -- #### CONFIG
      local heightness = params.ulloc_mountain_height
      local hillyness = params.ulloc_terrain_ratio / 10
      if heightness > 5 then
        hillyness = hillyness / 2
      end
      local water = params.ulloc_rivers / 10
      local humidity = params.ulloc_tree_density / 10
      local treeline = params.ulloc_treeline / 10

      local noWater = water == 0

      local riverConfig = {
        depthScale = 1.5,
        maxOrder = math.round(water * 16), --2,
        segmentLength = 2400,
        bounds = params.bounds,
        baseProbability = water * water * 2,
        minDist = water > 0.5 and 2 or 3,
        width = params.ulloc_river_width,
        doRandomWidth = params.ulloc_rand_river == 1,
      }

      local rivers = {}
      if not noWater then
        local start = mapgenutil.FindGoodRiverStart(params.bounds)
        mapgenutil.MakeRivers(rivers, riverConfig, 120000, start.pos, start.angle)

        if params.ulloc_river_lakes == 1 then
          local lakeProb1 = water > 0.2 and 0.2 or 0 -- math.map(water, 0, 1, 0.0, 0.1)
          local lakeProb2 = water > 0.2 and 0.4 or 0.9 -- math.map(water, 0, 1, 0.1, 0.1)
          local lakeConfig = {
            getLakePropability = function()
              return water + 0.2
            end,
            lakeSize = water * 600,
          }
          mapgenutil.MakeLakesOld(rivers, lakeConfig)
        end

        -- local curvesConfig = {
        -- getStrength = function(position)
        -- return 0.7
        -- end,
        -- getWidthMultiplier = function(position)
        -- return 1
        -- end
        -- }
        -- mapgenutil.MakeCurvesOld(rivers, curvesConfig)

        maputil.Convert(rivers)
        maputil.ValidateRiver(rivers)
        -- maputil.PrintRiver(rivers)
      end

      -- if params.ulloc_lakes > 0 then

      -- end

      local ridgesConfig = {
        bounds = params.bounds,
        probabilityLow = 0.1 + 0.5 * hillyness,
        probabilityHigh = 0.3 + 0.3 * hillyness,
        minHeight = 0 + 10 * heightness,
        maxHeight = 75 + 100 * heightness,
      }

      local valleys = {}
      local ridges = mapgenutil.MakeRidges(ridgesConfig)

      -- #################
      -- #### PREPARE
      local mkTemp = layersutil.TempMaker.new()

      -- #################
      -- #### BACKGROUND AND RIVER
      result.layers:Constant(result.heightmapLayer, .01)

      do
        -- river
        result.layers:PushColor("#0022DD")
        result.layers:River(result.heightmapLayer, rivers)
        result.layers:PopColor()
      end

      local noiseMap = mkTemp:Get()
      result.layers:Noise(noiseMap, 150 * hillyness)

      local distanceMap = mkTemp:Get()
      result.layers:Distance(result.heightmapLayer, distanceMap)

      -- #################
      -- #### RIDGES
      local ridgesMap
      do
        -- ridges
        result.layers:PushColor("#22AADD")
        local t1 = mkTemp:Get()
        result.layers:Map(distanceMap, t1, { 15, 2500 }, { 0, 1 }, true)
        result.layers:Mad(t1, noiseMap, result.heightmapLayer)
        noiseMap = mkTemp:Restore(noiseMap)

        local t2 = mkTemp:Get()
        result.layers:Ridge(t2, {
          valleys = valleys.points,
          ridges = ridges,
          noiseStrength = 10
        })

        result.layers:Map(distanceMap, t1, { 50, 1500 }, { 0, 1 }, true)
        ridgesMap = mkTemp:Get()
        result.layers:Mul(t1, t2, ridgesMap)
        t1 = mkTemp:Restore(t1)
        t2 = mkTemp:Restore(t2)

        result.layers:Add(ridgesMap, result.heightmapLayer, result.heightmapLayer)
        result.layers:PopColor()
      end

      -- #################
      -- #### NOISE
      local noiseStrength = 25.7
      local addNoise = true
      if addNoise then
        result.layers:PushColor("#5577DD")
        local t2 = mkTemp:Get()
        result.layers:RidgedNoise(t2, { octaves = 5, frequency = 1 / 444, lacunarity = 2.2, gain = 0.8 })
        result.layers:Map(t2, t2, { 0, 4 }, { 0, noiseStrength * 1.2 }, false)

        local t1 = mkTemp:Get()
        result.layers:Map(distanceMap, t1, { 0, 30 }, { 0, 1 }, true)

        result.layers:Mad(t2, t1, result.heightmapLayer)
        mkTemp:Restore(t1)
        mkTemp:Restore(t2)
        result.layers:PopColor()
      end

      -- #################
      -- #### ASSETS

      local config = {}

      if humidity == 0 then
        config = {
          -- GENERIC
          humidity = -1,
          water = water,
          -- LEVEL 3
          hillsLowLimit = 0, -- relative [m]
          hillsLowTransition = 0, -- relative [m]
          -- LEVEL 4
          treeLimit = 0, --160, -- absolute [m] (absolute maximal height)
          ridgeFactor = 0 , -- lower means softer ridges detection, more trees (0.8)
          valleyFactor = 0, -- lower means softer valleys detection, more trees (0.8)
          do_rocks = params.ulloc_rocks,
        }
      else
        config = {
          -- GENERIC
          humidity = humidity / 2.5,
          water = water,
          -- LEVEL 3
          hillsLowLimit = 20, -- relative [m]
          hillsLowTransition = 20, -- relative [m]
          -- LEVEL 4
          treeLimit = treeline * ridgesConfig.maxHeight, --160, -- absolute [m] (absolute maximal height)
          ridgeFactor = 1 - (humidity / 10), -- lower means softer ridges detection, more trees (0.8)
          valleyFactor = 1 - (humidity / 10), -- lower means softer valleys detection, more trees (0.8)
          do_rocks = params.ulloc_rocks,
        }
      end

      result.layers:PushColor("#007777")
      result.forestMap, result.treesMapping, result.assetsMap, result.assetsMapping = temperateassetsgen.Make(
       result.layers, config, mkTemp, result.heightmapLayer, ridgesMap, distanceMap
      )
      result.layers:PopColor()
      distanceMap = nil

      -- #################
      -- #### FINISH
      ridgesMap = mkTemp:Restore(ridgesMap)
      mkTemp:Restore(result.forestMap)
      mkTemp:Restore(result.assetsMap)
      mkTemp:Finish()
      -- maputil.PrintGraph(result)

      return result

    end
  }

end
