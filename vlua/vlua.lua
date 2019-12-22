local Computed = require("vlua.apiComputed")
local Observer = require("vlua.observer")
local Ref = require("vlua.apiRef")
local apiNew = require("vlua.apiNew")
local observe = Observer.observe


local function reactive(value)
    observe(value)
    return value
end

local plugins = {}
local function use(plugin)
    assert(plugins[plugin] == nil , "dup plugin")
    plugin.install()
end


---@class vlua
local vlua = {
    ref = Ref.ref,
    computed = Computed.computed,
    reactive = reactive,
    new = apiNew.new,
    use = use
}

return vlua