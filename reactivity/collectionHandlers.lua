require("reactivity/src/reactive")
require("reactivity/src/reactive/ReactiveFlags")
require("reactivity/src/effect")
require("reactivity/src/operations/TrackOpTypes")
require("reactivity/src/operations/TriggerOpTypes")
require("@vue/shared")

local toReactive = function(value)
  -- [ts2lua]lua中0和空字符串也是true，此处isObject(value)需要确认
  (isObject(value) and {reactive(value)} or {value})[1]
end

local toReadonly = function(value)
  -- [ts2lua]lua中0和空字符串也是true，此处isObject(value)需要确认
  (isObject(value) and {readonly(value)} or {value})[1]
end

local toShallow = function(value)
  value
end

local getProto = function(v)
  Reflect:getPrototypeOf(v)
end

function get(target, key, wrap)
  target = toRaw(target)
  local rawKey = toRaw(key)
  if key ~= rawKey then
    track(target, TrackOpTypes.GET, key)
  end
  track(target, TrackOpTypes.GET, rawKey)
  local  = getProto(target)
  if has:call(target, key) then
    return wrap(get:call(target, key))
  elseif has:call(target, rawKey) then
    return wrap(get:call(target, rawKey))
  end
end

function has(this, key)
  local target = toRaw(self)
  local rawKey = toRaw(key)
  if key ~= rawKey then
    track(target, TrackOpTypes.HAS, key)
  end
  track(target, TrackOpTypes.HAS, rawKey)
  local has = getProto(target).has
  return has:call(target, key) or has:call(target, rawKey)
end

function size(target)
  target = toRaw(target)
  track(target, TrackOpTypes.ITERATE, ITERATE_KEY)
  return Reflect:get(getProto(target), 'size', target)
end

function add(this, value)
  value = toRaw(value)
  local target = toRaw(self)
  local proto = getProto(target)
  local hadKey = proto.has:call(target, value)
  local result = proto.add:call(target, value)
  if not hadKey then
    trigger(target, TriggerOpTypes.ADD, value, value)
  end
  return result
end

function set(this, key, value)
  value = toRaw(value)
  local target = toRaw(self)
  local  = getProto(target)
  local hadKey = has:call(target, key)
  if not hadKey then
    key = toRaw(key)
    hadKey = has:call(target, key)
  elseif __DEV__ then
    checkIdentityKeys(target, has, key)
  end
  local oldValue = get:call(target, key)
  local result = set:call(target, key, value)
  if not hadKey then
    trigger(target, TriggerOpTypes.ADD, key, value)
  elseif hasChanged(value, oldValue) then
    trigger(target, TriggerOpTypes.SET, key, value, oldValue)
  end
  return result
end

function deleteEntry(this, key)
  local target = toRaw(self)
  local  = getProto(target)
  local hadKey = has:call(target, key)
  if not hadKey then
    key = toRaw(key)
    hadKey = has:call(target, key)
  elseif __DEV__ then
    checkIdentityKeys(target, has, key)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处get需要确认
  local oldValue = (get and {get:call(target, key)} or {undefined})[1]
  local result = del:call(target, key)
  if hadKey then
    trigger(target, TriggerOpTypes.DELETE, key, undefined, oldValue)
  end
  return result
end

function clear(this)
  local target = toRaw(self)
  local hadItems = target.size ~= 0
  -- [ts2lua]lua中0和空字符串也是true，此处target:instanceof(Map)需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
  local oldTarget = (__DEV__ and {(target:instanceof(Map) and {Map(target)} or {Set(target)})[1]} or {undefined})[1]
  local result = getProto(target).clear:call(target)
  if hadItems then
    trigger(target, TriggerOpTypes.CLEAR, undefined, undefined, oldTarget)
  end
  return result
end

function createForEach(isReadonly, shallow)
  return function forEach(this, callback, thisArg)
    local observed = self
    local target = toRaw(observed)
    -- [ts2lua]lua中0和空字符串也是true，此处shallow需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
    local wrap = (isReadonly and {toReadonly} or {(shallow and {toShallow} or {toReactive})[1]})[1]
    not isReadonly and track(target, TrackOpTypes.ITERATE, ITERATE_KEY)
    function wrappedCallback(value, key)
      return callback:call(thisArg, wrap(value), wrap(key), observed)
    end
    
    return getProto(target).forEach:call(target, wrappedCallback)
  end
  

end

