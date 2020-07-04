require("@vue/shared")
-- [ts2lua]请手动处理DeclareFunction


-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function defineComponent(options)
  -- [ts2lua]lua中0和空字符串也是true，此处isFunction(options)需要确认
  return (isFunction(options) and {{setup=options}} or {options})[1]
end
