require("compiler-core/src")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/transforms/vOnce")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/transforms/vBind")
require("compiler-core/src/transforms/transformSlotOutlet")
local parse = baseParse

function transformWithOnce(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformOnce, transformElement, transformSlotOutlet}, directiveTransforms={bind=transformBind}, ...})
  return ast
end

describe('compiler: v-once transform', function()
  test('as root node', function()
    local root = transformWithOnce()
    expect(root.cached):toBe(1)
    expect(root.helpers):toContain(SET_BLOCK_TRACKING)
    expect(root.codegenNode):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.VNODE_CALL, tag=}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('on nested plain element', function()
    local root = transformWithOnce()
    expect(root.cached):toBe(1)
    expect(root.helpers):toContain(SET_BLOCK_TRACKING)
    expect(root.children[0+1].children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.VNODE_CALL, tag=}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('on component', function()
    local root = transformWithOnce()
    expect(root.cached):toBe(1)
    expect(root.helpers):toContain(SET_BLOCK_TRACKING)
    expect(root.children[0+1].children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.VNODE_CALL, tag=}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('on slot outlet', function()
    local root = transformWithOnce()
    expect(root.cached):toBe(1)
    expect(root.helpers):toContain(SET_BLOCK_TRACKING)
    expect(root.children[0+1].children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('with hoistStatic: true', function()
    local root = transformWithOnce({hoistStatic=true})
    expect(root.cached):toBe(1)
    expect(root.helpers):toContain(SET_BLOCK_TRACKING)
    expect(#root.hoists):toBe(0)
    expect(root.children[0+1].children[0+1].codegenNode):toMatchObject({type=NodeTypes.JS_CACHE_EXPRESSION, index=1, value={type=NodeTypes.VNODE_CALL, tag=}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
end
)