local vlua = require('vlua')
local Watcher = require('observer.Watcher')
local CallContext = require('observer.CallContext')
local HookIds = CallContext.HookIds
local tinsert = table.insert

local Generic = {}

Generic.install = function()
    --- call cb when expr changed
    ---@param expOrFn string | Function
    ---@param cb Function
    ---@param options WatcherOptions
    function vlua.watch(expOrFn, cb, options)
        -- watch and run one time
        return Watcher.new(CallContext.target, expOrFn, cb, options)
    end

    --- call when CallContext teardown
    function vlua.onBeforeMount(cb)
        CallContext.target:on(HookIds.beforeMount, cb)
    end

    function vlua.onMount(cb)
        CallContext.target:on(HookIds.mounted, cb)
    end

    function vlua.onBeforeCreate(cb)
        CallContext.target:on(HookIds.beforeCreate, cb)
    end

    function vlua.onCreated(cb)
        CallContext.target:on(HookIds.created, cb)
    end

    function vlua.onBeforeDestroy(cb)
        CallContext.target:on(HookIds.beforeDestroy, cb)
    end

    function vlua.onDestroyed(cb)
        CallContext.target:on(HookIds.destroyed, cb)
    end

    function vlua.onErrorCaptured(cb)
        CallContext.target:on(HookIds.errorCaptured, cb)
    end

end


return Generic