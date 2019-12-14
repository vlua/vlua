local config = require("config")
local Observer = require('observer.Observer')
local Util = require('util.Util')
local observe, toggleObserving, shouldObserve = Observer.observe, Observer.toggleObserving, Observer.shouldObserve
local
  hasOwn,
  isObject,
  toRawType,
  hyphenate,
  capitalize,
  isPlainObject
=
Util.hasOwn,
Util.isObject,
Util.toRawType,
Util.hyphenate,
Util.capitalize,
Util.isPlainObject

---@class PropOptions 
---@field type Function | Array<Function> | nil
---@field default any
---@field required boolean
---@field validator Function
local _

---@param key string
---@param propOptions Object
---@param propsData Object
---@param vm Component
local function validateProp (
    key,
    propOptions,
    propsData,
    vm
)
    local prop = propOptions[key]
    local absent = not hasOwn(propsData, key)
    local value = propsData[key]
    -- boolean casting
    local booleanIndex = getTypeIndex(Boolean, prop.type)
    if (booleanIndex > -1) then
        if (absent and not hasOwn(prop, 'default')) then
            value = false
        elseif (value == '' or value == hyphenate(key)) then
            -- only cast empty string / same name to boolean if
            -- boolean has higher priority
            local stringIndex = getTypeIndex(String, prop.type)
            if (stringIndex < 0 or booleanIndex < stringIndex) then
            value = true
            end
        end
    end
    -- check default value
    if (value == nil) then
        value = getPropDefaultValue(vm, prop, key)
        -- since the default value is a fresh copy,
        -- make sure to observe it.
        local prevShouldObserve = shouldObserve()
        toggleObserving(true)
        observe(value)
        toggleObserving(prevShouldObserve)
    end
    if (
        config.env ~= 'production' and
        -- skip validation for weex recycle-list child component props
        not (__WEEX__ and isObject(value) and (value['@binding'] ~= nil))
    ) then
        assertProp(prop, key, value, vm, absent)
    end
    return value
end

--[[*
 * Get the default value of a prop.
 ]]
 ---@param vm Component
 ---@param prop PropOptions
 ---@param key string
local function getPropDefaultValue (vm, prop, key)
    -- no default, return nil
    if (not hasOwn(prop, 'default')) then
        return nil
    end
    local def = prop.default
    -- warn against non-factory defaults for Object & Array
    if (config.env ~= 'production' and isObject(def)) then
        warn(
            'Invalid default value for prop "' + key + '": ' +
            'Props with type Object/Array must use a factory function ' +
            'to return the default value.',
            vm
        )
    end
    -- the raw prop value was also nil from previous render,
    -- return previous default value to avoid unnecessary watcher trigger
    if (vm and vm._options.propsData and
        vm._options.propsData[key] == nil and
        vm._props[key] ~= nil
    ) then
        return vm._props[key]
    end
    -- call factory function for non-Function types
    -- a value is Function if its prototype is function even across different execution context
    return type(def) == 'function' and getType(prop.type) ~= 'Function'
        and def.call(vm)
        or def
end

--[[*
 * Assert whether a prop is valid.
 ]]
---@param prop PropOptions
---@param name string
---@param value any
---@param vm Component
---@param absent boolean
local function assertProp (
    prop,
    name,
    value,
    vm,
    absent
)
    if (prop.required and absent) then
        warn(
        'Missing required prop: "' + name + '"',
        vm
        )
        return
    end
    if (value == nil and not prop.required) then
        return
    end
    local type = prop.type
    local valid = not type or type == true
    local expectedTypes = {}
    if (type) then
        if (not Array.isArray(type)) then
            type = {type}
        end
        for i = 1, #type.length do
            local assertedType = assertType(value, type[i])
            expectedTypes.push(assertedType.expectedType or '')
            valid = assertedType.valid
            if not valid then
                break
            end
        end
    end

    if (not valid) then
        warn(
            getInvalidTypeMessage(name, value, expectedTypes),
            vm
        )
        return
    end
    local validator = prop.validator
    if (validator) then
        if (not validator(value)) then
            warn(
            'Invalid prop: custom validator check failed for prop "' + name + '".',
            vm
            )
        end
    end
end

local simpleCheckRE = '^(String|Number|Boolean|Function|Symbol)$'

---@class AssertTyped
---@field valid boolean
---@field expectedType string

---@param value any
---@param type Function
---@return AssertTyped
local function assertType (value, type)
    local valid
    local expectedType = getType(type)
    if (simpleCheckRE.test(expectedType)) then
        local t = type(value)
        valid = t == expectedType.toLowerCase()
        -- for primitive wrapper objects
        if (not valid and t == 'object') then
            valid = instanceof(value, type)
        end
    elseif (expectedType == 'Object') then
        valid = isPlainObject(value)
    elseif (expectedType == 'Array') then
        valid = Array.isArray(value)
    else
        valid = instanceof(value, type)
    end

    return {
        valid = valid,
        expectedType = expectedType
    }
end

--[[*
 * Use function string name to check built-in types,
 * because a simple equality check will fail when running
 * across different vms / iframes.
 ]]
local function getType (fn)
    local match = fn and fn.toString().match('^\\s*function (\\w+)')
    return match and match[1] or ''
end

local function isSameType (a, b)
    return getType(a) == getType(b)
end

---@return number
local function getTypeIndex (type, expectedTypes)
    if (not isArray(expectedTypes)) then
        return isSameType(expectedTypes, type) and 0 or -1
    end
    for i = 1 , #expectedTypes do
        if (isSameType(expectedTypes[i], type)) then
            return i
        end
    end
    return -1
end

local function getInvalidTypeMessage (name, value, expectedTypes)
    local message = 'Invalid prop: type check failed for prop "$thennameend".' +
    ' Expected $thenexpectedTypes.map(capitalize).join(', ')end'
    local expectedType = expectedTypes[1]
    local receivedType = toRawType(value)
    local expectedValue = styleValue(value, expectedType)
    local receivedValue = styleValue(value, receivedType)
    -- check if we need to specify expected value
    if (#expectedTypes == 1 and
        isExplicable(expectedType) and
        not isBoolean(expectedType, receivedType)) then
        message = message .. ' with value $thenexpectedValueend'
    end
    message = message ..  ', got $thenreceivedTypeend '
    -- check if we need to specify received value
    if (isExplicable(receivedType)) then
        message = message ..  'with value $thenreceivedValueend.'
    end
    return message
end

local function styleValue (value, type)
    if (type == 'String') then
        return '"$thenvalueend"'
    elseif (type == 'Number') then
        return '$thenNumber(value)end'
    else
        return '$thenvalueend'
    end
end

local function isExplicable (value)
    local explicitTypes = {'string', 'number', 'boolean'}
    return explicitTypes.some(function(elem)return value.toLowerCase() == elem end)
end

function isBoolean (...)
    local args = {...}
    return args.some(function(elem)return elem.toLowerCase() == 'boolean' end)
end

return {
    validateProp = validateProp
}