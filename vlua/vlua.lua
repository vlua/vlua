local Computed = require("vlua.apiComputed")
local Observer = require("vlua.observer")
local Binder = require("vlua.binder")
local HookIds = Binder.HookIds
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

local function createBinder(source, parent)
    return Binder.new(source, parent)
end

---@class vlua
local vlua = {
    ref = Ref.ref,
    computed = Computed.computed,
    reactive = reactive,
    new = apiNew.new,
    use = use,
    createBinder = createBinder
}


function vlua.onMounted(cb)
    Binder.target:on(HookIds.mounted, cb)
end

function vlua.onUnmount(cb)
    Binder.target:on(HookIds.unmount, cb)
end

function vlua.onDestroy(cb)
    Binder.target:on(HookIds.destroy, cb)
end

function vlua.onErrorCaptured(cb)
    Binder.target:on(HookIds.errorCaptured, cb)
end

return vlua