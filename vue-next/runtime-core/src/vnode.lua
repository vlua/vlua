require("tableutil")
require("@vue/shared")
require("@vue/shared/PatchFlags")
require("@vue/shared/ShapeFlags")
require("@vue/reactivity")
require("runtime-core/src/components/Suspense")
require("runtime-core/src/warning")
require("runtime-core/src/helpers/scopeId")
require("runtime-core/src/components/Teleport")
require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/helpers/resolveAssets")
require("runtime-core/src/hmr")
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认

local Fragment = Symbol((__DEV__ and {'Fragment'} or {undefined})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local Text = Symbol((__DEV__ and {'Text'} or {undefined})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local Comment = Symbol((__DEV__ and {'Comment'} or {undefined})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local Static = Symbol((__DEV__ and {'Static'} or {undefined})[1])
local blockStack = {}
local currentBlock = nil
function openBlock(disableTracking)
  if disableTracking == nil then
    disableTracking=false
  end
  -- [ts2lua]lua中0和空字符串也是true，此处disableTracking需要确认
  currentBlock = (disableTracking and {nil} or {{}})[1]
  table.insert(blockStack, currentBlock)
end

local shouldTrack = 1
function setBlockTracking(value)
  shouldTrack = shouldTrack + value
end

function createBlock(type, props, children, patchFlag, dynamicProps)
  local vnode = createVNode(type, props, children, patchFlag, dynamicProps, true)
  vnode.dynamicChildren = currentBlock or EMPTY_ARR
  blockStack:pop()
  -- [ts2lua]blockStack下标访问可能不正确
  currentBlock = blockStack[#blockStack - 1] or nil
  if currentBlock then
    table.insert(currentBlock, vnode)
  end
  return vnode
end

function isVNode(value)
  -- [ts2lua]lua中0和空字符串也是true，此处value需要确认
  return (value and {value.__v_isVNode == true} or {false})[1]
end

function isSameVNodeType(n1, n2)
  if (__DEV__ and n2.shapeFlag & ShapeFlags.COMPONENT) and hmrDirtyComponents:has(n2.type) then
    return false
  end
  return n1.type == n2.type and n1.key == n2.key
end

local vnodeArgsTransformer = nil
function transformVNodeArgs(transformer)
  vnodeArgsTransformer = transformer
end

local createVNodeWithArgsTransform = function(...)
  return _createVNode(...)
end

local InternalObjectKey = nil
local normalizeKey = function()
  -- [ts2lua]lua中0和空字符串也是true，此处key ~= nil需要确认
  (key ~= nil and {key} or {nil})[1]
end

local normalizeRef = function()
  -- [ts2lua]lua中0和空字符串也是true，此处isArray(ref)需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处ref ~= nil需要确认
  return (ref ~= nil and {(isArray(ref) and {ref} or {{ref}})[1]} or {nil})[1]
end

-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local createVNode = (__DEV__ and {createVNodeWithArgsTransform} or {_createVNode})[1]
function _createVNode(type, props, children, patchFlag, dynamicProps, isBlockNode)
  if props == nil then
    props=nil
  end
  if children == nil then
    children=nil
  end
  if patchFlag == nil then
    patchFlag=0
  end
  if dynamicProps == nil then
    dynamicProps=nil
  end
  if isBlockNode == nil then
    isBlockNode=false
  end
  if not type or type == NULL_DYNAMIC_COMPONENT then
    if __DEV__ and not type then
      warn()
    end
    type = Comment
  end
  if isVNode(type) then
    return cloneVNode(type, props, children)
  end
  if isFunction(type) and type['__vccOpts'] then
    type = type.__vccOpts
  end
  if props then
    if isProxy(props) or props[InternalObjectKey] then
      props = extend({}, props)
    end
    local  = props
    if klass and not isString(klass) then
      props.class = normalizeClass(klass)
    end
    if isObject(style) then
      if isProxy(style) and not isArray(style) then
        style = extend({}, style)
      end
      props.style = normalizeStyle(style)
    end
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isFunction(type)需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处isObject(type)需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处isTeleport(type)需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处__FEATURE_SUSPENSE__ and isSuspense(type)需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处isString(type)需要确认
  local shapeFlag = (isString(type) and {ShapeFlags.ELEMENT} or {(__FEATURE_SUSPENSE__ and isSuspense(type) and {ShapeFlags.SUSPENSE} or {(isTeleport(type) and {ShapeFlags.TELEPORT} or {(isObject(type) and {ShapeFlags.STATEFUL_COMPONENT} or {(isFunction(type) and {ShapeFlags.FUNCTIONAL_COMPONENT} or {0})[1]})[1]})[1]})[1]})[1]
  if (__DEV__ and shapeFlag & ShapeFlags.STATEFUL_COMPONENT) and isProxy(type) then
    type = toRaw(type)
    warn( +  +  + , , type)
  end
  local vnode = {__v_isVNode=true, __v_skip=true, type=type, props=props, key=props and normalizeKey(props), ref=props and normalizeRef(props), scopeId=currentScopeId, children=nil, component=nil, suspense=nil, dirs=nil, transition=nil, el=nil, anchor=nil, target=nil, targetAnchor=nil, staticCount=0, shapeFlag=shapeFlag, patchFlag=patchFlag, dynamicProps=dynamicProps, dynamicChildren=nil, appContext=nil}
  normalizeChildren(vnode, children)
  if (((shouldTrack > 0 and not isBlockNode) and currentBlock) and patchFlag ~= PatchFlags.HYDRATE_EVENTS) and ((((patchFlag > 0 or shapeFlag & ShapeFlags.SUSPENSE) or shapeFlag & ShapeFlags.TELEPORT) or shapeFlag & ShapeFlags.STATEFUL_COMPONENT) or shapeFlag & ShapeFlags.FUNCTIONAL_COMPONENT) then
    table.insert(currentBlock, vnode)
  end
  return vnode
end

function cloneVNode(vnode, extraProps, children)
  -- [ts2lua]lua中0和空字符串也是true，此处vnode.props需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处extraProps需要确认
  local props = (extraProps and {(vnode.props and {mergeProps(vnode.props, extraProps)} or {extend({}, extraProps)})[1]} or {vnode.props})[1]
  -- [ts2lua]lua中0和空字符串也是true，此处extraProps and extraProps.ref需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处vnode.dynamicChildren需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处extraProps需要确认
  local cloned = {__v_isVNode=true, __v_skip=true, type=vnode.type, props=props, key=props and normalizeKey(props), ref=(extraProps and extraProps.ref and {normalizeRef(extraProps)} or {vnode.ref})[1], scopeId=vnode.scopeId, children=vnode.children, target=vnode.target, targetAnchor=vnode.targetAnchor, staticCount=vnode.staticCount, shapeFlag=vnode.shapeFlag, patchFlag=(extraProps and {(vnode.dynamicChildren and {vnode.patchFlag | PatchFlags.FULL_PROPS} or {PatchFlags.BAIL})[1]} or {vnode.patchFlag})[1], dynamicProps=vnode.dynamicProps, dynamicChildren=vnode.dynamicChildren, appContext=vnode.appContext, dirs=vnode.dirs, transition=vnode.transition, component=vnode.component, suspense=vnode.suspense, el=vnode.el, anchor=vnode.anchor}
  if children then
    normalizeChildren(cloned, children)
  end
  return cloned
end

function createTextVNode(text, flag)
  if text == nil then
    text=' '
  end
  if flag == nil then
    flag=0
  end
  return createVNode(Text, nil, text, flag)
end

function createStaticVNode(content, numberOfNodes)
  local vnode = createVNode(Static, nil, content)
  vnode.staticCount = numberOfNodes
  return vnode
end

function createCommentVNode(text, asBlock)
  if text == nil then
    text=''
  end
  if asBlock == nil then
    asBlock=false
  end
  -- [ts2lua]lua中0和空字符串也是true，此处asBlock需要确认
  return (asBlock and {openBlock(); createBlock(Comment, nil, text)} or {createVNode(Comment, nil, text)})[1]
end

function normalizeVNode(child)
  if child == nil or type(child) == 'boolean' then
    return createVNode(Comment)
  elseif isArray(child) then
    return createVNode(Fragment, nil, child)
  elseif type(child) == 'object' then
    -- [ts2lua]lua中0和空字符串也是true，此处child.el == nil需要确认
    return (child.el == nil and {child} or {cloneVNode(child)})[1]
  else
    return createVNode(Text, nil, String(child))
  end
end

function cloneIfMounted(child)
  -- [ts2lua]lua中0和空字符串也是true，此处child.el == nil需要确认
  return (child.el == nil and {child} or {cloneVNode(child)})[1]
end

function normalizeChildren(vnode, children)
  local type = 0
  local  = vnode
  if children == nil then
    children = nil
  elseif isArray(children) then
    type = ShapeFlags.ARRAY_CHILDREN
  elseif type(children) == 'object' then
    if (shapeFlag & ShapeFlags.ELEMENT or shapeFlag & ShapeFlags.TELEPORT) and children.default then
      normalizeChildren(vnode, children:default())
      return
    else
      type = ShapeFlags.SLOTS_CHILDREN
      if not children._ and not ([InternalObjectKey]) then
        
        children._ctx = currentRenderingInstance
      end
    end
  elseif isFunction(children) then
    children = {default=children, _ctx=currentRenderingInstance}
    type = ShapeFlags.SLOTS_CHILDREN
  else
    children = String(children)
    if shapeFlag & ShapeFlags.TELEPORT then
      type = ShapeFlags.ARRAY_CHILDREN
      children = {createTextVNode(children)}
    else
      type = ShapeFlags.TEXT_CHILDREN
    end
  end
  vnode.children = children
  vnode.shapeFlag = vnode.shapeFlag | type
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local handlersRE = /^on|^vnode/
function mergeProps(...)
  local ret = extend({}, args[0+1])
  local i = 1
  repeat
    local toMerge = args[i+1]
    for key in pairs(toMerge) do
      if key == 'class' then
        if ret.class ~= toMerge.class then
          ret.class = normalizeClass({ret.class, toMerge.class})
        end
      elseif key == 'style' then
        ret.style = normalizeStyle({ret.style, toMerge.style})
      elseif handlersRE:test(key) then
        -- [ts2lua]ret下标访问可能不正确
        local existing = ret[key]
        -- [ts2lua]toMerge下标访问可能不正确
        local incoming = toMerge[key]
        if existing ~= incoming then
          -- [ts2lua]ret下标访问可能不正确
          -- [ts2lua]toMerge下标访问可能不正确
          -- [ts2lua]lua中0和空字符串也是true，此处existing需要确认
          ret[key] = (existing and {table.merge(({}), existing, toMerge[key])} or {incoming})[1]
        end
      else
        -- [ts2lua]ret下标访问可能不正确
        -- [ts2lua]toMerge下标访问可能不正确
        ret[key] = toMerge[key]
      end
    end
    i=i+1
  until not(i < #args)
  return ret
end
