require("reactivity/src/reactive")
require("reactivity/src/reactive/ReactiveFlags")
require("reactivity/src/operations/TrackOpTypes")
require("reactivity/src/operations/TriggerOpTypes")
require("reactivity/src/effect")
require("@vue/shared")
require("reactivity/src/ref")

local builtInSymbols = Set(Object:getOwnPropertyNames(Symbol):map(function(key)
  -- [ts2lua]Symbol下标访问可能不正确
  Symbol[key]
end
):filter(isSymbol))
local get = createGetter()
local shallowGet = createGetter(false, true)
local readonlyGet = createGetter(true)
local shallowReadonlyGet = createGetter(true, true)
local arrayInstrumentations = {}
({'includes', 'indexOf', 'lastIndexOf'}):forEach(function(key)
  -- [ts2lua]arrayInstrumentations下标访问可能不正确
  arrayInstrumentations[key] = function(...)
    local arr = toRaw(self)
    local i = 0
    local l = #self
    repeat
      track(arr, TrackOpTypes.GET, i .. '')
      i=i+1
    until not(i < l)
    -- [ts2lua]arr下标访问可能不正确
    local res = arr[key](...)
    if res == -1 or res == false then
      -- [ts2lua]arr下标访问可能不正确
      return arr[key](...)
    else
      return res
    end
  end
  

end
)
function createGetter(isReadonly, shallow)
  if isReadonly == nil then
    isReadonly=false
  end
  if shallow == nil then
    shallow=false
  end
  return function get(target, key, receiver)
    if key == ReactiveFlags.IS_REACTIVE then
      return not isReadonly
    elseif key == ReactiveFlags.IS_READONLY then
      return isReadonly
    -- [ts2lua]target下标访问可能不正确
    -- [ts2lua]target下标访问可能不正确
    -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
    elseif key == ReactiveFlags.RAW and receiver == (isReadonly and {target[ReactiveFlags.READONLY]} or {target[ReactiveFlags.REACTIVE]})[1] then
      return target
    end
    local targetIsArray = isArray(target)
    if targetIsArray and hasOwn(arrayInstrumentations, key) then
      return Reflect:get(arrayInstrumentations, key, receiver)
    end
    local res = Reflect:get(target, key, receiver)
    -- [ts2lua]lua中0和空字符串也是true，此处isSymbol(key)需要确认
    if (isSymbol(key) and {builtInSymbols:has(key)} or {key ==  or key == })[1] then
      return res
    end
    if not isReadonly then
      track(target, TrackOpTypes.GET, key)
    end
    if shallow then
      return res
    end
    if isRef(res) then
      -- [ts2lua]lua中0和空字符串也是true，此处targetIsArray需要确认
      return (targetIsArray and {res} or {res.value})[1]
    end
    if isObject(res) then
      -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
      return (isReadonly and {readonly(res)} or {reactive(res)})[1]
    end
    return res
  end
  

end

local set = createSetter()
local shallowSet = createSetter(true)
function createSetter(shallow)
  if shallow == nil then
    shallow=false
  end
  return function set(target, key, value, receiver)
    -- [ts2lua]target下标访问可能不正确
    local oldValue = target[key]
    if not shallow then
      value = toRaw(value)
      if (not isArray(target) and isRef(oldValue)) and not isRef(value) then
        oldValue.value = value
        return true
      end
    end
    local hadKey = hasOwn(target, key)
    local result = Reflect:set(target, key, value, receiver)
    if target == toRaw(receiver) then
      if not hadKey then
        trigger(target, TriggerOpTypes.ADD, key, value)
      elseif hasChanged(value, oldValue) then
        trigger(target, TriggerOpTypes.SET, key, value, oldValue)
      end
    end
    return result
  end
  

end

function deleteProperty(target, key)
  local hadKey = hasOwn(target, key)
  -- [ts2lua]target下标访问可能不正确
  local oldValue = target[key]
  local result = Reflect:deleteProperty(target, key)
  if result and hadKey then
    trigger(target, TriggerOpTypes.DELETE, key, undefined, oldValue)
  end
  return result
end

function has(target, key)
  local result = Reflect:has(target, key)
  track(target, TrackOpTypes.HAS, key)
  return result
end

function ownKeys(target)
  track(target, TrackOpTypes.ITERATE, ITERATE_KEY)
  return Reflect:ownKeys(target)
end

local mutableHandlers = {get=get, set=set, deleteProperty=deleteProperty, has=has, ownKeys=ownKeys}
local readonlyHandlers = {get=readonlyGet, has=has, ownKeys=ownKeys, set=function(target, key)
  if __DEV__ then
    console:warn(target)
  end
  return true
end
, deleteProperty=function(target, key)
  if __DEV__ then
    console:warn(target)
  end
  return true
end
}
local shallowReactiveHandlers = extend({}, mutableHandlers, {get=shallowGet, set=shallowSet})
local shallowReadonlyHandlers = extend({}, readonlyHandlers, {get=shallowReadonlyGet})