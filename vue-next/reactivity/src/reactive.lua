require("@vue/shared")
require("reactivity/src/baseHandlers")
require("reactivity/src/collectionHandlers")
require("reactivity/src/reactive/ReactiveFlags")

local collectionTypes = Set({Set, Map, WeakMap, WeakSet})
local isObservableType = makeMap('Object,Array,Map,Set,WeakMap,WeakSet')
local canObserve = function(value)
  -- [ts2lua]value下标访问可能不正确
  return (not value[ReactiveFlags.SKIP] and isObservableType(toRawType(value))) and not Object:isFrozen(value)
end

-- [ts2lua]请手动处理DeclareFunction

function reactive(target)
  -- [ts2lua]target下标访问可能不正确
  if target and target[ReactiveFlags.IS_READONLY] then
    return target
  end
  return createReactiveObject(target, false, mutableHandlers, mutableCollectionHandlers)
end

function shallowReactive(target)
  return createReactiveObject(target, false, shallowReactiveHandlers, shallowCollectionHandlers)
end

function readonly(target)
  return createReactiveObject(target, true, readonlyHandlers, readonlyCollectionHandlers)
end

function shallowReadonly(target)
  return createReactiveObject(target, true, shallowReadonlyHandlers, readonlyCollectionHandlers)
end

function createReactiveObject(target, isReadonly, baseHandlers, collectionHandlers)
  if not isObject(target) then
    if __DEV__ then
      console:warn()
    end
    return target
  end
  -- [ts2lua]target下标访问可能不正确
  -- [ts2lua]target下标访问可能不正确
  if target[ReactiveFlags.RAW] and not (isReadonly and target[ReactiveFlags.IS_REACTIVE]) then
    return target
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
  if hasOwn(target, (isReadonly and {ReactiveFlags.READONLY} or {ReactiveFlags.REACTIVE})[1]) then
    -- [ts2lua]target下标访问可能不正确
    -- [ts2lua]target下标访问可能不正确
    -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
    return (isReadonly and {target[ReactiveFlags.READONLY]} or {target[ReactiveFlags.REACTIVE]})[1]
  end
  if not canObserve(target) then
    return target
  end
  -- [ts2lua]lua中0和空字符串也是true，此处collectionTypes:has(target.constructor)需要确认
  local observed = Proxy(target, (collectionTypes:has(target.constructor) and {collectionHandlers} or {baseHandlers})[1])
  -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
  def(target, (isReadonly and {ReactiveFlags.READONLY} or {ReactiveFlags.REACTIVE})[1], observed)
  return observed
end

function isReactive(value)
  if isReadonly(value) then
    -- [ts2lua]value下标访问可能不正确
    return isReactive(value[ReactiveFlags.RAW])
  end
  -- [ts2lua]value下标访问可能不正确
  return not (not (value and value[ReactiveFlags.IS_REACTIVE]))
end

function isReadonly(value)
  -- [ts2lua]value下标访问可能不正确
  return not (not (value and value[ReactiveFlags.IS_READONLY]))
end

function isProxy(value)
  return isReactive(value) or isReadonly(value)
end

function toRaw(observed)
  -- [ts2lua]observed下标访问可能不正确
  return observed and toRaw(observed[ReactiveFlags.RAW]) or observed
end

function markRaw(value)
  def(value, ReactiveFlags.SKIP, true)
  return value
end
