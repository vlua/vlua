require("stringutil")
require("shared/src/codeframe")

describe('compiler: codeframe', function()
  local source = ():trim()
  test('line near top', function()
    local keyStart = source:find()
    local keyEnd = keyStart + #()
    expect(generateCodeFrame(source, keyStart, keyEnd)):toMatchSnapshot()
  end
  )
  test('line in middle', function()
    local forStart = source:find()
    local forEnd = forStart + #()
    expect(generateCodeFrame(source, forStart, forEnd)):toMatchSnapshot()
  end
  )
  test('line near bottom', function()
    local keyStart = source:find()
    local keyEnd = keyStart + #()
    expect(generateCodeFrame(source, keyStart, keyEnd)):toMatchSnapshot()
  end
  )
  test('multi-line highlights', function()
    local source = ():trim()
    local attrStart = source:find()
    local attrEnd = source:find() + 1
    expect(generateCodeFrame(source, attrStart, attrEnd)):toMatchSnapshot()
  end
  )
end
)