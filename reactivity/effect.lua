local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs, tinsert,xpcall = type, ipairs, pairs, table.insert,xpcall

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, EMPTY_OBJ, isFunction,traceback =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.EMPTY_OBJ,
    reactiveUtils.isFunction,
    reactiveUtils.traceback

-- The main WeakMap that stores {target -> key -> dep} connections.
-- Conceptually, it's easier to think of a dependency as a Dep class
-- which maintains a Set of subscribers, but we simply store them as
-- raw Sets to reduce memory overhead.
local targetMap = setmetatable({}, {__mode = "k"})

local effectStack = {}
local activeEffect = nil
local ITERATOR_KEY = "iterator"
local shouldTrack = true
local trackStack = {}
local uid = 0

local function isEffect(fn)
    return fn and fn._isEffect == true
end

local function pauseTracking()
    tinsert(trackStack, shouldTrack)
    shouldTrack = false
end

local function enableTracking()
    tinsert(trackStack, shouldTrack)
    shouldTrack = true
end

local function resetTracking()
    local last = trackStack:pop()
    shouldTrack = last == nil and true or last
end

local function cleanup(effect)
    local deps = {effect}
    if #deps then
        local i = 0
        repeat
            deps[i + 1]:delete(effect)
            i = i + 1
        until not (i < #deps)
        -- [ts2lua]修改数组长度需要手动处理。
        deps.length = 0
    end
end

local function createReactiveEffect(fn, options)
    local effect  = {}
    effect.run = function(...)
        if not effect.active then
            if options.scheduler then
                return nil
            else
                return return fn(...)
            end
        end
        if not effectStack:includes(effect) then
            cleanup(effect)
            xpcall(function()
                    enableTracking()
                    tinsert(effectStack, effect)
                    activeEffect = effect
                    return fn(...)
                end, traceback)
                
            effectStack:pop()
            resetTracking()
            activeEffect = effectStack[#effectStack - 1]
        end
    end

    uid = uid + 1
    effect.id = uid
    effect._isEffect = true
    effect.active = true
    effect.raw = fn
    effect.deps = {}
    effect.options = options
    return effect
end

local function effect(fn, options)
    if options == nil then
        options = EMPTY_OBJ
    end
    if isEffect(fn) then
        fn = fn.raw
    end
    local effect = createReactiveEffect(fn, options)
    if not options.lazy then
        effect.run()
    end
    return effect.run
end

local function stop(effect)
    if effect.active then
        cleanup(effect)
        if effect.options.onStop then
            effect.options:onStop()
        end
        effect.active = false
    end
end


local function track(target, type, key)
    if not shouldTrack or activeEffect == nil then
        return
    end
    local depsMap = targetMap[target]
    if not depsMap then
        depsMap = {}
        targetMap[target] = depsMap
    end
    local dep = depsMap[key]
    if not dep then
        dep = {}
        depsMap[key] = dep
    end
    if not dep[activeEffect] then
        dep[activeEffect] = true
        tinsert(activeEffect.deps, dep)
        if __DEV__ and activeEffect.options.onTrack then
            activeEffect.options:onTrack({effect = activeEffect, target = target, type = type, key = key})
        end
    end
end

local function trigger(target, type, key, newValue, oldValue, oldTarget)
    local depsMap = targetMap[target]
    if not depsMap then
        -- never been tracked
        return
    end
    local effects = {}
    local add = function(effectsToAdd)
        if effectsToAdd then
            for _, effect in ipairs(effectsToAdd) do
                if effect ~= activeEffect or not shouldTrack then
                    effects:add(effect)
                -- the effect mutated its own dependency during its execution.
                -- this can be caused by operations like foo.value++
                -- do not trigger or we end in an infinite loop
                end
            end
        end
    end

    if type == TriggerOpTypes.CLEAR then
        -- collection being cleared
        -- trigger all effects for target
        for _,v in pairs(depsMap) do
            add(v)
        end
    else
        -- schedule runs for SET | ADD | DELETE
        if key ~= nil then
            add(depsMap[key])
        end
        -- also run for iteration key on ADD | DELETE | Map.SET
        if type == TriggerOpTypes.ADD or type == TriggerOpTypes.DELETE then
            add(depsMap[ITERATOR_KEY])
        end
    end

    for _, effect in ipairs(effects) do
        if __DEV__ and effect.options.onTrigger then
            effect.options:onTrigger(
                {
                    effect = effect,
                    target = target,
                    key = key,
                    type = type,
                    newValue = newValue,
                    oldValue = oldValue,
                    oldTarget = oldTarget
                }
            )
        end
        if effect.options.scheduler then
            effect.options:scheduler(effect)
        else
            effect()
        end
    end
end

return {
    trigger = trigger,
    track = track,
    stop = stop,
    ITERATOR_KEY = ITERATOR_KEY,
}
