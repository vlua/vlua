
local seenObjects = {}


local function _traverse (val, seen)
    if type(val) ~= "table" then
        return
    end
    ---@type ReactiveMetatable
    local mt = getmetatable(val)
    if (mt and mt.__ob__) then
        local depId = mt.__ob__.dep.id
        if (seen[depId]) then
            return
        end
        seen[depId] = val
    end
    for i,v in pairs(val) do
        _traverse(i, seen)
        _traverse(v, seen)
    end
end

--[[
 * Recursively traverse an object to evoke all converted
 * getters, so that every nested property inside the object
 * is collected as a "deep" dependency.
--]]
local function traverse(val)
    _traverse(val, seenObjects)
    seenObjects = {}
end

return {
    traverse = traverse
}