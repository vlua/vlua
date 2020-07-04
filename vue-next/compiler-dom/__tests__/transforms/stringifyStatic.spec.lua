require("compiler-dom/src")
require("compiler-dom/src/NodeTypes")
require("compiler-dom/src/transforms/stringifyStatic")
require("compiler-dom/src/transforms/stringifyStatic/StringifyThresholds")

describe('stringify static html', function()
  function compileWithStringify(template)
    return compile(template, {hoistStatic=true, prefixIdentifiers=true, transformHoist=stringifyStatic})
  end
  
  function tsvar_repeat(code, n)
    return ({}):fill(0):map(function()
      code
    end
    ):join('')
  end
  
  test('should bail on non-eligible static trees', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(().type):toBe(NodeTypes.VNODE_CALL)
  end
  )
  test('should work on eligible content (elements with binding > 5)', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_STATIC, arguments={JSON:stringify(), '1'}})
  end
  )
  test('should work on eligible content (elements > 20)', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_STATIC, arguments={JSON:stringify(), '1'}})
  end
  )
  test('should work for multiple adjacent nodes', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(5)
    local i = 1
    repeat
      expect(ast.hoists[i+1]):toBe(nil)
      i=i+1
    until not(i < 5)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_STATIC, arguments={JSON:stringify(tsvar_repeat(StringifyThresholds.ELEMENT_WITH_BINDING_COUNT)), '5'}})
  end
  )
  test('serializing constant bindings', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_STATIC, arguments={JSON:stringify(), '1'}})
  end
  )
  test('escape', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_STATIC, arguments={JSON:stringify(), '1'}})
  end
  )
  test('should bail on runtime constant v-bind bindings', function()
    local  = compile({hoistStatic=true, prefixIdentifiers=true, transformHoist=stringifyStatic, nodeTransforms={function(node)
      if node.type == NodeTypes.ELEMENT and node.tag == 'img' then
        local exp = createSimpleExpression('_imports_0_', false, node.loc, true)
        exp.isRuntimeConstant = true
        node.props[0+1] = {type=NodeTypes.DIRECTIVE, name='bind', arg=createSimpleExpression('src', true), exp=exp, modifiers={}, loc=node.loc}
      end
    end
    }})
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.VNODE_CALL})
  end
  )
  test('should bail on non attribute bindings', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.VNODE_CALL})
    local  = compileWithStringify()
    expect(#ast2.hoists):toBe(1)
    expect(ast2.hoists[0+1]):toMatchObject({type=NodeTypes.VNODE_CALL})
  end
  )
  test('should bail on non attribute bindings', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.VNODE_CALL})
    local  = compileWithStringify()
    expect(#ast2.hoists):toBe(1)
    expect(ast2.hoists[0+1]):toMatchObject({type=NodeTypes.VNODE_CALL})
  end
  )
  test('should bail on tags that has placement constraints (eg.tables related tags)', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(1)
    expect(ast.hoists[0+1]):toMatchObject({type=NodeTypes.VNODE_CALL})
  end
  )
  test('should bail inside slots', function()
    local  = compileWithStringify()
    expect(#ast.hoists):toBe(StringifyThresholds.ELEMENT_WITH_BINDING_COUNT)
    ast.hoists:forEach(function(node)
      expect(node):toMatchObject({type=NodeTypes.VNODE_CALL})
    end
    )
    local  = compileWithStringify()
    expect(#ast2.hoists):toBe(StringifyThresholds.ELEMENT_WITH_BINDING_COUNT)
    ast2.hoists:forEach(function(node)
      expect(node):toMatchObject({type=NodeTypes.VNODE_CALL})
    end
    )
  end
  )
end
)