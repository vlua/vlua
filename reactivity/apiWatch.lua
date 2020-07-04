local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")
local ErrorCodes = require("reactivity.ErrorCodes")
local Effect = require("reactivity.effect")
local track, trigger, ITERATE_KEY, stop, effect =
    Effect.track,
    Effect.trigger,
    Effect.ITERATE_KEY,
    Effect.stop,
    Effect.effect

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs, tinsert = type, ipairs, pairs, table.insert

local scheduler = require("reactivity.scheduler")
local queueJob, queuePostFlushCb = scheduler.queueJob, scheduler.queuePostFlushCb

local reactiveUtils = require("reactivity.reactiveUtils")
local isFunction, isObject, hasChanged, extend, warn, callWithErrorHandling, callWithAsyncErrorHandling, NOOP =
    reactiveUtils.isFunction,
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.callWithErrorHandling,
    reactiveUtils.callWithAsyncErrorHandling,
    reactiveUtils.NOOP

local reactive = require("reactivity.reactive")
local ref = require("reactivity.ref")(reactive)

local isReactive = reactive.isReactive
local isRef = ref.isRef

-- initial value for watchers to trigger on nil initial values
local INITIAL_WATCHER_VALUE = {}

local invoke = function(fn)
    fn()
end

local function traverse(value, seen)
    if seen == nil then
        seen = {}
    end
    if not isObject(value) or seen[value] then
        return value
    end
    seen[value] = true
    -- if isArray(value) then
    --     local i = 0
    --     repeat
    --         traverse(value[i + 1], seen)
    --         i = i + 1
    --     until not (i < #value)
    -- elseif value:instanceof(Map) then
    --     value:forEach(
    --         function(v, key)
    --             -- to register mutation dep for existing keys
    --             traverse(value:get(key), seen)
    --         end
    --     )
    -- elseif value:instanceof(Set) then
    --     value:forEach(
    --         function(v)
    --             traverse(v, seen)
    --         end
    --     )
    -- else
    for key in pairs(value) do
        -- [ts2lua]value下标访问可能不正确
        traverse(value[key], seen)
    end
    -- end
    return value
end

local function doWatch(multiSource, source, cb, options)
    local immediate, deep, flush, onTrack, onTrigger
    if options then
        immediate, deep, flush, onTrack, onTrigger =
            options.immediate,
            options.deep,
            options.flush,
            options.onTrack,
            options.onTrigger
    end
    if __DEV__ and not cb then
        if immediate ~= nil then
            warn(
                [[`watch() "immediate" option is only respected when using the ` +
          `watch(source, callback, options?) signature.`]]
            )
        end
        if deep ~= nil then
            warn(
                [[`watch() "deep" option is only respected when using the ` +
          `watch(source, callback, options?) signature.`]]
            )
        end
    end
    local warnInvalidSource = function(s)
        warn(
            [[`Invalid watch source: `,
      s,
      `A watch source can only be a getter/effect function, a ref, ` +
        `a reactive object, or an array of these types.`]]
        )
    end

    local cleanup = NOOP
    local instance = currentInstance
    local onInvalidate
    local runner
    local getter = nil

    if multiSource then
        getter = function()
            local result = {}
            for _, s in ipairs(source) do
                if isRef(s) then
                    tinsert(result, s.value)
                elseif isReactive(s) then
                    tinsert(result, traverse(s))
                elseif isFunction(s) then
                    tinsert(result, callWithErrorHandling(s, instance, ErrorCodes.WATCH_GETTER))
                else
                    if __DEV__ then
                        warnInvalidSource(s)
                    end
                end
            end
            return result
        end
    elseif isFunction(source) then
        if cb then
            -- getter with cb
            getter = function()
                return callWithErrorHandling(source, instance, ErrorCodes.WATCH_GETTER)
            end
        else
            -- no cb -> simple effect
            getter = function()
                if instance and instance.isUnmounted then
                    return
                end
                if cleanup then
                    cleanup()
                end
                return callWithErrorHandling(source, instance, ErrorCodes.WATCH_CALLBACK, onInvalidate)
            end
        end
    elseif isRef(source) then
        getter = function()
            return source.value
        end
    elseif isReactive(source) then
        getter = function()
            return source
        end
        deep = true
    else
        getter = NOOP
        if __DEV__ then
            warnInvalidSource(source)
        end
    end

    if cb and deep then
        local baseGetter = getter
        getter = function()
            return traverse(baseGetter())
        end
    end
    onInvalidate = function(fn)
        runner.options.onStop = function()
            callWithErrorHandling(fn, instance, ErrorCodes.WATCH_CLEANUP)
        end

        cleanup = runner.options.onStop
    end

    -- in SSR there is no need to setup an actual effect, and it should be noop
    -- unless it's eager
    -- if __NODE_JS__ and isInSSRComponentSetup then
    --     if not cb then
    --         getter()
    --     elseif immediate then
    --         callWithAsyncErrorHandling(cb, instance, ErrorCodes.WATCH_CALLBACK, {getter(), nil, onInvalidate})
    --     end
    --     return NOOP
    -- end
    local oldValue = (multiSource and {} or INITIAL_WATCHER_VALUE)
    local applyCb =
        (cb and
        function()
            if instance and instance.isUnmounted then
                return
            end
            local newValue = runner()
            if deep or hasChanged(newValue, oldValue) then
                -- cleanup before running cb again
                if cleanup then
                    cleanup()
                end
                callWithAsyncErrorHandling(
                    cb,
                    instance,
                    ErrorCodes.WATCH_CALLBACK,
                    newValue,
                    -- pass nil as the old value when it's changed for the first time
                    (oldValue ~= INITIAL_WATCHER_VALUE and oldValue or nil),
                    onInvalidate
                )
                oldValue = newValue
            end
        end or
        nil)
    local scheduler = nil
    if flush == "sync" then
        scheduler = invoke
    elseif flush == "pre" then
        scheduler = function(job)
            if not instance or instance.isMounted then
                queueJob(job)
            else
                -- with 'pre' option, the first call must happen before
                -- the component is mounted so it is called synchronously.
                job()
            end
        end
    else
        scheduler = function(job)
            queuePostFlushCb(job, instance and instance.suspense)
        end
    end
    runner =
        effect(
        getter,
        {
            lazy = true,
            -- so it runs before component update effects in pre flush mode
            computed = true,
            onTrack = onTrack,
            onTrigger = onTrigger,
            scheduler = (applyCb and function()
                    scheduler(applyCb)
                end or scheduler)
        }
    )
    -- recordInstanceBoundEffect(runner)

    -- initial run
    if applyCb then
        if immediate then
            applyCb()
        else
            oldValue = runner()
        end
    else
        runner()
    end
    return function()
        stop(runner)
        if instance then
            remove(instance.effects, runner)
        end
    end
end

local function watchEffect(effect, options)
    return doWatch(false, effect, nil, options)
end

-- overload #1: array of multiple sources + cb
-- Readonly constraint helps the callback to correctly infer value types based
-- on position in the source array. Otherwise the values will get a union type
-- of all possible value types.
-- overload #2: single source + cb
-- overload #3: watching reactive object w/ cb
-- implementation
local function watch(source, cb, options)
    if __DEV__ and not isFunction(cb) then
        warn(
            [[`\`watch(fn, options?)\` signature has been moved to a separate API. ` +
      `Use \`watchEffect(fn, options?)\` instead. \`watch\` now only ` +
      `supports \`watch(source, cb, options?) signature.`]]
        )
    end
    return doWatch(false, source, cb, options)
end

-- this.$watch
local function instanceWatch(this, source, cb, options)
    local publicThis = self.proxy
    local getter = type(source) == "string" and function()
            return publicThis[source]
        end or source:bind(publicThis)
    local stop = watch(getter, cb:bind(publicThis), options)
    onBeforeUnmount(stop, self)
    return stop
end

return {
    watch = watch,
    instanceWatch = instanceWatch
}
