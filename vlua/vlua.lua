local Computed = require("vlua.apiComputed")
local Observer = require("vlua.observer")
local Binder = require("vlua.binder")
local Ref = require("vlua.apiRef")


local plugins = {}
local function use(plugin)
    assert(plugins[plugin] == nil , "dup plugin")
    plugin.install()
end

---@class vlua
local vlua = {
    ref = Ref.ref,
    computed = Computed.computed,
    reactive = Observer.reactive,
    new = Binder.apiNew,
    newBinder = Binder.apiNewBinder,
    use = use,
}


return vlua