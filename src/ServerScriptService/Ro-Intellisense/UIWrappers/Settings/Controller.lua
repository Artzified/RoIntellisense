-- [[ SERVICES ]]

local ScriptEditorService = game:GetService("ScriptEditorService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")

-- [[ WIDGET VARIABLES ]]

local Wrapper = script.Parent
local Canvas = Wrapper.Canvas

local SettingsWidget: DockWidgetPluginGui = Wrapper.Parent

-- [[ VARIABLES ]]

local RoIntellisense

local plugin: Plugin
local Framework

local inputData = {
	number = function(input: TextBox, value: number)
		input.Text = value
	end;

	string = function(input: TextBox, value: string)
		input.Text = value
	end;

	bool = function(input: Frame, value: boolean)
		local pos = value and UDim2.fromScale(1, 0) or UDim2.fromScale(.4, 0)
		local color = value and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)

		input.Slide:TweenPosition(pos, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, .1, true)
		input.Slide.BackgroundColor3 = color
	end;
}

local inputListeners = {
	number = function(input: TextBox, body, callback)
		local previousInput = input.Text

		input.FocusLost:Connect(function()
			if body.restriction(input.Text) then
				input.Text = previousInput
			end

			local value = tonumber(input.Text)
			Framework.settings:SetSetting(body.key, value)

			inputData['number'](input, value)
			previousInput = input.Text
		end)
	end;

	string = function(input: TextBox, body)
		local previousInput = input.Text

		input.FocusLost:Connect(function()
			if body.restriction(input.Text) then
				input.Text = previousInput
			end

			local value = input.Text
			Framework.settings:SetSetting(body.key, value)

			inputData['string'](input, value)
			previousInput = input.Text
		end)
	end;

	bool = function(input: Frame, body)
		input.Trigger.MouseButton1Click:Connect(function()
			local value = not Framework:GetSetting(body.key, body.default)
			Framework:SetSetting(body.key, value)

			inputData['bool'](input, value)
		end)
	end;
}

-- [[ FUNCTIONS ]]

local function title(x)
	return x:sub(1, 1):upper() .. x:sub(2, #x)
end

local function onUpdate()
	Framework.clearWithWhitelist(Canvas, {'Frame'})

	for _, body in Framework.settings:GetBody() do
		local value = Framework:GetSetting(body.key, body.default)

		local clone = RoIntellisense.UIComponents[title(body.valueType) .. 'SettingField']:Clone()
		clone.Heading.Header.Text = title(body.key)

		clone.Heading.Trigger.MouseButton1Click:Connect(function()
			clone.Heading.Value.Visible = not clone.Heading.Value.Visible
		end)

		clone.Heading.Value.Description.Text = body.description

		clone.Parent = Canvas

		inputData[body.valueType](clone.Heading.Value.Input, value)
		inputListeners[body.valueType](clone.Heading.Value.Input, body)
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
	SettingsWidget:GetPropertyChangedSignal('Enabled'):Connect(onUpdate)
end

return Controller