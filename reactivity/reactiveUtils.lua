local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")
local type = type
local pairs = pairs

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

local function NOOP()end
local EMPTY_OBJ = {}

local warn = print

local function traceback(msg)
    warn(debug.traceback(msg))
end

local function proxy()

end

return {
    isObject = isObject,
    isFunction = isFunction,
    hasChanged = hasChanged,
    extend = extend,
    warn = warn,
    NOOP = NOOP,
    EMPTY_OBJ = EMPTY_OBJ,
    traceback = traceback,
    proxy = proxy
}
