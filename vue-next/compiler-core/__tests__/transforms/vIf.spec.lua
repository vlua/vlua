require("compiler-core/src/parse")
require("compiler-core/src/transform")
require("compiler-core/src/transforms/vIf")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/transformSlotOutlet")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/__tests__/testUtils")
local parse = baseParse

function parseWithIfTransform(template, options, returnIndex)
  if options == nil then
    options={}
  end
  if returnIndex == nil then
    returnIndex=0
  end
  local ast = parse(template, options)
  transform(ast, {nodeTransforms={transformIf, transformSlotOutlet, transformElement}, ...})
  if not options.onError then
    expect(#ast.children):toBe(1)
    expect(ast.children[0+1].type):toBe(NodeTypes.IF)
  end
  -- [ts2lua]ast.children下标访问可能不正确
  return {root=ast, node=ast.children[returnIndex]}
end

describe('compiler: v-if', function()
  describe('transform', function()
    test('basic v-if', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(1)
      expect(node.branches[0+1].condition.content):toBe()
      expect(#node.branches[0+1].children):toBe(1)
      expect(node.branches[0+1].children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(node.branches[0+1].children[0+1].tag):toBe()
    end
    )
    test('template v-if', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(1)
      expect(node.branches[0+1].condition.content):toBe()
      expect(#node.branches[0+1].children):toBe(3)
      expect(node.branches[0+1].children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(node.branches[0+1].children[0+1].tag):toBe()
      expect(node.branches[0+1].children[1+1].type):toBe(NodeTypes.TEXT)
      expect(node.branches[0+1].children[1+1].content):toBe()
      expect(node.branches[0+1].children[2+1].type):toBe(NodeTypes.ELEMENT)
      expect(node.branches[0+1].children[2+1].tag):toBe()
    end
    )
    test('component v-if', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(1)
      expect(node.branches[0+1].children[0+1].tag):toBe()
      expect(node.branches[0+1].children[0+1].tagType):toBe(ElementTypes.COMPONENT)
      expect(().isBlock):toBe(false)
    end
    )
    test('v-if + v-else', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(2)
      local b1 = node.branches[0+1]
      expect(b1.condition.content):toBe()
      expect(#b1.children):toBe(1)
      expect(b1.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(b1.children[0+1].tag):toBe()
      local b2 = node.branches[1+1]
      expect(b2.condition):toBeUndefined()
      expect(#b2.children):toBe(1)
      expect(b2.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(b2.children[0+1].tag):toBe()
    end
    )
    test('v-if + v-else-if', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(2)
      local b1 = node.branches[0+1]
      expect(b1.condition.content):toBe()
      expect(#b1.children):toBe(1)
      expect(b1.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(b1.children[0+1].tag):toBe()
      local b2 = node.branches[1+1]
      expect(b2.condition.content):toBe()
      expect(#b2.children):toBe(1)
      expect(b2.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(b2.children[0+1].tag):toBe()
    end
    )
    test('v-if + v-else-if + v-else', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(3)
      local b1 = node.branches[0+1]
      expect(b1.condition.content):toBe()
      expect(#b1.children):toBe(1)
      expect(b1.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(b1.children[0+1].tag):toBe()
      local b2 = node.branches[1+1]
      expect(b2.condition.content):toBe()
      expect(#b2.children):toBe(1)
      expect(b2.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(b2.children[0+1].tag):toBe()
      local b3 = node.branches[2+1]
      expect(b3.condition):toBeUndefined()
      expect(#b3.children):toBe(1)
      expect(b3.children[0+1].type):toBe(NodeTypes.TEXT)
      expect(b3.children[0+1].content):toBe()
    end
    )
    test('comment between branches', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(3)
      local b1 = node.branches[0+1]
      expect(b1.condition.content):toBe()
      expect(#b1.children):toBe(1)
      expect(b1.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(b1.children[0+1].tag):toBe()
      local b2 = node.branches[1+1]
      expect(b2.condition.content):toBe()
      expect(#b2.children):toBe(2)
      expect(b2.children[0+1].type):toBe(NodeTypes.COMMENT)
      expect(b2.children[0+1].content):toBe()
      expect(b2.children[1+1].type):toBe(NodeTypes.ELEMENT)
      expect(b2.children[1+1].tag):toBe()
      local b3 = node.branches[2+1]
      expect(b3.condition):toBeUndefined()
      expect(#b3.children):toBe(2)
      expect(b3.children[0+1].type):toBe(NodeTypes.COMMENT)
      expect(b3.children[0+1].content):toBe()
      expect(b3.children[1+1].type):toBe(NodeTypes.TEXT)
      expect(b3.children[1+1].content):toBe()
    end
    )
    test('should prefix v-if condition', function()
      local  = parseWithIfTransform({prefixIdentifiers=true})
      expect(node.branches[0+1].condition):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    end
    )
  end
  )
  describe('errors', function()
    test('error on v-else missing adjacent v-if', function()
      local onError = jest:fn()
      local  = parseWithIfTransform({onError=onError})
      expect(onError.mock.calls[0+1]):toMatchObject({{code=ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, loc=node1.loc}})
      local  = parseWithIfTransform({onError=onError}, 1)
      expect(onError.mock.calls[1+1]):toMatchObject({{code=ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, loc=node2.loc}})
      local  = parseWithIfTransform({onError=onError}, 2)
      expect(onError.mock.calls[2+1]):toMatchObject({{code=ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, loc=node3.loc}})
    end
    )
    test('error on v-else-if missing adjacent v-if', function()
      local onError = jest:fn()
      local  = parseWithIfTransform({onError=onError})
      expect(onError.mock.calls[0+1]):toMatchObject({{code=ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, loc=node1.loc}})
      local  = parseWithIfTransform({onError=onError}, 1)
      expect(onError.mock.calls[1+1]):toMatchObject({{code=ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, loc=node2.loc}})
      local  = parseWithIfTransform({onError=onError}, 2)
      expect(onError.mock.calls[2+1]):toMatchObject({{code=ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, loc=node3.loc}})
    end
    )
  end
  )
  describe('codegen', function()
    function assertSharedCodegen(node, depth, hasElse)
      if depth == nil then
        depth=0
      end
      if hasElse == nil then
        hasElse=false
      end
      -- [ts2lua]lua中0和空字符串也是true，此处hasElse需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处hasElse需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处depth < 1需要确认
      expect(node):toMatchObject({type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test={content=}, consequent={type=NodeTypes.VNODE_CALL, isBlock=true}, alternate=(depth < 1 and {(hasElse and {{type=NodeTypes.VNODE_CALL, isBlock=true}} or {{type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_COMMENT}})[1]} or {{type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test={content=}, consequent={type=NodeTypes.VNODE_CALL, isBlock=true}, alternate=(hasElse and {{type=NodeTypes.VNODE_CALL, isBlock=true}} or {{type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_COMMENT}})[1]}})[1]})
    end
    
    test('basic v-if', function()
      local  = parseWithIfTransform()
      assertSharedCodegen(codegenNode)
      expect(codegenNode.consequent):toMatchObject({tag=, props=createObjectMatcher({key=})})
      expect(codegenNode.alternate):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_COMMENT})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('template v-if', function()
      local  = parseWithIfTransform()
      assertSharedCodegen(codegenNode)
      expect(codegenNode.consequent):toMatchObject({tag=FRAGMENT, props=createObjectMatcher({key=}), children={{type=NodeTypes.ELEMENT, tag='div'}, {type=NodeTypes.TEXT, content=}, {type=NodeTypes.ELEMENT, tag='p'}}})
      expect(codegenNode.alternate):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_COMMENT})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('template v-if w/ single <slot/> child', function()
      local  = parseWithIfTransform()
      expect(codegenNode.consequent):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={'$slots', '"default"', createObjectMatcher({key=})}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-if on <slot/>', function()
      local  = parseWithIfTransform()
      expect(codegenNode.consequent):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT, arguments={'$slots', '"default"', createObjectMatcher({key=})}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-if + v-else', function()
      local  = parseWithIfTransform()
      assertSharedCodegen(codegenNode, 0, true)
      expect(codegenNode.consequent):toMatchObject({tag=, props=createObjectMatcher({key=})})
      expect(codegenNode.alternate):toMatchObject({tag=, props=createObjectMatcher({key=})})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-if + v-else-if', function()
      local  = parseWithIfTransform()
      assertSharedCodegen(codegenNode, 1)
      expect(codegenNode.consequent):toMatchObject({tag=, props=createObjectMatcher({key=})})
      local branch2 = codegenNode.alternate
      expect(branch2.consequent):toMatchObject({tag=, props=createObjectMatcher({key=})})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-if + v-else-if + v-else', function()
      local  = parseWithIfTransform()
      assertSharedCodegen(codegenNode, 1, true)
      expect(codegenNode.consequent):toMatchObject({tag=, props=createObjectMatcher({key=})})
      local branch2 = codegenNode.alternate
      expect(branch2.consequent):toMatchObject({tag=, props=createObjectMatcher({key=})})
      expect(branch2.alternate):toMatchObject({tag=FRAGMENT, props=createObjectMatcher({key=}), children={{type=NodeTypes.TEXT, content=}}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('key injection (only v-bind)', function()
      local  = parseWithIfTransform()
      local branch1 = codegenNode.consequent
      expect(branch1.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={createObjectMatcher({key=}), {content=}}})
    end
    )
    test('key injection (before v-bind)', function()
      local  = parseWithIfTransform()
      local branch1 = codegenNode.consequent
      expect(branch1.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={createObjectMatcher({key='[0]', id='foo'}), {content=}}})
    end
    )
    test('key injection (after v-bind)', function()
      local  = parseWithIfTransform()
      local branch1 = codegenNode.consequent
      expect(branch1.props):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=MERGE_PROPS, arguments={createObjectMatcher({key=}), {content=}, createObjectMatcher({id='foo'})}})
    end
    )
    test('key injection (w/ custom directive)', function()
      local  = parseWithIfTransform()
      local branch1 = codegenNode.consequent
      expect(branch1.directives).tsvar_not:toBeUndefined()
      expect(branch1.props):toMatchObject(createObjectMatcher({key=}))
    end
    )
    test('v-if with key', function()
      local  = parseWithIfTransform()
      expect(codegenNode.consequent):toMatchObject({tag=, props=createObjectMatcher({key='some-key'})})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('with comments', function()
      local  = parseWithIfTransform()
      expect(node.type):toBe(NodeTypes.IF)
      expect(#node.branches):toBe(1)
      local b1 = node.branches[0+1]
      expect(b1.condition.content):toBe()
      expect(#b1.children):toBe(4)
      expect(b1.children[0+1].type):toBe(NodeTypes.COMMENT)
      expect(b1.children[0+1].content):toBe()
      expect(b1.children[1+1].type):toBe(NodeTypes.IF)
      expect(#b1.children[1+1].branches):toBe(2)
      local b1b1 = b1.children[1+1].branches[0+1].children[0+1]
      expect(b1b1.type):toBe(NodeTypes.ELEMENT)
      expect(b1b1.tag):toBe('div')
      expect(b1b1.children[0+1].type):toBe(NodeTypes.COMMENT)
      expect(b1b1.children[0+1].content):toBe('comment2')
      local b1b2 = b1.children[1+1].branches[1+1]
      expect(b1b2.children[0+1].type):toBe(NodeTypes.COMMENT)
      expect(b1b2.children[0+1].content):toBe()
      expect(b1b2.children[1+1].type):toBe(NodeTypes.ELEMENT)
      expect(b1b2.children[1+1].tag):toBe()
      expect(b1.children[2+1].type):toBe(NodeTypes.COMMENT)
      expect(b1.children[2+1].content):toBe()
      expect(b1.children[3+1].type):toBe(NodeTypes.ELEMENT)
      expect(b1.children[3+1].tag):toBe()
    end
    )
  end
  )
end
)