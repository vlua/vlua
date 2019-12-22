local find, format, sub, gsub = string.find, string.format, string.sub, string.gsub
local tonumber = tonumber
local tostring = tostring
local tremove = table.remove
local tinsert = table.insert
local setmetatable = setmetatable
local select = select
local min = math.min
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

return {
    parsePath = parsePath,
    removeArrayItem = removeArrayItem,
    class = class,
    slice = slice,
    splice = splice,
    isReserved = isReserved,
    instanceof = instanceof
}
