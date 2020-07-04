require("trycatch")
require("reactivity/src/operations/TriggerOpTypes")
require("@vue/shared")

local targetMap = WeakMap()
local effectStack = {}
local activeEffect = nil
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local ITERATE_KEY = Symbol((__DEV__ and {'iterate'} or {''})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local MAP_KEY_ITERATE_KEY = Symbol((__DEV__ and {'Map key iterate'} or {''})[1])
function isEffect(fn)
  return fn and fn._isEffect == true
end

function effect(fn, options)
  if options == nil then
    options=EMPTY_OBJ
  end
  if isEffect(fn) then
    fn = fn.raw
  end
  local effect = createReactiveEffect(fn, options)
  if not options.lazy then
    effect()
  end
  return effect
end

function stop(effect)
  if effect.active then
    cleanup(effect)
    if effect.options.onStop then
      effect.options:onStop()
    end
    effect.active = false
  end
end

local uid = 0
function createReactiveEffect(fn, options)
  local effect = function reactiveEffect(...)
    if not effect.active then
      -- [ts2lua]lua中0和空字符串也是true，此处options.scheduler需要确认
      return (options.scheduler and {undefined} or {fn(...)})[1]
    end
    if not effectStack:includes(effect) then
      cleanup(effect)
      try_catch{
        main = function()
          enableTracking()
          table.insert(effectStack, effect)
          activeEffect = effect
          return fn(...)
        end,
        finally = function()
          effectStack:pop()
          resetTracking()
          -- [ts2lua]effectStack下标访问可能不正确
          activeEffect = effectStack[#effectStack - 1]
        end
      }
    end
  end
  
  effect.id = uid=uid+1
  effect._isEffect = true
  effect.active = true
  effect.raw = fn
  effect.deps = {}
  effect.options = options
  return effect
end

function cleanup(effect)
  local  = effect
  if #deps then
    local i = 0
    repeat
      deps[i+1]:delete(effect)
      i=i+1
    until not(i < #deps)
    -- [ts2lua]修改数组长度需要手动处理。
    deps.length = 0
  end
end

local shouldTrack = true
local trackStack = {}
function pauseTracking()
  table.insert(trackStack, shouldTrack)
  shouldTrack = false
end

function enableTracking()
  table.insert(trackStack, shouldTrack)
  shouldTrack = true
end

function resetTracking()
  local last = trackStack:pop()
  -- [ts2lua]lua中0和空字符串也是true，此处last == undefined需要确认
  shouldTrack = (last == undefined and {true} or {last})[1]
end

function track(target, type, key)
  if not shouldTrack or activeEffect == undefined then
    return
  end
  local depsMap = targetMap:get(target)
  if not depsMap then
    targetMap:set(target, depsMap)
  end
  local dep = depsMap:get(key)
  if not dep then
    depsMap:set(key, dep)
  end
  if not dep:has(activeEffect) then
    dep:add(activeEffect)
    table.insert(activeEffect.deps, dep)
    if __DEV__ and activeEffect.options.onTrack then
      activeEffect.options:onTrack({effect=activeEffect, target=target, type=type, key=key})
    end
  end
end

function trigger(target, type, key, newValue, oldValue, oldTarget)
  local depsMap = targetMap:get(target)
  if not depsMap then
    return
  end
  local effects = Set()
  local add = function(effectsToAdd)
    if effectsToAdd then
      effectsToAdd:forEach(function(effect)
        if effect ~= activeEffect or not shouldTrack then
          effects:add(effect)
        end
      end
      )
    end
  end
  
  if type == TriggerOpTypes.CLEAR then
    depsMap:forEach(add)
  elseif key == 'length' and isArray(target) then
    depsMap:forEach(function(dep, key)
      if key == 'length' or key >= newValue then
        add(dep)
      end
    end
    )
  else
    if key ~= undefined then
      add(depsMap:get(key))
    end
    local isAddOrDelete = type == TriggerOpTypes.ADD or type == TriggerOpTypes.DELETE and not isArray(target)
    if isAddOrDelete or type == TriggerOpTypes.SET and target:instanceof(Map) then
      -- [ts2lua]lua中0和空字符串也是true，此处isArray(target)需要确认
      add(depsMap:get((isArray(target) and {'length'} or {ITERATE_KEY})[1]))
    end
    if isAddOrDelete and target:instanceof(Map) then
      add(depsMap:get(MAP_KEY_ITERATE_KEY))
    end
  end
  local run = function(effect)
    if __DEV__ and effect.options.onTrigger then
      effect.options:onTrigger({effect=effect, target=target, key=key, type=type, newValue=newValue, oldValue=oldValue, oldTarget=oldTarget})
    end
    if effect.options.scheduler then
      effect.options:scheduler(effect)
    else
      effect()
    end
  end
  
  effects:forEach(run)
end
