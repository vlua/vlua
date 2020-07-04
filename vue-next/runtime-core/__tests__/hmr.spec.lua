require("@vue/runtime-test")
require("@vue/compiler-core")

local __VUE_HMR_RUNTIME__ = nil
local  = __VUE_HMR_RUNTIME__
function compileToFunction(template)
  local  = baseCompile(template)
  local render = Function('Vue', code)(runtimeTest)
  render._rc = true
  return render
end

describe('hot module replacement', function()
  test('inject global runtime', function()
    expect(createRecord):toBeDefined()
    expect(rerender):toBeDefined()
    expect(reload):toBeDefined()
  end
  )
  test('createRecord', function()
    expect(createRecord('test1')):toBe(true)
    expect(createRecord('test1')):toBe(false)
  end
  )
  test('rerender', function()
    local root = nodeOps:createElement('div')
    local parentId = 'test2-parent'
    local childId = 'test2-child'
    local Child = {__hmrId=childId, render=compileToFunction()}
    createRecord(childId)
    local Parent = {__hmrId=parentId, data=function()
      return {count=0}
    end
    , components={Child=Child}, render=compileToFunction()}
    createRecord(parentId)
    render(h(Parent), root)
    expect(serializeInner(root)):toBe()
    triggerEvent(root.children[0+1], 'click')
    expect(serializeInner(root)):toBe()
    rerender(parentId, compileToFunction())
    expect(serializeInner(root)):toBe()
    rerender(parentId, compileToFunction())
    expect(serializeInner(root)):toBe()
    rerender(parentId, compileToFunction())
    expect(serializeInner(root)):toBe()
    rerender(parentId, compileToFunction())
    expect(serializeInner(root)):toBe()
  end
  )
  test('reload', function()
    local root = nodeOps:createElement('div')
    local childId = 'test3-child'
    local unmountSpy = jest:fn()
    local mountSpy = jest:fn()
    local Child = {__hmrId=childId, data=function()
      return {count=0}
    end
    , unmounted=unmountSpy, render=compileToFunction()}
    createRecord(childId)
    local Parent = {render=function()
      h(Child)
    end
    }
    render(h(Parent), root)
    expect(serializeInner(root)):toBe()
    reload(childId, {__hmrId=childId, data=function()
      return {count=1}
    end
    , mounted=mountSpy, render=compileToFunction()})
    expect(serializeInner(root)):toBe()
    expect(unmountSpy):toHaveBeenCalledTimes(1)
    expect(mountSpy):toHaveBeenCalledTimes(1)
  end
  )
  test('static el reference', function()
    local root = nodeOps:createElement('div')
    local id = 'test-static-el'
    local template = nil
    local Comp = {__hmrId=id, data=function()
      return {count=0}
    end
    , render=compileToFunction(template)}
    createRecord(id)
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    triggerEvent(root.children[0+1].children[1+1], 'click')
    expect(serializeInner(root)):toBe()
    rerender(id, compileToFunction(template:gsub()))
    expect(serializeInner(root)):toBe()
  end
  )
  test('force update child component w/ static props', function()
    local root = nodeOps:createElement('div')
    local parentId = 'test-force-props-parent'
    local childId = 'test-force-props-child'
    local Child = {__hmrId=childId, props={msg=String}, render=compileToFunction()}
    createRecord(childId)
    local Parent = {__hmrId=parentId, components={Child=Child}, render=compileToFunction()}
    createRecord(parentId)
    render(h(Parent), root)
    expect(serializeInner(root)):toBe()
    rerender(parentId, compileToFunction())
    expect(serializeInner(root)):toBe()
  end
  )
  test('remove static class from parent', function()
    local root = nodeOps:createElement('div')
    local parentId = 'test-force-class-parent'
    local childId = 'test-force-class-child'
    local Child = {__hmrId=childId, render=compileToFunction()}
    createRecord(childId)
    local Parent = {__hmrId=parentId, components={Child=Child}, render=compileToFunction()}
    createRecord(parentId)
    render(h(Parent), root)
    expect(serializeInner(root)):toBe()
    rerender(parentId, compileToFunction())
    expect(serializeInner(root)):toBe()
  end
  )
  test('rerender if any parent in the parent chain', function()
    local root = nodeOps:createElement('div')
    local parent = 'test-force-props-parent-'
    local childId = 'test-force-props-child'
    local numberOfParents = 5
    local Child = {__hmrId=childId, render=compileToFunction()}
    createRecord(childId)
    local components = {}
    local i = 0
    repeat
      local parentId = nil
      local parentComp = {__hmrId=parentId}
      table.insert(components, parentComp)
      if i == 0 then
        parentComp.render = compileToFunction()
        parentComp.components = {Child=Child}
      else
        parentComp.render = compileToFunction()
        -- [ts2lua]components下标访问可能不正确
        parentComp.components = {Parent=components[i - 1]}
      end
      createRecord(parentId)
      i=i+1
    until not(i < numberOfParents)
    -- [ts2lua]components下标访问可能不正确
    local last = components[#components - 1]
    render(h(last), root)
    expect(serializeInner(root)):toBe()
    rerender(compileToFunction())
    expect(serializeInner(root)):toBe()
  end
  )
end
)