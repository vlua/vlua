local typeof = type
local tinsert = table.insert
local getmetatable = getmetatable
local setmetatable = setmetatable
local Lang = require("util.Lang")
local emptyObject = {}

--- 基于原型创建一个对象
local function createObject(prototype)
    if prototype then
        return setmetatable({}, prototype)
    else
        return {}
    end
end

--- 创建一个属性
local function defineProperty(target, key, getter, setter)
    local properties = target.__properties
    properties[key] = {getter, setter}
end


-- These helpers produce better VM code in JS engines due to their
-- explicitness and function inlining.
local function isUndef(v)
    return v == nil
end

local function isDef(v)
    return v ~= nil
end

local function isTrue(v)
    return v == true
end

local function isFalse(v)
    return v == false
end

--[[*
 * Check if value is primitive.
 ]]
local function isPrimitive(value)
    return (typeof(value) == "string" or typeof(value) == "number" or typeof(value) == "boolean")
end

--[[*
 * Quick object check - this is primarily used to tell
 * Objects from primitive values when we know the value
 * is a JSON-compliant type.
 ]]
local function isObject(obj)
    return typeof(obj) == "table"
end

--[[*
 * Get the raw type string of a value, e.g., [object Object].
 ]]
local tostring = tostring
local getmetatable = getmetatable

local function toRawType(value)
    return tostring(value)
end

--[[*
 * Strict object type check. Only returns true
 * for plain JavaScript objects.
 ]]
local function isPlainObject(obj)
    return typeof(obj) == "table" and getmetatable(obj) == nil
end

local function isPromise(val)
    return false
end

--[[*
 * Convert a value to a string that is actually rendered.
 ]]
local function toString(val)
    return val == nil and "" or
        ((Array.isArray(val) or (isPlainObject(val) and val.toString == tostring)) and JSON.stringify(val, nil, 2) or
            tostring(val))
end

--[[*
 * Convert an input value to a number for persistence.
 * If the conversion fails, return original string.
 ]]
local function toNumber(val)
    return tonumber(val)
end
-- 切割函数(split功能)
---@param szFullString string 待切割数据
---@param szSeparator string 切割判断
---@return string
local function split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
      local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
      if not nFindLastIndex then
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
        break
      end
      nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
      nFindStartIndex = nFindLastIndex + string.len(szSeparator)
      nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
  end

--[[*
 * Make a map and return a function for checking if a key
 * is in that map.
 ]]
local function makeMap(str, expectsLowerCase)
    local map = createObject(nil)
    local list = split(str, ",")
    for i = 1, #list do
        map[list[i]] = true
    end
    return expectsLowerCase and function(val)
            return map[string.lower(val)]
        end or function(val)
            return map[val]
        end
end

--[[*
 * Check if a tag is a built-in tag.
 ]]
local isBuiltInTag = makeMap("slot,component", true)

--[[*
 * Check if an attribute is a reserved attribute.
 ]]
local isReservedAttribute = makeMap("key,ref,slot,slot-scope,is")

--[[*
 * Remove an item from an array.
 ]]
local function remove(arr, item)
    if (arr.length) then
        local index = arr.indexOf(item)
        if (index > -1) then
            return arr.splice(index, 1)
        end
    end
end

--[[*
 * Check whether an object has the property.
 ]]
local function hasOwn(obj, key)
    return obj[key] ~= nil
end

--[[*
 * Create a cached version of a pure function.
 ]]
local function cached(fn)
    local cache = createObject(nil)
    return function(str)
        local hit = cache[str]
        if not hit then
            hit = fn(str)
            cache[str] = hit
        end
        return hit
    end
end

--[[*
 * Camelize a hyphen-delimited string.
 ]]
local camelizeRE = "-(\\w)"
local camelize =
    cached(
    function(str)
        return string.gsub(str,
            camelizeRE,
            function(_, c)
                return c and string.upper(c) or ""
            end
        )
    end
)

--[[*
 * Capitalize a string.
 ]]
local capitalize =
    cached(
        ---@param str string
    function(str)
        return string.upper(str[1]) .. string.sub(str, 2)
    end
)

--[[*
 * Hyphenate a camelCase string.
 ]]
local hyphenateRE = "\\B([A-Z])"
local hyphenate =
    cached(
    function(str)
        return string.lower(string.gsub(str, hyphenateRE, "-$1"))
    end
)

--[[*
 * Convert an Array-like object to a real Array.
 ]]
local function toArray(list, start)
    start = (start or 1) - 1
    local i = #list - start
    local ret = {}
    for j = 1, i do
        ret[j] = list[j + start]
    end
    return ret
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

--[[*
 * Merge an Array of Objects into a single Object.
 ]]
local function toObject(arr)
    local res = {}
    for i = 1, #arr do
        if (arr[i]) then
            extend(res, arr[i])
        end
    end
    return res
end

--[[ eslint-disable no-unused-vars ]]
--[[*
 * Perform no operation.
 * Stubbing args to make Flow happy without leaving useless transpiled code
 * with ...rest (https:--flow.org/blog/2017/05/07/Strict-Function-Call-Arity/).
 ]]
local function noop(a, b, c)
end

--[[*
 * Always return false.
 ]]
local no = function(a, b, c)
    return false
end

--[[ eslint-enable no-unused-vars ]]
--[[*
 * Return the same value.
 ]]
local identity = function(_)
    return _
end

--[[*
 * Generate a string containing static keys from compiler modules.
 ]]
local function genStaticKeys(modules)
    return modules.reduce(
        function(keys, m)
            return keys.concat(m.staticKeys or {})
        end,
        {}
    ).join(",")
end

--[[*
 * Ensure a function is called only once.
 ]]
local function once(fn)
    local called = false
    return function(...)
        if (not called) then
            called = true
            return fn(...)
        end
    end
end

local function isArray(obj)
    return typeof(obj) == "table"
end

local function concat(...)
    local args = {...}
    local result = {}
    for i = 1, #args do
        local t = args[i]
        for j = 1, #t do
            tinsert(result, t[i])
        end
    end
    return result
end
local function indexOf(t, v)
    for i = 1, #t do
        if t[i] == v then
            return i
        end
    end
    return 0
end

local warn = print
local hasSymbol = false
local function isServerRendering()
    return false
end


return {
    emptyObject = emptyObject,
    isUndef = isUndef,
    isDef = isDef,
    isTrue = isTrue,
    isFalse = isFalse,
    isPrimitive = isPrimitive,
    isObject = isObject,
    toRawType = toRawType,
    isPlainObject = isPlainObject,
    isPromise = isPromise,
    toString = toString,
    toNumber = toNumber,
    makeMap = makeMap,
    isBuiltInTag = isBuiltInTag,
    isReservedAttribute = isReservedAttribute,
    remove = remove,
    hasOwn = hasOwn,
    cached = cached,
    camelize = camelize,
    capitalize = capitalize,
    hyphenate = hyphenate,
    toArray = toArray,
    extend = extend,
    toObject = toObject,
    noop = noop,
    no = no,
    identity = identity,
    genStaticKeys = genStaticKeys,
    once = once,
    isArray = isArray,
    createObject = createObject,
    defineProperty = defineProperty,
    warn = warn,
    hasSymbol = hasSymbol,
    indexOf = indexOf,
    concat = concat,
    isReserved = Lang.isReserved,
    isServerRendering = isServerRendering
}