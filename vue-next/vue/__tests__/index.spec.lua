require("stringutil")
require("vue/src")
require("@vue/shared")

describe('compiler + runtime integration', function()
  mockWarn()
  it('should support runtime template compilation', function()
    local container = document:createElement('div')
    local App = {template=, data=function()
      return {count=0}
    end
    }
    createApp(App):mount(container)
    expect(container.innerHTML):toBe()
  end
  )
  it('should support runtime template via CSS ID selector', function()
    local container = document:createElement('div')
    local template = document:createElement('div')
    template.id = 'template'
    template.innerHTML = '{{ count }}'
    document.body:appendChild(template)
    local App = {template=, data=function()
      return {count=0}
    end
    }
    createApp(App):mount(container)
    expect(container.innerHTML):toBe()
  end
  )
  it('should support runtime template via direct DOM node', function()
    local container = document:createElement('div')
    local template = document:createElement('div')
    template.id = 'template'
    template.innerHTML = '{{ count }}'
    local App = {template=template, data=function()
      return {count=0}
    end
    }
    createApp(App):mount(container)
    expect(container.innerHTML):toBe()
  end
  )
  it('should warn template compilation errors with codeframe', function()
    local container = document:createElement('div')
    local App = {template=}
    createApp(App):mount(container)
    expect():toHaveBeenWarned()
    expect(():trim()):toHaveBeenWarned()
    expect():toHaveBeenWarned()
    expect(():trim()):toHaveBeenWarned()
  end
  )
  it('should support custom element', function()
    local app = createApp({template='<custom></custom>'})
    local container = document:createElement('div')
    app.config.isCustomElement = function(tag)
      tag == 'custom'
    end
    
    app:mount(container)
    expect(container.innerHTML):toBe('<custom></custom>')
  end
  )
  it('should support using element innerHTML as template', function()
    local app = createApp({data=function()
      {msg='hello'}
    end
    })
    local container = document:createElement('div')
    container.innerHTML = '{{msg}}'
    app:mount(container)
    expect(container.innerHTML):toBe('hello')
  end
  )
  it('should support selector of rootContainer', function()
    local container = document:createElement('div')
    local origin = document.querySelector
    document.querySelector = jest:fn():mockReturnValue(container)
    local App = {template=, data=function()
      return {count=0}
    end
    }
    createApp(App):mount('#app')
    expect(container.innerHTML):toBe()
    document.querySelector = origin
  end
  )
  it('should warn when template is not avaiable', function()
    local app = createApp({template={}})
    local container = document:createElement('div')
    app:mount(container)
    expect('[Vue warn]: invalid template option:'):toHaveBeenWarned()
  end
  )
  it('should warn when template is is not found', function()
    local app = createApp({template='#not-exist-id'})
    local container = document:createElement('div')
    app:mount(container)
    expect('[Vue warn]: Template element not found or is empty: #not-exist-id'):toHaveBeenWarned()
  end
  )
  it('should warn when container is not found', function()
    local origin = document.querySelector
    document.querySelector = jest:fn():mockReturnValue(nil)
    local App = {template=, data=function()
      return {count=0}
    end
    }
    createApp(App):mount('#not-exist-id')
    expect('[Vue warn]: Failed to mount app: mount target selector returned null.'):toHaveBeenWarned()
    document.querySelector = origin
  end
  )
end
)