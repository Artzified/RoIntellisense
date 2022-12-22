-- [[ SERVICES ]]

local ScriptEditorService = game:GetService("ScriptEditorService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")

-- [[ WIDGET VARIABLES ]]

local Wrapper = script.Parent

local Topbar = Wrapper.Topbar
local Canvas = Wrapper.Canvas

local CEditorWidget: DockWidgetPluginGui = Wrapper.Parent

-- [[ VARIABLES ]]

local RoIntellisense

local plugin: Plugin
local Framework

-- [[ FUNCTIONS ]]

local function onUpdate()
	Framework.clearWithWhitelist(Canvas, {'Frame'})
	
	Framework.commands:Load()
	for _, command in Framework.commands:GetCommands() do
		local clone = RoIntellisense.UIComponents.EditorField:Clone()
		local id = HttpService:GenerateGUID(false)
		
		clone.Name = command.identifier .. ' [cmd]'
		clone.Identifier.Text = command.identifier
		
		clone.MouseEnter:Connect(function()
			clone.Actions.Visible = true
		end)
		
		clone.MouseLeave:Connect(function()
			clone.Actions.Visible = false
		end)
		
		clone.Actions.Delete.MouseButton1Click:Connect(function()
			Framework.commands:RemoveCommandModule(command.identifier)
			onUpdate()
		end)

		clone.Actions.Edit.MouseButton1Click:Connect(function()
			local tagged = Framework.collection:GetFirstTagged(id)

			if tagged then -- submit
				Framework.commands:AddCommandModule(tagged)
				tagged:Destroy()

				onUpdate()
			else -- edit
				local cmd = Framework.commands:GetCommandModule(command.identifier)
				cmd.Parent = ServerStorage

				Selection:Set{cmd}
				ScriptEditorService:OpenScriptDocumentAsync(cmd)

				Framework.collection:Tag(cmd, id)
				clone.Actions.Edit.Image = 'rbxassetid://11593381530'
			end
		end)
		
		clone.LayoutOrder = command.priority
		clone.Parent = Canvas
	end
end

-- [[ MODULE ]]

local Controller = {}

function Controller:__env(plugin_ref, framework_ref)	
	plugin = plugin_ref
	Framework = framework_ref
	
	RoIntellisense = Framework.RoIntellisense
end

function Controller:init()
	onUpdate()
	CEditorWidget:GetPropertyChangedSignal('Enabled'):Connect(onUpdate)
	
	Topbar.CreateNewCommand.MouseButton1Click:Connect(function()
		local clone = script.temp:Clone()
		clone.Parent = RoIntellisense.Commands
		
		onUpdate()
	end)
end

return Controller