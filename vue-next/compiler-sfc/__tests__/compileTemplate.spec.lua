require("compiler-sfc/src/compileTemplate")
require("compiler-sfc/src/parse")

test('should work', function()
  local source = nil
  local result = compileTemplate({filename='example.vue', source=source})
  expect(#result.errors):toBe(0)
  expect(result.source):toBe(source)
  expect(result.code):toMatch()
end
)
test('preprocess pug', function()
  local template = parse({filename='example.vue', sourceMap=true}).descriptor.template
  local result = compileTemplate({filename='example.vue', source=template.content, preprocessLang=template.lang})
  expect(#result.errors):toBe(0)
end
)
test('warn missing preprocessor', function()
  local template = parse({filename='example.vue', sourceMap=true}).descriptor.template
  local result = compileTemplate({filename='example.vue', source=template.content, preprocessLang=template.lang})
  expect(#result.errors):toBe(1)
end
)
test('transform asset url options', function()
  local input = {source=, filename='example.vue'}
  local  = compileTemplate({..., transformAssetUrls={tags={foo={'bar'}}}})
  expect(code1):toMatch()
  local  = compileTemplate({..., transformAssetUrls={foo={'bar'}}})
  expect(code2):toMatch()
  local  = compileTemplate({..., transformAssetUrls=false})
  expect(code3).tsvar_not:toMatch()
end
)
test('source map', function()
  local template = parse({filename='example.vue', sourceMap=true}).descriptor.template
  local result = compileTemplate({filename='example.vue', source=template.content})
  expect(result.map):toMatchSnapshot()
end
)
test('template errors', function()
  local result = compileTemplate({filename='example.vue', source=})
  expect(result.errors):toMatchSnapshot()
end
)
test('preprocessor errors', function()
  local template = parse({filename='example.vue', sourceMap=true}).descriptor.template
  local result = compileTemplate({filename='example.vue', source=template.content, preprocessLang=template.lang})
  expect(#result.errors):toBe(1)
  local message = result.errors[0+1]:toString()
  expect(message):toMatch()
  expect(message):toMatch()
end
)