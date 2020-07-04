require("compiler-ssr/src")

local scopeId = 'data-v-xxxxxxx'
describe('ssr: scopeId', function()
  test('basic', function()
    expect(compile({scopeId=scopeId, mode='module'}).code):toMatchInlineSnapshot()
  end
  )
  test('inside slots (only text)', function()
    expect(compile({scopeId=scopeId, mode='module'}).code):toMatchInlineSnapshot()
  end
  )
  test('inside slots (with elements)', function()
    expect(compile({scopeId=scopeId, mode='module'}).code):toMatchInlineSnapshot()
  end
  )
  test('nested slots', function()
    expect(compile({scopeId=scopeId, mode='module'}).code):toMatchInlineSnapshot()
  end
  )
end
)