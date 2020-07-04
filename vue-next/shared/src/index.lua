require("shared/src/makeMap")

undefined
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local EMPTY_OBJ = (__DEV__ and {Object:freeze({})} or {{}})[1]
local EMPTY_ARR = {}
local NOOP = function()
  
end

local NO = function()
  false
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local onRE = /^on[^a-z]/
local isOn = function(key)
  onRE:test(key)
end

local extend = Object.assign
local remove = function(arr, el)
  local i = arr:find(el)
  if i > -1 then
    arr:splice(i, 1)
  end
end

local hasOwnProperty = Object.prototype.hasOwnProperty
local hasOwn = function(val, key)
  hasOwnProperty.call(val, key)
end

local isArray = Array.isArray
local isFunction = function(val)
  type(val) == 'function'
end

local isString = function(val)
  type(val) == 'string'
end

local isSymbol = function(val)
  type(val) == 'symbol'
end

local isObject = function(val)
  val ~= nil and type(val) == 'object'
end

local isPromise = function(val)
  return (isObject(val) and isFunction(val.tsvar_then)) and isFunction(val.catch)
end

local objectToString = Object.prototype.toString
local toTypeString = function(value)
  objectToString:call(value)
end

local toRawType = function(value)
  return toTypeString(value):slice(8, -1)
end

local isPlainObject = function(val)
  toTypeString(val) == '[object Object]'
end

local isReservedProp = makeMap('key,ref,' .. 'onVnodeBeforeMount,onVnodeMounted,' .. 'onVnodeBeforeUpdate,onVnodeUpdated,' .. 'onVnodeBeforeUnmount,onVnodeUnmounted')
local cacheStringFunction = function(fn)
  local cache = Object:create(nil)
  return function(str)
    -- [ts2lua]cache下标访问可能不正确
    local hit = cache[str]
    -- [ts2lua]cache下标访问可能不正确
    return hit or (cache[str] = fn(str))
  end
  

end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local camelizeRE = /-(\w)/g
local camelize = cacheStringFunction(function(str)
  return str:gsub(camelizeRE, function(_, c)
    -- [ts2lua]lua中0和空字符串也是true，此处c需要确认
    (c and {c:toUpperCase()} or {''})[1]
  end
  )
end
)
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local hyphenateRE = /\B([A-Z])/g
local hyphenate = cacheStringFunction(function(str)
  return str:gsub(hyphenateRE, '-$1'):toLowerCase()
end
)
local capitalize = cacheStringFunction(function(str)
  return str:sub(0):toUpperCase() + str:slice(1)
end
)
local hasChanged = function(value, oldValue)
  value ~= oldValue and (value == value or oldValue == oldValue)
end

local invokeArrayFns = function(fns, arg)
  local i = 0
  repeat
    fns[i+1](arg)
    i=i+1
  until not(i < #fns)
end

local def = function(obj, key, value)
  Object:defineProperty(obj, key, {configurable=true, enumerable=false, value=value})
end

local toNumber = function(val)
  local n = parseFloat(val)
  -- [ts2lua]lua中0和空字符串也是true，此处isNaN(n)需要确认
  return (isNaN(n) and {val} or {n})[1]
end
