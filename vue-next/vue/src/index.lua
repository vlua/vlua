require("@vue/compiler-dom")
require("@vue/runtime-dom")
require("@vue/shared")

local compileCache = Object:create(nil)
function compileToFunction(template, options)
  if not isString(template) then
    if template.nodeType then
      template = template.innerHTML
    else
      __DEV__ and warn(template)
      return NOOP
    end
  end
  local key = template
  -- [ts2lua]compileCache下标访问可能不正确
  local cached = compileCache[key]
  if cached then
    return cached
  end
  if template[0+1] == '#' then
    local el = document:querySelector(template)
    if __DEV__ and not el then
      warn()
    end
    -- [ts2lua]lua中0和空字符串也是true，此处el需要确认
    template = (el and {el.innerHTML} or {})[1]
  end
  local  = compile(template, extend({hoistStatic=true, onError=function(err)
    if __DEV__ then
      local message = nil
      local codeFrame = err.loc and generateCodeFrame(template, err.loc.start.offset, err.loc.tsvar_end.offset)
      -- [ts2lua]lua中0和空字符串也是true，此处codeFrame需要确认
      warn((codeFrame and {} or {message})[1])
    else
      error(err)
    end
  end
  }, options))
  -- [ts2lua]lua中0和空字符串也是true，此处__GLOBAL__需要确认
  local render = (__GLOBAL__ and {Function(code)()} or {Function('Vue', code)(runtimeDom)})[1]
  -- [ts2lua]compileCache下标访问可能不正确
  return compileCache[key] = render
end

registerRuntimeCompiler(compileToFunction)
undefined