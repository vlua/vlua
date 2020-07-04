require("@vue/runtime-core")
require("@vue/runtime-dom")

local withVShow = function(node, exp)
  withDirectives(node, {{vShow, exp}})
end

local root = nil
beforeEach(function()
  root = document:createElement('div')
end
)
describe('runtime-dom: v-show directive', function()
  test('should check show value is truthy', function()
    local component = defineComponent({data=function()
      return {value=true}
    end
    , render=function()
      return {withVShow(h('div'), self.value)}
    end
    })
    render(h(component), root)
    local tsvar_div = root:querySelector('div')
    expect(tsvar_div.style.display):toEqual('')
  end
  )
  test('should check show value is falsy', function()
    local component = defineComponent({data=function()
      return {value=false}
    end
    , render=function()
      return {withVShow(h('div'), self.value)}
    end
    })
    render(h(component), root)
    local tsvar_div = root:querySelector('div')
    expect(tsvar_div.style.display):toEqual('none')
  end
  )
  it('should update show value changed', function()
    local component = defineComponent({data=function()
      return {value=true}
    end
    , render=function()
      return {withVShow(h('div'), self.value)}
    end
    })
    render(h(component), root)
    local tsvar_div = root:querySelector('div')
    local data = root._vnode.component.data
    expect(tsvar_div.style.display):toEqual('')
    data.value = false
    expect(tsvar_div.style.display):toEqual('none')
    data.value = {}
    expect(tsvar_div.style.display):toEqual('')
    data.value = 0
    expect(tsvar_div.style.display):toEqual('none')
    data.value = {}
    expect(tsvar_div.style.display):toEqual('')
    data.value = nil
    expect(tsvar_div.style.display):toEqual('none')
    data.value = '0'
    expect(tsvar_div.style.display):toEqual('')
    data.value = undefined
    expect(tsvar_div.style.display):toEqual('none')
    data.value = 1
    expect(tsvar_div.style.display):toEqual('')
  end
  )
  test('should respect display value in style attribute', function()
    local component = defineComponent({data=function()
      return {value=true}
    end
    , render=function()
      return {withVShow(h('div', {style={display='block'}}), self.value)}
    end
    })
    render(h(component), root)
    local tsvar_div = root:querySelector('div')
    local data = root._vnode.component.data
    expect(tsvar_div.style.display):toEqual('block')
    data.value = false
    expect(tsvar_div.style.display):toEqual('none')
    data.value = true
    expect(tsvar_div.style.display):toEqual('block')
  end
  )
end
)