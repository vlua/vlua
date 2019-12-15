local config = require("config")
local Util = require("util.Util")
local Error = require("util.Error")
local warn = Util.warn
local invokeWithErrorHandling = Error.invokeWithErrorHandling
local cached, isUndef, isTrue, isPlainObject, isArray, slice =
    Util.cached,
    Util.isUndef,
    Util.isTrue,
    Util.isPlainObject,
    Util.isArray,
    Util.slice

local normalizeEvent =
    cached(
    function(name)
        local passive = name.charAt(0) == "&"
        name = passive and name.slice(1) or name
        local once = name.charAt(0) == "~" -- Prefixed last, checked first
        name = once and name.slice(1) or name
        local capture = name.charAt(0) == "!"
        name = capture and name.slice(1) or name
        return {
            name = name,
            once = once,
            capture = capture,
            passive = passive
        }
    end
)

local function createFnInvoker(fns, vm)
    local fn
    local invoker = {}
    fn = function(...)
        local fns = invoker.fns
        if (isArray(fns)) then
            local cloned = slice(fns)
            for i = 1, #cloned do
                invokeWithErrorHandling(cloned[i], vm, "v-on handler", ...)
            end
        else
            -- return handler return value for single handlers
            return invokeWithErrorHandling(fns, vm, "v-on handler", ...)
        end
    end

    invoker.fns = fns
    invoker.__call = fn
    setmetatable(invoker, invoker)
    return invoker
end

local function updateListeners(on, oldOn, add, remove, createOnceHandler, vm)
    local def, old, event
    for name, cur in pairs(on) do
        def = cur
        old = oldOn[name]
        event = normalizeEvent(name)

        if (config.weex and isPlainObject(def)) then
            cur = def.handler
            event.params = def.params
        end
        if (isUndef(cur)) then
            if config.env ~= "production" then
                warn('Invalid handler for event "${event.name}": got ' .. tostring(cur), vm)
            end
        elseif (isUndef(old)) then
            if (isUndef(cur.fns)) then
                cur = createFnInvoker(cur, vm)
                on[name] = cur
            end
            if (isTrue(event.once)) then
                cur = createOnceHandler(event.name, cur, event.capture)
                on[name] = cur
            end
            add(event.name, cur, event.capture, event.passive, event.params)
        elseif (cur ~= old) then
            old.fns = cur
            on[name] = old
        end
    end
    for name, cur in pairs(oldOn) do
        if (isUndef(on[name])) then
            event = normalizeEvent(name)
            remove(event.name, cur, event.capture)
        end
    end
end

return {
    updateListeners = updateListeners
}
