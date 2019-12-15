local config = require("config")

local Observer = require("observer.Observer")
local Watcher = require("observer.Watcher")
local Dep = require("observer.Dep")
local Util = require("util.Util")
local Props = require("util.Props")
local pushTarget, popTarget = Dep.pushTarget, Dep.popTarget

local isUpdatingChildComponent = require("instance.Lifecycle").isUpdatingChildComponent

local tinsert, tremove = table.insert, table.remove
local type = type
local pairs = pairs
local ipairs = ipairs

local set, del, observe, defineReactive, toggleObserving =
    Observer.set,
    Observer.del,
    Observer.observe,
    Observer.defineReactive,
    Observer.toggleObserving

local validateProp = Props.validateProp

local warn,
    bind,
    noop,
    hasOwn,
    hyphenate,
    isReserved,
    handleError,
    nativeWatch,
    isPlainObject,
    isServerRendering,
    isReservedAttribute,
    createObject,
    defineProperty,
    isArray =
    Util.warn,
    Util.bind,
    Util.noop,
    Util.hasOwn,
    Util.hyphenate,
    Util.isReserved,
    Util.handleError,
    Util.nativeWatch,
    Util.isPlainObject,
    Util.isServerRendering,
    Util.isReservedAttribute,
    Util.createObject,
    Util.defineProperty,
    Util.isArray

local initState
local initProps
local initMethods
local initData
local initComputed
local initWatch
local defineComputed
local getData
local createComputedGetter
local createWatcher
local createGetterInvoker

---@param target Object
---@param sourceKey string
---@param key string
local function proxy(target, sourceKey, key)
    local getter = function()
        return target[sourceKey][key]
    end
    local setter = function(val)
        target[sourceKey][key] = val
    end
    defineProperty(target, key, getter, setter)
end

---@param vm Component
initState = function(vm)
    vm._watchers = {}
    local opts = vm._options
    if (opts.props) then
        initProps(vm, opts.props)
    end
    if (opts.methods) then
        initMethods(vm, opts.methods)
    end
    if (opts.data) then
        initData(vm)
    else
        vm._data = {}
        observe(vm._data, true --[[asRootData]])
    end
    if (opts.computed) then
        initComputed(vm, opts.computed)
    end
    if (opts.watch and opts.watch ~= nativeWatch) then
        initWatch(vm, opts.watch)
    end
end

---@param vm Component
initProps = function(vm, propsOptions)
    local propsData = vm._options.propsData or {}
    local props = {}
    vm._props = props
    -- cache prop keys so that future props updates can iterate using Array
    -- instead of dynamic object key enumeration.
    local keys = {}
    vm._options._propKeys = keys
    local isRoot = not vm._parent
    -- root instance props should be converted
    if (not isRoot) then
        toggleObserving(false)
    end
    for key in pairs(propsOptions) do
        tinsert(keys, key)
        local value = validateProp(key, propsOptions, propsData, vm)
        --[[ istanbul ignore else ]]
        if (config.env ~= "production") then
            local hyphenatedKey = hyphenate(key)
            if (isReservedAttribute(hyphenatedKey) or config.isReservedAttr(hyphenatedKey)) then
                warn('"_{hyphenatedKey}" is a reserved attribute and cannot be used as component prop.', vm)
            end
            defineReactive(
                props,
                key,
                value,
                function()
                    if (not isRoot and not isUpdatingChildComponent) then
                        warn(
                            "Avoid mutating a prop directly since the value will be " ..
                                "overwritten whenever the parent component re-renders. " ..
                                    "Instead, use a data or computed property based on the prop's " ..
                                        'value. Prop being mutated: "_{key}"',
                            vm
                        )
                    end
                end
            )
        else
            defineReactive(props, key, value)
        end
        -- static props are already proxied on the component's prototype
        -- during Vue.extend(). We only need to proxy props defined at
        -- instantiation here.
        if vm[key] == nil then
            proxy(vm, "_props", key)
        end
    end
    toggleObserving(true)
end

---@param Component
initData = function(vm)
    local data = vm._options.data
    data = (type(data) == "function" and getData(data, vm) or data) or {}
    vm._data = data

    if (not isPlainObject(data)) then
        data = {}
        if config.env ~= "production" then
            warn(
                "data functions should return an object:\n" +
                    "https:--vuejs.org/v2/guide/components.html#data-Must-Be-a-Function",
                vm
            )
        end
    end
    -- proxy data on instance
    local props = vm._options.props
    local methods = vm._options.methods
    for key in pairs(data) do
        if (config.env ~= "production") then
            if (methods and hasOwn(methods, key)) then
                warn('Method "_{key}" has already been defined as a data property.', vm)
            end
        end
        if (props and hasOwn(props, key)) then
            if config.env ~= "production" then
                warn(
                    'The data property "_{key}" is already declared as a prop. ' .. "Use prop default value instead.",
                    vm
                )
            end
        elseif (not isReserved(key)) then
            proxy(vm, "_data", key)
        end
    end
    -- observe data
    observe(data, true --[[ asRootData ]])
end

---@param data Function
---@param vm Component
getData = function(data, vm)
    -- #7573 disable dep collection when invoking data getters
    pushTarget()
    --   try {
    local ret = data(vm)
    --   } catch (e) {
    --     handleError(e, vm, 'data()')
    --     return {}
    --   } finally {
    popTarget()
    --   }

    return ret
end

