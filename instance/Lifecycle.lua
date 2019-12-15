local config = require("config")
local Watcher = require("observer.Watcher")
local Observer = require("observer.Observer")
local Perf = require("util.Perf")
local Util = require("util.Util")
local Events = require("instance.Events")
local mark, measure = Perf.mark, Perf.measure
--local createEmptyVNode } from '../vdom/vnode'
local updateComponentListeners = Events.updateComponentListeners
--local  resolveSlots } from './render-helpers/resolve-slots'
local toggleObserving = Observer.toggleObserving
local tinsert, tremove = table.insert, table.remove

local callHook = Events.callHook
local warn, noop, remove, emptyObject, validateProp =
    Util.warn,
    Util.noop,
    Util.remove,
    Util.emptyObject,
    Util.validateProp

local activeInstance = nil
local isUpdatingChildComponent = false

local isInInactiveTree
local mountComponent

---@param vm Component
local function setActiveInstance(vm)
    local prevActiveInstance = activeInstance
    activeInstance = vm
    return function()
        activeInstance = prevActiveInstance
    end
end

---@param vm Component
local function initLifecycle(vm)
    local options = vm._options

    -- locate first non-abstract parent
    local parent = options.parent
    if (parent and not options.abstract) then
        while (parent._options.abstract and parent._parent) do
            parent = parent._parent
        end
        tinsert(parent._children, vm)
    end

    vm._parent = parent
    vm._root = parent and parent._root or vm

    vm._children = {}
    vm._refs = {}

    vm._watcher = nil
    vm._inactive = nil
    vm._directInactive = false
    vm._isMounted = false
    vm._isDestroyed = false
    vm._isBeingDestroyed = false
end