function createIterableMethod(method, isReadonly, shallow)
  return function(this, ...)
    local target = toRaw(self)
    local isMap = target:instanceof(Map)
    local isPair = method == 'entries' or method == Symbol.iterator and isMap
    local isKeyOnly = method == 'keys' and isMap
    -- [ts2lua]getProto(target)下标访问可能不正确
    local innerIterator = getProto(target)[method]:apply(target, args)
    -- [ts2lua]lua中0和空字符串也是true，此处shallow需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
    local wrap = (isReadonly and {toReadonly} or {(shallow and {toShallow} or {toReactive})[1]})[1]
    -- [ts2lua]lua中0和空字符串也是true，此处isKeyOnly需要确认
    not isReadonly and track(target, TrackOpTypes.ITERATE, (isKeyOnly and {MAP_KEY_ITERATE_KEY} or {ITERATE_KEY})[1])
    return {next=function()
      local  = innerIterator:next()
      -- [ts2lua]lua中0和空字符串也是true，此处isPair需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处done需要确认
      return (done and {{value=value, done=done}} or {{value=(isPair and {{wrap(value[0+1]), wrap(value[1+1])}} or {wrap(value)})[1], done=done}})[1]
    end
    , Symbol.iterator=function()
      return self
    end
    }
  end
  

end

function createReadonlyMethod(type)
  return function(this, ...)
    if __DEV__ then
      -- [ts2lua]lua中0和空字符串也是true，此处args[0+1]需要确认
      local key = (args[0+1] and {} or {})[1]
      console:warn(toRaw(self))
    end
    -- [ts2lua]lua中0和空字符串也是true，此处type == TriggerOpTypes.DELETE需要确认
    return (type == TriggerOpTypes.DELETE and {false} or {self})[1]
  end
  

end

local mutableInstrumentations = {get=function(this, key)
  return get(self, key, toReactive)
end
, size=function()
  return size(self)
end
, has=has, add=add, set=set, delete=deleteEntry, clear=clear, forEach=createForEach(false, false)}
local shallowInstrumentations = {get=function(this, key)
  return get(self, key, toShallow)
end
, size=function()
  return size(self)
end
, has=has, add=add, set=set, delete=deleteEntry, clear=clear, forEach=createForEach(false, true)}
local readonlyInstrumentations = {get=function(this, key)
  return get(self, key, toReadonly)
end
, size=function()
  return size(self)
end
, has=has, add=createReadonlyMethod(TriggerOpTypes.ADD), set=createReadonlyMethod(TriggerOpTypes.SET), delete=createReadonlyMethod(TriggerOpTypes.DELETE), clear=createReadonlyMethod(TriggerOpTypes.CLEAR), forEach=createForEach(true, false)}
local iteratorMethods = {'keys', 'values', 'entries', Symbol.iterator}
iteratorMethods:forEach(function(method)
  -- [ts2lua]mutableInstrumentations下标访问可能不正确
  mutableInstrumentations[method] = createIterableMethod(method, false, false)
  -- [ts2lua]readonlyInstrumentations下标访问可能不正确
  readonlyInstrumentations[method] = createIterableMethod(method, true, false)
  -- [ts2lua]shallowInstrumentations下标访问可能不正确
  shallowInstrumentations[method] = createIterableMethod(method, false, true)
end
)
function createInstrumentationGetter(isReadonly, shallow)
  -- [ts2lua]lua中0和空字符串也是true，此处isReadonly需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处shallow需要确认
  local instrumentations = (shallow and {shallowInstrumentations} or {(isReadonly and {readonlyInstrumentations} or {mutableInstrumentations})[1]})[1]
  return function(target, key, receiver)
    if key == ReactiveFlags.IS_REACTIVE then
      return not isReadonly
    elseif key == ReactiveFlags.IS_READONLY then
      return isReadonly
    elseif key == ReactiveFlags.RAW then
      return target
    end
    -- [ts2lua]lua中0和空字符串也是true，此处hasOwn(instrumentations, key) and target[key]需要确认
    return Reflect:get((hasOwn(instrumentations, key) and target[key] and {instrumentations} or {target})[1], key, receiver)
  end
  

end

local mutableCollectionHandlers = {get=createInstrumentationGetter(false, false)}
local shallowCollectionHandlers = {get=createInstrumentationGetter(false, true)}
local readonlyCollectionHandlers = {get=createInstrumentationGetter(true, false)}
function checkIdentityKeys(target, has, key)
  local rawKey = toRaw(key)
  if rawKey ~= key and has:call(target, rawKey) then
    local type = toRawType(target)
    console:warn( +  +  +  + )
  end
end
