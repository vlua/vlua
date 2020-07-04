require("vue")
require("@vue/compiler-ssr")
require("@vue/shared")

local compileCache = Object:create(nil)
function ssrCompile(template, instance)
  -- [ts2lua]compileCache下标访问可能不正确
  local cached = compileCache[template]
  if cached then
    return cached
  end
  local  = compile(template, {isCustomElement=instance.appContext.config.isCustomElement or NO, isNativeTag=instance.appContext.config.isNativeTag or NO, onError=function(err)
    if __DEV__ then
      local message = nil
      local codeFrame = err.loc and generateCodeFrame(template, err.loc.start.offset, err.loc.tsvar_end.offset)
      -- [ts2lua]lua中0和空字符串也是true，此处codeFrame需要确认
      warn((codeFrame and {} or {message})[1])
    else
      error(err)
    end
  end
  })
  -- [ts2lua]compileCache下标访问可能不正确
  return compileCache[template] = Function('require', code)(require)
end
