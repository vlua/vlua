require("compiler-core/src")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/transforms/vIf")
require("compiler-core/src/transforms/transformExpression")
local parse = baseParse

function parseWithExpressionTransform(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {prefixIdentifiers=true, nodeTransforms={transformIf, transformExpression}, ...})
  return ast.children[0+1]
end

describe('compiler: expression transform', function()
  test('interpolation (root)', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
  end
  )
  test('empty interpolation', function()
    local node = parseWithExpressionTransform()
    local node2 = parseWithExpressionTransform()
    local node3 = parseWithExpressionTransform()
    local objectToBeMatched = {type=NodeTypes.SIMPLE_EXPRESSION, content=}
    expect(node.content):toMatchObject(objectToBeMatched)
    expect(node2.content):toMatchObject(objectToBeMatched)
    expect(node3.children[0+1].content):toMatchObject(objectToBeMatched)
  end
  )
  test('interpolation (children)', function()
    local el = parseWithExpressionTransform()
    local node = el.children[0+1]
    expect(node.content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
  end
  )
  test('interpolation (complex)', function()
    local el = parseWithExpressionTransform()
    local node = el.children[0+1]
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, , {content=}, }})
  end
  )
  test('directive value', function()
    local node = parseWithExpressionTransform()
    local arg = nil
    expect(arg):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    local exp = nil
    expect(exp):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
  end
  )
  test('dynamic directive arg', function()
    local node = parseWithExpressionTransform()
    local arg = nil
    expect(arg):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    local exp = nil
    expect(exp):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
  end
  )
  test('should prefix complex expressions', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=, loc={source=, start={offset=3, line=1, column=4}, tsvar_end={offset=6, line=1, column=7}}}, , {content=, loc={source=, start={offset=7, line=1, column=8}, tsvar_end={offset=10, line=1, column=11}}}, , {content=, loc={source=, start={offset=23, line=1, column=24}, tsvar_end={offset=26, line=1, column=27}}}, }})
  end
  )
  test('should not prefix whitelisted globals', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, }})
  end
  )
  test('should not prefix reserved literals', function()
    function assert(exp)
      local node = parseWithExpressionTransform()
      expect(node.content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=exp})
    end
    
    assert()
    assert()
    assert()
    assert()
  end
  )
  test('should not prefix id of a function declaration', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, }})
  end
  )
  test('should not prefix params of a function expression', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}}})
  end
  )
  test('should prefix default value of a function expression param', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, , {content=}}})
  end
  )
  test('should not prefix function param destructuring', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}}})
  end
  )
  test('function params should not affect out of scope identifiers', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, }})
  end
  )
  test('should prefix default value of function param destructuring', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, , {content=}}})
  end
  )
  test('should not prefix an object property key', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, }})
  end
  )
  test('should not duplicate object key with same name as value', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }})
  end
  )
  test('should prefix a computed object property key', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, }})
  end
  )
  test('should prefix object property shorthand value', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }})
  end
  )
  test('should not prefix id in a member expression', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}}})
  end
  )
  test('should prefix computed id in a member expression', function()
    local node = parseWithExpressionTransform()
    expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content='_ctx.baz'}, }})
  end
  )
  test('should handle parse error', function()
    local onError = jest:fn()
    parseWithExpressionTransform({onError=onError})
    expect(onError.mock.calls[0+1][0+1].message):toMatch()
  end
  )
  describe('ES Proposals support', function()
    test('bigInt', function()
      local node = parseWithExpressionTransform()
      expect(node.content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false, isConstant=true})
    end
    )
    test('nullish colescing', function()
      local node = parseWithExpressionTransform()
      expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}}})
    end
    )
    test('optional chaining', function()
      local node = parseWithExpressionTransform()
      expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}}})
    end
    )
    test('Enabling additional plugins', function()
      local node = parseWithExpressionTransform({expressionPlugins={{'pipelineOperator', {proposal='minimal'}}}})
      expect(node.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}}})
    end
    )
  end
  )
end
)