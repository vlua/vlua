
---@param vm Component
local function initRender (vm)
    vm._vnode = nil -- the root of the child tree
    vm._staticTrees = nil -- v-once cached trees
    local options = vm._options
    local parentVnode = options._parentVnode -- the placeholder node in parent tree
    vm._vnode = parentVnode
    local renderContext = parentVnode and parentVnode.context
    vm._slots = resolveSlots(options._renderChildren, renderContext)
    vm._scopedSlots = emptyObject
    -- bind the createElement fn to self instance
    -- so that we get proper render context inside it.
    -- args order: tag, data, children, normalizationType, alwaysNormalize
    -- internal version is used by render functions compiled from templates
    vm._c = function(a, b, c, d) createElement(vm, a, b, c, d, false) end
    -- normalization is always applied for the public version, used in
    -- user-written render functions.
    vm._createElement = function(a, b, c, d) createElement(vm, a, b, c, d, true) end

    -- $attrs & $listeners are exposed for easier HOC creation.
    -- they need to be reactive so that HOCs using them are always updated
    local parentData = parentVnode and parentVnode.data

    if (config.env ~= 'production') then
        defineReactive(vm, '$attrs', parentData and parentData.attrs or emptyObject, function()
            if not isUpdatingChildComponent then
                warn('$attrs is readonly.', vm)
            end
        end, true)
        defineReactive(vm, '$listeners', options._parentListeners or emptyObject, function()
            if not isUpdatingChildComponent then
                warn('$listeners is readonly.', vm)
            end
        end, true)
    else
        defineReactive(vm, '$attrs', parentData and parentData.attrs or emptyObject, nil, true)
        defineReactive(vm, '$listeners', options._parentListeners or emptyObject, nil, true)
    end
end

---@type Component | nil
local currentRenderingInstance = nil

-- for testing only
---@param vm Component
local function setCurrentRenderingInstance (vm)
  currentRenderingInstance = vm
end

---@param Vue Component
local function renderMixin (Vue)
    -- install runtime convenience helpers
    installRenderHelpers(Vue)

    ---@param fn Function 
    function Vue.prototype:_nextTick(fn)
        return nextTick(fn, self)
    end

    ---@return VNode
    function Vue.prototype:_render()
        ---@type Component
        local vm = self
        local render, _parentVnode = vm._options.render, vm._options._parentVnode

        -- if (_parentVnode) then
        --     vm._scopedSlots = normalizeScopedSlots(
        --     _parentVnode.data.scopedSlots,
        --     vm._slots,
        --     vm._scopedSlots
        --     )
        -- end

        -- set parent vnode. self allows render functions to have access
        -- to the data on the placeholder node.
        vm._vnode = _parentVnode
        -- render self
        local vnode
        -- try {
            -- There's no need to maintain a stack because all render fns are called
            -- separately from one another. Nested component's render fns are called
            -- when parent component is patched.
            currentRenderingInstance = vm
            vnode = render(vm._renderProxy, vm._createElement)
        -- end catch (e) {
        --   handleError(e, vm, 'render')
        --   -- return error render result,
        --   -- or previous vnode to prevent render error causing blank component
            
        --   if (config.env ~= 'production' and vm._options.renderError) then
        --     -- try {
        --       vnode = vm._options.renderError.call(vm._renderProxy, vm._createElement, e)
        --     -- end catch (e) {
        --     --   handleError(e, vm, 'renderError')
        --     --   vnode = vm._vnode
        --     -- end
        --   else
        --     vnode = vm._vnode
        --   end
        -- end finally {
            currentRenderingInstance = nil
        -- end
        -- if the returned array contains only a single node, allow it
        if (Array.isArray(vnode) and vnode.length == 1) then
            vnode = vnode[0]
        end
        -- return empty vnode in case the render function errored out
        if (not (instanceof(vnode, VNode))) then
            if (config.env ~= 'production' and Array.isArray(vnode)) then
            warn(
                'Multiple root nodes returned from render function. Render function ' +
                'should return a single root node.',
                vm
            )
            end
            vnode = createEmptyVNode()
        end
        -- set parent
        vnode.parent = _parentVnode
        return vnode
    end
end
