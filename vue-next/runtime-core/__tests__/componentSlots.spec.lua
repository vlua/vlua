require("@vue/runtime-test")

describe('component: slots', function()
  test('should respect $stable flag', function()
    local flag1 = ref(1)
    local flag2 = ref(2)
    local spy = jest:fn()
    local Child = function()
      spy()
      return 'child'
    end
    
    local App = {setup=function()
      return function()
        {flag1.value, h(Child, {n=flag2.value}, {foo=function()
          'foo'
        end
        , tsvar_stable=true})}
      end
      
    
    end
    }
    render(h(App), nodeOps:createElement('div'))
    expect(spy):toHaveBeenCalledTimes(1)
    flag1.value=flag1.value+1
    expect(spy):toHaveBeenCalledTimes(1)
    flag2.value=flag2.value+1
    expect(spy):toHaveBeenCalledTimes(2)
  end
  )
end
)