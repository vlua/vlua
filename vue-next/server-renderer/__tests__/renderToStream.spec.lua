require("vue")
require("@vue/shared")
require("server-renderer/src/renderToStream")
require("server-renderer/src/helpers/ssrRenderSlot")
local _renderToStream = renderToStream

mockWarn()
local promisifyStream = function(stream)
  return Promise(function(resolve, reject)
    local result = ''
    stream:on('data', function(data)
      result = result + data
    end
    )
    stream:on('error', function()
      reject(result)
    end
    )
    stream:on('end', function()
      resolve(result)
    end
    )
  end
  )
end

local renderToStream = function(app, context)
  promisifyStream(_renderToStream(app, context))
end

describe('ssr: renderToStream', function()
  test('should apply app context', function()
    local app = createApp({render=function()
      local Foo = resolveComponent('foo')
      return h(Foo)
    end
    })
    app:component('foo', {render=function()
      h('div', 'foo')
    end
    })
    local html = nil
    expect(html):toBe()
  end
  )
  describe('components', function()
    test('vnode components', function()
      expect():toBe()
    end
    )
    test('option components returning render from setup', function()
      expect():toBe()
    end
    )
    test('setup components returning render from setup', function()
      expect():toBe()
    end
    )
    test('optimized components', function()
      expect():toBe()
    end
    )
    describe('template components', function()
      test('render', function()
        expect():toBe()
      end
      )
      test('handle compiler errors', function()
        
        expect('Template compilation error: Unexpected EOF in tag.\n' .. '1  |  <\n' .. '   |   ^'):toHaveBeenWarned()
      end
      )
    end
    )
    test('nested vnode components', function()
      local Child = {props={'msg'}, render=function(this)
        return h('div', self.msg)
      end
      }
      expect():toBe()
    end
    )
    test('nested optimized components', function()
      local Child = {props={'msg'}, ssrRender=function(ctx, push)
        push()
      end
      }
      expect():toBe()
    end
    )
    test('nested template components', function()
      local Child = {props={'msg'}, template=}
      local app = createApp({template=})
      app:component('Child', Child)
      expect():toBe()
    end
    )
    test('mixing optimized / vnode / template components', function()
      local OptimizedChild = {props={'msg'}, ssrRender=function(ctx, push)
        push()
      end
      }
      local VNodeChild = {props={'msg'}, render=function(this)
        return h('div', self.msg)
      end
      }
      local TemplateChild = {props={'msg'}, template=}
      expect():toBe()
    end
    )
    test('nested components with optimized slots', function()
      local Child = {props={'msg'}, ssrRender=function(ctx, push, parent)
        push()
        ssrRenderSlot(ctx.tsvar_slots, 'default', {msg='from slot'}, function()
          push()
        end
        , push, parent)
        push()
      end
      }
      expect():toBe( +  + )
      expect():toBe()
    end
    )
    test('nested components with vnode slots', function()
      local Child = {props={'msg'}, ssrRender=function(ctx, push, parent)
        push()
        ssrRenderSlot(ctx.tsvar_slots, 'default', {msg='from slot'}, nil, push, parent)
        push()
      end
      }
      expect():toBe( +  + )
    end
    )
    test('nested components with template slots', function()
      local Child = {props={'msg'}, template=}
      local app = createApp({components={Child=Child}, template=})
      expect():toBe( +  + )
    end
    )
    test('nested render fn components with template slots', function()
      local Child = {props={'msg'}, render=function(this)
        return h('div', {class='child'}, self.tsvar_slots:default({msg='from slot'}))
      end
      }
      local app = createApp({template=})
      app:component('Child', Child)
      expect():toBe( +  + )
    end
    )
    test('async components', function()
      local Child = {setup=function()
        return {msg='hello'}
      end
      , ssrRender=function(ctx, push)
        push()
      end
      }
      expect():toBe()
    end
    )
    test('parallel async components', function()
      local OptimizedChild = {props={'msg'}, setup=function(props)
        return {localMsg=props.msg .. '!'}
      end
      , ssrRender=function(ctx, push)
        push()
      end
      }
      local VNodeChild = {props={'msg'}, setup=function(props)
        return {localMsg=props.msg .. '!'}
      end
      , render=function(this)
        return h('div', self.localMsg)
      end
      }
      expect():toBe()
    end
    )
  end
  )
  describe('vnode element', function()
    test('props', function()
      expect():toBe()
    end
    )
    test('text children', function()
      expect():toBe()
    end
    )
    test('array children', function()
      expect():toBe()
    end
    )
    test('void elements', function()
      expect():toBe()
    end
    )
    test('innerHTML', function()
      expect():toBe()
    end
    )
    test('textContent', function()
      expect():toBe()
    end
    )
    test('textarea value', function()
      expect():toBe()
    end
    )
  end
  )
  describe('raw vnode types', function()
    test('Text', function()
      expect():toBe()
    end
    )
    test('Comment', function()
      expect():toBe()
    end
    )
    test('Static', function()
      local content = nil
      expect():toBe(content)
    end
    )
  end
  )
  describe('scopeId', function()
    local withId = withScopeId('data-v-test')
    local withChildId = withScopeId('data-v-child')
    test('basic', function()
      expect():toBe()
    end
    )
    test('with slots', function()
      local Child = {__scopeId='data-v-child', render=withChildId(function(this)
        return h('div', self.tsvar_slots:default())
      end
      )}
      local Parent = {__scopeId='data-v-test', render=withId(function()
        return h(Child, nil, {default=withId(function()
          h('span', 'slot')
        end
        )})
      end
      )}
      expect():toBe()
    end
    )
  end
  )
end
)