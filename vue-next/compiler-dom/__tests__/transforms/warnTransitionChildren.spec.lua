require("stringutil")
require("compiler-dom/src")

describe('compiler warnings', function()
  describe('Transition', function()
    function checkWarning(template, shouldWarn, message)
      if message == nil then
        message=
      end
      local spy = jest:fn()
      compile(template:trim(), {hoistStatic=true, transformHoist=nil, onError=function(err)
        spy(err.message)
      end
      })
      if shouldWarn then
        expect(spy):toHaveBeenCalledWith(message)
      else
        expect(spy).tsvar_not:toHaveBeenCalled()
      end
    end
    
    test('warns if multiple children', function()
      checkWarning(true)
    end
    )
    test('warns with v-for', function()
      checkWarning(true)
    end
    )
    test('warns with multiple v-if + v-for', function()
      checkWarning(true)
    end
    )
    test('warns with template v-if', function()
      checkWarning(true)
    end
    )
    test('warns with multiple templates', function()
      checkWarning(true)
    end
    )
    test('warns if multiple children with v-if', function()
      checkWarning(true)
    end
    )
    test('does not warn with regular element', function()
      checkWarning(false)
    end
    )
    test('does not warn with one single v-if', function()
      checkWarning(false)
    end
    )
    test('does not warn with v-if v-else-if v-else', function()
      checkWarning(false)
    end
    )
    test('does not warn with v-if v-else', function()
      checkWarning(false)
    end
    )
  end
  )
end
)