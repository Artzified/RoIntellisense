--[[ 
	    ____    ____            ____    _   __  ______    ______    __     __     ____   _____    ______    _   __   _____    ______
	   / __ \  / __ \          /  _/   / | / / /_  __/   / ____/   / /    / /    /  _/  / ___/   / ____/   / | / /  / ___/   / ____/
	  / /_/ / / / / / ______   / /    /  |/ /   / /     / __/     / /    / /     / /    \__ \   / __/     /  |/ /   \__ \   / __/   
	 / _, _/ / /_/ / /_____/ _/ /    / /|  /   / /     / /___    / /___ / /___ _/ /    ___/ /  / /___    / /|  /   ___/ /  / /___   
	/_/ |_|  \____/         /___/   /_/ |_/   /_/     /_____/   /_____//_____//___/   /____/  /_____/   /_/ |_/   /____/  /_____/   
	     	                    
	Ro-Intellisense v0.0
	Made by Artzified
	
	Released in 26 June 2022
	
	FEATURES
		- 	Customizable commands (suggested by TheDeadBoneDev, 27 June 2022)
		-	Place exclusive commands
		-	Comment Dividers
		
	BUILT-IN COMMANDS
		-	helloworld
		-	pairs
		-	ipairs
		-	while
	
	This plugin is licensed under the MIT License
	
	Copyright © 2022 Artzified
]]

if not plugin then
	return
end

-- [[ SERVICES ]]

-- [[ VARIABLES ]]

local RoIntellisense = script.Parent

local Modules = RoIntellisense.Modules

local UIWrappers = RoIntellisense.UIWrappers

-- [[ WRAPPERS ]]

local CEditorWrapper = UIWrappers.CEditor
local CTEditorWrapper = UIWrappers.CTEditor
local SettingsWrapper = UIWrappers.Settings

-- [[ PLUGIN ]]
local Framework = require(Modules.Framework).new('Ro-Intellisense')
Framework.enabled = false

-- [[ MODULES ]]

local Commands = require(Modules.Commands)
local Settings = require(Modules.Settings)

Commands:__env(plugin, Framework)
Settings:__env(plugin, Framework)

-- [[ PLUGIN BUTTONS ]]

Framework:CreateToolbarButton('Ro-Intellisense', 'Turn Ro-Intellisense on/off', 11358529382)
Framework:CreateToolbarButton('Settings', 'Plugin configuration', 11358544124)

Framework:CreateToolbarButton('Commands Editor', 'Edit command snippets', 11817732062)
Framework:CreateToolbarButton('Comments Editor', 'Edit comment dividers', 11817718878)

-- [[ PLUGIN WIDGETS ]]

local info = {
	initialDockState = Enum.InitialDockState.Bottom;
	enabled = false;
	override = false;
	floatSize = {
		x = 300;
		y = 150;
	};
	minSize = {
		x = 150;
		y = 150;
	}
}

Framework:CreateDockWidgetGui('CEditor', CEditorWrapper, info)
Framework:CreateDockWidgetGui('CTEditor', CTEditorWrapper, info)
Framework:CreateDockWidgetGui('Settings', SettingsWrapper, info)

-- [[ FUNCTIONS ]]

local function outputDebug(...)
	if Framework:GetSetting('debug', false) then
		Framework:Output(...)
	end
end

local function clearWithWhitelist(instance: Instance, whitelist: {string})	
	for _, v in instance:GetChildren() do		
		for _, class in whitelist do
			if v:IsA(class) then
				v:Destroy()
			end
		end
	end
end

-- [[ INITIALIZE ]]

do
	Settings:AddSetting({
		key = 'debug';
		default = false;
		
		valueType = 'bool';
		restrictions = nil;
	})
	
	Settings:build()
end

Commands:Load()

Framework.settings = Settings
Framework.commands = Commands

Framework.outputDebug = outputDebug
Framework.clearWithWhitelist = clearWithWhitelist
	
Framework.RoIntellisense = RoIntellisense

Framework:ExecuteAllWrappers()

print(Commands:GetCommands())

-- [[ CONNECTIONS ]]

Framework:OnClick('Ro-Intellisense', function()
	if Framework.loadingCommands then return end
	
	local enabled = not Framework.enabled
	local text = enabled and 'Activated' or 'Deactivated'
	
	Framework.enabled = enabled
	Framework:Output(text)
	
	Commands:Load()
	local commands = Commands:GetCommands()
	
	Framework.loadingCommands = true
	
	for identifier, command in commands do
		outputDebug('•	Deregistered %s', identifier)

		Commands:Deregister(identifier)
		
		if not enabled then continue end
		
		outputDebug('•	Registered %s', identifier)
		
		Commands:Register(command)
	end
	
	Framework.loadingCommands = false
end)

Framework:OnClick('Commands Editor', function()
	local enabled = not Framework:GetDockWidgetEnabled('CEditor')
	
	Commands:Load()
	Framework:EnableDockWidget('CEditor', enabled)
end)

Framework:OnClick('Comments Editor', function()
	local enabled = not Framework:GetDockWidgetEnabled('CTEditor')

	Framework:EnableDockWidget('CTEditor', enabled)
end)