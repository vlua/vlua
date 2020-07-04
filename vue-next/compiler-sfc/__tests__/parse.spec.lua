require("stringutil")
require("compiler-sfc/src")
require("@vue/shared")
require("@vue/compiler-core")
require("source-map")

describe('compiler:sfc', function()
  mockWarn()
  describe('source map', function()
    test('style block', function()
      local padding = Math:round(Math:random() * 10)
      local style = parse().descriptor.styles[0+1]
      expect(style.map).tsvar_not:toBeUndefined()
      local consumer = SourceMapConsumer()
      consumer:eachMapping(function(mapping)
        expect(mapping.originalLine - mapping.generatedLine):toBe(padding)
      end
      )
    end
    )
    test('script block', function()
      local padding = Math:round(Math:random() * 10)
      local script = parse().descriptor.script
      expect(().map).tsvar_not:toBeUndefined()
      local consumer = SourceMapConsumer()
      consumer:eachMapping(function(mapping)
        expect(mapping.originalLine - mapping.generatedLine):toBe(padding)
      end
      )
    end
    )
  end
  )
  test('pad content', function()
    local content = nil
    local padFalse = parse(content:trim(), {pad=false}).descriptor
    expect(().content):toBe('\n<div></div>\n')
    expect(().content):toBe('\nexport default {}\n')
    expect(padFalse.styles[0+1].content):toBe('\nh1 { color: red }\n')
    local padTrue = parse(content:trim(), {pad=true}).descriptor
    expect(().content):toBe(Array(3 + 1):join('//\n') .. '\nexport default {}\n')
    expect(padTrue.styles[0+1].content):toBe(Array(6 + 1):join('\n') .. '\nh1 { color: red }\n')
    local padLine = parse(content:trim(), {pad='line'}).descriptor
    expect(().content):toBe(Array(3 + 1):join('//\n') .. '\nexport default {}\n')
    expect(padLine.styles[0+1].content):toBe(Array(6 + 1):join('\n') .. '\nh1 { color: red }\n')
    local padSpace = parse(content:trim(), {pad='space'}).descriptor
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    expect(().content):toBe(():gsub(/./g, ' ') .. '\nexport default {}\n')
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    expect(padSpace.styles[0+1].content):toBe(():gsub(/./g, ' ') .. '\nh1 { color: red }\n')
  end
  )
  test('should ignore nodes with no content', function()
    expect(parse().descriptor.template):toBe(nil)
    expect(parse().descriptor.script):toBe(nil)
    expect(#parse().descriptor.styles):toBe(0)
    expect(#parse().descriptor.customBlocks):toBe(0)
  end
  )
  test('handle empty nodes with src attribute', function()
    local  = parse()
    expect(descriptor.script):toBeTruthy()
    expect(().content):toBeFalsy()
    -- [ts2lua]().attrs下标访问可能不正确
    expect(().attrs['src']):toBe('com')
  end
  )
  test('nested templates', function()
    local content = nil
    local  = parse()
    expect(().content):toBe(content)
  end
  )
  test('alternative template lang should be treated as plain text', function()
    local content = nil
    local  = parse( + content + )
    expect(#errors):toBe(0)
    expect(().content):toBe(content)
  end
  )
  test('error tolerance', function()
    local  = parse()
    expect(#errors):toBe(1)
  end
  )
  test('should parse as DOM by default', function()
    local  = parse()
    expect(#errors):toBe(0)
  end
  )
  test('custom compiler', function()
    local  = parse({compiler={parse=baseParse, compile=baseCompile}})
    expect(#errors):toBe(1)
  end
  )
  test('treat custom blocks as raw text', function()
    local  = parse()
    expect(#errors):toBe(0)
    expect(descriptor.customBlocks[0+1].content):toBe()
  end
  )
  describe('warnings', function()
    test('should only allow single template element', function()
      parse()
      expect():toHaveBeenWarned()
    end
    )
    test('should only allow single script element', function()
      parse()
      expect():toHaveBeenWarned()
    end
    )
  end
  )
end
)