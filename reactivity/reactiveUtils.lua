local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")
local type, ipairs, pairs, ltraceback, xpcall, tinsert, getmetatable =
    type,
    ipairs,
    pairs,
    debug.traceback,
    xpcall,
    table.tinsert,
    getmetatable

--[[*
 * Quick object check - this is primarily used to tell
 * Objects from primitive values when we know the value
 * is a JSON-compliant type.
 ]]
local function isObject(obj)
    return type(obj) == "table"
end

local function isFunction(obj)
    return type(obj) == "function"
end

local function isCallable(obj)
    local t = type(obj)
    if t == "function" then
        return true
    elseif t == "table" then
        local mt = getmetatable(obj)
        if mt then
            return mt.__call ~= nil
        end
    end
    return false
end
-- compare whether a value has changed, accounting for NaN.
local function hasChanged(value, oldValue)
    return value ~= oldValue and (value == value or oldValue == oldValue)
end

--[[*
 * Mix properties into target object.
 ]]
local function extend(to, _from)
    for key, value in pairs(_from) do
        to[key] = value
    end
    return to
end

local function NOOP()
end
local EMPTY_OBJ = {}

local warn = print

local function traceback(msg)
    warn(ltraceback(msg))
end

local function callWithErrorHandling(fn, instance, type, ...)
    local result, ret =
        xpcall(
        fn,
        function(err)
            warn(ltraceback(err, instance, type))
        end,
        instance,
        ...
    )
    return ret
end

local function callWithAsyncErrorHandling(fn, instance, type, ...)
    if isCallable(fn) then
        local res = callWithErrorHandling(fn, instance, type, ...)
        return res
    end
    local values = {}
    for i = 1, #fn do
        tinsert(values, callWithAsyncErrorHandling(fn[i], instance, type, ...))
    end
    return values
end

local function array_includes(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

return {
    isObject = isObject,
    isFunction = isFunction,
    isCallable = isCallable,
    hasChanged = hasChanged,
    extend = extend,
    warn = warn,
    NOOP = NOOP,
    EMPTY_OBJ = EMPTY_OBJ,
    traceback = traceback,
    callWithErrorHandling = callWithErrorHandling,
    callWithAsyncErrorHandling = callWithAsyncErrorHandling,
    array_includes = array_includes
}
