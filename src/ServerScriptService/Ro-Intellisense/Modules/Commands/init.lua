-- [[ TYPES ]]

export type command = {
	identifier: string;
	priority: number;
	
	label: string;
	kind: Enum.CompletionItemKind;
	documentation: {
		value: string;								
	}?;
	codeSample: string;
}

-- [[ SERVICES ]]

local ScriptEditorService = game:GetService('ScriptEditorService')
local HttpService = game:GetService('HttpService')

-- [[ VARIABLES ]]

local RoIntellisense = script.Parent.Parent

local plugin: Plugin
local Framework

local commands = {}

-- [[ MODULE CONFIGURATION ]]

local MASTER_KEY = 'CommandsData'
local LOADER_VERSION = 0

-- [[ FUNCTIONS ]]

local function encode(x)
	return HttpService:JSONEncode(x)
end

local function decode(x)
	return HttpService:JSONDecode(x)
end

local function esc(x)
	return (x:gsub('%%', '%%%%')
		:gsub('^%^', '%%^')
		:gsub('%$$', '%%$')
		:gsub('%(', '%%(')
		:gsub('%)', '%%)')
		:gsub('%.', '%%.')
		:gsub('%[', '%%[')
		:gsub('%]', '%%]')
		:gsub('%*', '%%*')
		:gsub('%+', '%%+')
		:gsub('%-', '%%-')
		:gsub('%?', '%%?'))
end

-- [[ MODULE ]]

local Manager = {}

function Manager:__env(plugin_ref, framework_ref)	
	plugin = plugin_ref
	Framework = framework_ref
end

-- [[ LOADERS ]] 

function Manager:Load()
	commands = {}
	
	local data = Framework:GetSetting(MASTER_KEY, '{}')

	do
		data = decode(data)
		
		local loaderVersion = tostring(Framework:GetSetting('cmdLoaderVersion', LOADER_VERSION))
		local loader = require(script['LoaderV' .. loaderVersion])
		
		loader:load(data, RoIntellisense.Commands)
	end
		
	for _, cmd in RoIntellisense.Commands:GetChildren() do
		local command = require(cmd)
		
		commands[command.identifier] = command
	end
end

function Manager:Save()	
	Framework:SetSetting('cmdLoaderVersion', LOADER_VERSION)
	local loader = require(script['LoaderV' .. LOADER_VERSION])
	
	local serialized = loader:save(RoIntellisense.Commands:GetChildren())
	Framework:SetSetting(MASTER_KEY, encode(serialized))
end

-- [[ SETTERS ]]

function Manager:Deregister(id: string): (boolean, string?)
	return pcall(ScriptEditorService.DeregisterAutocompleteCallback, ScriptEditorService, id)
end

function Manager:Register(command: command)
	if not (command.identifier or command.label or command.codeSample) then
		Framework:Output('Unable to register %s due to lack of properties')
		return 1
	end

	ScriptEditorService:RegisterAutocompleteCallback(command.identifier, command.priority or 1, function(req, res)		
		local doc: ScriptDocument = req.textDocument.document
		if doc:IsCommandBar() then return res end

		local position = req.position

		local line = doc:GetLine()
		local label = command.label
		local escaped = esc(label)

		local characters = escaped:split('')
		local start, _end = nil, nil

		local str = ''

		for _, v in characters do
			str ..= v

			local match = line:match('%-%-(' .. escaped .. ')') or line:match('"(' .. escaped .. ')"') or line:match("'(" .. escaped .. ")'")

			if match and match == escaped then
				return res
			end

			local s, e = line:find(str)

			if s and e then
				start, _end = s, e
			end
		end

		if not (start or _end) then return res end

		local items = {
			label = label;
			kind = command.kind;
			tags = {};
			documentation = command.documentation or {};
			codeSample = command.codeSample;
			preselect = true;
			textEdit = {
				newText = command.codeSample;
				replace = {
					start = {
						line = position.line;
						character = start;
					};
					['end'] = {
						line = position.line;
						character = _end + 1;
					};
				}
			}
		}
		table.insert(res.items, items)

		return res
	end)

	return 0
end

function Manager:AddCommandModule(cmd: ModuleScript)
	local command = require(cmd)
	if not (command.identifier or command.label or command.codeSample) then
		Framework:Output('Unable to register due to lack of properties')
		return 1
	end

	local module = RoIntellisense.Commands:FindFirstChild(cmd.Name) or Instance.new('ModuleScript')
	module.Name = command.identifier
	module.Source = cmd.Source

	module.Parent = RoIntellisense.Commands

	Manager:Save()
	Manager:Load()

	cmd:Destroy()

	return 0
end

function Manager:RemoveCommandModule(id: string)
	local cmd = Manager:GetCommandModule(id)

	if not cmd then return end

	cmd:Destroy()
	Manager:Save()

	commands[id] = nil

	return 0
end

-- [[ GETTERS ]]

function Manager:GetCommands()
	return commands
end

function Manager:GetCommand(id: string)
	return commands[id]
end

function Manager:GetCommandModule(id: string)
	return RoIntellisense.Commands:FindFirstChild(id)
end

return Manager
