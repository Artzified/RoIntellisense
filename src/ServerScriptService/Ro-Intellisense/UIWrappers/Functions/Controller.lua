-- [[ SERVICES ]]

local Selection = game:GetService("Selection")

-- [[ WIDGET VARIABLES ]]

local Wrapper = script.Parent

local Canvas = Wrapper.Canvas
local Topbar = Wrapper.Topbar

-- [[ VARIABLES ]]

local RoIntellisense

local Framework

local start_pattern = "^%s*%-%-%[%["
local end_pattern = "%]%]"

-- [[ FUNCTIONS ]]

local function onUpdate(src)
	Framework.clearWithWhitelist(Canvas, {'Frame'})

    local lines = src.Source:split('\n')

    local lastLineStart, lastLineEnd
    local data = {}

    for i, line in lines do
        if i == #lines then continue end

        if line:match(start_pattern) then
            lastLineStart = i
        elseif line:match(end_pattern) and lastLineStart then
            lastLineEnd = i

            local nextLine = lines[i+1]
            local func = nextLine:match('function ([%w%p]+)%(%)') or ''

            local temp = {
                name = func;
                line = nextLine;

                ret = {};
                
                description = nil;
                parameters = {};
            }

            for x = lastLineStart + 1, lastLineEnd - 1 do
                line = lines[x]

                local tag, contents = line:match('@(%a+) (.+)')

                if tag == 'param' then
                    local _type, name, desc = contents:match('(%w+) (%w+) (.+)')

                    table.insert(temp.parameters, {
                        name = name;
                        description = desc;
                        _type = _type
                    })
                elseif tag == 'return' then
                    local _type, desc = contents:match('(%w+) (.+)')

                    temp.ret = {_type = _type, description = desc}
                else
                    if temp.description then continue end

                    temp.description = line:gsub('^%s+', '')
                end
            end

            table.insert(data, temp)
        end
    end

    for _, info in data do
        if not (info.name or info.line or info.description) then continue end

        local clone = RoIntellisense.UIComponents.FunctionField:Clone()
        clone.Name = info.name

        clone.Line.Text = info.line

        clone.Info.description.Text = info.description
        
        for i, parameter in info.parameters do
            if not parameter.description then continue end

            local param = RoIntellisense.UIComponents.ParameterField:Clone()

            param.description.Text = parameter.description

            param.Argument.name.Text = parameter.name
            param.Argument._type.Text = parameter._type

            param.LayoutOrder = i
            param.Parent = clone.Info.ParameterList
        end

        clone.Info.ReturnField.returnType.Text = info.ret._type or 'nil'
        clone.Info.ReturnField.returnText.Text = info.ret.description or 'No description specified'

        clone.Line.MouseButton1Click:Connect(function()
            clone.Info.Visible = not clone.Info.Visible
        end)

        clone.Parent = Canvas
    end
end

-- [[ MODULE ]]

local Controller = {}

function Controller:__env(_, framework_ref)
	Framework = framework_ref

	RoIntellisense = Framework.RoIntellisense
end

function Controller:init()
    Topbar.Buttons.Load.MouseButton1Click:Connect(function()
        local selected = Selection:Get()
        local src = table.remove(selected, 1)

        if not src or not src:IsA('LuaSourceContainer') then return end
        onUpdate(src)
    end)
end

return Controller