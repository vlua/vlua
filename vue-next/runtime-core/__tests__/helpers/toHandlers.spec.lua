require("runtime-core/src/helpers/toHandlers")
require("@vue/shared")

describe('toHandlers', function()
  mockWarn()
  it('should not accept non-objects', function()
    toHandlers(nil)
    toHandlers(undefined)
    expect('v-on with no argument expects an object value.'):toHaveBeenWarnedTimes(2)
  end
  )
  it('should properly change object keys', function()
    local input = function()
      
    end
    
    local change = function()
      
    end
    
    expect(toHandlers({input=input, change=change})):toStrictEqual({onInput=input, onChange=change})
  end
  )
end
)