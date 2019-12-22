local vlua = require("vlua")
local Watcher = require("observer.Watcher")
local CallContext = require("observer.CallContext")
local Binder = require("plugins.generic.Binder")
local HookIds = CallContext.HookIds
local tinsert = table.insert

local Generic = {}

Generic.install = function()
    --- call cb when expr changed
    ---@param expOrFn string | Function
    ---@param cb Function
    ---@param options WatcherOptions
    function vlua.watch(source, expOrFn, cb, options)
        -- watch and run one time
        local watcher = Watcher.new(source, expOrFn, cb, options)
        CallContext.target:once(
            HookIds.unmount,
            function()
                watcher:teardown()
            end
        )
    end

    function vlua.createBinder(source)
        local binder = Binder.new(source)
        vlua.onUnmount(
            function()
                binder:teardown()
            end
        )
    end

    function vlua.onMounted(cb)
        CallContext.target:on(HookIds.mounted, cb)
    end

    function vlua.onUnmount(cb)
        CallContext.target:on(HookIds.unmount, cb)
    end

    function vlua.onDestroy(cb)
        CallContext.target:on(HookIds.destroy, cb)
    end

    function vlua.onErrorCaptured(cb)
        CallContext.target:on(HookIds.errorCaptured, cb)
    end
end

return Generic
