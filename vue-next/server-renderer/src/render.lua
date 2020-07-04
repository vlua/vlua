require("vue")
require("@vue/shared")
require("@vue/shared/ShapeFlags")
require("server-renderer/src/helpers/ssrRenderAttrs")
require("server-renderer/src/helpers/ssrCompile")
require("server-renderer/src/helpers/ssrRenderTeleport")

local  = ssrUtils
function createBuffer()
  local appendable = false
  local buffer = {}
  return {getBuffer=function()
    return buffer
  end
  , push=function(item)
    local isStringItem = isString(item)
    if appendable and isStringItem then
      -- [ts2lua]buffer下标访问可能不正确
      -- [ts2lua]buffer下标访问可能不正确
      buffer[#buffer - 1] = buffer[#buffer - 1] + item
    else
      table.insert(buffer, item)
    end
    appendable = isStringItem
    if isPromise(item) or isArray(item) and item.hasAsync then
      buffer.hasAsync = true
    end
  end
  }
end

function renderComponentVNode(vnode, parentComponent)
  if parentComponent == nil then
    parentComponent=nil
  end
  local instance = createComponentInstance(vnode, parentComponent, nil)
  local res = setupComponent(instance, true)
  if isPromise(res) then
    return res:catch(function(err)
      warn(err)
    end
    ):tsvar_then(function()
      renderComponentSubTree(instance)
    end
    )
  else
    return renderComponentSubTree(instance)
  end
end

function renderComponentSubTree(instance)
  local comp = instance.type
  local  = createBuffer()
  if isFunction(comp) then
    renderVNode(push, renderComponentRoot(instance), instance)
  else
    if (not instance.render and not comp.ssrRender) and isString(comp.template) then
      comp.ssrRender = ssrCompile(comp.template, instance)
    end
    if comp.ssrRender then
      -- [ts2lua]lua中0和空字符串也是true，此处instance.type.inheritAttrs ~= false需要确认
      local attrs = (instance.type.inheritAttrs ~= false and {instance.attrs} or {undefined})[1]
      local scopeId = instance.vnode.scopeId
      local treeOwnerId = instance.parent and instance.parent.type.__scopeId
      -- [ts2lua]lua中0和空字符串也是true，此处treeOwnerId and treeOwnerId ~= scopeId需要确认
      local slotScopeId = (treeOwnerId and treeOwnerId ~= scopeId and {treeOwnerId .. '-s'} or {nil})[1]
      if scopeId or slotScopeId then
        attrs = {...}
        if scopeId then
          -- [ts2lua]attrs下标访问可能不正确
          attrs[scopeId] = ''
        end
        if slotScopeId then
          -- [ts2lua]attrs下标访问可能不正确
          attrs[slotScopeId] = ''
        end
      end
      setCurrentRenderingInstance(instance)
      comp:ssrRender(instance.proxy, push, instance, attrs)
      setCurrentRenderingInstance(nil)
    elseif instance.render then
      renderVNode(push, renderComponentRoot(instance), instance)
    else
      warn()
      push()
    end
  end
  return getBuffer()
end

function renderVNode(push, vnode, parentComponent)
  local  = vnode
  local switch = {
    [Text] = function()
      push(escapeHtml(children))
    end,
    [Comment] = function()
      -- [ts2lua]lua中0和空字符串也是true，此处children需要确认
      push((children and {} or {})[1])
    end,
    [Static] = function()
      push(children)
    end,
    [Fragment] = function()
      push()
      renderVNodeChildren(push, children, parentComponent)
      push()
    end,
    ["default"] = function()
      if shapeFlag & ShapeFlags.ELEMENT then
        renderElementVNode(push, vnode, parentComponent)
      elseif shapeFlag & ShapeFlags.COMPONENT then
        push(renderComponentVNode(vnode, parentComponent))
      elseif shapeFlag & ShapeFlags.TELEPORT then
        renderTeleportVNode(push, vnode, parentComponent)
      elseif shapeFlag & ShapeFlags.SUSPENSE then
        renderVNode(push, normalizeSuspenseChildren(vnode).content, parentComponent)
      else
        warn('[@vue/server-renderer] Invalid VNode type:', type, )
      end
    end
  }
  local casef = switch[type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end

function renderVNodeChildren(push, children, parentComponent)
  local i = 0
  repeat
    renderVNode(push, normalizeVNode(children[i+1]), parentComponent)
    i=i+1
  until not(i < #children)
end

function renderElementVNode(push, vnode, parentComponent)
  local tag = vnode.type
  local  = vnode
  local openTag = nil
  if dirs then
    props = applySSRDirectives(vnode, props, dirs)
  end
  if props then
    openTag = openTag + ssrRenderAttrs(props, tag)
  end
  if scopeId then
    openTag = openTag + 
    local treeOwnerId = parentComponent and parentComponent.type.__scopeId
    if treeOwnerId and treeOwnerId ~= scopeId then
      openTag = openTag + 
    end
  end
  push(openTag + )
  if not isVoidTag(tag) then
    local hasChildrenOverride = false
    if props then
      if props.innerHTML then
        hasChildrenOverride = true
        push(props.innerHTML)
      elseif props.textContent then
        hasChildrenOverride = true
        push(escapeHtml(props.textContent))
      elseif tag == 'textarea' and props.value then
        hasChildrenOverride = true
        push(escapeHtml(props.value))
      end
    end
    if not hasChildrenOverride then
      if shapeFlag & ShapeFlags.TEXT_CHILDREN then
        push(escapeHtml(children))
      elseif shapeFlag & ShapeFlags.ARRAY_CHILDREN then
        renderVNodeChildren(push, children, parentComponent)
      end
    end
    push()
  end
end

function applySSRDirectives(vnode, rawProps, dirs)
  local toMerge = {}
  local i = 0
  repeat
    local binding = dirs[i+1]
    local  = binding
    if getSSRProps then
      local props = getSSRProps(binding, vnode)
      if props then
        table.insert(toMerge, props)
      end
    end
    i=i+1
  until not(i < #dirs)
  return mergeProps(rawProps or {}, ...)
end

function renderTeleportVNode(push, vnode, parentComponent)
  local target = vnode.props and vnode.props.to
  local disabled = vnode.props and vnode.props.disabled
  if not target then
    warn()
    return {}
  end
  if not isString(target) then
    warn()
    return {}
  end
  ssrRenderTeleport(push, function(push)
    renderVNodeChildren(push, vnode.children, parentComponent)
  end
  , target, disabled or disabled == '', parentComponent)
end