local computedWatcherOptions = {lazy = true}

---@param vm Component
---@param computed table
initComputed = function(vm, computed)
    -- _flow-disable-line
    local watchers = {}
    vm._computedWatchers = watchers
    -- computed properties are just getters during SSR
    local isSSR = isServerRendering()

    for key, userDef in pairs(computed) do
        local getter = type(userDef) == "function" and userDef or userDef.get
        if (config.env ~= "production" and getter == nil) then
            warn('Getter is missing for computed property "_{key}".', vm)
        end

        if (not isSSR) then
            -- create internal watcher for the computed property.
            watchers[key] = Watcher.new(vm, getter or noop, noop, computedWatcherOptions)
        end

        -- component-defined computed properties are already defined on the
        -- component prototype. We only need to define computed properties defined
        -- at instantiation here.
        if vm[key] == nil then
            defineComputed(vm, key, userDef)
        elseif (config.env ~= "production") then
            if vm._data[key] ~= nil then
                warn('The computed property "_{key}" is already defined in data.', vm)
            elseif (vm._options.props and vm._options.props[key] ~= nil) then
                warn('The computed property "_{key}" is already defined as a prop.', vm)
            end
        end
    end
end

---@param key string
---@param userDef Object | Function
defineComputed = function(target, key, userDef)
    local shouldCache = not isServerRendering()

    local getter, setter
    if (type(userDef) == "function") then
        getter = shouldCache and createComputedGetter(key) or createGetterInvoker(userDef)
        setter = noop
    else
        getter =
            userDef.get and
            ((shouldCache and userDef.cache ~= false) and createComputedGetter(key) or createGetterInvoker(userDef.get)) or
            noop
        setter = userDef.set or noop
    end
    if (config.env ~= "production" and setter == noop) then
        setter = function(self)
            warn('Computed property "' .. key .. '" was assigned to but it has no setter.', self)
        end
    end
    defineProperty(target, key, getter, setter)
end

createComputedGetter = function(key)
    return function(self)
        local watcher = self._computedWatchers and self._computedWatchers[key]
        if (watcher) then
            if (watcher.dirty) then
                watcher:evaluate()
            end
            if (Dep.target) then
                watcher:depend()
            end
            return watcher.value
        end
    end
end

createGetterInvoker = function(fn)
    return function(self)
        return fn(self)
    end
end

---@param vm Component
initMethods = function(vm, methods)
    local props = vm._options.props
    for key, method in pairs(methods) do
        if (config.env ~= "production") then
            if (type(method) ~= "function") then
                warn(
                    'Method "_{' .. key .. '}" has type "_{' .. type(method) .. '}" in the component definition. ' ..
                        "Did you reference the function correctly?",
                    vm
                )
            end
            if (props and hasOwn(props, key)) then
                warn('Method "_{' .. key .. '}" has already been defined as a prop.', vm)
            end
            if (vm[key] ~= nil and isReserved(key)) then
                warn(
                    'Method "_{' .. key .. '}" conflicts with an existing Vue instance method. ' ..
                        "Avoid defining component methods that start with _ or _."
                )
            end
        end
        vm[key] = type(method) ~= "function" and noop or method
    end
end

---@param vm Component
initWatch = function(vm, watch)
    for key, handler in pairs(watch) do
        if (isArray(handler)) then
            for i = 1, #handler do
                createWatcher(vm, key, handler[i])
            end
        else
            createWatcher(vm, key, handler)
        end
    end
end

---@param vm Component
---@param expOrFn string | Function
---@param handler any
---@param options Object
createWatcher = function(vm, expOrFn, handler, options)
    if (isPlainObject(handler)) then
        options = handler
        handler = handler.handler
    end
    if (type(handler) == "string") then
        handler = vm[handler]
    end
    return vm:_watch(expOrFn, handler, options)
end

---@param Vue Vue
local function stateMixin(Vue)
    -- flow somehow has problems with directly declared definition object
    -- when using Object.defineProperty, so we have to procedurally build up
    -- the object here.

    -- local dataDefget = function (self) return self._data end
    -- local propsDefget = function (self) return self._props end
    -- local dataDefset
    -- local propsDefset
    -- if (config.env ~= 'production') then
    --     dataDefset = function (self)
    --         warn(
    --         'Avoid replacing instance root _data. ' +
    --         'Use nested data properties instead.',
    --         self
    --         )
    --     end
    --     propsDefset = function (self)
    --         warn('_props is readonly.', self)
    --     end
    -- end
    -- defineProperty(Vue, '_data', dataDefget, dataDefset)
    -- defineProperty(Vue, '_props', propsDefget, propsDefset)

    Vue.prototype._set = set
    Vue.prototype._delete = del

    function Vue.prototype:_watch(expOrFn, cb, options)
        ---@type Component
        local vm = self
        if (isPlainObject(cb)) then
            return createWatcher(vm, expOrFn, cb, options)
        end
        options = options or {}
        options.user = true
        local watcher = Watcher.new(vm, expOrFn, cb, options)
        if (options.immediate) then
            --   try {
            cb(vm, watcher.value)
        --   end catch (error) {
        --     handleError(error, vm, 'callback for immediate watcher "_{watcher.expressionend"')
        --   end
        end
        return function()
            watcher:teardown()
        end
    end
end

return {
    proxy = proxy,
    getData = getData,
    defineComputed = defineComputed,
    initState = initState,
    stateMixin = stateMixin
}
