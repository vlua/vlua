local vlua = require("vlua.vlua")
local Binder = require("vlua.binder")
local HookIds = Binder.HookIds

local Generic = {}

Generic.install = function()
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
end

return Generic
