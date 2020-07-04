require("compiler-core/src/parse")
require("compiler-core/src/transform")
require("compiler-core/src/transforms/vIf")
require("compiler-core/src/transforms/vFor")
require("compiler-core/src/transforms/vBind")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/transformSlotOutlet")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src")
require("compiler-core/src/runtimeHelpers")
require("@vue/shared/PatchFlags")
require("compiler-core/__tests__/testUtils")
local parse = baseParse

function parseWithForTransform(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template, options)
  transform(ast, {nodeTransforms={transformIf, transformFor, ..., transformSlotOutlet, transformElement}, directiveTransforms={bind=transformBind}, ...})
  return {root=ast, node=ast.children[0+1]}
end

describe('compiler: v-for', function()
  describe('transform', function()
    test('number expression', function()
      local  = parseWithForTransform('<span v-for="index in 5" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias):toBeUndefined()
      expect(forNode.valueAlias.content):toBe('index')
      expect(forNode.source.content):toBe('5')
    end
    )
    test('value', function()
      local  = parseWithForTransform('<span v-for="(item) in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias):toBeUndefined()
      expect(forNode.valueAlias.content):toBe('item')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('object de-structured value', function()
      local  = parseWithForTransform('<span v-for="({ id, value }) in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias):toBeUndefined()
      expect(forNode.valueAlias.content):toBe('{ id, value }')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('array de-structured value', function()
      local  = parseWithForTransform('<span v-for="([ id, value ]) in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias):toBeUndefined()
      expect(forNode.valueAlias.content):toBe('[ id, value ]')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('value and key', function()
      local  = parseWithForTransform('<span v-for="(item, key) in items" />')
      expect(forNode.keyAlias).tsvar_not:toBeUndefined()
      expect(forNode.keyAlias.content):toBe('key')
      expect(forNode.objectIndexAlias):toBeUndefined()
      expect(forNode.valueAlias.content):toBe('item')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('value, key and index', function()
      local  = parseWithForTransform('<span v-for="(value, key, index) in items" />')
      expect(forNode.keyAlias).tsvar_not:toBeUndefined()
      expect(forNode.keyAlias.content):toBe('key')
      expect(forNode.objectIndexAlias).tsvar_not:toBeUndefined()
      expect(forNode.objectIndexAlias.content):toBe('index')
      expect(forNode.valueAlias.content):toBe('value')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('skipped key', function()
      local  = parseWithForTransform('<span v-for="(value,,index) in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias).tsvar_not:toBeUndefined()
      expect(forNode.objectIndexAlias.content):toBe('index')
      expect(forNode.valueAlias.content):toBe('value')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('skipped value and key', function()
      local  = parseWithForTransform('<span v-for="(,,index) in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias).tsvar_not:toBeUndefined()
      expect(forNode.objectIndexAlias.content):toBe('index')
      expect(forNode.valueAlias):toBeUndefined()
      expect(forNode.source.content):toBe('items')
    end
    )
    test('unbracketed value', function()
      local  = parseWithForTransform('<span v-for="item in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias):toBeUndefined()
      expect(forNode.valueAlias.content):toBe('item')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('unbracketed value and key', function()
      local  = parseWithForTransform('<span v-for="item, key in items" />')
      expect(forNode.keyAlias).tsvar_not:toBeUndefined()
      expect(forNode.keyAlias.content):toBe('key')
      expect(forNode.objectIndexAlias):toBeUndefined()
      expect(forNode.valueAlias.content):toBe('item')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('unbracketed value, key and index', function()
      local  = parseWithForTransform('<span v-for="value, key, index in items" />')
      expect(forNode.keyAlias).tsvar_not:toBeUndefined()
      expect(forNode.keyAlias.content):toBe('key')
      expect(forNode.objectIndexAlias).tsvar_not:toBeUndefined()
      expect(forNode.objectIndexAlias.content):toBe('index')
      expect(forNode.valueAlias.content):toBe('value')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('unbracketed skipped key', function()
      local  = parseWithForTransform('<span v-for="value, , index in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias).tsvar_not:toBeUndefined()
      expect(forNode.objectIndexAlias.content):toBe('index')
      expect(forNode.valueAlias.content):toBe('value')
      expect(forNode.source.content):toBe('items')
    end
    )
    test('unbracketed skipped value and key', function()
      local  = parseWithForTransform('<span v-for=", , index in items" />')
      expect(forNode.keyAlias):toBeUndefined()
      expect(forNode.objectIndexAlias).tsvar_not:toBeUndefined()
      expect(forNode.objectIndexAlias.content):toBe('index')
      expect(forNode.valueAlias):toBeUndefined()
      expect(forNode.source.content):toBe('items')
    end
    )
  end
  )
  describe('errors', function()
    test('missing expression', function()
      local onError = jest:fn()
      parseWithForTransform('<span v-for />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_FOR_NO_EXPRESSION}))
    end
    )
    test('empty expression', function()
      local onError = jest:fn()
      parseWithForTransform('<span v-for="" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_FOR_MALFORMED_EXPRESSION}))
    end
    )
    test('invalid expression', function()
      local onError = jest:fn()
      parseWithForTransform('<span v-for="items" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_FOR_MALFORMED_EXPRESSION}))
    end
    )
    test('missing source', function()
      local onError = jest:fn()
      parseWithForTransform('<span v-for="item in" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_FOR_MALFORMED_EXPRESSION}))
    end
    )
    test('missing value', function()
      local onError = jest:fn()
      parseWithForTransform('<span v-for="in items" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_FOR_MALFORMED_EXPRESSION}))
    end
    )
  end
  )
  describe('source location', function()
    test('value & source', function()
      local source = '<span v-for="item in items" />'
      local  = parseWithForTransform(source)
      local itemOffset = source:find('item')
      local value = forNode.valueAlias
      expect(forNode.valueAlias.content):toBe('item')
      expect(value.loc.start.offset):toBe(itemOffset)
      expect(value.loc.start.line):toBe(1)
      expect(value.loc.start.column):toBe(itemOffset + 1)
      expect(value.loc.tsvar_end.line):toBe(1)
      expect(value.loc.tsvar_end.column):toBe(itemOffset + 1 + #())
      local itemsOffset = source:find('items')
      expect(forNode.source.content):toBe('items')
      expect(forNode.source.loc.start.offset):toBe(itemsOffset)
      expect(forNode.source.loc.start.line):toBe(1)
      expect(forNode.source.loc.start.column):toBe(itemsOffset + 1)
      expect(forNode.source.loc.tsvar_end.line):toBe(1)
      expect(forNode.source.loc.tsvar_end.column):toBe(itemsOffset + 1 + #())
    end
    )
    test('bracketed value', function()
      local source = '<span v-for="( item ) in items" />'
      local  = parseWithForTransform(source)
      local itemOffset = source:find('item')
      local value = forNode.valueAlias
      expect(value.content):toBe('item')
      expect(value.loc.start.offset):toBe(itemOffset)
      expect(value.loc.start.line):toBe(1)
      expect(value.loc.start.column):toBe(itemOffset + 1)
      expect(value.loc.tsvar_end.line):toBe(1)
      expect(value.loc.tsvar_end.column):toBe(itemOffset + 1 + #())
      local itemsOffset = source:find('items')
      expect(forNode.source.content):toBe('items')
      expect(forNode.source.loc.start.offset):toBe(itemsOffset)
      expect(forNode.source.loc.start.line):toBe(1)
      expect(forNode.source.loc.start.column):toBe(itemsOffset + 1)
      expect(forNode.source.loc.tsvar_end.line):toBe(1)
      expect(forNode.source.loc.tsvar_end.column):toBe(itemsOffset + 1 + #())
    end
    )
    test('de-structured value', function()
      local source = '<span v-for="(  { id, key }) in items" />'
      local  = parseWithForTransform(source)
      local value = forNode.valueAlias
      local valueIndex = source:find('{ id, key }')
      expect(value.content):toBe('{ id, key }')
      expect(value.loc.start.offset):toBe(valueIndex)
      expect(value.loc.start.line):toBe(1)
      expect(value.loc.start.column):toBe(valueIndex + 1)
      expect(value.loc.tsvar_end.line):toBe(1)
      expect(value.loc.tsvar_end.column):toBe(valueIndex + 1 + #('{ id, key }'))
      local itemsOffset = source:find('items')
      expect(forNode.source.content):toBe('items')
      expect(forNode.source.loc.start.offset):toBe(itemsOffset)
      expect(forNode.source.loc.start.line):toBe(1)
      expect(forNode.source.loc.start.column):toBe(itemsOffset + 1)
      expect(forNode.source.loc.tsvar_end.line):toBe(1)
      expect(forNode.source.loc.tsvar_end.column):toBe(itemsOffset + 1 + #())
    end
    )
    test('bracketed value, key, index', function()
      local source = '<span v-for="( item, key, index ) in items" />'
      local  = parseWithForTransform(source)
      local itemOffset = source:find('item')
      local value = forNode.valueAlias
      expect(value.content):toBe('item')
      expect(value.loc.start.offset):toBe(itemOffset)
      expect(value.loc.start.line):toBe(1)
      expect(value.loc.start.column):toBe(itemOffset + 1)
      expect(value.loc.tsvar_end.line):toBe(1)
      expect(value.loc.tsvar_end.column):toBe(itemOffset + 1 + #())
      local keyOffset = source:find('key')
      local key = forNode.keyAlias
      expect(key.content):toBe('key')
      expect(key.loc.start.offset):toBe(keyOffset)
      expect(key.loc.start.line):toBe(1)
      expect(key.loc.start.column):toBe(keyOffset + 1)
      expect(key.loc.tsvar_end.line):toBe(1)
      expect(key.loc.tsvar_end.column):toBe(keyOffset + 1 + #())
      local indexOffset = source:find('index')
      local index = forNode.objectIndexAlias
      expect(index.content):toBe('index')
      expect(index.loc.start.offset):toBe(indexOffset)
      expect(index.loc.start.line):toBe(1)
      expect(index.loc.start.column):toBe(indexOffset + 1)
      expect(index.loc.tsvar_end.line):toBe(1)
      expect(index.loc.tsvar_end.column):toBe(indexOffset + 1 + #())
      local itemsOffset = source:find('items')
      expect(forNode.source.content):toBe('items')
      expect(forNode.source.loc.start.offset):toBe(itemsOffset)
      expect(forNode.source.loc.start.line):toBe(1)
      expect(forNode.source.loc.start.column):toBe(itemsOffset + 1)
      expect(forNode.source.loc.tsvar_end.line):toBe(1)
      expect(forNode.source.loc.tsvar_end.column):toBe(itemsOffset + 1 + #())
    end
    )
    test('skipped key', function()
      local source = '<span v-for="( item,, index ) in items" />'
      local  = parseWithForTransform(source)
      local itemOffset = source:find('item')
      local value = forNode.valueAlias
      expect(value.content):toBe('item')
      expect(value.loc.start.offset):toBe(itemOffset)
      expect(value.loc.start.line):toBe(1)
      expect(value.loc.start.column):toBe(itemOffset + 1)
      expect(value.loc.tsvar_end.line):toBe(1)
      expect(value.loc.tsvar_end.column):toBe(itemOffset + 1 + #())
      local indexOffset = source:find('index')
      local index = forNode.objectIndexAlias
      expect(index.content):toBe('index')
      expect(index.loc.start.offset):toBe(indexOffset)
      expect(index.loc.start.line):toBe(1)
      expect(index.loc.start.column):toBe(indexOffset + 1)
      expect(index.loc.tsvar_end.line):toBe(1)
      expect(index.loc.tsvar_end.column):toBe(indexOffset + 1 + #())
      local itemsOffset = source:find('items')
      expect(forNode.source.content):toBe('items')
      expect(forNode.source.loc.start.offset):toBe(itemsOffset)
      expect(forNode.source.loc.start.line):toBe(1)
      expect(forNode.source.loc.start.column):toBe(itemsOffset + 1)
      expect(forNode.source.loc.tsvar_end.line):toBe(1)
      expect(forNode.source.loc.tsvar_end.column):toBe(itemsOffset + 1 + #())
    end
    )
  end
  )
  describe('prefixIdentifiers: true', function()
    test('should prefix v-for source', function()
      local  = parseWithForTransform({prefixIdentifiers=true})
      expect(node.source):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    end
    )
    test('should prefix v-for source w/ complex expression', function()
      local  = parseWithForTransform({prefixIdentifiers=true})
      expect(node.source):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, }})
    end
    )
    test('should not prefix v-for alias', function()
      local  = parseWithForTransform({prefixIdentifiers=true})
      local div = node.children[0+1]
      expect(div.children[0+1].content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
      expect(div.children[1+1].content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    end
    )
    test('should not prefix v-for aliases (multiple)', function()
      local  = parseWithForTransform({prefixIdentifiers=true})
      local div = node.children[0+1]
      expect(div.children[0+1].content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}}})
      expect(div.children[1+1].content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    end
    )
    test('should prefix id outside of v-for', function()
      local  = parseWithForTransform({prefixIdentifiers=true})
      expect(node.children[1+1].content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    end
    )
    test('nested v-for', function()
      local  = parseWithForTransform({prefixIdentifiers=true})
      local outerDiv = node.children[0+1]
      local innerFor = outerDiv.children[0+1]
      local innerExp = innerFor.children[0+1].children[0+1]
      expect(innerExp.content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content='i'}, , {content=}}})
      local outerExp = outerDiv.children[1+1]
      expect(outerExp.content):toMatchObject({type=NodeTypes.SIMPLE_EXPRESSION, content=})
    end
    )
    test('v-for aliases w/ complex expressions', function()
      local  = parseWithForTransform({prefixIdentifiers=true})
      expect():toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, , {content=}, }})
      local div = node.children[0+1]
      expect(div.children[0+1].content):toMatchObject({type=NodeTypes.COMPOUND_EXPRESSION, children={{content=}, , {content=}, , {content=}, , {content=}, , {content=}}})
    end
    )
  end
  )
  describe('codegen', function()
    function assertSharedCodegen(node, keyed, customReturn, disableTracking)
      if keyed == nil then
        keyed=false
      end
      if customReturn == nil then
        customReturn=false
      end
      if disableTracking == nil then
        disableTracking=true
      end
      -- [ts2lua]lua中0和空字符串也是true，此处keyed需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处not disableTracking需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处customReturn需要确认
      expect(node):toMatchObject({type=NodeTypes.VNODE_CALL, tag=FRAGMENT, disableTracking=disableTracking, patchFlag=(not disableTracking and {genFlagText(PatchFlags.STABLE_FRAGMENT)} or {(keyed and {genFlagText(PatchFlags.KEYED_FRAGMENT)} or {genFlagText(PatchFlags.UNKEYED_FRAGMENT)})[1]})[1], children={type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_LIST, arguments={{}, {type=NodeTypes.JS_FUNCTION_EXPRESSION, returns=(customReturn and {{}} or {{type=NodeTypes.VNODE_CALL, isBlock=disableTracking}})[1]}}}})
      local renderListArgs = node.children.arguments
      -- [ts2lua]lua中0和空字符串也是true，此处customReturn需要确认
      return {source=renderListArgs[0+1], params=renderListArgs[1+1].params, returns=renderListArgs[1+1].returns, innerVNodeCall=(customReturn and {nil} or {renderListArgs[1+1].returns})[1]}
    end
    
    test('basic v-for', function()
      local  = parseWithForTransform('<span v-for="(item) in items" />')
      expect(assertSharedCodegen(codegenNode)):toMatchObject({source={content=}, params={{content=}}, innerVNodeCall={tag=}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('value + key + index', function()
      local  = parseWithForTransform('<span v-for="(item, key, index) in items" />')
      expect(assertSharedCodegen(codegenNode)):toMatchObject({source={content=}, params={{content=}, {content=}, {content=}}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('skipped value', function()
      local  = parseWithForTransform('<span v-for="(, key, index) in items" />')
      expect(assertSharedCodegen(codegenNode)):toMatchObject({source={content=}, params={{content=}, {content=}, {content=}}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('skipped key', function()
      local  = parseWithForTransform('<span v-for="(item,,index) in items" />')
      expect(assertSharedCodegen(codegenNode)):toMatchObject({source={content=}, params={{content=}, {content=}, {content=}}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('skipped value & key', function()
      local  = parseWithForTransform('<span v-for="(,,index) in items" />')
      expect(assertSharedCodegen(codegenNode)):toMatchObject({source={content=}, params={{content=}, {content=}, {content=}}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-for with constant expression', function()
      local  = parseWithForTransform('<p v-for="item in 10">{{item}}</p>', {prefixIdentifiers=true})
      expect(assertSharedCodegen(codegenNode, false, false, false)):toMatchObject({source={content=, isConstant=true}, params={{content=}}, innerVNodeCall={tag=, props=undefined, isBlock=false, children={type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content='item', isStatic=false, isConstant=false}}, patchFlag=genFlagText(PatchFlags.TEXT)}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('template v-for', function()
      local  = parseWithForTransform('<template v-for="item in items">hello<span/></template>')
      expect(assertSharedCodegen(codegenNode)):toMatchObject({source={content=}, params={{content=}}, innerVNodeCall={tag=FRAGMENT, props=undefined, isBlock=true, children={{type=NodeTypes.TEXT, content=}, {type=NodeTypes.ELEMENT, tag=}}, patchFlag=genFlagText(PatchFlags.STABLE_FRAGMENT)}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('template v-for w/ <slot/>', function()
      local  = parseWithForTransform('<template v-for="item in items"><slot/></template>')
      expect(assertSharedCodegen(codegenNode, false, true)):toMatchObject({source={content=}, params={{content=}}, returns={type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-for on <slot/>', function()
      local  = parseWithForTransform('<slot v-for="item in items"></slot>')
      expect(assertSharedCodegen(codegenNode, false, true)):toMatchObject({source={content=}, params={{content=}}, returns={type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_SLOT}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('keyed v-for', function()
      local  = parseWithForTransform('<span v-for="(item) in items" :key="item" />')
      expect(assertSharedCodegen(codegenNode, true)):toMatchObject({source={content=}, params={{content=}}, innerVNodeCall={tag=, props=createObjectMatcher({key=})}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('keyed template v-for', function()
      local  = parseWithForTransform('<template v-for="item in items" :key="item">hello<span/></template>')
      expect(assertSharedCodegen(codegenNode, true)):toMatchObject({source={content=}, params={{content=}}, innerVNodeCall={tag=FRAGMENT, props=createObjectMatcher({key=}), children={{type=NodeTypes.TEXT, content=}, {type=NodeTypes.ELEMENT, tag=}}, patchFlag=genFlagText(PatchFlags.STABLE_FRAGMENT)}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-if + v-for', function()
      local  = parseWithForTransform()
      expect(codegenNode):toMatchObject({type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test={content=}, consequent={type=NodeTypes.VNODE_CALL, props=createObjectMatcher({key=}), isBlock=true, disableTracking=true, patchFlag=genFlagText(PatchFlags.UNKEYED_FRAGMENT), children={type=NodeTypes.JS_CALL_EXPRESSION, callee=RENDER_LIST, arguments={{content=}, {type=NodeTypes.JS_FUNCTION_EXPRESSION, params={{content=}}, returns={type=NodeTypes.VNODE_CALL, tag=, isBlock=true}}}}}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('v-for on element with custom directive', function()
      local  = parseWithForTransform('<div v-for="i in list" v-foo/>')
      local  = assertSharedCodegen(codegenNode, false, true)
      expect(returns):toMatchObject({type=NodeTypes.VNODE_CALL, directives={type=NodeTypes.JS_ARRAY_EXPRESSION}})
      expect(generate(root).code):toMatchSnapshot()
    end
    )
  end
  )
end
)