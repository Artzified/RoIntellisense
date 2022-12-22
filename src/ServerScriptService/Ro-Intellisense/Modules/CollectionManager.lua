-- [[ SERVICES ]]

local CollectionService = game:GetService("CollectionService")

-- [[ VARIABLES ]]

-- [[ MODULE ]]

local Manager = {}

function Manager:__env(plugin_ref, framework_ref) end

function Manager:GetFirstTagged(tag: string)
    local tagged = CollectionService:GetTagged(tag)
    return table.remove(tagged, 1)
end

function Manager:Tag(instance: Instance, tag: string)
    CollectionService:AddTag(instance, tag)
end

return Manager
