require("runtime-core/src/vnode")
require("@vue/shared")
-- [ts2lua]请手动处理DeclareFunction


-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function h(type, propsOrChildren, children)
  if #arguments == 2 then
    if isObject(propsOrChildren) and not isArray(propsOrChildren) then
      if isVNode(propsOrChildren) then
        return createVNode(type, nil, {propsOrChildren})
      end
      return createVNode(type, propsOrChildren)
    else
      return createVNode(type, nil, propsOrChildren)
    end
  else
    if isVNode(children) then
      children = {children}
    end
    return createVNode(type, propsOrChildren, children)
  end
end
