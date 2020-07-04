require("compiler-ssr/src")

function getCompiledString(src)
  local  = compile()
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local match = code:match(/_push\(\`<div\${\s*_ssrRenderAttrs\(_attrs\)\s*}>([^]*)<\/div>\`\)/)
  if not match then
    error(Error())
  end
  return 
end
