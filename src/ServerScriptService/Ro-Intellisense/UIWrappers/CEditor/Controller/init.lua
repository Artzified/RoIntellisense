-- [[ SERVICES ]]



-- [[ WIDGET VARIABLES ]]

local Wrapper = script.Parent

local Topbar = Wrapper.Topbar
local Canvas = Wrapper.Canvas

local CEditorWidget: DockWidgetPluginGui = Wrapper.Parent

-- [[ VARIABLES ]]

local RoIntellisense

local plugin: Plugin
local Framework -- @module Framework

-- [[ FUNCTIONS ]]

local function onUpdate()
	Framework.clearWithWhitelist(Canvas, {'Frame'})
	
	Framework.commands:Load()
	for _, command in Framework.commands:GetCommands() do
		local clone = RoIntellisense.UIComponents.EditorField:Clone()
		
		clone.Name = command.identifier .. ' [COMMAND]'
		clone.Identifier.Text = command.identifier
		
		clone.MouseEnter:Connect(function()
			clone.Actions.Visible = true
		end)
		
		clone.MouseLeave:Connect(function()
			clone.Actions.Visible = false
		end)
		
		clone.Actions.Delete.MouseButton1Click:Connect(function()
			local cmd = Framework.commands:GetCommandModule(command.identifier)
			
			if cmd then
				cmd:Destroy()
			end
			
			clone:Destroy()
			
			Framework.commands:Save()
			onUpdate()
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