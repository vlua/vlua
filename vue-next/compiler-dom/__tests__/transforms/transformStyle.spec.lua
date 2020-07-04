require("@vue/compiler-core")
require("@vue/compiler-core/NodeTypes")
require("compiler-core/src/transforms/vBind")
require("compiler-core/src/transforms/transformElement")
require("compiler-dom/src/transforms/transformStyle")
local parse = baseParse

function transformWithStyleTransform(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformStyle}, ...})
  return {root=ast, node=ast.children[0+1]}
end

describe('compiler: style transform', function()
  test('should transform into directive node', function()
    local  = transformWithStyleTransform()
    expect(node.props[0+1]):toMatchObject({type=NodeTypes.DIRECTIVE, name=, arg={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, exp={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}})
  end
  )
  test('working with v-bind transform', function()
    local  = transformWithStyleTransform({nodeTransforms={transformStyle, transformElement}, directiveTransforms={bind=transformBind}})
    expect(node.codegenNode.props):toMatchObject({type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{key={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}})
    expect(node.codegenNode.patchFlag):toBeUndefined()
  end
  )
end
)