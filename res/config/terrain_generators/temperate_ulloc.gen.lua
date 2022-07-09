local mapgenutil = require "terrain/ulloc_mapgenutil"
local temperateassetsgen = require "terrain/ulloc_temperateassetsgen"
local layersutil = require "terrain/layersutil"
local maputil = require "maputil"

function data()

  return {
    climate = "temperate.clima.lua",
    order = 0,
    name = _("Ultima Loca Temperate"),
    params = {
      {
        key = "ulloc_mountain_low",
        name = _("Minimum Height Mountains"),
        values = { "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
        tooltip = "From 20 to 200m in steps of 20m.",
      },
      {
        key = "ulloc_mountain_height",
        name = _("Maximum Height Mountains"),
        values = { "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
        tooltip = "From 300 to 1500m in steps of 150m.",
      },
      {
        key = "ulloc_terrain_ratio",
        name = _("Mountain Density"),
        values = { "Low", "Medium", "High" },
        defaultIndex = 1,
        uiType = "BUTTON",
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
        defaultIndex = 8,
        uiType = "SLIDER",
      },
      {
        key = "ulloc_curves",
        name = _("River curvature"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 2,
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
        key = "ulloc_winding_river",
        name = _("Winding (zig-zag) rivers?"),
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
        key = "ulloc_tree_density",
        name = _("Number of forests"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
        tooltip = "Trees along mountains are only marginally affected by this, except when set to 0.",
      },
      {
        key = "ulloc_treeline",
        name = _("Treeline height"),
        values = { "", "", "", "", "", "", "", "", "", "", "" },
        defaultIndex = 5,
        uiType = "SLIDER",
      },
      {
        key = "ulloc_rocks",
        name = _("Scattered Rocks?"),
        values = { "None", "Along rivers", "Everywhere" },
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

      local result = {
        parallelFactor = 32,
        heightmapLayer = "HM",
        layers = layersutil.Layer.new(),
      }

      -- #################
      -- #### CONFIG
      local min_height_mountains = params.ulloc_mountain_low + 1
      local max_height_mountains = params.ulloc_mountain_height + 2
      local avg_height_mountains = (max_height_mountains + min_height_mountains) / 2

      -- There are 9 levels, determined practically MAX density goes from 0.1 to 0.9; so we can divide by 10
      -- The minimum height does not have much effect on density (just slightly, we can ignore it)
      local mountain_density = (11 - max_height_mountains) / 10
      -- LOW, MED & MAX is 3 levels, so we divide by 3
      mountain_density = mountain_density / 3
      -- then we multiple by level
      mountain_density = (params.ulloc_terrain_ratio + 1) * mountain_density

      local river_amount = params.ulloc_rivers / 10
      local humidity = params.ulloc_tree_density / 10
      local treeline = params.ulloc_treeline / 10

      local noWater = river_amount == 0

      local riverConfig = {
        depthScale = 1.5,
        maxOrder = math.floor(river_amount * 14),
        segmentLength = 2400,
        bounds = params.bounds,
        baseProbability = river_amount * river_amount * 2,
        minDist = river_amount > 0.5 and 2 or 3,
        width = params.ulloc_river_width,
        doRandomWidth = params.ulloc_rand_river == 1,
        curvature = params.ulloc_curves / 10,
        is_winding = params.ulloc_winding_river == 1,
      }

      local rivers = {}
      if not noWater then
        local start = mapgenutil.FindGoodRiverStart(params.bounds)
        mapgenutil.MakeRivers(rivers, riverConfig, 120000, start.pos, start.angle)

        if params.ulloc_river_lakes == 1 then
          local lakeConfig = {
            getLakePropability = function()
              return river_amount + 0.2
            end,
            lakeSize = river_amount * 600,
          }
          mapgenutil.MakeLakesOld(rivers, lakeConfig)
        end

        maputil.Convert(rivers)
        maputil.ValidateRiver(rivers)
      end

      local ridgesConfig = {
        bounds = params.bounds,
        probabilityLow = mountain_density,
        probabilityHigh = 0,
        minHeight = (10 * min_height_mountains) + (10 * min_height_mountains),
        maxHeight = (50 * max_height_mountains) + (100 * max_height_mountains),
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
      result.layers:Noise(noiseMap, 15 * avg_height_mountains)

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

      config = {
        -- GENERIC
        humidity = humidity / 2.5,
        water = river_amount,
        -- LEVEL 3
        hillsLowLimit = 20, -- relative [m]
        hillsLowTransition = 20, -- relative [m]
        -- LEVEL 4
        treeLimit = treeline * ridgesConfig.maxHeight, --160, -- absolute [m] (absolute maximal height)
        ridgeFactor = 1 - (humidity / 10), -- lower means softer ridges detection, more trees (0.8)
        valleyFactor = 1 - (humidity / 10), -- lower means softer valleys detection, more trees (0.8)
        do_rocks = params.ulloc_rocks,
      }

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
