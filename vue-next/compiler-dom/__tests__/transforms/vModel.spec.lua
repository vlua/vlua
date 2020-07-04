require("@vue/compiler-core")
require("compiler-dom/src/transforms/vModel")
require("compiler-core/src/transforms/transformElement")
require("compiler-dom/src/errors/DOMErrorCodes")
require("compiler-dom/src/runtimeHelpers")
local parse = baseParse

function transformWithModel(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={transformElement}, directiveTransforms={model=transformModel}, ...})
  return ast
end

describe('compiler: transform v-model', function()
  test('simple expression', function()
    local root = transformWithModel('<input v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_TEXT)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('simple expression for input (text)', function()
    local root = transformWithModel('<input type="text" v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_TEXT)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('simple expression for input (radio)', function()
    local root = transformWithModel('<input type="radio" v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_RADIO)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('simple expression for input (checkbox)', function()
    local root = transformWithModel('<input type="checkbox" v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_CHECKBOX)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('simple expression for input (dynamic type)', function()
    local root = transformWithModel('<input :type="foo" v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_DYNAMIC)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('input w/ dynamic v-bind', function()
    local root = transformWithModel('<input v-bind="obj" v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_DYNAMIC)
    expect(generate(root).code):toMatchSnapshot()
    local root2 = transformWithModel('<input v-bind:[key]="val" v-model="model" />')
    expect(root2.helpers):toContain(V_MODEL_DYNAMIC)
    expect(generate(root2).code):toMatchSnapshot()
  end
  )
  test('simple expression for select', function()
    local root = transformWithModel('<select v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_SELECT)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  test('simple expression for textarea', function()
    local root = transformWithModel('<textarea v-model="model" />')
    expect(root.helpers):toContain(V_MODEL_TEXT)
    expect(generate(root).code):toMatchSnapshot()
  end
  )
  describe('errors', function()
    test('plain elements with argument', function()
      local onError = jest:fn()
      transformWithModel('<input v-model:value="model" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=DOMErrorCodes.X_V_MODEL_ARG_ON_ELEMENT}))
    end
    )
    test('invalid element', function()
      local onError = jest:fn()
      transformWithModel('<span v-model="model" />', {onError=onError})
      expect(onError):toHaveBeenCalledTimes(1)
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=DOMErrorCodes.X_V_MODEL_ON_INVALID_ELEMENT}))
    end
    )
    test('should raise error if used file input element', function()
      local onError = jest:fn()
      transformWithModel({onError=onError})
      expect(onError):toHaveBeenCalledWith(expect:objectContaining({code=DOMErrorCodes.X_V_MODEL_ON_FILE_INPUT_ELEMENT}))
    end
    )
  end
  )
  describe('modifiers', function()
    test('.number', function()
      local root = transformWithModel('<input  v-model.number="model" />')
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('.trim', function()
      local root = transformWithModel('<input  v-model.trim="model" />')
      expect(generate(root).code):toMatchSnapshot()
    end
    )
    test('.lazy', function()
      local root = transformWithModel('<input  v-model.lazy="model" />')
      expect(generate(root).code):toMatchSnapshot()
    end
    )
  end
  )
end
)