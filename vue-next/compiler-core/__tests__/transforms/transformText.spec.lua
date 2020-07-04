require("compiler-core/src")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/transforms/vFor")
require("compiler-core/src/transforms/transformText")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/__tests__/testUtils")
require("@vue/shared/PatchFlags")
local parse = baseParse

function transformWithTextOpt(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformFor, ..., transformText, transformElement}, ...})
  return ast
end

describe('compiler: transform text', function()
  test('no consecutive text', function()
    local root = transformWithTextOpt()
    expect(root.children[0+1]):toMatchObject({type=NodeTypes.INTERPOLATION, content={content=}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('consecutive text', function()
    local root = transformWithTextOpt()
    expect(#root.children):toBe(1)
    expect(root.children[0+1]):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{type=NodeTypes.INTERPOLATION, content={content=}}, , {type=NodeTypes.TEXT, content=}, , {type=NodeTypes.INTERPOLATION, content={content=}}}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('consecutive text between elements', function()
    local root = transformWithTextOpt()
    expect(#root.children):toBe(3)
    expect(root.children[0+1].type):toBe(NodeTypes.ELEMENT)
    expect(root.children[1+1]):toMatchObject({type=NodeTypes.TEXT_CALL, codegenNode={type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_TEXT, arguments={{type=NodeTypes.COMPOUND_EXPRESSION, children={{type=NodeTypes.INTERPOLATION, content={content=}}, , {type=NodeTypes.TEXT, content=}, , {type=NodeTypes.INTERPOLATION, content={content=}}}}, genFlagText(PatchFlags.TEXT)}}})
    expect(root.children[2+1].type):toBe(NodeTypes.ELEMENT)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('text between elements (static)', function()
    local root = transformWithTextOpt()
    expect(#root.children):toBe(3)
    expect(root.children[0+1].type):toBe(NodeTypes.ELEMENT)
    expect(root.children[1+1]):toMatchObject({type=NodeTypes.TEXT_CALL, codegenNode={type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_TEXT, arguments={{type=NodeTypes.TEXT, content=}}}})
    expect(root.children[2+1].type):toBe(NodeTypes.ELEMENT)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('consecutive text mixed with elements', function()
    local root = transformWithTextOpt()
    expect(#root.children):toBe(5)
    expect(root.children[0+1].type):toBe(NodeTypes.ELEMENT)
    expect(root.children[1+1]):toMatchObject({type=NodeTypes.TEXT_CALL, codegenNode={type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_TEXT, arguments={{type=NodeTypes.COMPOUND_EXPRESSION, children={{type=NodeTypes.INTERPOLATION, content={content=}}, , {type=NodeTypes.TEXT, content=}, , {type=NodeTypes.INTERPOLATION, content={content=}}}}, genFlagText(PatchFlags.TEXT)}}})
    expect(root.children[2+1].type):toBe(NodeTypes.ELEMENT)
    expect(root.children[3+1]):toMatchObject({type=NodeTypes.TEXT_CALL, codegenNode={type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_TEXT, arguments={{type=NodeTypes.TEXT, content=}}}})
    expect(root.children[4+1].type):toBe(NodeTypes.ELEMENT)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('<template v-for>', function()
    local root = transformWithTextOpt()
    expect(root.children[0+1].type):toBe(NodeTypes.FOR)
    local forNode = root.children[0+1]
    expect(forNode.children[0+1]):toMatchObject({type=NodeTypes.TEXT_CALL})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('with prefixIdentifiers: true', function()
    local root = transformWithTextOpt({prefixIdentifiers=true})
    expect(#root.children):toBe(1)
    expect(root.children[0+1]):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{type=NodeTypes.INTERPOLATION, content={content=}}, , {type=NodeTypes.TEXT, content=}, , {type=NodeTypes.INTERPOLATION, content={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}}}}}})
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
end
)