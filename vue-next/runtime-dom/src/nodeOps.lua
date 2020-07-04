
local svgNS = 'http://www.w3.org/2000/svg'
-- [ts2lua]lua中0和空字符串也是true，此处type(document) ~= 'undefined'需要确认
local doc = (type(document) ~= 'undefined' and {document} or {nil})[1]
local tempContainer = nil
local tempSVGContainer = nil
local nodeOps = {insert=function(child, parent, anchor)
  parent:insertBefore(child, anchor or nil)
end
, remove=function(child)
  local parent = child.parentNode
  if parent then
    parent:removeChild(child)
  end
end
, createElement=function(tag, isSVG, is)
  -- [ts2lua]lua中0和空字符串也是true，此处is需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处isSVG需要确认
  (isSVG and {doc:createElementNS(svgNS, tag)} or {doc:createElement(tag, (is and {{is=is}} or {undefined})[1])})[1]
end
, createText=function(text)
  doc:createTextNode(text)
end
, createComment=function(text)
  doc:createComment(text)
end
, setText=function(node, text)
  node.nodeValue = text
end
, setElementText=function(el, text)
  el.textContent = text
end
, parentNode=function(node)
  node.parentNode
end
, nextSibling=function(node)
  node.nextSibling
end
, querySelector=function(selector)
  doc:querySelector(selector)
end
, setScopeId=function(el, id)
  el:setAttribute(id, '')
end
, cloneNode=function(el)
  return el:cloneNode(true)
end
, insertStaticContent=function(content, parent, anchor, isSVG)
  -- [ts2lua]lua中0和空字符串也是true，此处isSVG需要确认
  local temp = (isSVG and {tempSVGContainer or (tempSVGContainer = doc:createElementNS(svgNS, 'svg'))} or {tempContainer or (tempContainer = doc:createElement('div'))})[1]
  temp.innerHTML = content
  local first = temp.firstChild
  local node = first
  local last = node
  while(node)
  do
  last = node
  nodeOps:insert(node, parent, anchor)
  node = temp.firstChild
  end
  return {first, last}
end
}