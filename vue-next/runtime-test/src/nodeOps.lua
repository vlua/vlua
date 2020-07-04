require("@vue/reactivity")
require("runtime-test/src/nodeOps/NodeTypes")
require("runtime-test/src/nodeOps/NodeOpTypes")

local nodeId = 0
local recordedNodeOps = {}
function logNodeOp(op)
  table.insert(recordedNodeOps, op)
end

function resetOps()
  recordedNodeOps = {}
end

function dumpOps()
  local ops = recordedNodeOps:slice()
  resetOps()
  return ops
end

function createElement(tag)
  local node = {id=nodeId=nodeId+1, type=NodeTypes.ELEMENT, tag=tag, children={}, props={}, parentNode=nil, eventListeners=nil}
  logNodeOp({type=NodeOpTypes.CREATE, nodeType=NodeTypes.ELEMENT, targetNode=node, tag=tag})
  markRaw(node)
  return node
end

function createText(text)
  local node = {id=nodeId=nodeId+1, type=NodeTypes.TEXT, text=text, parentNode=nil}
  logNodeOp({type=NodeOpTypes.CREATE, nodeType=NodeTypes.TEXT, targetNode=node, text=text})
  markRaw(node)
  return node
end

function createComment(text)
  local node = {id=nodeId=nodeId+1, type=NodeTypes.COMMENT, text=text, parentNode=nil}
  logNodeOp({type=NodeOpTypes.CREATE, nodeType=NodeTypes.COMMENT, targetNode=node, text=text})
  markRaw(node)
  return node
end

function setText(node, text)
  logNodeOp({type=NodeOpTypes.SET_TEXT, targetNode=node, text=text})
  node.text = text
end

function insert(child, parent, ref)
  local refIndex = nil
  if ref then
    refIndex = parent.children:find(ref)
    if refIndex == -1 then
      console:error('ref: ', ref)
      console:error('parent: ', parent)
      error(Error('ref is not a child of parent'))
    end
  end
  logNodeOp({type=NodeOpTypes.INSERT, targetNode=child, parentNode=parent, refNode=ref})
  remove(child, false)
  -- [ts2lua]lua中0和空字符串也是true，此处ref需要确认
  refIndex = (ref and {parent.children:find(ref)} or {-1})[1]
  if refIndex == -1 then
    table.insert(parent.children, child)
    child.parentNode = parent
  else
    parent.children:splice(refIndex, 0, child)
    child.parentNode = parent
  end
end

function remove(child, logOp)
  if logOp == nil then
    logOp=true
  end
  local parent = child.parentNode
  if parent then
    if logOp then
      logNodeOp({type=NodeOpTypes.REMOVE, targetNode=child, parentNode=parent})
    end
    local i = parent.children:find(child)
    if i > -1 then
      parent.children:splice(i, 1)
    else
      console:error('target: ', child)
      console:error('parent: ', parent)
      error(Error('target is not a childNode of parent'))
    end
    child.parentNode = nil
  end
end

function setElementText(el, text)
  logNodeOp({type=NodeOpTypes.SET_ELEMENT_TEXT, targetNode=el, text=text})
  el.children:forEach(function(c)
    c.parentNode = nil
  end
  )
  if not text then
    el.children = {}
  else
    el.children = {{id=nodeId=nodeId+1, type=NodeTypes.TEXT, text=text, parentNode=el}}
  end
end

function parentNode(node)
  return node.parentNode
end

function nextSibling(node)
  local parent = node.parentNode
  if not parent then
    return nil
  end
  local i = parent.children:find(node)
  -- [ts2lua]parent.children下标访问可能不正确
  return parent.children[i + 1] or nil
end

function querySelector()
  error(Error('querySelector not supported in test renderer.'))
end

function setScopeId(el, id)
  -- [ts2lua]el.props下标访问可能不正确
  el.props[id] = ''
end

local nodeOps = {insert=insert, remove=remove, createElement=createElement, createText=createText, createComment=createComment, setText=setText, setElementText=setElementText, parentNode=parentNode, nextSibling=nextSibling, querySelector=querySelector, setScopeId=setScopeId}