require("trycatch")
require("runtime-core/src/vnode")
require("runtime-core/src/errorHandling")
require("runtime-core/src/errorHandling/ErrorCodes")
require("@vue/shared/PatchFlags")
require("@vue/shared/ShapeFlags")
require("@vue/shared")
require("runtime-core/src/warning")
require("runtime-core/src/hmr")

local currentRenderingInstance = nil
function setCurrentRenderingInstance(instance)
  currentRenderingInstance = instance
end

local accessedAttrs = false
function markAttrsAccessed()
  accessedAttrs = true
end

function renderComponentRoot(instance)
  local  = instance
  local result = nil
  currentRenderingInstance = instance
  if __DEV__ then
    accessedAttrs = false
  end
  try_catch{
    main = function()
      local fallthroughAttrs = nil
      if vnode.shapeFlag & ShapeFlags.STATEFUL_COMPONENT then
        local proxyToUse = withProxy or proxy
        result = normalizeVNode(():call(proxyToUse, , renderCache))
        fallthroughAttrs = attrs
      else
        local render = Component
        if __DEV__ and attrs == props then
          markAttrsAccessed()
        end
        result = normalizeVNode((#render > 1 and {render(props, (__DEV__ and {{attrs=function()
          markAttrsAccessed()
          return attrs
        end
        -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
        -- [ts2lua]lua中0和空字符串也是true，此处#render > 1需要确认
        , slots=slots, emit=emit}} or {{attrs=attrs, slots=slots, emit=emit}})[1])} or {render(props, nil)})[1])
        -- [ts2lua]lua中0和空字符串也是true，此处Component.props需要确认
        fallthroughAttrs = (Component.props and {attrs} or {getFallthroughAttrs(attrs)})[1]
      end
      local root = result
      local setRoot = undefined
      if __DEV__ then
        
         = getChildRoot(result)
      end
      if (Component.inheritAttrs ~= false and fallthroughAttrs) and #Object:keys(fallthroughAttrs) then
        if root.shapeFlag & ShapeFlags.ELEMENT or root.shapeFlag & ShapeFlags.COMPONENT then
          root = cloneVNode(root, fallthroughAttrs)
        elseif (__DEV__ and not accessedAttrs) and root.type ~= Comment then
          local allAttrs = Object:keys(attrs)
          local eventAttrs = {}
          local extraAttrs = {}
          local i = 0
          local l = #allAttrs
          repeat
            local key = allAttrs[i+1]
            if isOn(key) then
              table.insert(eventAttrs, key[2+1]:toLowerCase() + key:slice(3))
            else
              table.insert(extraAttrs, key)
            end
            i=i+1
          until not(i < l)
          if #extraAttrs then
            warn( +  +  + )
          end
          if #eventAttrs then
            warn( +  +  +  +  + )
          end
        end
      end
      local scopeId = vnode.scopeId
      local treeOwnerId = parent and parent.type.__scopeId
      -- [ts2lua]lua中0和空字符串也是true，此处treeOwnerId and treeOwnerId ~= scopeId需要确认
      local slotScopeId = (treeOwnerId and treeOwnerId ~= scopeId and {treeOwnerId .. '-s'} or {nil})[1]
      if scopeId or slotScopeId then
        local extras = {}
        if scopeId then
          -- [ts2lua]extras下标访问可能不正确
          extras[scopeId] = ''
        end
        if slotScopeId then
          -- [ts2lua]extras下标访问可能不正确
          extras[slotScopeId] = ''
        end
        root = cloneVNode(root, extras)
      end
      if vnode.dirs then
        if __DEV__ and not isElementRoot(root) then
          warn( + )
        end
        root.dirs = vnode.dirs
      end
      if vnode.transition then
        if __DEV__ and not isElementRoot(root) then
          warn( + )
        end
        root.transition = vnode.transition
      end
      if __DEV__ and setRoot then
        setRoot(root)
      else
        result = root
      end
    end,
    catch = function(err)
      handleError(err, instance, ErrorCodes.RENDER_FUNCTION)
      result = createVNode(Comment)
    end
  }
  currentRenderingInstance = nil
  return result
