local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")
local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")

local Effect = require("reactivity.effect")
local track, trigger, IPAIR_KEY, PAIR_KEY, effect =
    Effect.track,
    Effect.trigger,
    Effect.IPAIR_KEY,
    Effect.PAIR_KEY,
    Effect.effect

local V_GETTER, V_SETTER, SKIP, IS_REACTIVE, IS_SHALLOW, IS_READONLY, RAW, REACTIVE, READONLY, DEPSMAP, IS_REF =
    ReactiveFlags.V_GETTER,
    ReactiveFlags.V_SETTER,
    ReactiveFlags.SKIP,
    ReactiveFlags.IS_REACTIVE,
    ReactiveFlags.IS_SHALLOW,
    ReactiveFlags.IS_READONLY,
    ReactiveFlags.RAW,
    ReactiveFlags.REACTIVE,
    ReactiveFlags.READONLY,
    ReactiveFlags.DEPSMAP,
    ReactiveFlags.IS_REF

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs, setmetatable = type, ipairs, pairs, setmetatable

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, isFunction =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.isFunction

local function computed(getter, setter)
    local dirty = true
    local value = nil
    local computed = nil
    local runner =
        effect(
        function(effect, target, type, key, newValue, oldValue)
            return getter(target)
        end,
        {
            lazy = true,
            -- mark effect as computed so that it gets priority during trigger
            scheduler = function(effect, target, type, key, newValue, oldValue)
                if not dirty then
                    dirty = true
                    trigger(computed, TriggerOpTypes.SET, "value", newValue, oldValue)
                end
            end
        }
    )

    local getterImpl = function(self)
        if dirty then
            value = runner(runner, self)
            dirty = false
        end
        track(computed, TrackOpTypes.GET, "value")
        return value
    end

    local setterImpl
    if not setter then
        setterImpl = function(self)
            warn("readonly computed value")
        end
    else
        setterImpl = setter
    end

    local RefMetatable = {
        [IS_READONLY] = (setter == nil),
        [IS_SHALLOW] = false,
        [IS_REACTIVE] = true,
        __index = function(self, key)
            assert(key == "value", 'only access Ref getter with "value" key')
            return getter()
        end,
        __newindex = function(self, key, newValue)
            assert(key == "value", 'only access Ref setter with "value" key')
            setter(self, newValue)
        end
    }
    computed = {
        [V_GETTER] = getterImpl,
        [V_SETTER] = setterImpl,
        [IS_REF] = true,
        -- expose effect so computed can be stopped
        effect = runner
    }
    setmetatable(computed, RefMetatable)
    return computed
end

return {
    computed = computed
}
