require("runtime-test/src/nodeOps/NodeTypes")
require("@vue/shared")

function serialize(node, indent, depth)
  if indent == nil then
    indent=0
  end
  if depth == nil then
    depth=0
  end
  if node.type == NodeTypes.ELEMENT then
    return serializeElement(node, indent, depth)
  else
    return serializeText(node, indent, depth)
  end
end

function serializeInner(node, indent, depth)
  if indent == nil then
    indent=0
  end
  if depth == nil then
    depth=0
  end
  -- [ts2lua]lua中0和空字符串也是true，此处indent需要确认
  local newLine = (indent and {} or {})[1]
  return (#node.children and {newLine + node.children:map(function(c)
    serialize(c, indent, depth + 1)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处#node.children需要确认
  ):join(newLine) + newLine} or {})[1]
end

function serializeElement(node, indent, depth)
  local props = Object:keys(node.props):map(function(key)
    -- [ts2lua]node.props下标访问可能不正确
    local value = node.props[key]
    -- [ts2lua]lua中0和空字符串也是true，此处value == 需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处isOn(key) or value == nil需要确认
    return (isOn(key) or value == nil and {} or {(value ==  and {key} or {})[1]})[1]
  end
  ):filter(Boolean):join(' ')
  -- [ts2lua]lua中0和空字符串也是true，此处indent需要确认
  local padding = (indent and {():tsvar_repeat(indent):tsvar_repeat(depth)} or {})[1]
  return  +  + 
end

function serializeText(node, indent, depth)
  -- [ts2lua]lua中0和空字符串也是true，此处indent需要确认
  local padding = (indent and {():tsvar_repeat(indent):tsvar_repeat(depth)} or {})[1]
  -- [ts2lua]lua中0和空字符串也是true，此处node.type == NodeTypes.COMMENT需要确认
  return padding + (node.type == NodeTypes.COMMENT and {} or {node.text})[1]
end
