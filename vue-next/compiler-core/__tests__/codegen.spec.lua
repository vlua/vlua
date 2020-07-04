require("stringutil")
require("compiler-core/src")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/__tests__/testUtils")
require("@vue/shared/PatchFlags")

function createRoot(options)
  if options == nil then
    options={}
  end
  return {type=NodeTypes.ROOT, children={}, helpers={}, components={}, directives={}, imports={}, hoists={}, cached=0, temps=0, codegenNode=createSimpleExpression(false), loc=locStub, ...}
end

describe('compiler: codegen', function()
  test('module mode preamble', function()
    local root = createRoot({helpers={CREATE_VNODE, RESOLVE_DIRECTIVE}})
    local  = generate(root, {mode='module'})
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('module mode preamble w/ optimizeBindings: true', function()
    local root = createRoot({helpers={CREATE_VNODE, RESOLVE_DIRECTIVE}})
    local  = generate(root, {mode='module', optimizeBindings=true})
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('function mode preamble', function()
    local root = createRoot({helpers={CREATE_VNODE, RESOLVE_DIRECTIVE}})
    local  = generate(root, {mode='function'})
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('function mode preamble w/ prefixIdentifiers: true', function()
    local root = createRoot({helpers={CREATE_VNODE, RESOLVE_DIRECTIVE}})
    local  = generate(root, {mode='function', prefixIdentifiers=true})
    expect(code).tsvar_not:toMatch()
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('assets + temps', function()
    local root = createRoot({components={}, directives={}, temps=3})
    local  = generate(root, {mode='function'})
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('hoists', function()
    local root = createRoot({hoists={createSimpleExpression(false, locStub), createObjectExpression({createObjectProperty(createSimpleExpression(true, locStub), createSimpleExpression(true, locStub))}, locStub)}})
    local  = generate(root)
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('temps', function()
    local root = createRoot({temps=3})
    local  = generate(root)
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('static text', function()
    local  = generate(createRoot({codegenNode={type=NodeTypes.TEXT, content='hello', loc=locStub}}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('interpolation', function()
    local  = generate(createRoot({codegenNode=createInterpolation(locStub)}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('comment', function()
    local  = generate(createRoot({codegenNode={type=NodeTypes.COMMENT, content='foo', loc=locStub}}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('compound expression', function()
    local  = generate(createRoot({codegenNode=createCompoundExpression({createSimpleExpression(false, locStub), , {type=NodeTypes.INTERPOLATION, loc=locStub, content=createSimpleExpression(false, locStub)}, createCompoundExpression({})})}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('ifNode', function()
    local  = generate(createRoot({codegenNode={type=NodeTypes.IF, loc=locStub, branches={}, codegenNode=createConditionalExpression(createSimpleExpression('foo', false), createSimpleExpression('bar', false), createSimpleExpression('baz', false))}}))
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    expect(code):toMatch(/return foo\s+\? bar\s+: baz/)
    expect(code):toMatchSnapshot()
  end
  )
  test('forNode', function()
    local  = generate(createRoot({codegenNode={type=NodeTypes.FOR, loc=locStub, source=createSimpleExpression('foo', false), valueAlias=undefined, keyAlias=undefined, objectIndexAlias=undefined, children={}, parseResult={}, codegenNode={type=NodeTypes.VNODE_CALL, tag=FRAGMENT, isBlock=true, disableTracking=true, props=undefined, children=createCallExpression(RENDER_LIST), patchFlag='1', dynamicProps=undefined, directives=undefined, loc=locStub}}}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('forNode with constant expression', function()
    local  = generate(createRoot({codegenNode={type=NodeTypes.FOR, loc=locStub, source=createSimpleExpression('1 + 2', false, locStub, true), valueAlias=undefined, keyAlias=undefined, objectIndexAlias=undefined, children={}, parseResult={}, codegenNode={type=NodeTypes.VNODE_CALL, tag=FRAGMENT, isBlock=true, disableTracking=false, props=undefined, children=createCallExpression(RENDER_LIST), patchFlag=genFlagText(PatchFlags.STABLE_FRAGMENT), dynamicProps=undefined, directives=undefined, loc=locStub}}}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('Element (callExpression + objectExpression + TemplateChildNode[])', function()
    local  = generate(createRoot({codegenNode=createElementWithCodegen(createObjectExpression({createObjectProperty(createSimpleExpression(true, locStub), createSimpleExpression(true, locStub)), createObjectProperty(createSimpleExpression(false, locStub), createSimpleExpression(false, locStub)), createObjectProperty({type=NodeTypes.COMPOUND_EXPRESSION, loc=locStub, children={createSimpleExpression(false, locStub)}}, createSimpleExpression(false, locStub))}, locStub), {createElementWithCodegen(createObjectExpression({createObjectProperty(createSimpleExpression(true, locStub), createSimpleExpression(true, locStub))}, locStub))}, PatchFlags.FULL_PROPS .. '')}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('ArrayExpression', function()
    local  = generate(createRoot({codegenNode=createArrayExpression({createSimpleExpression(false), createCallExpression({})})}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('ConditionalExpression', function()
    local  = generate(createRoot({codegenNode=createConditionalExpression(createSimpleExpression(false), createCallExpression(), createConditionalExpression(createSimpleExpression(false), createCallExpression(), createCallExpression()))}))
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('CacheExpression', function()
    local  = generate(createRoot({cached=1, codegenNode=createCacheExpression(1, createSimpleExpression(false))}), {mode='module', prefixIdentifiers=true})
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('CacheExpression w/ isVNode: true', function()
    local  = generate(createRoot({cached=1, codegenNode=createCacheExpression(1, createSimpleExpression(false), true)}), {mode='module', prefixIdentifiers=true})
    expect(code):toMatch(():trim())
    expect(code):toMatchSnapshot()
  end
  )
  test('TemplateLiteral', function()
    local  = generate(createRoot({codegenNode=createCallExpression({createTemplateLiteral({createCallExpression({'id', 'foo'}), })})}), {ssr=true, mode='module'})
    expect(code):toMatchInlineSnapshot()
  end
  )
  describe('IfStatement', function()
    test('if', function()
      local  = generate(createRoot({codegenNode=createBlockStatement({createIfStatement(createSimpleExpression('foo', false), createBlockStatement({createCallExpression()}))})}), {ssr=true, mode='module'})
      expect(code):toMatchInlineSnapshot()
    end
    )
    test('if/else', function()
      local  = generate(createRoot({codegenNode=createBlockStatement({createIfStatement(createSimpleExpression('foo', false), createBlockStatement({createCallExpression()}), createBlockStatement({createCallExpression('bar')}))})}), {ssr=true, mode='module'})
      expect(code):toMatchInlineSnapshot()
    end
    )
    test('if/else-if', function()
      local  = generate(createRoot({codegenNode=createBlockStatement({createIfStatement(createSimpleExpression('foo', false), createBlockStatement({createCallExpression()}), createIfStatement(createSimpleExpression('bar', false), createBlockStatement({createCallExpression()})))})}), {ssr=true, mode='module'})
      expect(code):toMatchInlineSnapshot()
    end
    )
    test('if/else-if/else', function()
      local  = generate(createRoot({codegenNode=createBlockStatement({createIfStatement(createSimpleExpression('foo', false), createBlockStatement({createCallExpression()}), createIfStatement(createSimpleExpression('bar', false), createBlockStatement({createCallExpression()}), createBlockStatement({createCallExpression('baz')})))})}), {ssr=true, mode='module'})
      expect(code):toMatchInlineSnapshot()
    end
    )
  end
  )
  test('AssignmentExpression', function()
    local  = generate(createRoot({codegenNode=createAssignmentExpression(createSimpleExpression(false), createSimpleExpression(false))}))
    expect(code):toMatchInlineSnapshot()
  end
  )
  describe('VNodeCall', function()
    function genCode(node)
      return ()[1+1]
    end
    
    local mockProps = createObjectExpression({createObjectProperty(createSimpleExpression(true))})
    local mockChildren = createCompoundExpression({'children'})
    local mockDirs = createArrayExpression({createArrayExpression({createSimpleExpression(false)})})
    test('tag only', function()
      expect(genCode(createVNodeCall(nil, ))):toMatchInlineSnapshot()
      expect(genCode(createVNodeCall(nil, FRAGMENT))):toMatchInlineSnapshot()
    end
    )
    test('with props', function()
      expect(genCode(createVNodeCall(nil, , mockProps))):toMatchInlineSnapshot()
    end
    )
    test('with children, no props', function()
      expect(genCode(createVNodeCall(nil, , undefined, mockChildren))):toMatchInlineSnapshot()
    end
    )
    test('with children + props', function()
      expect(genCode(createVNodeCall(nil, , mockProps, mockChildren))):toMatchInlineSnapshot()
    end
    )
    test('with patchFlag and no children/props', function()
      expect(genCode(createVNodeCall(nil, , undefined, undefined, '1'))):toMatchInlineSnapshot()
    end
    )
    test('as block', function()
      expect(genCode(createVNodeCall(nil, , mockProps, mockChildren, undefined, undefined, undefined, true))):toMatchInlineSnapshot()
    end
    )
    test('as for block', function()
      expect(genCode(createVNodeCall(nil, , mockProps, mockChildren, undefined, undefined, undefined, true, true))):toMatchInlineSnapshot()
    end
    )
    test('with directives', function()
      expect(genCode(createVNodeCall(nil, , mockProps, mockChildren, undefined, undefined, mockDirs))):toMatchInlineSnapshot()
    end
    )
    test('block + directives', function()
      expect(genCode(createVNodeCall(nil, , mockProps, mockChildren, undefined, undefined, mockDirs, true))):toMatchInlineSnapshot()
    end
    )
  end
  )
end
)