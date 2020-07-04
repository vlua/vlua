require("compiler-core/src")
require("compiler-core/src/NodeTypes")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/transforms/vModel")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/transformExpression")
require("compiler-core/src/transforms/vFor")
require("compiler-core/src/transforms/vSlot")
local parse = baseParse

function parseWithVModel(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformFor, transformExpression, transformElement, trackSlotScopes}, directiveTransforms={..., model=transformModel}, ...})
  return ast
end

describe('compiler: transform v-model', function()
  test('simple expression', function()
    local root = parseWithVModel('<input v-model="model" />')
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='modelValue', isStatic=true}, value={content='model', isStatic=false}})
    expect(props[1+1]):toMatchObject({key={content='onUpdate:modelValue', isStatic=true}, value={children={'$event => (', {content='model', isStatic=false}, ' = $event)'}}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('simple expression (with prefixIdentifiers)', function()
    local root = parseWithVModel('<input v-model="model" />', {prefixIdentifiers=true})
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='modelValue', isStatic=true}, value={content='_ctx.model', isStatic=false}})
    expect(props[1+1]):toMatchObject({key={content='onUpdate:modelValue', isStatic=true}, value={children={'$event => (', {content='_ctx.model', isStatic=false}, ' = $event)'}}})
    expect(generate(root, {mode='module'}).code):toMatchSnapshot()
  end
  )
  test('simple expression (with multilines)', function()
    local root = parseWithVModel('<input v-model="\n model \n" />')
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='modelValue', isStatic=true}, value={content='\n model \n', isStatic=false}})
    expect(props[1+1]):toMatchObject({key={content='onUpdate:modelValue', isStatic=true}, value={children={'$event => (', {content='\n model \n', isStatic=false}, ' = $event)'}}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('compound expression', function()
    local root = parseWithVModel('<input v-model="model[index]" />')
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='modelValue', isStatic=true}, value={content='model[index]', isStatic=false}})
    expect(props[1+1]):toMatchObject({key={content='onUpdate:modelValue', isStatic=true}, value={children={'$event => (', {content='model[index]', isStatic=false}, ' = $event)'}}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('compound expression (with prefixIdentifiers)', function()
    local root = parseWithVModel('<input v-model="model[index]" />', {prefixIdentifiers=true})
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='modelValue', isStatic=true}, value={children={{content='_ctx.model', isStatic=false}, '[', {content='_ctx.index', isStatic=false}, ']'}}})
    expect(props[1+1]):toMatchObject({key={content='onUpdate:modelValue', isStatic=true}, value={children={'$event => (', {children={{content='_ctx.model', isStatic=false}, '[', {content='_ctx.index', isStatic=false}, ']'}}, ' = $event)'}}})
    expect(generate(root, {mode='module'}).code):toMatchSnapshot()
  end
  )
  test('with argument', function()
    local root = parseWithVModel('<input v-model:value="model" />')
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='value', isStatic=true}, value={content='model', isStatic=false}})
    expect(props[1+1]):toMatchObject({key={content='onUpdate:value', isStatic=true}, value={children={'$event => (', {content='model', isStatic=false}, ' = $event)'}}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('with dynamic argument', function()
    local root = parseWithVModel('<input v-model:[value]="model" />')
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='value', isStatic=false}, value={content='model', isStatic=false}})
    expect(props[1+1]):toMatchObject({key={children={'"onUpdate:" + ', {content='value', isStatic=false}}}, value={children={'$event => (', {content='model', isStatic=false}, ' = $event)'}}})
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('with dynamic argument (with prefixIdentifiers)', function()
    local root = parseWithVModel('<input v-model:[value]="model" />', {prefixIdentifiers=true})
    local node = root.children[0+1]
    local props = node.codegenNode.props.properties
    expect(props[0+1]):toMatchObject({key={content='_ctx.value', isStatic=false}, value={content='_ctx.model', isStatic=false}})
    expect(props[1+1]):toMatchObject({key={children={'"onUpdate:" + ', {content='_ctx.value', isStatic=false}}}, value={children={'$event => (', {content='_ctx.model', isStatic=false}, ' = $event)'}}})
    expect(generate(root, {mode='module'}).code):toMatchSnapshot()
  end
  )
  test('should cache update handler w/ cacheHandlers: true', function()
    local root = parseWithVModel('<input v-model="foo" />', {prefixIdentifiers=true, cacheHandlers=true})
    expect(root.cached):toBe(1)
    local codegen = root.children[0+1].codegenNode
    expect(codegen.dynamicProps):toBe()
    expect(codegen.props.properties[1+1].value.type):toBe(NodeTypes.JS_CACHE_EXPRESSION)
  end
  )
  test('should not cache update handler if it refers v-for scope variables', function()
    local root = parseWithVModel('<input v-for="i in list" v-model="foo[i]" />', {prefixIdentifiers=true, cacheHandlers=true})
    expect(root.cached):toBe(0)
    local codegen = root.children[0+1].children[0+1].codegenNode
    expect(codegen.dynamicProps):toBe()
    expect(codegen.props.properties[1+1].value.type).tsvar_not:toBe(NodeTypes.JS_CACHE_EXPRESSION)
  end
  )
  test('should mark update handler dynamic if it refers slot scope variables', function()
    local root = parseWithVModel('<Comp v-slot="{ foo }"><input v-model="foo.bar"/></Comp>', {prefixIdentifiers=true})
    local codegen = root.children[0+1].children[0+1].codegenNode
    expect(codegen.dynamicProps):toBe()
  end
  )
  test('should generate modelModifiers for component v-model', function()
    local root = parseWithVModel('<Comp v-model.trim.bar-baz="foo" />', {prefixIdentifiers=true})
    local vnodeCall = root.children[0+1].codegenNode
    expect(vnodeCall.props):toMatchObject({properties={{key={content=}}, {key={content=}}, {key={content='modelModifiers'}, value={content=, isStatic=false}}}})
    expect(vnodeCall.dynamicProps):toBe()
  end
  )
  test('should generate modelModifiers for component v-model with arguments', function()
    local root = parseWithVModel('<Comp v-model:foo.trim="foo" v-model:bar.number="bar" />', {prefixIdentifiers=true})
    local vnodeCall = root.children[0+1].codegenNode
    expect(vnodeCall.props):toMatchObject({properties={{key={content=}}, {key={content=}}, {key={content='fooModifiers'}, value={content=, isStatic=false}}, {key={content=}}, {key={content=}}, {key={content='barModifiers'}, value={content=, isStatic=false}}}})
    expect(vnodeCall.dynamicProps):toBe()
  end
  )
  describe('errors', function()
    test('missing expression', function()
      local onError = jest:fn()
      parseWithVModel('<span v-model />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_MODEL_NO_EXPRESSION}))
    end
    )
    test('empty expression', function()
      local onError = jest:fn()
      parseWithVModel('<span v-model="" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_MODEL_MALFORMED_EXPRESSION}))
    end
    )
    test('mal-formed expression', function()
      local onError = jest:fn()
      parseWithVModel('<span v-model="a + b" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_MODEL_MALFORMED_EXPRESSION}))
    end
    )
    test('used on scope variable', function()
      local onError = jest:fn()
      parseWithVModel('<span v-for="i in list" v-model="i" />', {onError=onError, prefixIdentifiers=true})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=ErrorCodes.X_V_MODEL_ON_SCOPE_VARIABLE}))
    end
    )
  end
  )
end
)