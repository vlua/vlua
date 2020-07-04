require("@vue/compiler-core")
require("@vue/compiler-core/NodeTypes")
require("compiler-dom/src/transforms/vOn")
require("compiler-dom/src/runtimeHelpers")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/transformExpression")
require("compiler-core/__tests__/testUtils")
require("@vue/shared/PatchFlags")
local parse = baseParse

function parseWithVOn(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformExpression, transformElement}, directiveTransforms={on=transformOn}, ...})
  return {root=ast, props=ast.children[0+1].codegenNode.props.properties}
end

describe('compiler-dom: transform v-on', function()
  it('should support multiple modifiers w/ prefixIdentifiers: true', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(prop):toMatchObject({type=NodeTypes.JS_PROPERTY, value={callee=V_ON_WITH_MODIFIERS, arguments={{content='_ctx.test'}, '["stop","prevent"]'}}})
  end
  )
  it('should support multiple events and modifiers options w/ prefixIdentifiers: true', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    local  = props
    expect(props):toHaveLength(2)
    expect(clickProp):toMatchObject({type=NodeTypes.JS_PROPERTY, value={callee=V_ON_WITH_MODIFIERS, arguments={{content='_ctx.test'}, '["stop"]'}}})
    expect(keyUpProp):toMatchObject({type=NodeTypes.JS_PROPERTY, value={callee=V_ON_WITH_KEYS, arguments={{content='_ctx.test'}, '["enter"]'}}})
  end
  )
  it('should support multiple modifiers and event options w/ prefixIdentifiers: true', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(prop):toMatchObject({type=NodeTypes.JS_PROPERTY, value=createObjectMatcher({handler={callee=V_ON_WITH_MODIFIERS, arguments={{content='_ctx.test'}, '["stop"]'}}, options=createObjectMatcher({capture={content='true', isStatic=false}, passive={content='true', isStatic=false}})})})
  end
  )
  it('should wrap keys guard for keyboard events or dynamic events', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(prop):toMatchObject({type=NodeTypes.JS_PROPERTY, value=createObjectMatcher({handler={callee=V_ON_WITH_KEYS, arguments={{callee=V_ON_WITH_MODIFIERS, arguments={{content='_ctx.test'}, '["stop","ctrl"]'}}, '["a"]'}}, options=createObjectMatcher({capture={content='true', isStatic=false}})})})
  end
  )
  it('should not wrap keys guard if no key modifier is present', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(prop):toMatchObject({type=NodeTypes.JS_PROPERTY, value={callee=V_ON_WITH_MODIFIERS, arguments={{content='_ctx.test'}, '["exact"]'}}})
  end
  )
  it('should not wrap normal guard if there is only keys guard', function()
    local  = parseWithVOn({prefixIdentifiers=true})
    expect(prop):toMatchObject({type=NodeTypes.JS_PROPERTY, value={callee=V_ON_WITH_KEYS, arguments={{content='_ctx.test'}, '["enter"]'}}})
  end
  )
  test('should transform click.right', function()
    local  = parseWithVOn()
    expect(prop.key):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    local  = parseWithVOn()
    expect(prop2.key):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{children={{content='event'}, }}, , {children={{content='event'}, }}, }})
  end
  )
  test('should transform click.middle', function()
    local  = parseWithVOn()
    expect(prop.key):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    local  = parseWithVOn()
    expect(prop2.key):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{children={{content='event'}, }}, , {children={{content='event'}, }}, }})
  end
  )
  test('cache handler w/ modifiers', function()
    local  = parseWithVOn({prefixIdentifiers=true, cacheHandlers=true})
    expect(root.cached):toBe(1)
    expect(root.children[0+1].codegenNode.patchFlag):toBe(genFlagText(PatchFlags.HYDRATE_EVENTS))
    expect(prop.value):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{key={content='handler'}, value={type=NodeTypes.JS_CALL_EXPRESSION, callee=V_ON_WITH_KEYS}}, {key={content='options'}, value={type=NodeTypes.JS_OBJECT_EXPRESSION}}}}})
  end
  )
end
)