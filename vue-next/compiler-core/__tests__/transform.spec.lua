require("compiler-core/src/parse")
require("compiler-core/src/transform")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/errors")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/transforms/vIf")
require("compiler-core/src/transforms/vFor")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/transformSlotOutlet")
require("compiler-core/src/transforms/transformText")
require("compiler-core/__tests__/testUtils")
require("@vue/shared/PatchFlags")

describe('compiler: transform', function()
  test('context state', function()
    local ast = baseParse()
    local calls = {}
    local plugin = function(node, context)
      table.insert(calls, {node, {...}})
    end
    
    transform(ast, {nodeTransforms={plugin}})
    local div = ast.children[0+1]
    expect(#calls):toBe(4)
    expect(calls[0+1]):toMatchObject({ast, {parent=nil, currentNode=ast}})
    expect(calls[1+1]):toMatchObject({div, {parent=ast, currentNode=div}})
    expect(calls[2+1]):toMatchObject({div.children[0+1], {parent=div, currentNode=div.children[0+1]}})
    expect(calls[3+1]):toMatchObject({div.children[1+1], {parent=div, currentNode=div.children[1+1]}})
  end
  )
  test('context.replaceNode', function()
    local ast = baseParse()
    local plugin = function(node, context)
      if node.type == NodeTypes.ELEMENT and node.tag == 'div' then
        context:replaceNode(Object:assign({}, node, {tag='p', children={{type=NodeTypes.TEXT, content='hello', isEmpty=false}}}))
      end
    end
    
    local spy = jest:fn(plugin)
    transform(ast, {nodeTransforms={spy}})
    expect(#ast.children):toBe(2)
    local newElement = ast.children[0+1]
    expect(newElement.tag):toBe('p')
    expect(spy):toHaveBeenCalledTimes(4)
    expect(spy.mock.calls[2+1][0+1]):toBe(newElement.children[0+1])
    expect(spy.mock.calls[3+1][0+1]):toBe(ast.children[1+1])
  end
  )
  test('context.removeNode', function()
    local ast = baseParse()
    local c1 = ast.children[0+1]
    local c2 = ast.children[2+1]
    local plugin = function(node, context)
      if node.type == NodeTypes.ELEMENT and node.tag == 'div' then
        context:removeNode()
      end
    end
    
    local spy = jest:fn(plugin)
    transform(ast, {nodeTransforms={spy}})
    expect(#ast.children):toBe(2)
    expect(ast.children[0+1]):toBe(c1)
    expect(ast.children[1+1]):toBe(c2)
    expect(spy):toHaveBeenCalledTimes(4)
    expect(spy.mock.calls[1+1][0+1]):toBe(c1)
    expect(spy.mock.calls[3+1][0+1]):toBe(c2)
  end
  )
  test('context.removeNode (prev sibling)', function()
    local ast = baseParse()
    local c1 = ast.children[0+1]
    local c2 = ast.children[2+1]
    local plugin = function(node, context)
      if node.type == NodeTypes.ELEMENT and node.tag == 'div' then
        context:removeNode()
        context:removeNode(().children[0+1])
      end
    end
    
    local spy = jest:fn(plugin)
    transform(ast, {nodeTransforms={spy}})
    expect(#ast.children):toBe(1)
    expect(ast.children[0+1]):toBe(c2)
    expect(spy):toHaveBeenCalledTimes(4)
    expect(spy.mock.calls[1+1][0+1]):toBe(c1)
    expect(spy.mock.calls[3+1][0+1]):toBe(c2)
  end
  )
  test('context.removeNode (next sibling)', function()
    local ast = baseParse()
    local c1 = ast.children[0+1]
    local d1 = ast.children[1+1]
    local plugin = function(node, context)
      if node.type == NodeTypes.ELEMENT and node.tag == 'div' then
        context:removeNode()
        context:removeNode(().children[1+1])
      end
    end
    
    local spy = jest:fn(plugin)
    transform(ast, {nodeTransforms={spy}})
    expect(#ast.children):toBe(1)
    expect(ast.children[0+1]):toBe(c1)
    expect(spy):toHaveBeenCalledTimes(3)
    expect(spy.mock.calls[1+1][0+1]):toBe(c1)
    expect(spy.mock.calls[2+1][0+1]):toBe(d1)
  end
  )
  test('context.hoist', function()
    local ast = baseParse()
    local hoisted = {}
    local mock = function(node, context)
      if node.type == NodeTypes.ELEMENT then
        local dir = node.props[0+1]
        table.insert(hoisted)
        dir.exp = context:hoist()
      end
    end
    
    transform(ast, {nodeTransforms={mock}})
    expect(ast.hoists):toMatchObject(hoisted)
    expect(ast.children[0+1].props[0+1].exp.content):toBe()
    expect(ast.children[1+1].props[0+1].exp.content):toBe()
  end
  )
  test('onError option', function()
    local ast = baseParse()
    local loc = ast.children[0+1].loc
    local plugin = function(node, context)
      context:onError(createCompilerError(ErrorCodes.X_INVALID_END_TAG, node.loc))
    end
    
    local spy = jest:fn()
    transform(ast, {nodeTransforms={plugin}, onError=spy})
    expect(spy.mock.calls[0+1]):toMatchObject({{code=ErrorCodes.X_INVALID_END_TAG, loc=loc}})
  end
  )
  test('should inject toString helper for interpolations', function()
    local ast = baseParse()
    transform(ast, {})
    expect(ast.helpers):toContain(TO_DISPLAY_STRING)
  end
  )
  test('should inject createVNode and Comment for comments', function()
    local ast = baseParse()
    transform(ast, {})
    expect(ast.helpers):toContain(CREATE_COMMENT)
  end
  )
  describe('root codegenNode', function()
    function transformWithCodegen(template)
      local ast = baseParse(template)
      transform(ast, {nodeTransforms={transformIf, transformFor, transformText, transformSlotOutlet, transformElement}})
      return ast
    end
    
    function createBlockMatcher(tag, props, children, patchFlag)
      return {type=NodeTypes.VNODE_CALL, isBlock=true, tag=tag, props=props, children=children, patchFlag=patchFlag}
    end
    
    test('no children', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toBeUndefined()
    end
    )
    test('single <slot/>', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject({codegenNode={type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT}})
    end
    )
    test('single element', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject(createBlockMatcher())
    end
    )
    test('root v-if', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject({type=NodeTypes.IF})
    end
    )
    test('root v-for', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject({type=NodeTypes.FOR})
    end
    )
    test('root element with custom directive', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject({type=NodeTypes.VNODE_CALL, directives={type=NodeTypes.JS_ARRAY_EXPRESSION}})
    end
    )
    test('single text', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject({type=NodeTypes.TEXT})
    end
    )
    test('single interpolation', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject({type=NodeTypes.INTERPOLATION})
    end
    )
    test('single CompoundExpression', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION})
    end
    )
    test('multiple children', function()
      local ast = transformWithCodegen()
      expect(ast.codegenNode):toMatchObject(createBlockMatcher(FRAGMENT, undefined, {{type=NodeTypes.ELEMENT, tag=}, {type=NodeTypes.ELEMENT, tag=}}, genFlagText(PatchFlags.STABLE_FRAGMENT)))
    end
    )
  end
  )
end
)