require("compiler-core/src")
require("compiler-core/src/ErrorCodes")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/transforms/transformElement")
require("compiler-dom/src/transforms/transformStyle")
require("compiler-core/src/transforms/vOn")
require("compiler-core/src/transforms/vBind")
require("@vue/shared/PatchFlags")
require("compiler-core/__tests__/testUtils")
require("compiler-core/src/transforms/transformText")
local parse = baseParse

function parseWithElementTransform(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(options)
  transform(ast, {nodeTransforms={transformElement, transformText}, ...})
  local codegenNode = ast.children[0+1].children[0+1].codegenNode
  expect(codegenNode.type):toBe(NodeTypes.VNODE_CALL)
  return {root=ast, node=codegenNode}
end

function parseWithBind(template)
  return parseWithElementTransform(template, {directiveTransforms={bind=transformBind}})
end

describe('compiler: element transform', function()
  test('import + resolve component', function()
    local  = parseWithElementTransform()
    expect(root.helpers):toContain(RESOLVE_COMPONENT)
    expect(root.components):toContain()
  end
  )
  test('static props', function()
    local  = parseWithElementTransform()
    expect(node):toMatchObject({tag=, props=createObjectMatcher({id='foo', class='bar'}), children=undefined})
  end
  )
  test('props + children', function()
    local  = parseWithElementTransform()
    expect(node):toMatchObject({tag=, props=createObjectMatcher({id='foo'}), children={{type=NodeTypes.ELEMENT, tag='span', codegenNode={type=NodeTypes.VNODE_CALL, tag=}}}})
  end
  )
  test('0 placeholder for children with no props', function()
    local  = parseWithElementTransform()
    expect(node):toMatchObject({tag=, props=undefined, children={{type=NodeTypes.ELEMENT, tag='span', codegenNode={type=NodeTypes.VNODE_CALL, tag=}}}})
  end
  )
  test('v-bind="obj"', function()
    local  = parseWithElementTransform()
    expect(root.helpers).tsvar_not:toContain(MERGE_PROPS)
    expect(node.props):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
  end
  )
  test('v-bind="obj" after static prop', function()
    local  = parseWithElementTransform()
    expect(root.helpers):toContain(MERGE_PROPS)
    expect(node.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={createObjectMatcher({id='foo'}), {type=NodeTypes.SIMPLE_EXPRESSION, content=}}})
  end
  )
  test('v-bind="obj" before static prop', function()
    local  = parseWithElementTransform()
    expect(root.helpers):toContain(MERGE_PROPS)
    expect(node.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={{type=NodeTypes.SIMPLE_EXPRESSION, content=}, createObjectMatcher({id='foo'})}})
  end
  )
  test('v-bind="obj" between static props', function()
    local  = parseWithElementTransform()
    expect(root.helpers):toContain(MERGE_PROPS)
    expect(node.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={createObjectMatcher({id='foo'}), {type=NodeTypes.SIMPLE_EXPRESSION, content=}, createObjectMatcher({class='bar'})}})
  end
  )
  test('v-on="obj"', function()
    local  = parseWithElementTransform()
    expect(root.helpers):toContain(MERGE_PROPS)
    expect(node.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={createObjectMatcher({id='foo'}), {type=NodeTypes.JS_CALL_EXPRESSION, callee=TO_HANDLERS, arguments={{type=NodeTypes.SIMPLE_EXPRESSION, content=}}}, createObjectMatcher({class='bar'})}})
  end
  )
  test('v-on="obj" + v-bind="obj"', function()
    local  = parseWithElementTransform()
    expect(root.helpers):toContain(MERGE_PROPS)
    expect(node.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={createObjectMatcher({id='foo'}), {type=NodeTypes.JS_CALL_EXPRESSION, callee=TO_HANDLERS, arguments={{type=NodeTypes.SIMPLE_EXPRESSION, content=}}}, {type=NodeTypes.SIMPLE_EXPRESSION, content=}}})
  end
  )
  test('should handle plain <template> as normal element', function()
    local  = parseWithElementTransform()
    expect(node):toMatchObject({tag=, props=createObjectMatcher({id='foo'})})
  end
  )
  test('should handle <Teleport> with normal children', function()
    function assert(tag)
      local  = parseWithElementTransform()
      expect(#root.components):toBe(0)
      expect(root.helpers):toContain(TELEPORT)
      expect(node):toMatchObject({tag=TELEPORT, props=createObjectMatcher({target='#foo'}), children={{type=NodeTypes.ELEMENT, tag='span', codegenNode={type=NodeTypes.VNODE_CALL, tag=}}}})
    end
    
    assert()
    assert()
  end
  )
  test('should handle <Suspense>', function()
    function assert(tag, content, hasFallback)
      local  = parseWithElementTransform()
      expect(#root.components):toBe(0)
      expect(root.helpers):toContain(SUSPENSE)
      -- [ts2lua]lua中0和空字符串也是true，此处hasFallback需要确认
      expect(node):toMatchObject({tag=SUSPENSE, props=undefined, children=(hasFallback and {createObjectMatcher({default={type=NodeTypes.JS_FUNCTION_EXPRESSION}, fallback={type=NodeTypes.JS_FUNCTION_EXPRESSION}, _=})} or {createObjectMatcher({default={type=NodeTypes.JS_FUNCTION_EXPRESSION}, _=})})[1]})
    end
    
    assert()
    assert()
    assert(true)
  end
  )
  test('should handle <KeepAlive>', function()
    function assert(tag)
      local root = parse()
      transform(root, {nodeTransforms={transformElement, transformText}})
      expect(#root.components):toBe(0)
      expect(root.helpers):toContain(KEEP_ALIVE)
      local node = root.children[0+1].children[0+1].codegenNode
      expect(node):toMatchObject({type=NodeTypes.VNODE_CALL, tag=KEEP_ALIVE, isBlock=true, props=undefined, children={{type=NodeTypes.ELEMENT, tag='span'}}, patchFlag=genFlagText(PatchFlags.DYNAMIC_SLOTS)})
    end
    
    assert()
    assert()
  end
  )
  test('should handle <BaseTransition>', function()
    function assert(tag)
      local  = parseWithElementTransform()
      expect(#root.components):toBe(0)
      expect(root.helpers):toContain(BASE_TRANSITION)
      expect(node):toMatchObject({tag=BASE_TRANSITION, props=undefined, children=createObjectMatcher({default={type=NodeTypes.JS_FUNCTION_EXPRESSION}, _=})})
    end
    
    assert()
    assert()
  end
  )
  test('error on v-bind with no argument', function()
    local onError = jest:fn()
    parseWithElementTransform({onError=onError})
    expect(onError.mock.calls[0+1]):toMatchObject({{code=ErrorCodes.X_V_BIND_NO_EXPRESSION}})
  end
  )
  test('directiveTransforms', function()
    local _dir = nil
    local  = parseWithElementTransform({directiveTransforms={foo=function(dir)
      _dir = dir
      return {props={createObjectProperty()}}
    end
    }})
    expect(node.props):toMatchObject({type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{type=NodeTypes.JS_PROPERTY, key=().arg, value=().exp}}})
    expect(node.patchFlag):toMatch(PatchFlags.PROPS .. '')
    expect(node.dynamicProps):toMatch()
  end
  )
  test('directiveTransform with needRuntime: true', function()
    local  = parseWithElementTransform({directiveTransforms={foo=function()
      return {props={}, needRuntime=true}
    end
    }})
    expect(root.helpers):toContain(RESOLVE_DIRECTIVE)
    expect(root.directives):toContain()
    expect(node):toMatchObject({tag=, props=undefined, children=undefined, patchFlag=genFlagText(PatchFlags.NEED_PATCH), directives={type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}, {type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}}}}}})
  end
  )
  test('directiveTransform with needRuntime: Symbol', function()
    local  = parseWithElementTransform({directiveTransforms={foo=function()
      return {props={}, needRuntime=CREATE_VNODE}
    end
    }})
    expect(root.helpers):toContain(CREATE_VNODE)
    expect(root.helpers).tsvar_not:toContain(RESOLVE_DIRECTIVE)
    expect(#root.directives):toBe(0)
    expect(().elements[0+1].elements[0+1]):toBe()
  end
  )
  test('runtime directives', function()
    local  = parseWithElementTransform()
    expect(root.helpers):toContain(RESOLVE_DIRECTIVE)
    expect(root.directives):toContain()
    expect(root.directives):toContain()
    expect(root.directives):toContain()
    expect(node):toMatchObject({directives={type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.JS_ARRAY_EXPRESSION, elements={}}, {type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.SIMPLE_EXPRESSION, content=}}}, {type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}, {type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}, {type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{type=NodeTypes.JS_PROPERTY, key={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}, {type=NodeTypes.JS_PROPERTY, key={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, value={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}}}}}}})
  end
  )
  test(function()
    local  = parseWithElementTransform({directiveTransforms={on=transformOn}})
    expect(node.props):toMatchObject({type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{type=NodeTypes.JS_PROPERTY, key={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, value={type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}, {type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}}}})
  end
  )
  test(function()
    local  = parseWithElementTransform({nodeTransforms={transformStyle, transformElement}, directiveTransforms={bind=transformBind}})
    expect(node.props):toMatchObject({type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{type=NodeTypes.JS_PROPERTY, key={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, value={type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}, {type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}}}})
  end
  )
  test(function()
    local  = parseWithElementTransform({directiveTransforms={bind=transformBind}})
    expect(node.props):toMatchObject({type=NodeTypes.JS_OBJECT_EXPRESSION, properties={{type=NodeTypes.JS_PROPERTY, key={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, value={type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=true}, {type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}}}})
  end
  )
  describe('patchFlag analysis', function()
    test('TEXT', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBeUndefined()
      local  = parseWithBind()
      expect(node2.patchFlag):toBe(genFlagText(PatchFlags.TEXT))
      local  = parseWithBind()
      expect(node3.patchFlag):toBe(genFlagText(PatchFlags.TEXT))
    end
    )
    test('CLASS', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.CLASS))
    end
    )
    test('STYLE', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.STYLE))
    end
    )
    test('PROPS', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.PROPS))
      expect(node.dynamicProps):toBe()
    end
    )
    test('CLASS + STYLE + PROPS', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText({PatchFlags.CLASS, PatchFlags.STYLE, PatchFlags.PROPS}))
      expect(node.dynamicProps):toBe()
    end
    )
    test('PROPS on component', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.PROPS))
      expect(node.dynamicProps):toBe()
    end
    )
    test('FULL_PROPS (v-bind)', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.FULL_PROPS))
    end
    )
    test('FULL_PROPS (dynamic key)', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.FULL_PROPS))
    end
    )
    test('FULL_PROPS (w/ others)', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.FULL_PROPS))
    end
    )
    test('NEED_PATCH (static ref)', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.NEED_PATCH))
    end
    )
    test('NEED_PATCH (dynamic ref)', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.NEED_PATCH))
    end
    )
    test('NEED_PATCH (custom directives)', function()
      local  = parseWithBind()
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.NEED_PATCH))
    end
    )
    test('HYDRATE_EVENTS', function()
      local  = parseWithElementTransform({directiveTransforms={on=transformOn}})
      expect(node.patchFlag):toBe(genFlagText(PatchFlags.PROPS))
      local  = parseWithElementTransform({directiveTransforms={on=transformOn}})
      expect(node2.patchFlag):toBe(genFlagText({PatchFlags.PROPS, PatchFlags.HYDRATE_EVENTS}))
    end
    )
  end
  )
  describe('dynamic component', function()
    test('static binding', function()
      local  = parseWithBind()
      expect(root.helpers):toContain(RESOLVE_DYNAMIC_COMPONENT)
      expect(node):toMatchObject({isBlock=true, tag={callee=RESOLVE_DYNAMIC_COMPONENT, arguments={{type=NodeTypes.SIMPLE_EXPRESSION, content='foo', isStatic=true}}}})
    end
    )
    test('dynamic binding', function()
      local  = parseWithBind()
      expect(root.helpers):toContain(RESOLVE_DYNAMIC_COMPONENT)
      expect(node):toMatchObject({isBlock=true, tag={callee=RESOLVE_DYNAMIC_COMPONENT, arguments={{type=NodeTypes.SIMPLE_EXPRESSION, content='foo', isStatic=false}}}})
    end
    )
    test('v-is', function()
      local  = parseWithBind()
      expect(root.helpers):toContain(RESOLVE_DYNAMIC_COMPONENT)
      expect(node):toMatchObject({tag={callee=RESOLVE_DYNAMIC_COMPONENT, arguments={{type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}}, directives=undefined})
    end
    )
  end
  )
  test('<svg> should be forced into blocks', function()
    local ast = parse()
    transform(ast, {nodeTransforms={transformElement}})
    expect(ast.children[0+1].children[0+1].codegenNode):toMatchObject({type=NodeTypes.VNODE_CALL, tag=, isBlock=true})
  end
  )
  test('element with dynamic keys should be forced into blocks', function()
    local ast = parse()
    transform(ast, {nodeTransforms={transformElement}})
    expect(ast.children[0+1].children[0+1].codegenNode):toMatchObject({type=NodeTypes.VNODE_CALL, tag=, isBlock=true})
  end
  )
end
)