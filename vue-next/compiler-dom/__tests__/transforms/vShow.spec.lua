require("@vue/compiler-core")
require("compiler-core/src/transforms/transformElement")
require("compiler-dom/src/transforms/vShow")
require("compiler-dom/src/errors/DOMErrorCodes")
local parse = baseParse

function transformWithShow(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformElement}, directiveTransforms={show=transformShow}, ...})
  return ast
end

describe('compiler: v-show transform', function()
  test('simple expression', function()
    local ast = transformWithShow()
    expect(generate(ast).code):toMatchSnapshot()
  end
  )
  test('should raise error if has no expression', function()
    local onError = jest:fn()
    transformWithShow({onError=onError})
    expect(onError):toHaveBeenCalledTimes(1)
    expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=DOMErrorCodes.X_V_SHOW_NO_EXPRESSION}))
  end
  )
end
)