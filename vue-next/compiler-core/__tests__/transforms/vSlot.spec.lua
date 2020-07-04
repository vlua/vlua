require("tableutil")
require("compiler-core/src")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/ErrorCodes")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/vOn")
require("compiler-core/src/transforms/vBind")
require("compiler-core/src/transforms/vSlot")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/__tests__/testUtils")
require("@vue/shared/PatchFlags")
require("compiler-core/src/transforms/vFor")
require("compiler-core/src/transforms/vIf")
local parse = baseParse

function parseWithSlots(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformIf, transformFor, ..., transformElement, trackSlotScopes}, directiveTransforms={on=transformOn, bind=transformBind}, ...})
  -- [ts2lua]lua中0和空字符串也是true，此处ast.children[0+1].type == NodeTypes.ELEMENT需要确认
  return {root=ast, slots=(ast.children[0+1].type == NodeTypes.ELEMENT and {ast.children[0+1].codegenNode.children} or {nil})[1]}
end

function createSlotMatcher(obj)
  return {type=NodeTypes.JS_OBJECT_EXPRESSION, properties=table.merge(Object:keys(obj):map(function(key)
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    -- [ts2lua]obj下标访问可能不正确
    return {type=NodeTypes.JS_PROPERTY, key={type=NodeTypes.SIMPLE_EXPRESSION, isStatic=not (/^\[/):test(key), content=key:gsub(/^\[|\]$/g, '')}, value=obj[key]}
  end
  ), {key={content=}, value={content=, isStatic=false}})}
end

describe('compiler: transform component slots', function()
  test('implicit default slot', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject(createSlotMatcher({default={type=NodeTypes.JS_FUNCTION_EXPRESSION, params=undefined, returns={{type=NodeTypes.ELEMENT, tag=}}}}))
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('on-component default slot', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject(createSlotMatcher({default={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}}))
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('on component named slot', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject(createSlotMatcher({named={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}}))
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('template named slots', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject(createSlotMatcher({one={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}, two={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}}))
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('on component dynamically named slot', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject(createSlotMatcher({[_ctx.named]={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}}))
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('named slots w/ implicit default slot', function()
    local  = parseWithSlots()
    expect(slots):toMatchObject(createSlotMatcher({one={type=NodeTypes.JS_FUNCTION_EXPRESSION, params=undefined, returns={{type=NodeTypes.TEXT, content=}}}, default={type=NodeTypes.JS_FUNCTION_EXPRESSION, params=undefined, returns={{type=NodeTypes.TEXT, content=}, {type=NodeTypes.ELEMENT, tag=}}}}))
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('dynamically named slots', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject(createSlotMatcher({[_ctx.one]={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}, [_ctx.two]={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}}))
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('nested slots scoping', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject(createSlotMatcher({default={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.ELEMENT, codegenNode={type=NodeTypes.VNODE_CALL, tag=, props=undefined, children=createSlotMatcher({default={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, }}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}}), patchFlag=genFlagText(PatchFlags.DYNAMIC_SLOTS)}}, {type=NodeTypes.TEXT, content=}, {type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}, {type=NodeTypes.INTERPOLATION, content={content=}}}}}))
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('should force dynamic when inside v-for', function()
    local  = parseWithSlots()
    local div = root.children[0+1].children[0+1].codegenNode
    local comp = div.children[0+1]
    expect(comp.codegenNode.patchFlag):toBe(genFlagText(PatchFlags.DYNAMIC_SLOTS))
  end
  )
  test('should only force dynamic slots when actually using scope vars w/ prefixIdentifiers: true', function()
    function assertDynamicSlots(template, shouldForce)
      local  = parseWithSlots(template, {prefixIdentifiers=true})
      local flag = nil
      if root.children[0+1].type == NodeTypes.FOR then
        local div = root.children[0+1].children[0+1].codegenNode
        local comp = div.children[0+1]
        flag = comp.codegenNode.patchFlag
      else
        local innerComp = root.children[0+1].children[0+1]
        flag = innerComp.codegenNode.patchFlag
      end
      if shouldForce then
        expect(flag):toBe(genFlagText(PatchFlags.DYNAMIC_SLOTS))
      else
        expect(flag):toBeUndefined()
      end
    end
    
    assertDynamicSlots(false)
    assertDynamicSlots(true)
    assertDynamicSlots(false)
    assertDynamicSlots(true)
  end
  )
  test('named slot with v-if', function()
    local  = parseWithSlots()
    expect(slots):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_SLOTS, arguments={createObjectMatcher({_=}), {type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test={content=}, consequent=createObjectMatcher({name=, fn={type=NodeTypes.JS_FUNCTION_EXPRESSION, returns={{type=NodeTypes.TEXT, content=}}}}), alternate={content=, isStatic=false}}}}}})
    expect(root.children[0+1].codegenNode.patchFlag):toMatch(PatchFlags.DYNAMIC_SLOTS .. '')
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('named slot with v-if + prefixIdentifiers: true', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_SLOTS, arguments={createObjectMatcher({_=}), {type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test={content=}, consequent=createObjectMatcher({name=, fn={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={content=}, returns={{type=NodeTypes.INTERPOLATION, content={content=}}}}}), alternate={content=, isStatic=false}}}}}})
    expect(root.children[0+1].codegenNode.patchFlag):toMatch(PatchFlags.DYNAMIC_SLOTS .. '')
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  test('named slot with v-if + v-else-if + v-else', function()
    local  = parseWithSlots()
    expect(slots):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_SLOTS, arguments={createObjectMatcher({_=}), {type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test={content=}, consequent=createObjectMatcher({name=, fn={type=NodeTypes.JS_FUNCTION_EXPRESSION, params=undefined, returns={{type=NodeTypes.TEXT, content=}}}}), alternate={type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test={content=}, consequent=createObjectMatcher({name=, fn={type=NodeTypes.JS_FUNCTION_EXPRESSION, params={content=}, returns={{type=NodeTypes.TEXT, content=}}}}), alternate=createObjectMatcher({name=, fn={type=NodeTypes.JS_FUNCTION_EXPRESSION, params=undefined, returns={{type=NodeTypes.TEXT, content=}}}})}}}}}})
    expect(root.children[0+1].codegenNode.patchFlag):toMatch(PatchFlags.DYNAMIC_SLOTS .. '')
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('named slot with v-for w/ prefixIdentifiers: true', function()
    local  = parseWithSlots({prefixIdentifiers=true})
    expect(slots):toMatchObject({type=NodeTypes.JS_CALL_EXPRESSION, callee=CREATE_SLOTS, arguments={createObjectMatcher({_=}), {type=NodeTypes.JS_ARRAY_EXPRESSION, elements={{type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_LIST, arguments={{content=}, {type=NodeTypes.JS_FUNCTION_EXPRESSION, params={{content=}}, returns=createObjectMatcher({name=, fn={type=NodeTypes.JS_FUNCTION_EXPRESSION, returns={{type=NodeTypes.INTERPOLATION, content={content=, isStatic=false}}}}})}}}}}}})
    expect(root.children[0+1].codegenNode.patchFlag):toMatch(PatchFlags.DYNAMIC_SLOTS .. '')
    expect(generate(root, {prefixIdentifiers=true}).code):toMatchSnapshot()
  end
  )
  describe('errors', function()
    test('error on extraneous children w/ named default slot', function()
      local onError = jest:fn()
      local source = nil
      parseWithSlots(source, {onError=onError})
      local index = source:find('bar')
      expect(onError.mock.calls[0+1][0+1]):toMatchObject({code=ErrorCodes.X_V_SLOT_EXTRANEOUS_DEFAULT_SLOT_CHILDREN, loc={source=, start={offset=index, line=1, column=index + 1}, tsvar_end={offset=index + 3, line=1, column=index + 4}}})
    end
    )
    test('error on duplicated slot names', function()
      local onError = jest:fn()
      local source = nil
      parseWithSlots(source, {onError=onError})
      local index = source:lastIndexOf('#foo')
      expect(onError.mock.calls[0+1][0+1]):toMatchObject({code=ErrorCodes.X_V_SLOT_DUPLICATE_SLOT_NAMES, loc={source=, start={offset=index, line=1, column=index + 1}, tsvar_end={offset=index + 4, line=1, column=index + 5}}})
    end
    )
    test('error on invalid mixed slot usage', function()
      local onError = jest:fn()
      local source = nil
      parseWithSlots(source, {onError=onError})
      local index = source:lastIndexOf('#foo')
      expect(onError.mock.calls[0+1][0+1]):toMatchObject({code=ErrorCodes.X_V_SLOT_MIXED_SLOT_USAGE, loc={source=, start={offset=index, line=1, column=index + 1}, tsvar_end={offset=index + 4, line=1, column=index + 5}}})
    end
    )
    test('error on v-slot usage on plain elements', function()
      local onError = jest:fn()
      local source = nil
      parseWithSlots(source, {onError=onError})
      local index = source:find('v-slot')
      expect(onError.mock.calls[0+1][0+1]):toMatchObject({code=ErrorCodes.X_V_SLOT_MISPLACED, loc={source=, start={offset=index, line=1, column=index + 1}, tsvar_end={offset=index + 6, line=1, column=index + 7}}})
    end
    )
  end
  )
end
)