require("stringutil")
require("compiler-core/src")
require("source-map")
local compile = baseCompile

describe('compiler: integration tests', function()
  local source = ():trim()
  function getPositionInCode(code, token, expectName)
    if expectName == nil then
      expectName=false
    end
    local generatedOffset = code:find(token)
    local line = 1
    local lastNewLinePos = -1
    local i = 0
    repeat
      if code:charCodeAt(i) == 10 then
        line=line+1
        lastNewLinePos = i
      end
      i=i+1
    until not(i < generatedOffset)
    -- [ts2lua]lua中0和空字符串也是true，此处lastNewLinePos == -1需要确认
    local res = {line=line, column=(lastNewLinePos == -1 and {generatedOffset} or {generatedOffset - lastNewLinePos - 1})[1]}
    if expectName then
      -- [ts2lua]lua中0和空字符串也是true，此处type(expectName) == 'string'需要确认
      res.name = (type(expectName) == 'string' and {expectName} or {token})[1]
    end
    return res
  end
  
  test('function mode', function()
    local  = compile(source, {sourceMap=true, filename=})
    expect(code):toMatchSnapshot()
    expect(().sources):toEqual({})
    expect(().sourcesContent):toEqual({source})
    local consumer = SourceMapConsumer(map)
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
  end
  )
  test('function mode w/ prefixIdentifiers: true', function()
    local  = compile(source, {sourceMap=true, filename=, prefixIdentifiers=true})
    expect(code):toMatchSnapshot()
    expect(().sources):toEqual({})
    expect(().sourcesContent):toEqual({source})
    local consumer = SourceMapConsumer(map)
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , true))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , true))):toMatchObject(getPositionInCode(source, , ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , true))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , true))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
  end
  )
  test('module mode', function()
    local  = compile(source, {mode='module', sourceMap=true, filename=})
    expect(code):toMatchSnapshot()
    expect(().sources):toEqual({})
    expect(().sourcesContent):toEqual({source})
    local consumer = SourceMapConsumer(map)
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , true))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , true))):toMatchObject(getPositionInCode(source, , ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , true))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, , ))):toMatchObject(getPositionInCode(source, , true))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
    expect(consumer:originalPositionFor(getPositionInCode(code, ))):toMatchObject(getPositionInCode(source, ))
  end
  )
end
)