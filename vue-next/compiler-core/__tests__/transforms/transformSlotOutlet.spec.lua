require("compiler-core/src")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/ErrorCodes")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/vOn")
require("compiler-core/src/transforms/vBind")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/transforms/transformSlotOutlet")
local parse = baseParse

function parseWithSlots(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={..., transformSlotOutlet, transformElement}, directiveTransforms={on=transformOn, bind=transformBind}, ...})
  return ast
end

describe('compiler: transform <slot> outlets', function()
  test('default slot outlet', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={}})
  end
  )
  test('statically named slot outlet', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={}})
  end
  )
  test('dynamically named slot outlet', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}})
  end
  )
  test('dynamically named slot outlet w/ prefixIdentifiers: true', function()
    local ast = parseWithSlots({prefixIdentifiers=true})
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.COMPOUND_EXPRESSION, children={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}, , {type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}}})
  end
  )
  test('default slot outlet with props', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{key={content=, isStatic=true}, value={content=, isStatic=true}}, {key={content=, isStatic=true}, value={content=, isStatic=false}}}}}})
  end
  )
  test('statically named slot outlet with props', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{key={content=, isStatic=true}, value={content=, isStatic=true}}, {key={content=, isStatic=true}, value={content=, isStatic=false}}}}}})
  end
  )
  test('dynamically named slot outlet with props', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{content=, isStatic=false}, {type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{key={content=, isStatic=true}, value={content=, isStatic=true}}, {key={content=, isStatic=true}, value={content=, isStatic=false}}}}}})
  end
  )
  test('default slot outlet with fallback', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.JS_FUNCTION_EXPRESSION, params={}, returns={{type=NodeTypes.ELEMENT, tag=}}}}})
  end
  )
  test('named slot outlet with fallback', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.JS_FUNCTION_EXPRESSION, params={}, returns={{type=NodeTypes.ELEMENT, tag=}}}}})
  end
  )
  test('default slot outlet with props & fallback', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{key={content=, isStatic=true}, value={content=, isStatic=false}}}}, {type=NodeTypes.JS_FUNCTION_EXPRESSION, params={}, returns={{type=NodeTypes.ELEMENT, tag=}}}}})
  end
  )
  test('named slot outlet with props & fallback', function()
    local ast = parseWithSlots()
    expect(ast.children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={{type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{key={content=, isStatic=true}, value={content=, isStatic=false}}}}, {type=NodeTypes.JS_FUNCTION_EXPRESSION, params={}, returns={{type=NodeTypes.ELEMENT, tag=}}}}})
  end
  )
  test(function()
    local onError = jest:fn()
    local source = nil
    parseWithSlots(source, {onError=onError})
    local index = source:find('v-foo')
    expect(onError.mock.calls[0+1][0+1]):toMatchObject({code=ErrorCodes.X_V_SLOT_UNEXPECTED_DIRECTIVE_ON_SLOT_OUTLET, loc={source=, start={offset=index, line=1, column=index + 1}, tsvar_end={offset=index + 5, line=1, column=index + 6}}})
  end
  )
end
)