end

local getChildRoot = function(vnode)
  if vnode.type ~= Fragment then
    return {vnode, undefined}
  end
  local rawChildren = vnode.children
  local dynamicChildren = vnode.dynamicChildren
  local children = rawChildren:filter(function(child)
    return not (isVNode(child) and child.type == Comment)
  end
  )
  if #children ~= 1 then
    return {vnode, undefined}
  end
  local childRoot = children[0+1]
  local index = rawChildren:find(childRoot)
  -- [ts2lua]lua中0和空字符串也是true，此处dynamicChildren需要确认
  local dynamicIndex = (dynamicChildren and {dynamicChildren:find(childRoot)} or {nil})[1]
  local setRoot = function(updatedRoot)
    -- [ts2lua]rawChildren下标访问可能不正确
    rawChildren[index] = updatedRoot
    if dynamicIndex ~= nil then
      -- [ts2lua]dynamicChildren下标访问可能不正确
      dynamicChildren[dynamicIndex] = updatedRoot
    end
  end
  
  return {normalizeVNode(childRoot), setRoot}
end

local getFallthroughAttrs = function(attrs)
  local res = nil
  for key in pairs(attrs) do
    if (key == 'class' or key == 'style') or isOn(key) then
      
      -- [ts2lua](res or (res = {}))下标访问可能不正确
      -- [ts2lua]attrs下标访问可能不正确
      (res or (res = {}))[key] = attrs[key]
    end
  end
  return res
end

local isElementRoot = function(vnode)
  return (vnode.shapeFlag & ShapeFlags.COMPONENT or vnode.shapeFlag & ShapeFlags.ELEMENT) or vnode.type == Comment
end

function shouldUpdateComponent(prevVNode, nextVNode, optimized)
  local  = prevVNode
  local  = nextVNode
  if (__DEV__ and (prevChildren or nextChildren)) and isHmrUpdating then
    return true
  end
  if nextVNode.dirs or nextVNode.transition then
    return true
  end
  if patchFlag > 0 then
    if patchFlag & PatchFlags.DYNAMIC_SLOTS then
      return true
    end
    if patchFlag & PatchFlags.FULL_PROPS then
      if not prevProps then
        return not (not nextProps)
      end
      return hasPropsChanged(prevProps, )
    elseif patchFlag & PatchFlags.PROPS then
      local dynamicProps = nil
      local i = 0
      repeat
        local key = dynamicProps[i+1]
        -- [ts2lua]()下标访问可能不正确
        -- [ts2lua]()下标访问可能不正确
        if ()[key] ~= ()[key] then
          return true
        end
        i=i+1
      until not(i < #dynamicProps)
    end
  elseif not optimized then
    if prevChildren or nextChildren then
      if not nextChildren or not nextChildren.tsvar_stable then
        return true
      end
    end
    if prevProps == nextProps then
      return false
    end
    if not prevProps then
      return not (not nextProps)
    end
    if not nextProps then
      return true
    end
    return hasPropsChanged(prevProps, nextProps)
  end
  return false
end

function hasPropsChanged(prevProps, nextProps)
  local nextKeys = Object:keys(nextProps)
  if #nextKeys ~= #Object:keys(prevProps) then
    return true
  end
  local i = 0
  repeat
    local key = nextKeys[i+1]
    -- [ts2lua]nextProps下标访问可能不正确
    -- [ts2lua]prevProps下标访问可能不正确
    if nextProps[key] ~= prevProps[key] then
      return true
    end
    i=i+1
  until not(i < #nextKeys)
  return false
end

function updateHOCHostEl(, el)
  while(parent and parent.subTree == vnode)
  do
  
  (vnode = parent.vnode).el = el
  parent = parent.parent
  end
end
