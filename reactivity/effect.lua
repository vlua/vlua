local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")
local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local SET, ADD, DELETE = TriggerOpTypes.SET, TriggerOpTypes.ADD, TriggerOpTypes.DELETE

local assert, getmetatable, setmetatable, type, ipairs, pairs, tinsert, xpcall, tremove, tunpack =
    assert,
    getmetatable,
    setmetatable,
    type,
    ipairs,
    pairs,
    table.insert,
    xpcall,
    table.remove,
    table.unpack
local V_GETTER, V_SETTER, IS_REF, DEPSMAP =
    ReactiveFlags.V_GETTER,
    ReactiveFlags.V_SETTER,
    ReactiveFlags.IS_REF,
    ReactiveFlags.DEPSMAP

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, EMPTY_OBJ, isFunction, traceback, array_includes =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.EMPTY_OBJ,
    reactiveUtils.isFunction,
    reactiveUtils.traceback,
    reactiveUtils.array_includes

local effectStack = {}
local activeEffect = nil
local ITERATE_KEY = "iterate"
local shouldTrack = true
local trackStack = {}
local uid = 0

local function isEffect(fn)
    return type(fn) == "table" and fn._isEffect == true
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
    local last = tremove(trackStack)
    shouldTrack = last == nil and true or last
end

local function cleanup(effect)
    if #effect.deps > 0 then
        for i, v in ipairs(effect.deps) do
            v[effect] = nil
        end

        effect.deps = {}
    end
end

local function createReactiveEffect(fn, options)
    local effect = {}
    local run = function(self, ...)
        if not effect.active then
            if options.scheduler then
                return nil
            else
                return fn(...)
            end
        end
        if not array_includes(effectStack, effect) then
            cleanup(effect)
            enableTracking()
            tinsert(effectStack, effect)
            activeEffect = effect

            local result, ret = xpcall(fn, traceback, ...)

            tremove(effectStack)
            resetTracking()
            activeEffect = effectStack[#effectStack]
            return ret
        end
    end

    uid = uid + 1
    effect.id = uid
    effect._isEffect = true
    effect.active = true
    effect.raw = fn
    effect.deps = {}
    effect.options = options
    effect.__call = run
    setmetatable(effect, effect)
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
        effect()
    end
    return effect
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

local function track(target, trackType, key)
    if not shouldTrack or activeEffect == nil or type(target) ~= 'table' then
        return
    end
    local mt = getmetatable(target)
    assert(mt)
    local depsMap = mt[DEPSMAP]
    if not depsMap then
        depsMap = {}
        mt[DEPSMAP] = depsMap
    end
    local dep = depsMap[key]
    if not dep then
        dep = {}
        depsMap[key] = dep
    end
    if not dep[activeEffect] then
        dep[activeEffect] = activeEffect
        tinsert(activeEffect.deps, dep)
        if __DEV__ and activeEffect.options.onTrack then
            activeEffect.options.onTrack(activeEffect, target, trackType, key)
        end
    end
end

local function trigger(target, triggerType, key, newValue, oldValue)
    local mt = getmetatable(target)
    assert(mt)
    local depsMap = mt[DEPSMAP]
    if not depsMap then
        -- never been tracked
        return
    end
    local effects = {}
    local add = function(effectsToAdd)
        if effectsToAdd then
            for effect in pairs(effectsToAdd) do
                if effect ~= activeEffect or not shouldTrack then
                    effects[effect] = true
                -- the effect mutated its own dependency during its execution.
                -- this can be caused by operations like foo.value++
                -- do not trigger or we end in an infinite loop
                end
            end
        end
    end

    -- if type == CLEAR then
    --     -- collection being cleared
    --     -- trigger all effects for target
    --     for _, v in pairs(depsMap) do
    --         add(v)
    --     end
    -- else
        -- end
        -- schedule runs for SET | ADD | DELETE
        if key ~= nil then
            add(depsMap[key])
        end
        -- also run for iteration key on ADD | DELETE | Map.SET
        -- if type == ADD or type == DELETE then
        -- 不管是添加/删除/修改，只要是使用pairs或ipairs迭代过的，都要触发
        add(depsMap[ITERATE_KEY])
    -- end

    for effect in pairs(effects) do
        if __DEV__ and effect.options.onTrigger then
            effect.options.onTrigger(effect, target, triggerType, key, newValue, oldValue)
        end
        if effect.options.scheduler then
            effect.options.scheduler(effect, target, triggerType, key, newValue, oldValue)
        else
            effect(effect, target, triggerType, key, newValue, oldValue)
        end
    end
end

return {
    trigger = trigger,
    track = track,
    stop = stop,
    effect = effect,
    ITERATE_KEY = ITERATE_KEY
}
