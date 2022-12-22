-- [[ TYPES ]]

export type types = 'string' | 'bool' | 'number'

export type settingBody = {
	key: string;
	description: string;
	valueType: string;
	default: string;
	restrictions: (() -> boolean)?
}

-- [[ SERVICES ]]

-- [[ VARIABLES ]]

local plugin: Plugin
local Framework

local settingsBody = {}
local settingsData = {}

-- [[ FUNCTIONS ]]

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

function Manager:GetBody(): {settingBody}
	return settingsBody
end

function Manager:build(): {any}
	for _, body: settingBody in settingsBody do
		local value = Framework:GetSetting(body.key, body.default)
		
		settingsData[body.key] = value
	end
	
	return settingsData
end

return Manager
