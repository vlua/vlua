local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local effect = require("reactivity.effect")
local track, trigger, IPAIR_KEY, PAIR_KEY, createEffect = effect.track, effect.trigger, effect.IPAIR_KEY, effect.PAIR_KEY, effect.createEffect

local ref = require("reactivity.ref")
local isRef = ref.isRef

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs = type, ipairs, pairs

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, isFunction =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.isFunction

local function computed(getterOrOptions)
    local getter = nil
    local setter = nil
    if isFunction(getterOrOptions) then
        getter = getterOrOptions
        setter = __DEV__ and function()
                warn("Write operation failed: computed value is readonly")
            end or NOOP
    else
        getter = getterOrOptions.get
        setter = getterOrOptions.set
    end
    local dirty = true
    local value = nil
    local computed = nil
    local runner =
        createEffect(
        getter,
        {
            lazy = true,
            -- mark effect as computed so that it gets priority during trigger
            scheduler = function()
                if not dirty then
                    dirty = true
                    trigger(computed, TriggerOpTypes.SET, "value")
                end
            end
        }
    )
    computed = {
        __v_isRef = true,
        -- expose effect so computed can be stopped
        effect = runner,
        value = function()
            if dirty then
                value = runner()
                dirty = false
            end
            track(computed, TrackOpTypes.GET, "value")
            return value
        end,
        value = function(newValue)
            setter(newValue)
        end
    }
    return computed
end

return {
    computed = computed
}