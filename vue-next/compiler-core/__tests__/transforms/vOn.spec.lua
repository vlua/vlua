require("compiler-core/src")
require("compiler-core/src/ErrorCodes")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/transforms/vOn")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/transformExpression")
local parse = baseParse

function parseWithVOn(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformExpression, transformElement}, directiveTransforms={on=transformOn}, ...})
  return {root=ast, node=ast.children[0+1]}
end

describe('compiler: transform v-on', function()
  test('basic', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=, isStatic=true, loc={start={line=1, column=11}, tsvar_end={line=1, column=16}}}, value={content=, isStatic=false, loc={start={line=1, column=18}, tsvar_end={line=1, column=25}}}}}})
  end
  )
  test('dynamic arg', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}})
  end
  )
  test('dynamic arg with prefixing', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(node.codegenNode.props):toMatchObject({properties={{key={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}})
  end
  )
  test('dynamic arg with complex exp prefixing', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(node.codegenNode.props):toMatchObject({properties={{key={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , }}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}})
  end
  )
  test('should wrap as function if expression is inline statement', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}}}})
  end
  )
  test('should handle multiple inline statement', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}}}})
  end
  )
  test('should handle multi-line statement', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}}}})
  end
  )
  test('inline statement w/ prefixIdentifiers: true', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, }}, }}}}})
  end
  )
  test('multiple inline statements w/ prefixIdentifiers: true', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{children={{content=}, , {content=}, , {content=}, }}, }}}}})
  end
  )
  test('should NOT wrap as function if expression is already function expression', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=}}}})
  end
  )
  test('should NOT wrap as function if expression is complex member expression', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=}}}})
  end
  )
  test('complex member expression w/ prefixIdentifiers: true', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, }}}}})
  end
  )
  test('function expression w/ prefixIdentifiers: true', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, }}}}})
  end
  )
  test('should error if no expression AND no modifier', function()
    local onError = jest:fn()
    parseWithVOn({onError=onError})
    expect(onError.mock.calls[0+1][0+1]):toMatchObject({code=ErrorCodes.X_V_ON_NO_EXPRESSION, loc={start={line=1, column=6}, tsvar_end={line=1, column=16}}})
  end
  )
  test('should NOT error if no expression but has modifier', function()
    local onError = jest:fn()
    parseWithVOn({onError=onError})
    expect(onError).tsvar_not:toHaveBeenCalled()
  end
  )
  test('case conversion for vnode hooks', function()
    local  = parseWithVOn()
    expect(node.codegenNode.props):toMatchObject({properties={{key={content=}, value={content=}}}})
  end
  )
  describe('cacheHandler', function()
    test('empty handler', function()
      local  = parseWithVOn({prefixIdentifiers=true, cacheHandlers=true})
      expect(root.cached):toBe(1)
      local vnodeCall = node.codegenNode
      expect(vnodeCall.patchFlag):toBeUndefined()
      expect(vnodeCall.props.properties[0+1].value):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.SIMPLE_EXPRESSION, content=}})
    end
    )
    test('member expression handler', function()
      local  = parseWithVOn({prefixIdentifiers=true, cacheHandlers=true})
      expect(root.cached):toBe(1)
      local vnodeCall = node.codegenNode
      expect(vnodeCall.patchFlag):toBeUndefined()
      expect(vnodeCall.props.properties[0+1].value):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}})
    end
    )
    test('inline function expression handler', function()
      local  = parseWithVOn({prefixIdentifiers=true, cacheHandlers=true})
      expect(root.cached):toBe(1)
      local vnodeCall = node.codegenNode
      expect(vnodeCall.patchFlag):toBeUndefined()
      expect(vnodeCall.props.properties[0+1].value):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}})
    end
    )
    test('inline statement handler', function()
      local  = parseWithVOn({prefixIdentifiers=true, cacheHandlers=true})
      expect(root.cached):toBe(1)
      expect(root.cached):toBe(1)
      local vnodeCall = node.codegenNode
      expect(vnodeCall.patchFlag):toBeUndefined()
      expect(vnodeCall.props.properties[0+1].value):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.COMPOUND_EXPRESSION, children={{children={{content=}, }}, }}})
    end
    )
  end
  )
end
)