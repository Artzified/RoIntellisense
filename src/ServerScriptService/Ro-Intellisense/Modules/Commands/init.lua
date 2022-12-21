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
	
	print(data)
	do
		data = decode(data)
		
		print(data)
		
		local loaderVersion = tostring(Framework:GetSetting('cmdLoaderVersion', LOADER_VERSION))
		local loader = require(script['LoaderV' .. loaderVersion])
		
		loader:load(data, RoIntellisense.Commands)
	end
		
	for _, cmd in RoIntellisense.Commands:GetChildren() do
		local command = require(cmd)
		
		commands[command.identifier] = command
	end
	
	Manager:Save()
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
end

-- [[ GETTERS ]]

function Manager:GetCommands()
	return commands
end

function Manager:GetCommand(id: string)
	return commands[id]
end

function Manager:GetCommandModule(id: string)
	for _, cmd in RoIntellisense.Commands:GetChildren() do
		if cmd.Name == id then
			return cmd
		end
	end
end

return Manager
