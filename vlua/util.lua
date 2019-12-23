local typeof = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local next = next
local find, format, sub, gsub = string.find, string.format, string.sub, string.gsub
local tonumber = tonumber
local tostring = tostring
local tremove = table.remove
local tinsert = table.insert
local min = math.min
local type = type

local emptyObject = {}

--- 基于原型创建一个对象
local function createObject(prototype)
    if prototype then
        return setmetatable({}, prototype)
    else
        return {}
    end
end

local PlainObject = {}
local V_GETTER = 1
local V_SETTER = 2

--- 创建平摊的带属性的对象
local function createPlainObjectMetatable()
    local properties = {}

    ---@class ReactiveMetatable
    local mt = {}
    mt.__properties = properties
    mt.__index = function(self, key)
        local property = properties[key]
        if property then
            return property[V_GETTER](self)
        end
    end

    mt.__newindex = function(self, key, value)
        local property = properties[key]
        if property then
            property[V_SETTER](self, value)
        else
            properties[key] = {
                function(self)
                    return value
                end,
                function(self, newValue)
                    value = newValue
                end
            }
        end
    end

    mt.__pairs = function(self)
        local key, valueStore
        return function()
            key, valueStore = next(properties, key)
            return key, valueStore and valueStore[V_GETTER](self)
        end
    end

    mt.__ipairs = function(self)
        local i = 1
        local valueStore
        return function()
            valueStore = properties[i]
            i = i + 1
            return i, valueStore and valueStore[V_GETTER](self)
        end
    end

    mt.__len = function()
        return #properties
    end

    setmetatable(mt, PlainObject)
    return mt
end

--- 创建平摊的带属性的对象
local function createPlainObject()
    local instance = {}
    local mt = createPlainObjectMetatable()
    setmetatable(instance, mt)
    return instance
end


local function isPlainObject(obj)
    return type(obj) == "table" and getmetatable(obj) == nil
end

--[[ eslint-disable no-unused-vars ]]
--[[*
 * Perform no operation.
 * Stubbing args to make Flow happy without leaving useless transpiled code
 * with ...rest (https:--flow.org/blog/2017/05/07/Strict-Function-Call-Arity/).
 ]]
 local function noop()
 end



--- 创建一个属性
local function defineProperty(target, key, getter, setter)
    local mt = getmetatable(target)
    assert(mt, "not plain object or reactive object")
    local properties = mt.__properties
    assert(mt, "not plain object or reactive object")
    properties[key] = {getter or noop, setter or function()error('no setter for key : '.. key)end}
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

local function isCallable(fn)
    local t = type(fn)
    return t == "function" or (getmetatable(fn) and type(getmetatable(fn).__call) == "function")
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
        return string.gsub(
            str,
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

---@param handler Function
---@param args null | any[]
---@param vm any
---@param info string
local function invokeWithErrorHandling(handler, vm, info, ...)
    local res
    --   try {
    res = handler(...)
    -- if (res && !res._isVue && isPromise(res) && !res._handled) {
    --   res.catch(e => handleError(e, vm, info + ` (Promise/async)`))
    --   -- issue #9511
    --   -- avoid catch triggering multiple times when nested calls
    --   res._handled = true
    -- }
    --   } catch (e) {
    --     handleError(e, vm, info)
    --   }
    return res
end

--[[]
 * unicode letters used for parsing html tags, component names and property paths.
 * using https://www.w3.org/TR/html53/semantics-scripting.html#potentialcustomelementname
 * skipping \u10000-\uEFFFF due to it freezing up PhantomJS
]]
--export const unicodeRegExp = /a-zA-Z\u00B7\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u037D\u037F-\u1FFF\u200C-\u200D\u203F-\u2040\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD/

-- Check if a string starts with $ or _
---@param str string
---@return boolean
local function isReserved(str)
    local c = string.byte(str, 1)
    return c == 0x24 or c == 0x5F
end

