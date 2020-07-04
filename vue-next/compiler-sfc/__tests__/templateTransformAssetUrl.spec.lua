require("@vue/compiler-core")
require("compiler-sfc/src/templateTransformAssetUrl")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/vBind")

function compileWithAssetUrls(template, options)
  local ast = baseParse(template)
  -- [ts2lua]lua中0和空字符串也是true，此处options需要确认
  local t = (options and {createAssetUrlTransformWithOptions(normalizeOptions(options))} or {transformAssetUrl})[1]
  transform(ast, {nodeTransforms={t, transformElement}, directiveTransforms={bind=transformBind}})
  return generate(ast, {mode='module'})
end

describe('compiler sfc: transform asset url', function()
  test('transform assetUrls', function()
    local result = compileWithAssetUrls()
    expect(result.code):toMatchSnapshot()
  end
  )
  test('support uri fragment', function()
    local result = compileWithAssetUrls('<use href="~@svg/file.svg#fragment"></use>')
    expect(result.code):toMatchSnapshot()
  end
  )
  test('support uri is empty', function()
    local result = compileWithAssetUrls('<use href="~"></use>')
    expect(result.code):toMatchSnapshot()
  end
  )
  test('with explicit base', function()
    local  = compileWithAssetUrls( +  +  + , {base='/foo'})
    expect(code):toMatchSnapshot()
  end
  )
  test('with includeAbsolute: true', function()
    local  = compileWithAssetUrls( +  + , {includeAbsolute=true})
    expect(code):toMatchSnapshot()
  end
  )
  test('should not transform hash fragments', function()
    local  = compileWithAssetUrls()
    expect(code):toMatch()
  end
  )
end
)