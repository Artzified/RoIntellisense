-- [[ TYPES ]]

export type dockWidgetInfo = {
	initialDockState: Enum.InitialDockState;
	enabled: boolean;
	override: boolean;
	floatSize: {x: number, y: number};
	minSize: {x: number, y: number};
}

-- [[ SERVICES ]]

local CoreGui = game:GetService('CoreGui')

-- [[ VARIABLES ]]

local plugin: Plugin

-- [[ FUNCTIONS ]]

local function assert(exp, str, ...)
	if not exp then
		error('[Framework] ' .. str:format(...) .. '\n', 0)
	end

	return not exp
end

-- [[ MODULE ]]

local module = {}

function module.new(toolbarName: string)
	plugin = getfenv(2).plugin
	
	local toolbar: PluginToolbar = plugin:CreateToolbar(toolbarName)
	
	return setmetatable({
		__toolbar = toolbar;
		buttons = {};
		widgets = {};
		coregui = {};
	}, {__index = module})
end

-- [[ CONSTRUCTORS ]]

function module:CreateToolbarButton(text: string, tooltip: string, iconId: number)
	local button: PluginToolbarButton = self.__toolbar:CreateButton(text, tooltip, 'rbxassetid://' .. iconId)
	button.ClickableWhenViewportHidden = true
	
	self.buttons[text] = button
end

function module:CreateDockWidgetGui(id: string, wrapper: Frame, info: dockWidgetInfo)	
	info = {
		info.initialDockState;
		info.enabled;
		info.override;
		info.floatSize.x;
		info.floatSize.y;
		info.minSize.x;
		info.minSize.y
	}

	local widgetInfo = DockWidgetPluginGuiInfo.new(unpack(info))
	local widget = plugin:CreateDockWidgetPluginGui(id, widgetInfo)

	widget.Name = id
	widget.Title = id

	wrapper.Parent = widget

	self.widgets[id] = widget
end

function module:CreateCoreGui(id: string, wrapper: ScreenGui)
	local duplicate = CoreGui:FindFirstChild(wrapper.Name)
	
	if duplicate then
		duplicate:Destroy()
	end
	
	wrapper.Parent = CoreGui
	self.coregui[id] = wrapper
end

function module:Output(str: string, ...)
	warn('[' .. plugin.Name .. '] ' .. str:format(...))
end

-- [[ SETTERS ]]

function module:SetToolbarButtonIcon(text: string, iconId: number)
	local button: PluginToolbarButton = self.buttons[text]
	button.Icon = 'rbxassetid://' .. iconId
end

function module:EnableDockWidget(id: string, enabled: boolean)
	local widget = self:GetDockWidgetGui(id)
	
	widget.Enabled = enabled
end

function module:ExecuteWrapper(id: string): {any}
	local wrapper = self:GetDockWidgetWrapper(id)
	local controller = wrapper:FindFirstChild('Controller')
	
	assert(controller, 'Could not find wrapper\'s script controller in %s', id)
	
	controller = require(controller)
	controller:__env(plugin, self)
	controller:init()
end

function module:ExecuteAllWrappers()
	for id in self.widgets do
		self:ExecuteWrapper(id)
	end
end

function module:SetSetting(key: string, value: any)
	plugin:SetSetting(key, value)
end

-- [[ GETTERS ]]

function module:GetToolbarButton(text: string): PluginToolbarButton
	local button = self.buttons[text]
	assert(button, '%s button is not defined', text)
	
	return button
end

function module:GetDockWidgetGui(id: string): DockWidgetPluginGui
	local widget = self.widgets[id]
	assert(widget, '%s widget is not defined', id)

	return widget
end

function module:GetDockWidgetEnabled(id: string)
	local widget = self:GetDockWidgetGui(id)
	
	return widget.Enabled
end

function module:GetDockWidgetWrapper(id: string): Frame
	local widget = self:GetDockWidgetGui(id)

	return widget:FindFirstChildWhichIsA('Frame')
end

function module:GetCoreGui(id: string): ScreenGui
	local wrapper = self.coregui[id]
	assert(wrapper, '%s wrapper is not defined', id)
	
	return wrapper
end

function module:GetSetting(key: string, default: any)
	local value = plugin:GetSetting(key)
	
	if not value then
		plugin:SetSetting(key, default)
		
		return default
	end
	
	return value
end

-- [[ CONNECTIONS ]]

function module:OnClick(text: string, callback: () -> any): RBXScriptConnection
	local button = self:GetToolbarButton(text)
	assert(button, '%s button is not defined', text)
	
	return button.Click:Connect(callback)
end

return module