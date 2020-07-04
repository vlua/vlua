require("@vue/compiler-core")
require("compiler-dom/src/transforms/vText")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/__tests__/testUtils")
require("@vue/shared/PatchFlags")
require("compiler-dom/src/errors/DOMErrorCodes")
local parse = baseParse

function transformWithVText(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformElement}, directiveTransforms={text=transformVText}, ...})
  return ast
end

describe('compiler: v-text transform', function()
  it('should convert v-text to textContent', function()
    local ast = transformWithVText()
    expect(ast.children[0+1].codegenNode):toMatchObject({tag=, props=createObjectMatcher({textContent=}), children=undefined, patchFlag=genFlagText(PatchFlags.PROPS), dynamicProps=})
  end
  )
  it('should raise error and ignore children when v-text is present', function()
    local onError = jest:fn()
    local ast = transformWithVText({onError=onError})
    expect(onError.mock.calls):toMatchObject({{{code=DOMErrorCodes.X_V_TEXT_WITH_CHILDREN}}})
    expect(ast.children[0+1].codegenNode):toMatchObject({tag=, props=createObjectMatcher({textContent=}), children=undefined, patchFlag=genFlagText(PatchFlags.PROPS), dynamicProps=})
  end
  )
  it('should raise error if has no expression', function()
    local onError = jest:fn()
    transformWithVText({onError=onError})
    expect(onError.mock.calls):toMatchObject({{{code=DOMErrorCodes.X_V_TEXT_NO_EXPRESSION}}})
  end
  )
end
)