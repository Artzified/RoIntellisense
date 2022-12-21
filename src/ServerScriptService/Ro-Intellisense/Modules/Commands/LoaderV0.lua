--[[ 
	LOADER V0 — COMMANDS
	
	FORMAT:
	```
	{
		{
			name: string;
			source: string;
		}
	}
	```
]]

local Loader = {}

function Loader:load(data: {}, parent)	
	for _, v in data do
		
		local cmd = parent:FindFirstChild(v.name) or Instance.new('ModuleScript')
		cmd.Name = v.name
		cmd.Source = v.source

		cmd.Parent = parent
		
	end
end

function Loader:save(cmds: {ModuleScript})
	local serialized = {}
	
	for _, cmd in cmds do
		table.insert(serialized, {
			name = cmd.Name;
			source = cmd.Source;
		})
	end
	
	return serialized
end

return Loader
