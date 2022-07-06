-- namespace = ulloc
local climate = require "ulloc/snowtops"

-- ------------------------------------------------------------------ --

function data()
  return {
    info = {
      name = "Ultima Loca",
      description = "Temperate Terrain Generator with more options.",
      tags = { "Misc", "Script Mod" },
      authors = {
        {
          name = "Pentasis",
          role = 'CREATOR',
        },
      },
      minorVersion = 1,
      severityAdd = "NONE",
      severityRemove = "NONE",
      params = {
        {
          key = "ulloc_snowtops",
          name = "Snow tops on Mountains?",
          uiType = "BUTTON",
          values = { "Yes", "No" },
          defaultIndex = 0,
        },
      },
    },
    options = {},
    runFn = function(settings, modParams)
      local params = modParams[getCurrentModId()]
      if params.ulloc_snowtops == 0 then
        addModifier("loadClimate", climate.addSnowToTemperate)
      end
    end
    -- postRunFn = function (settings, params) end
  }
end