---@param Vue Vue
local function lifecycleMixin(Vue)
    ---@param vnode VNode
    ---@param hydrating boolean
    function Vue.prototype:_update(vnode, hydrating)
        -- ---@type Component
        -- local vm = self
        -- local prevEl = vm._el
        -- local prevVnode = vm._vnode
        -- local restoreActiveInstance = setActiveInstance(vm)
        -- vm._vnode = vnode
        -- -- Vue.__patch__ is injected in entry points
        -- -- based on the rendering backend used.
        -- if (not prevVnode) then
        --     -- initial render
        --     vm._el = vm:__patch__(vm._el, vnode, hydrating, false --[[ removeOnly ]])
        -- else
        --     -- updates
        --     vm._el = vm:__patch__(prevVnode, vnode)
        -- end
        -- restoreActiveInstance()
        -- -- update __vue__ reference
        -- if (prevEl) then
        --     prevEl.__vue__ = nil
        -- end
        -- if (vm._el) then
        --     vm._el.__vue__ = vm
        -- end
        -- -- if parent is an HOC, update its $el as well
        -- if (vm._vnode and vm._parent and vm._vnode == vm._parent._vnode) then
        --     vm._parent._el = vm._el
        -- end
        -- -- updated hook is called by the scheduler to ensure that children are
        -- -- updated in a parent's updated hook.
    end

    function Vue.prototype:_forceUpdate()
        local vm = self
        if (vm._watcher) then
            vm._watcher:update()
        end
    end

    function Vue.prototype:_destroy()
        local vm = self
        if (vm._isBeingDestroyed) then
            return
        end
        callHook(vm, "beforeDestroy")
        vm._isBeingDestroyed = true
        -- remove self from parent
        local parent = vm._parent
        if (parent and not parent._isBeingDestroyed and not vm._options.abstract) then
            remove(parent._children, vm)
        end
        -- teardown watchers
        if (vm._watcher) then
            vm._watcher:teardown()
        end
        for i = #vm._watchers, 1, -1 do
            vm._watchers[i]:teardown()
        end
        -- remove reference from data ob
        -- frozen object may not have observer.
        local ob = getmetatable(vm._data).__ob__
        if (ob) then
            ob.vmCount = ob.vmCount - 1
        end
        -- call the last hook...
        vm._isDestroyed = true
        -- invoke destroy hooks on current rendered tree
        vm:__patch__(vm._vnode, nil)
        -- fire destroyed hook
        callHook(vm, "destroyed")
        -- turn off all instance listeners.
        vm:_off()
        -- remove __vue__ reference
        if (vm._el) then
            vm._el.__vue__ = nil
        end
        -- release circular reference (#6759)
        if (vm._vnode) then
            vm._vnode.parent = nil
        end
    end

    -- default mount method
    ---@param el string | Element
    ---@param hydrating boolean
    ---@return Component
    function Vue.prototype:_mount(el, hydrating)
        return mountComponent(self, el, hydrating)
    end
end

---@param vm Component
---@param el Element
---@param hydrating boolean
---@return Component
mountComponent = function(vm, el, hydrating)
    vm._el = el
    if (not vm._render) then
        vm._render = noop
    --   if (config.env ~= 'production')  then
    --       warn(
    --         'Failed to mount component: template or render function not defined.',
    --         vm
    --       )
    --   end
    end
    callHook(vm, "beforeMount")

    local updateComponent
    --[[ istanbul ignore if ]]
    if (config.env ~= "production" and config.performance and mark) then
        updateComponent = function()
            local name = vm._name
            local id = vm._uid
            local startTag = "vue-perf-start:" .. id
            local endTag = "vue-perf-end:" .. id

            mark(startTag)
            local vnode = vm:_render()
            mark(endTag)
            measure("vue " .. name .. " render", startTag, endTag)

            mark(startTag)
            vm:_update(vnode, hydrating)
            mark(endTag)
            measure("vue " .. name .. " patch", startTag, endTag)
        end
    else
        updateComponent = function()
            vm:_update(vm:_render(), hydrating)
        end
    end

    -- we set self to vm._watcher inside the watcher's constructor
    -- since the watcher's initial patch may call $forceUpdate (e.g. inside child
    -- component's mounted hook), which relies on vm._watcher being already defined
    Watcher.new(
        vm,
        updateComponent,
        noop,
        {
            before = function()
                if (vm._isMounted and not vm._isDestroyed) then
                    callHook(vm, "beforeUpdate")
                end
            end
        },
        true --[[ isRenderWatcher ]]
    )
    hydrating = false

    -- manually mounted instance, call mounted on self
    -- mounted is called for render-created child components in its inserted hook
    if (vm._vnode == nil) then
        vm._isMounted = true
        callHook(vm, "mounted")
    end
    return vm
end

---@param vm Component
---@param propsData Object
---@param listeners Object
---@param parentVnode MountedComponentVNode
---@param renderChildren VNode[]
local function updateChildComponent(vm, propsData, listeners, parentVnode, renderChildren)
    if (config.env ~= "production") then
        isUpdatingChildComponent = true
    end

    -- determine whether component has slot children
    -- we need to do self before overwriting $options._renderChildren.

    -- check if there are dynamic scopedSlots (hand-written or compiled but with
    -- dynamic slot names). Static scoped slots compiled from template has the
    -- "$stable" marker.
    local newScopedSlots = parentVnode.data.scopedSlots
    local oldScopedSlots = vm._scopedSlots
    local hasDynamicScopedSlot =
        not (not ((newScopedSlots and not newScopedSlots._stable) or
        (oldScopedSlots ~= emptyObject and not oldScopedSlots._stable) or
        (newScopedSlots and vm._scopedSlots._key ~= newScopedSlots._key)))

    -- Any static slot children from the parent may have changed during parent's
    -- update. Dynamic scoped slots may also have changed. In such cases, a forced
    -- update is necessary to ensure correctness.
    local needsForceUpdate =
        not (not (renderChildren or -- has new static slots
        vm._options._renderChildren or -- has old static slots
        hasDynamicScopedSlot))

    vm._options._parentVnode = parentVnode
    vm._vnode = parentVnode -- update vm's placeholder node without re-render

    if (vm._vnode) then -- update child tree's parent
        vm._vnode.parent = parentVnode
    end
    vm._options._renderChildren = renderChildren

    -- update $attrs and $listeners hash
    -- these are also reactive so they may trigger child update if the child
    -- used them during render
    vm._attrs = parentVnode.data.attrs or emptyObject
    vm._listeners = listeners or emptyObject

    -- update props
    if (propsData and vm._options.props) then
        toggleObserving(false)
        local props = vm._props
        local propKeys = vm._options._propKeys or {}
        for i = 1, #propKeys do
            local key = propKeys[i]
            local propOptions = vm._options.props -- wtf flow?
            props[key] = validateProp(key, propOptions, propsData, vm)
        end
        toggleObserving(true)
        -- keep a copy of raw propsData
        vm._options.propsData = propsData
    end

    -- update listeners
    listeners = listeners or emptyObject
    local oldListeners = vm._options._parentListeners
    vm._options._parentListeners = listeners
    updateComponentListeners(vm, listeners, oldListeners)

    -- resolve slots + force update if has children
    if (needsForceUpdate) then
        -- vm._slots = resolveSlots(renderChildren, parentVnode.context)
        vm:_forceUpdate()
    end

    if (config.env ~= "production") then
        isUpdatingChildComponent = false
    end
end

---@param vm Component
isInInactiveTree = function(vm)
    while vm do
        if (vm._inactive) then
            return true
        end
        vm = vm._parent
    end
    return false
end

---@param vm Component
---@param direct boolean
local function activateChildComponent(vm, direct)
    if (direct) then
        vm._directInactive = false
        if (isInInactiveTree(vm)) then
            return
        end
    elseif (vm._directInactive) then
        return
    end
    if (vm._inactive or vm._inactive == nil) then
        vm._inactive = false
        for i = 1, #vm._children do
            activateChildComponent(vm._children[i])
        end
        callHook(vm, "activated")
    end
end

---@param vm Component
---@param direct boolean
local function deactivateChildComponent(vm, direct)
    if (direct) then
        vm._directInactive = true
        if (isInInactiveTree(vm)) then
            return
        end
    end
    if (not vm._inactive) then
        vm._inactive = true
        for i = 1, #vm._children do
            deactivateChildComponent(vm._children[i])
        end
        callHook(vm, "deactivated")
    end
end

return {
    initLifecycle = initLifecycle,
    isUpdatingChildComponent = isUpdatingChildComponent,
    activateChildComponent = activateChildComponent,
    lifecycleMixin = lifecycleMixin,
    mountComponent = mountComponent,
    updateChildComponent = updateChildComponent,
    deactivateChildComponent = deactivateChildComponent
}
