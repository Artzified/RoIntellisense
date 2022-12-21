-- [[ SERVICES ]]



-- [[ VARIABLES ]]

local Wrapper = script.Parent
local Canvas = Wrapper.Canvas

local SettingsWidget: DockWidgetPluginGui = Wrapper.Parent

-- [[ VARIABLES ]]

local plugin: Plugin
local Framework

-- [[ MODULE ]]

local Controller = {}

function Controller:__env()
	local fenv = getfenv(4)

	plugin = fenv.plugin;
	Framework = fenv.Framework;
end

function Controller:init()

end

return Controller