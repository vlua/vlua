require("@vue/runtime-dom")
require("@vue/server-renderer")
require("@vue/shared")

function mountWithHydration(html, render)
  local container = document:createElement('div')
  container.innerHTML = html
  local app = createSSRApp({render=render})
  return {vnode=app:mount(container).tsvar_.subTree, container=container}
end

local triggerEvent = function(type, el)
  local event = Event(type)
  el:dispatchEvent(event)
end

describe('SSR hydration', function()
  mockWarn()
  beforeEach(function()
    document.body.innerHTML = ''
  end
  )
  test('text', function()
    local msg = ref('foo')
    local  = mountWithHydration('foo', function()
      msg.value
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(container.textContent):toBe('foo')
    msg.value = 'bar'
    expect(container.textContent):toBe('bar')
  end
  )
  test('comment', function()
    local  = mountWithHydration('<!---->', function()
      nil
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(vnode.el.nodeType):toBe(8)
  end
  )
  test('static', function()
    local html = '<div><span>hello</span></div>'
    local  = mountWithHydration(html, function()
      createStaticVNode('', 1)
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(vnode.el.outerHTML):toBe(html)
    expect(vnode.anchor):toBe(container.firstChild)
    expect(vnode.children):toBe(html)
  end
  )
  test('static (multiple elements)', function()
    local staticContent = '<div></div><span>hello</span>'
    local html =  + staticContent + 
    local n1 = h('div', 'hi')
    local s = createStaticVNode('', 2)
    local n2 = h('div', 'ho')
    local  = mountWithHydration(html, function()
      h('div', {n1, s, n2})
    end
    )
    local div = nil
    expect(n1.el):toBe(div.firstChild)
    expect(n2.el):toBe(div.lastChild)
    expect(s.el):toBe(div.childNodes[1+1])
    expect(s.anchor):toBe(div.childNodes[2+1])
    expect(s.children):toBe(staticContent)
  end
  )
  test('element with text children', function()
    local msg = ref('foo')
    local  = mountWithHydration('<div class="foo">foo</div>', function()
      h('div', {class=msg.value}, msg.value)
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(().textContent):toBe('foo')
    msg.value = 'bar'
    expect(container.innerHTML):toBe()
  end
  )
  test('element with elements children', function()
    local msg = ref('foo')
    local fn = jest:fn()
    local  = mountWithHydration('<div><span>foo</span><span class="foo"></span></div>', function()
      h('div', {h('span', msg.value), h('span', {class=msg.value, onClick=fn})})
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(vnode.children[0+1].el):toBe(().childNodes[0+1])
    expect(vnode.children[1+1].el):toBe(().childNodes[1+1])
    triggerEvent('click', )
    expect(fn):toHaveBeenCalled()
    msg.value = 'bar'
    expect(vnode.el.innerHTML):toBe()
  end
  )
  test('element with ref', function()
    local el = ref()
    local  = mountWithHydration('<div></div>', function()
      h('div', {ref=el})
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(el.value):toBe(vnode.el)
  end
  )
  test('Fragment', function()
    local msg = ref('foo')
    local fn = jest:fn()
    local  = mountWithHydration('<div><!--[--><span>foo</span><!--[--><span class="foo"></span><!--]--><!--]--></div>', function()
      h('div', {{h('span', msg.value), {h('span', {class=msg.value, onClick=fn})}}})
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(vnode.el.innerHTML):toBe()
    local fragment1 = vnode.children[0+1]
    expect(fragment1.el):toBe(vnode.el.childNodes[0+1])
    local fragment1Children = fragment1.children
    expect(().tagName):toBe('SPAN')
    expect(fragment1Children[0+1].el):toBe(vnode.el.childNodes[1+1])
    local fragment2 = fragment1Children[1+1]
    expect(fragment2.el):toBe(vnode.el.childNodes[2+1])
    local fragment2Children = fragment2.children
    expect(().tagName):toBe('SPAN')
    expect(fragment2Children[0+1].el):toBe(vnode.el.childNodes[3+1])
    expect(fragment2.anchor):toBe(vnode.el.childNodes[4+1])
    expect(fragment1.anchor):toBe(vnode.el.childNodes[5+1])
    triggerEvent('click', )
    expect(fn):toHaveBeenCalled()
    msg.value = 'bar'
    expect(vnode.el.innerHTML):toBe()
  end
  )
  test('Teleport', function()
    local msg = ref('foo')
    local fn = jest:fn()
    local teleportContainer = document:createElement('div')
    teleportContainer.id = 'teleport'
    teleportContainer.innerHTML = 
    document.body:appendChild(teleportContainer)
    local  = mountWithHydration('<!--teleport start--><!--teleport end-->', function()
      h(Teleport, {to='#teleport'}, {h('span', msg.value), h('span', {class=msg.value, onClick=fn})})
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    expect(vnode.anchor):toBe(container.lastChild)
    expect(vnode.target):toBe(teleportContainer)
    expect(vnode.children[0+1].el):toBe(teleportContainer.childNodes[0+1])
    expect(vnode.children[1+1].el):toBe(teleportContainer.childNodes[1+1])
    expect(vnode.targetAnchor):toBe(teleportContainer.childNodes[2+1])
    triggerEvent('click', )
    expect(fn):toHaveBeenCalled()
    msg.value = 'bar'
    expect(teleportContainer.innerHTML):toBe()
  end
  )
  test('Teleport (multiple + integration)', function()
    local msg = ref('foo')
    local fn1 = jest:fn()
    local fn2 = jest:fn()
    local Comp = function()
      {h(Teleport, {to='#teleport2'}, {h('span', msg.value), h('span', {class=msg.value, onClick=fn1})}), h(Teleport, {to='#teleport2'}, {h('span', msg.value .. '2'), h('span', {class=msg.value .. '2', onClick=fn2})})}
    end
    
    local teleportContainer = document:createElement('div')
    teleportContainer.id = 'teleport2'
    local ctx = {}
    local mainHtml = nil
    expect(mainHtml):toMatchInlineSnapshot()
    -- [ts2lua]()下标访问可能不正确
    local teleportHtml = ()['#teleport2']
    expect(teleportHtml):toMatchInlineSnapshot()
    teleportContainer.innerHTML = teleportHtml
    document.body:appendChild(teleportContainer)
    local  = mountWithHydration(mainHtml, Comp)
    expect(vnode.el):toBe(container.firstChild)
    local teleportVnode1 = vnode.children[0+1]
    local teleportVnode2 = vnode.children[1+1]
    expect(teleportVnode1.el):toBe(container.childNodes[1+1])
    expect(teleportVnode1.anchor):toBe(container.childNodes[2+1])
    expect(teleportVnode2.el):toBe(container.childNodes[3+1])
    expect(teleportVnode2.anchor):toBe(container.childNodes[4+1])
    expect(teleportVnode1.target):toBe(teleportContainer)
    expect(teleportVnode1.children[0+1].el):toBe(teleportContainer.childNodes[0+1])
    expect(teleportVnode1.targetAnchor):toBe(teleportContainer.childNodes[2+1])
    expect(teleportVnode2.target):toBe(teleportContainer)
    expect(teleportVnode2.children[0+1].el):toBe(teleportContainer.childNodes[3+1])
    expect(teleportVnode2.targetAnchor):toBe(teleportContainer.childNodes[5+1])
    triggerEvent('click', )
    expect(fn1):toHaveBeenCalled()
    triggerEvent('click', )
    expect(fn2):toHaveBeenCalled()
    msg.value = 'bar'
    expect(teleportContainer.innerHTML):toMatchInlineSnapshot()
  end
  )
  test('Teleport (disabled)', function()
    local msg = ref('foo')
    local fn1 = jest:fn()
    local fn2 = jest:fn()
    local Comp = function()
      {h('div', 'foo'), h(Teleport, {to='#teleport3', disabled=true}, {h('span', msg.value), h('span', {class=msg.value, onClick=fn1})}), h('div', {class=msg.value .. '2', onClick=fn2}, 'bar')}
    end
    
    local teleportContainer = document:createElement('div')
    teleportContainer.id = 'teleport3'
    local ctx = {}
    local mainHtml = nil
    expect(mainHtml):toMatchInlineSnapshot()
    -- [ts2lua]()下标访问可能不正确
    local teleportHtml = ()['#teleport3']
    expect(teleportHtml):toMatchInlineSnapshot()
    teleportContainer.innerHTML = teleportHtml
    document.body:appendChild(teleportContainer)
    local  = mountWithHydration(mainHtml, Comp)
    expect(vnode.el):toBe(container.firstChild)
    local children = vnode.children
    expect(children[0+1].el):toBe(container.childNodes[1+1])
    local teleportVnode = children[1+1]
    expect(teleportVnode.el):toBe(container.childNodes[2+1])
    expect(teleportVnode.children[0+1].el):toBe(container.childNodes[3+1])
    expect(teleportVnode.children[1+1].el):toBe(container.childNodes[4+1])
    expect(teleportVnode.anchor):toBe(container.childNodes[5+1])
    expect(children[2+1].el):toBe(container.childNodes[6+1])
    expect(teleportVnode.target):toBe(teleportContainer)
    expect(teleportVnode.targetAnchor):toBe(teleportContainer.childNodes[0+1])
    triggerEvent('click', )
    expect(fn1):toHaveBeenCalled()
    triggerEvent('click', )
    expect(fn2):toHaveBeenCalled()
    msg.value = 'bar'
    expect(container.innerHTML):toMatchInlineSnapshot()
  end
  )
  test('full compiler integration', function()
    local mounted = {}
    local log = jest:fn()
    local toggle = ref(true)
    local Child = {data=function()
      return {count=0, text='hello', style={color='red'}}
    end
    , mounted=function()
      table.insert(mounted, 'child')
    end
    , template=}
    local App = {setup=function()
      return {toggle=toggle}
    end
    , mounted=function()
      table.insert(mounted, 'parent')
    end
    , template=, components={Child=Child}, methods={log=log}}
    local container = document:createElement('div')
    container.innerHTML = 
    createSSRApp(App):mount(container)
    triggerEvent('click', )
    expect(log):toHaveBeenCalledWith('click')
    local count = container:querySelector('.count')
    expect(count.textContent):toBe()
    triggerEvent('click', )
    expect(count.textContent):toBe()
    expect(count.style.color):toBe('red')
    triggerEvent('click', )
    expect(count.style.color):toBe('green')
    triggerEvent('click', )
    expect(log):toHaveBeenCalledWith('child')
    local text = nil
    local input = nil
    expect(text.textContent):toBe('hello')
    input.value = 'bye'
    triggerEvent('input', input)
    expect(text.textContent):toBe('bye')
  end
  )
  test('Suspense', function()
    local AsyncChild = {setup=function()
      local count = ref(0)
      return function()
        h('span', {onClick=function()
          count.value=count.value+1
        end
        }, count.value)
      end
      
    
    end
    }
    local  = mountWithHydration('<span>0</span>', function()
      h(Suspense, function()
        h(AsyncChild)
      end
      )
    end
    )
    expect(vnode.el):toBe(container.firstChild)
    triggerEvent('click', )
    expect(container.innerHTML):toBe()
  end
  )
  test('Suspense (full integration)', function()
    local mountedCalls = {}
    local asyncDeps = {}
    local AsyncChild = defineComponent({props={'n'}, setup=function(props)
      local count = ref(props.n)
      onMounted(function()
        table.insert(mountedCalls, props.n)
      end
      )
      local p = Promise(function(r)
        setTimeout(r, props.n * 10)
      end
      )
      table.insert(asyncDeps, p)
      return function()
        h('span', {onClick=function()
          count.value=count.value+1
        end
        }, count.value)
      end
      
    
    end
    })
    local done = jest:fn()
    local App = {template=, components={AsyncChild=AsyncChild}, methods={done=done}}
    local container = document:createElement('div')
    container.innerHTML = 
    expect(container.innerHTML):toMatchInlineSnapshot()
    
    asyncDeps.length = 0
    createSSRApp(App):mount(container)
    expect(#mountedCalls):toBe(0)
    expect(#asyncDeps):toBe(2)
    expect(mountedCalls):toMatchObject({1, 2})
    expect(container.innerHTML):toMatch()
    local span1 = nil
    triggerEvent('click', span1)
    expect(container.innerHTML):toMatch()
    local span2 = span1.nextSibling
    triggerEvent('click', span2)
    expect(container.innerHTML):toMatch()
  end
  )
  test('async component', function()
    local spy = jest:fn()
    local Comp = function()
      h('button', {onClick=spy}, 'hello!')
    end
    
    local serverResolve = nil
    local AsyncComp = defineAsyncComponent(function()
      Promise(function(r)
        serverResolve = r
      end
      )
    end
    )
    local App = {render=function()
      return {'hello', h(AsyncComp), 'world'}
    end
    }
    local htmlPromise = renderToString(h(App))
    serverResolve(Comp)
    local html = nil
    expect(html):toMatchInlineSnapshot()
    local clientResolve = nil
    AsyncComp = defineAsyncComponent(function()
      Promise(function(r)
        clientResolve = r
      end
      )
    end
    )
    local container = document:createElement('div')
    container.innerHTML = html
    createSSRApp(App):mount(container)
    triggerEvent('click', )
    expect(spy).tsvar_not:toHaveBeenCalled()
    clientResolve(Comp)
    triggerEvent('click', )
    expect(spy):toHaveBeenCalled()
  end
  )
  describe('mismatch handling', function()
    test('text node', function()
      local  = mountWithHydration(function()
        'bar'
      end
      )
      expect(container.textContent):toBe('bar')
      expect():toHaveBeenWarned()
    end
    )
    test('element text content', function()
      local  = mountWithHydration(function()
        h('div', 'bar')
      end
      )
      expect(container.innerHTML):toBe('<div>bar</div>')
      expect():toHaveBeenWarned()
    end
    )
    test('not enough children', function()
      local  = mountWithHydration(function()
        h('div', {h('span', 'foo'), h('span', 'bar')})
      end
      )
      expect(container.innerHTML):toBe('<div><span>foo</span><span>bar</span></div>')
      expect():toHaveBeenWarned()
    end
    )
    test('too many children', function()
      local  = mountWithHydration(function()
        h('div', {h('span', 'foo')})
      end
      )
      expect(container.innerHTML):toBe('<div><span>foo</span></div>')
      expect():toHaveBeenWarned()
    end
    )
    test('complete mismatch', function()
      local  = mountWithHydration(function()
        h('div', {h('div', 'foo'), h('p', 'bar')})
      end
      )
      expect(container.innerHTML):toBe('<div><div>foo</div><p>bar</p></div>')
      expect():toHaveBeenWarnedTimes(2)
    end
    )
    test('fragment mismatch removal', function()
      local  = mountWithHydration(function()
        h('div', {h('span', 'replaced')})
      end
      )
      expect(container.innerHTML):toBe('<div><span>replaced</span></div>')
      expect():toHaveBeenWarned()
    end
    )
    test('fragment not enough children', function()
      local  = mountWithHydration(function()
        h('div', {{h('div', 'foo'), h('div', 'bar')}, h('div', 'baz')})
      end
      )
      expect(container.innerHTML):toBe('<div><!--[--><div>foo</div><div>bar</div><!--]--><div>baz</div></div>')
      expect():toHaveBeenWarned()
    end
    )
    test('fragment too many children', function()
      local  = mountWithHydration(function()
        h('div', {{h('div', 'foo')}, h('div', 'baz')})
      end
      )
      expect(container.innerHTML):toBe('<div><!--[--><div>foo</div><!--]--><div>baz</div></div>')
      expect():toHaveBeenWarned()
      expect():toHaveBeenWarned()
    end
    )
    test('Teleport target has empty children', function()
      local teleportContainer = document:createElement('div')
      teleportContainer.id = 'teleport'
      document.body:appendChild(teleportContainer)
      mountWithHydration('<!--teleport start--><!--teleport end-->', function()
        h(Teleport, {to='#teleport'}, {h('span', 'value')})
      end
      )
      expect(teleportContainer.innerHTML):toBe()
      expect():toHaveBeenWarned()
    end
    )
  end
  )
end
)