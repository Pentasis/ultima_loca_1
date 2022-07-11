-- namespace = ulloc
local climate = require "ulloc/snowtops"

-- ------------------------------------------------------------------ --

function data()
  return {
    info = {
      name = "Not So Temperate Generator",
      description = "Temperate Terrain Generator that actually makes nice looking maps.",
      tags = { "Misc", "Script Mod" },
      authors = {
        {
          name = "Pentasis",
          role = 'CREATOR',
        },
      },
      minorVersion = 3,
      severityAdd = "NONE",
      severityRemove = "NONE",
      params = {
        {
          key = "ulloc_snowtops",
          name = "Snow caps on Mountains?",
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
