require("@vue/runtime-dom")

local triggerEvent = function(type, el)
  local event = Event(type)
  el:dispatchEvent(event)
end

local withVModel = function(node, arg, mods)
  withDirectives(node, {{vModelDynamic, arg, '', mods}})
end

local setValue = function(this, value)
  self.value = value
end

local root = nil
beforeEach(function()
  root = document:createElement('div')
end
)
describe('vModel', function()
  it('should work with text input', function()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('input', {onUpdate:modelValue=setValue:bind(self)}), self.value)}
    end
    })
    render(h(component), root)
    local input = nil
    local data = root._vnode.component.data
    input.value = 'foo'
    triggerEvent('input', input)
    expect(data.value):toEqual('foo')
    data.value = 'bar'
    expect(input.value):toEqual('bar')
  end
  )
  it('should work with multiple listeners', function()
    local spy = jest:fn()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('input', {onUpdate:modelValue={setValue:bind(self), spy}}), self.value)}
    end
    })
    render(h(component), root)
    local input = nil
    local data = root._vnode.component.data
    input.value = 'foo'
    triggerEvent('input', input)
    expect(data.value):toEqual('foo')
    expect(spy):toHaveBeenCalledWith('foo')
  end
  )
  it('should work with updated listeners', function()
    local spy1 = jest:fn()
    local spy2 = jest:fn()
    local toggle = ref(true)
    local component = defineComponent({render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      return {withVModel(h('input', {onUpdate:modelValue=(toggle.value and {spy1} or {spy2})[1]}), 'foo')}
    end
    })
    render(h(component), root)
    local input = nil
    input.value = 'foo'
    triggerEvent('input', input)
    expect(spy1):toHaveBeenCalledWith('foo')
    toggle.value = false
    input.value = 'bar'
    triggerEvent('input', input)
    expect(spy1).tsvar_not:toHaveBeenCalledWith('bar')
    expect(spy2):toHaveBeenCalledWith('bar')
  end
  )
  it('should work with textarea', function()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('textarea', {onUpdate:modelValue=setValue:bind(self)}), self.value)}
    end
    })
    render(h(component), root)
    local input = root:querySelector('textarea')
    local data = root._vnode.component.data
    input.value = 'foo'
    triggerEvent('input', input)
    expect(data.value):toEqual('foo')
    data.value = 'bar'
    expect(input.value):toEqual('bar')
  end
  )
  it('should support modifiers', function()
    local component = defineComponent({data=function()
      return {number=nil, trim=nil, lazy=nil}
    end
    , render=function()
      return {withVModel(h('input', {class='number', onUpdate:modelValue=function(val)
        self.number = val
      end
      }), self.number, {number=true}), withVModel(h('input', {class='trim', onUpdate:modelValue=function(val)
        self.trim = val
      end
      }), self.trim, {trim=true}), withVModel(h('input', {class='lazy', onUpdate:modelValue=function(val)
        self.lazy = val
      end
      }), self.lazy, {lazy=true})}
    end
    })
    render(h(component), root)
    local number = root:querySelector('.number')
    local trim = root:querySelector('.trim')
    local lazy = root:querySelector('.lazy')
    local data = root._vnode.component.data
    number.value = '+01.2'
    triggerEvent('input', number)
    expect(data.number):toEqual(1.2)
    trim.value = '    hello, world    '
    triggerEvent('input', trim)
    expect(data.trim):toEqual('hello, world')
    lazy.value = 'foo'
    triggerEvent('change', lazy)
    expect(data.lazy):toEqual('foo')
  end
  )
  it('should work with checkbox', function()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('input', {type='checkbox', onUpdate:modelValue=setValue:bind(self)}), self.value)}
    end
    })
    render(h(component), root)
    local input = root:querySelector('input')
    local data = root._vnode.component.data
    input.checked = true
    triggerEvent('change', input)
    expect(data.value):toEqual(true)
    data.value = false
    expect(input.checked):toEqual(false)
    data.value = true
    expect(input.checked):toEqual(true)
    input.checked = false
    triggerEvent('change', input)
    expect(data.value):toEqual(false)
  end
  )
  it('should work with checkbox and true-value/false-value', function()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('input', {type='checkbox', true-value='yes', false-value='no', onUpdate:modelValue=setValue:bind(self)}), self.value)}
    end
    })
    render(h(component), root)
    local input = root:querySelector('input')
    local data = root._vnode.component.data
    input.checked = true
    triggerEvent('change', input)
    expect(data.value):toEqual('yes')
    data.value = 'no'
    expect(input.checked):toEqual(false)
    data.value = 'yes'
    expect(input.checked):toEqual(true)
    input.checked = false
    triggerEvent('change', input)
    expect(data.value):toEqual('no')
  end
  )
  it('should work with checkbox and true-value/false-value with object values', function()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('input', {type='checkbox', true-value={yes='yes'}, false-value={no='no'}, onUpdate:modelValue=setValue:bind(self)}), self.value)}
    end
    })
    render(h(component), root)
    local input = root:querySelector('input')
    local data = root._vnode.component.data
    input.checked = true
    triggerEvent('change', input)
    expect(data.value):toEqual({yes='yes'})
    data.value = {no='no'}
    expect(input.checked):toEqual(false)
    data.value = {yes='yes'}
    expect(input.checked):toEqual(true)
    input.checked = false
    triggerEvent('change', input)
    expect(data.value):toEqual({no='no'})
  end
  )
  it(function()
    local component = defineComponent({data=function()
      return {value={}}
    end
    , render=function()
      return {withVModel(h('input', {type='checkbox', class='foo', value='foo', onUpdate:modelValue=setValue:bind(self)}), self.value), withVModel(h('input', {type='checkbox', class='bar', value='bar', onUpdate:modelValue=setValue:bind(self)}), self.value)}
    end
    })
    render(h(component), root)
    local foo = root:querySelector('.foo')
    local bar = root:querySelector('.bar')
    local data = root._vnode.component.data
    foo.checked = true
    triggerEvent('change', foo)
    expect(data.value):toMatchObject({'foo'})
    bar.checked = true
    triggerEvent('change', bar)
    expect(data.value):toMatchObject({'foo', 'bar'})
    bar.checked = false
    triggerEvent('change', bar)
    expect(data.value):toMatchObject({'foo'})
    foo.checked = false
    triggerEvent('change', foo)
    expect(data.value):toMatchObject({})
    data.value = {'foo'}
    expect(bar.checked):toEqual(false)
    expect(foo.checked):toEqual(true)
    data.value = {'bar'}
    expect(foo.checked):toEqual(false)
    expect(bar.checked):toEqual(true)
    data.value = {}
    expect(foo.checked):toEqual(false)
    expect(bar.checked):toEqual(false)
  end
  )
  it('should work with radio', function()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('input', {type='radio', class='foo', value='foo', onUpdate:modelValue=setValue:bind(self)}), self.value), withVModel(h('input', {type='radio', class='bar', value='bar', onUpdate:modelValue=setValue:bind(self)}), self.value)}
    end
    })
    render(h(component), root)
    local foo = root:querySelector('.foo')
    local bar = root:querySelector('.bar')
    local data = root._vnode.component.data
    foo.checked = true
    triggerEvent('change', foo)
    expect(data.value):toEqual('foo')
    bar.checked = true
    triggerEvent('change', bar)
    expect(data.value):toEqual('bar')
    data.value = nil
    expect(foo.checked):toEqual(false)
    expect(bar.checked):toEqual(false)
    data.value = 'foo'
    expect(foo.checked):toEqual(true)
    expect(bar.checked):toEqual(false)
    data.value = 'bar'
    expect(foo.checked):toEqual(false)
    expect(bar.checked):toEqual(true)
  end
  )
  it('should work with single select', function()
    local component = defineComponent({data=function()
      return {value=nil}
    end
    , render=function()
      return {withVModel(h('select', {value=nil, onUpdate:modelValue=setValue:bind(self)}, {h('option', {value='foo'}), h('option', {value='bar'})}), self.value)}
    end
    })
    render(h(component), root)
    local input = root:querySelector('select')
    local foo = root:querySelector('option[value=foo]')
    local bar = root:querySelector('option[value=bar]')
    local data = root._vnode.component.data
    foo.selected = true
    triggerEvent('change', input)
    expect(data.value):toEqual('foo')
    foo.selected = false
    bar.selected = true
    triggerEvent('change', input)
    expect(data.value):toEqual('bar')
    foo.selected = false
    bar.selected = false
    data.value = 'foo'
    expect(input.value):toEqual('foo')
    expect(foo.selected):toEqual(true)
    expect(bar.selected):toEqual(false)
    foo.selected = true
    bar.selected = false
    data.value = 'bar'
    expect(input.value):toEqual('bar')
    expect(foo.selected):toEqual(false)
    expect(bar.selected):toEqual(true)
  end
  )
  it('should work with multiple select', function()
    local component = defineComponent({data=function()
      return {value={}}
    end
    , render=function()
      return {withVModel(h('select', {value=nil, multiple=true, onUpdate:modelValue=setValue:bind(self)}, {h('option', {value='foo'}), h('option', {value='bar'})}), self.value)}
    end
    })
    render(h(component), root)
    local input = root:querySelector('select')
    local foo = root:querySelector('option[value=foo]')
    local bar = root:querySelector('option[value=bar]')
    local data = root._vnode.component.data
    foo.selected = true
    triggerEvent('change', input)
    expect(data.value):toMatchObject({'foo'})
    foo.selected = false
    bar.selected = true
    triggerEvent('change', input)
    expect(data.value):toMatchObject({'bar'})
    foo.selected = true
    bar.selected = true
    triggerEvent('change', input)
    expect(data.value):toMatchObject({'foo', 'bar'})
    foo.selected = false
    bar.selected = false
    data.value = {'foo'}
    expect(input.value):toEqual('foo')
    expect(foo.selected):toEqual(true)
    expect(bar.selected):toEqual(false)
    foo.selected = false
    bar.selected = false
    data.value = {'foo', 'bar'}
    expect(foo.selected):toEqual(true)
    expect(bar.selected):toEqual(true)
  end
  )
end
)