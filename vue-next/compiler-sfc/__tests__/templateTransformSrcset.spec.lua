require("@vue/compiler-core")
require("compiler-sfc/src/templateTransformSrcset")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/vBind")
require("compiler-sfc/src/templateTransformAssetUrl")

function compileWithSrcset(template, options)
  local ast = baseParse(template)
  -- [ts2lua]lua中0和空字符串也是true，此处options需要确认
  local srcsetTrasnform = (options and {createSrcsetTransformWithOptions(normalizeOptions(options))} or {transformSrcset})[1]
  transform(ast, {nodeTransforms={srcsetTrasnform, transformElement}, directiveTransforms={bind=transformBind}})
  return generate(ast, {mode='module'})
end

local src = nil
describe('compiler sfc: transform srcset', function()
  test('transform srcset', function()
    expect(compileWithSrcset(src).code):toMatchSnapshot()
  end
  )
  test('transform srcset w/ base', function()
    expect(compileWithSrcset(src, {base='/foo'}).code):toMatchSnapshot()
  end
  )
  test('transform srcset w/ includeAbsolute: true', function()
    expect(compileWithSrcset(src, {includeAbsolute=true}).code):toMatchSnapshot()
  end
  )
end
)