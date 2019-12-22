local Computed = require("vlua.computed")
local Observer = require("vlua.observer")
local Ref = require("vlua.ref")
local ReactiveCall = require("vlua.reactiveCall")
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
    reactiveCall = ReactiveCall.reactiveCall,
    new = ReactiveCall.reactiveCall,
    use = use
}
return vlua