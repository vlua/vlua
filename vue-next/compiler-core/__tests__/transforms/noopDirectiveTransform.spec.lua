require("compiler-core/src")
require("compiler-core/src/transforms/transformElement")
local parse = baseParse

describe('compiler: noop directive transform', function()
  test('should add no props to DOM', function()
    local ast = parse()
    transform(ast, {nodeTransforms={transformElement}, directiveTransforms={noop=noopDirectiveTransform}})
    local node = ast.children[0+1]
    expect(node.codegenNode.props):toBeUndefined()
  end
  )
end
)