local function parse_path(path)
    if not path or path == "" then
        error("invalid path:" .. tostring(path))
    end
    --print('start to parse ' .. path)
    local result = {}
    local i, n = 1, #path
    while i <= n do
        local s, e, split1, key, split2 = find(path, "([%.%[])([^%.^%[^%]]+)(%]?)", i)
        if not s or s > i then
            --print('"'.. sub(path, i, s and s - 1).. '"')
            tinsert(result, sub(path, i, s and s - 1))
        end
        if not s then
            break
        end
        if split1 == "[" then
            if split2 ~= "]" then
                error("invalid path:" .. path)
            end
            key = tonumber(key)
            if not key then
                error("invalid path:" .. path)
            end
            --print(key)
            tinsert(result, key)
        else
            --print('"'.. key .. '"')
            tinsert(result, key)
        end
        i = e + 1
    end
    --print('finish parse ' .. path)
    return result
end

---@param path string
local function parsePath(path)
    local segments = parse_path(path)
    return function(obj)
        for i = 1, #segments do
            if (not obj) then
                return
            end
            obj = obj[segments[i]]
        end
        return obj
    end
end

local function removeArrayItem(t, item)
    for i, v in ipairs(t) do
        if v == item then
            tremove(t, i)
            break
        end
    end
end
local function slice(array)
    local newArray = {}
    for i = 1, #array do
        newArray[i] = array[i]
    end
    return newArray
end

---@param name string
local function class(name, super)
    local cls = {}
    cls.__name = name
    cls.__index = cls
    cls.new = function(...)
        local instance = {}
        setmetatable(instance, cls)
        if cls.ctor then
            cls.ctor(instance, ...)
        end
        return instance
    end
    if super then
        setmetatable(cls, super)
    end
    return cls, super
end

-- http://phi.lho.free.fr/programming/TestLuaArray.lua.html
-- TODO move this to helpers
-- Emulate the splice function of JS (or array_splice of PHP)
-- I keep the imperfect parameter names from the Mozilla doc.
-- http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Global_Objects:Array:splice
-- I use 1-based indices, of course.
local function splice(t, index, howMany, ...)
    local removed = {}
    local tableSize = #t -- Table size
    -- Lua 5.0 handling of vararg...
    local args = {...}
    local argNb = #args -- Number of elements to insert
    -- Check parameter validity
    if index < 1 then
        index = 1
    end
    if howMany < 0 then
        howMany = 0
    end
    if index > tableSize then
        index = tableSize + 1 -- At end
        howMany = 0 -- Nothing to delete
    end
    if index + howMany - 1 > tableSize then
        howMany = tableSize - index + 1 -- Adjust to number of elements at index
    end

    local argIdx = 1 -- Index in arg
    -- Replace min(howMany, argNb) entries
    for pos = index, index + min(howMany, argNb) - 1 do
        -- Copy removed entry
        tinsert(removed, t[pos])
        -- Overwrite entry
        t[pos] = args[argIdx]
        argIdx = argIdx + 1
    end
    argIdx = argIdx - 1
    -- If howMany > argNb, remove extra entries
    for i = 1, howMany - argNb do
        tinsert(removed, tremove(t, index + argIdx))
    end
    -- If howMany < argNb, insert remaining new entries
    for i = argNb - howMany, 1, -1 do
        tinsert(t, index + howMany, args[argIdx + i])
    end
    return removed
end

local function instanceof(obj, cls)
    local mt = obj
    while(mt) do
        if mt == cls then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

local function isRef(val)
    return type(val) == "table" and val.__isref == true
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
    isCallable = isCallable,
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
    isServerRendering = isServerRendering,
    createPlainObject = createPlainObject,
    createPlainObjectMetatable = createPlainObjectMetatable,
    PlainObject = PlainObject,
    invokeWithErrorHandling = invokeWithErrorHandling,
    parsePath = parsePath,
    removeArrayItem = removeArrayItem,
    class = class,
    slice = slice,
    splice = splice,
    isReserved = isReserved,
    instanceof = instanceof,
    isRef = isRef
}
