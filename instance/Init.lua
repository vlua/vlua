local config = require("config")
local Perf = require("util.Perf")
local State = require("instance.State")
local Proxy = require("instance.Proxy")
local Events = require("instance.Events")
local Lifecycle = require("instance.Lifecycle")
local Inject = require("instance.Inject")
local Options = require("util.Options")
local Util = require("util.Util")
local Events = require("instance.Events")
local callHook = Events.callHook
local initProxy = Proxy.initProxy

local initState = State.initState
--local initRender = './render'
local initEvents = Events.initEvents
local mark, measure = Perf.mark, Perf.measure
local initLifecycle = Lifecycle.initLifecycle
local initProvide, initInjections = Inject.initProvide, Inject.initInjections
local extend, mergeOptions, formatComponentName, createObject =
    Util.extend,
    Options.mergeOptions,
    Util.formatComponentName,
    Util.createObject

local uid = 0

local initMixin
local initInternalComponent
local resolveConstructorOptions
local resolveModifiedOptions

---@param Vue Vue
initMixin = function(Vue)
    function Vue.prototype:_init(options)
        ---@type Component
        local vm = self
        -- a uid
        uid = uid + 1
        vm._uid = uid

        local startTag, endTag
        --[[ istanbul ignore if ]]
        if (config.env ~= "production" and config.performance and mark) then
            startTag = "vue-perf-start:${vm._uid}"
            endTag = "vue-perf-end:${vm._uid}"
            mark(startTag)
        end

        -- a flag to avoid self being observed
        vm._isVue = true
        -- merge options
        if (options and options._isComponent) then
            -- optimize internal component instantiation
            -- since dynamic options merging is pretty slow, and none of the
            -- internal component options needs special treatment.
            initInternalComponent(vm, options)
        else
            vm._options = mergeOptions(resolveConstructorOptions(vm.__proto), options or {}, vm)
        end
        --[[ istanbul ignore else ]]
        if (config.env ~= "production") then
            initProxy(vm)
        else
            vm._renderProxy = vm
        end
        -- expose real self
        vm._self = vm
        initLifecycle(vm)
        initEvents(vm)
        --initRender(vm)
        callHook(vm, "beforeCreate")
        initInjections(vm) -- resolve injections before data/props
        initState(vm)
        initProvide(vm) -- resolve provide after data/props
        callHook(vm, "created")

        --[[ istanbul ignore if ]]
        if (config.env ~= "production" and config.performance and mark) then
            vm._name = formatComponentName(vm, false)
            mark(endTag)
            measure("vue ${vm._name} init", startTag, endTag)
        end

        if vm._options.el then
            vm:_mount(vm._options.el)
        end
    end
end

---@param vm Component
---@param options InternalComponentOptions
initInternalComponent = function(vm, options)
    local opts = createObject(vm.__proto.options)
    vm._options = opts
    -- doing self because it's faster than dynamic enumeration.
    local parentVnode = options._parentVnode
    opts.parent = options.parent
    opts._parentVnode = parentVnode

    local vnodeComponentOptions = parentVnode.componentOptions
    opts.propsData = vnodeComponentOptions.propsData
    opts._parentListeners = vnodeComponentOptions.listeners
    opts._renderChildren = vnodeComponentOptions.children
    opts._componentTag = vnodeComponentOptions.tag

    if (options.render) then
        opts.render = options.render
        opts.staticRenderFns = options.staticRenderFns
    end
end

---@param Ctor Component
resolveConstructorOptions = function(Ctor)
    local options = Ctor.options
    if (Ctor.super) then
        local superOptions = resolveConstructorOptions(Ctor.super)
        local cachedSuperOptions = Ctor.superOptions
        if (superOptions ~= cachedSuperOptions) then
            -- super option changed,
            -- need to resolve new options.
            Ctor.superOptions = superOptions
            -- check if there are any late-modified/attached options (#4976)
            local modifiedOptions = resolveModifiedOptions(Ctor)
            -- update base extend options
            if (modifiedOptions) then
                extend(Ctor.extendOptions, modifiedOptions)
            end
            options = mergeOptions(superOptions, Ctor.extendOptions)
            Ctor.options = options
            if (options.name) then
                options.components[options.name] = Ctor
            end
        end
    end
    return options
end

---@param Component
resolveModifiedOptions = function(Ctor)
    local modified
    local latest = Ctor.options
    local sealed = Ctor.sealedOptions
    for key, value in pairs(latest) do
        if (value ~= sealed[key]) then
            if (not modified) then
                modified = {}
            end
            modified[key] = value
        end
    end
    return modified
end

return {
    initMixin = initMixin
}
