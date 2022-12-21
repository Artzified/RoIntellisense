-- [[ TYPES ]]

export type types = 'string' | 'bool' | 'number' | 'int'

export type settingBody = {
	key: string;
	default: string;
	valueType: string;
	restrictions: (() -> boolean)?
}

-- [[ SERVICES ]]

-- [[ VARIABLES ]]

local plugin: Plugin
local Framework

local settingsBody = {}
local settingsData = {}

-- [[ FUNCTIONS ]]

local function title(x)
	return x:sub(1, 1):upper() .. x:sub(2, #x)
end

-- [[ MODULE ]]

local Manager = {}

function Manager:__env(plugin_ref, framework_ref)	
	plugin = plugin_ref
	Framework = framework_ref
end

-- [[ SETTERS ]]

function Manager:Reset()
	settingsBody = {}
	settingsData = {}
end

function Manager:AddSetting(body: settingBody)
	table.insert(settingsBody, body)
end

-- [[ GETTERS ]]

function Manager:build()
	for _, body: settingBody in settingsBody do
		local value = Framework:GetSetting(body.key, body.default)
		
		local class: types = title(body.valueType) .. 'Value'
		
		local holder = script:FindFirstChild(body.key) or Instance.new(class)
		holder.Value = value
		holder.Parent = script
	end
	
	return settingsData
end

return Manager
