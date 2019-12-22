local Watcher = require("vlua.watcher")
local Util = require("vlua.util")
local Binder = require("vlua.binder")
local warn = Util.warn
local debug = debug
local pcall, xpcall = pcall, xpcall
local HookIds = Binder.HookIds
local pushContext, popContext = Binder.pushContext, Binder.popContext

---@param fn fun():nil
local function new(fn)
    -- a content hold my watches and all children
    ---@type Binder
    local binder = Binder.target and Binder.target:createChild() or Binder.new()

    local reactiveFn = function()
        binder:emit(HookIds.unmount)
        pushContext(binder)
        local value =
            xpcall(
            fn,
            function(msg)
                warn("error when new:" .. msg .. " stack :" .. debug.traceback())
                binder:emit(HookIds.errorCaptured, msg)
            end,
            binder
        )
        popContext()
        binder:emit(HookIds.mounted, value)
    end
    -- watch and run one time
    local watcher = Watcher.new(nil, reactiveFn)
    -- only teardown when destory, but not unmount
    binder:once(
        HookIds.destroy,
        function()
            watcher:teardown()
        end
    )
    return binder
end

return {
    new = new
}
