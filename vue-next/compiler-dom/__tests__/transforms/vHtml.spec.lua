require("@vue/compiler-core")
require("compiler-dom/src/transforms/vHtml")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/__tests__/testUtils")
require("@vue/shared/PatchFlags")
require("compiler-dom/src/errors/DOMErrorCodes")
local parse = baseParse

function transformWithVHtml(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformElement}, directiveTransforms={html=transformVHtml}, ...})
  return ast
end

describe('compiler: v-html transform', function()
  it('should convert v-html to innerHTML', function()
    local ast = transformWithVHtml()
    expect(ast.children[0+1].codegenNode):toMatchObject({tag=, props=createObjectMatcher({innerHTML=}), children=undefined, patchFlag=genFlagText(PatchFlags.PROPS), dynamicProps=})
  end
  )
  it('should raise error and ignore children when v-html is present', function()
    local onError = jest:fn()
    local ast = transformWithVHtml({onError=onError})
    expect(onError.mock.calls):toMatchObject({{{code=DOMErrorCodes.X_V_HTML_WITH_CHILDREN}}})
    expect(ast.children[0+1].codegenNode):toMatchObject({tag=, props=createObjectMatcher({innerHTML=}), children=undefined, patchFlag=genFlagText(PatchFlags.PROPS), dynamicProps=})
  end
  )
  it('should raise error if has no expression', function()
    local onError = jest:fn()
    transformWithVHtml({onError=onError})
    expect(onError.mock.calls):toMatchObject({{{code=DOMErrorCodes.X_V_HTML_NO_EXPRESSION}}})
  end
  )
end
)