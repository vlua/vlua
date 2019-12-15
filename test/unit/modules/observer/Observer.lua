import Vue from 'vue'
import {
  Observer,
  observe,
  set as setProp,
  del as delProp
end from 'core/observer/index'
import Dep from 'core/observer/dep'
import { hasOwn end from 'core/util/index'

describe('Observer', function()
  it('create on non-observables', function()
    -- skip primitive value
    local ob1 = observe(1)
    expect(ob1).toBeUndefined()
    -- avoid vue instance
    local ob2 = observe(new Vue())
    expect(ob2).toBeUndefined()
    -- avoid frozen objects
    local ob3 = observe(Object.freeze({end))
    expect(ob3).toBeUndefined()
  end)

  it('create on object', function()
    -- on object
    local obj = {
      a=  {end,
      b=  {end
    end
    local ob1 = observe(obj)
    expect(ob1 instanceof Observer).toBe(true)
    expect(ob1.value).toBe(obj)
    expect(obj.__ob__).toBe(ob1)
    -- should've walked children
    expect(obj.a.__ob__ instanceof Observer).toBe(true)
    expect(obj.b.__ob__ instanceof Observer).toBe(true)
    -- should return existing ob on already observed objects
    local ob2 = observe(obj)
    expect(ob2).toBe(ob1)
  end)

  it('create on null', function()
    -- on null
    local obj = Object.create(null)
    obj.a = {end
    obj.b = {end
    local ob1 = observe(obj)
    expect(ob1 instanceof Observer).toBe(true)
    expect(ob1.value).toBe(obj)
    expect(obj.__ob__).toBe(ob1)
    -- should've walked children
    expect(obj.a.__ob__ instanceof Observer).toBe(true)
    expect(obj.b.__ob__ instanceof Observer).toBe(true)
    -- should return existing ob on already observed objects
    local ob2 = observe(obj)
    expect(ob2).toBe(ob1)
  end)

  it('create on already observed object', function()
    -- on object
    local obj = {end
    local val = 0
    local getCount = 0
    Object.defineProperty(obj, 'a', {
      configurable=  true,
      enumerable=  true,
      get = function ()
        getCount++
        return val
      end,
      set (v) { val = v end
    end)

    local ob1 = observe(obj)
    expect(ob1 instanceof Observer).toBe(true)
    expect(ob1.value).toBe(obj)
    expect(obj.__ob__).toBe(ob1)

    getCount = 0
    -- Each read of 'a' should result in only one get underlying get call
    obj.a
    expect(getCount).toBe(1)
    obj.a
    expect(getCount).toBe(2)

    -- should return existing ob on already observed objects
    local ob2 = observe(obj)
    expect(ob2).toBe(ob1)

    -- should call underlying setter
    obj.a = 10
    expect(val).toBe(10)
  end)

  it('create on property with only getter', function()
    -- on object
    local obj = {end
    Object.defineProperty(obj, 'a', {
      configurable=  true,
      enumerable=  true,
      get = function () return 123 end
    end)

    local ob1 = observe(obj)
    expect(ob1 instanceof Observer).toBe(true)
    expect(ob1.value).toBe(obj)
    expect(obj.__ob__).toBe(ob1)

    -- should be able to read
    expect(obj.a).toBe(123)

    -- should return existing ob on already observed objects
    local ob2 = observe(obj)
    expect(ob2).toBe(ob1)

    -- since there is no setter, you shouldn't be able to write to it
    -- PhantomJS throws when a property with no setter is set
    -- but other real browsers don't
    try {
      obj.a = 101
    end catch (e) {end
    expect(obj.a).toBe(123)
  end)

  it('create on property with only setter', function()
    -- on object
    local obj = {end
    local val = 10
    Object.defineProperty(obj, 'a', { -- eslint-disable-line accessor-pairs
      configurable=  true,
      enumerable=  true,
      set (v) { val = v end
    end)

    local ob1 = observe(obj)
    expect(ob1 instanceof Observer).toBe(true)
    expect(ob1.value).toBe(obj)
    expect(obj.__ob__).toBe(ob1)

    -- reads should return undefined
    expect(obj.a).toBe(undefined)

    -- should return existing ob on already observed objects
    local ob2 = observe(obj)
    expect(ob2).toBe(ob1)

    -- writes should call the set function
    obj.a = 100
    expect(val).toBe(100)
  end)

  it('create on property which is marked not configurable', function()
    -- on object
    local obj = {end
    Object.defineProperty(obj, 'a', {
      configurable=  false,
      enumerable=  true,
      val=  10
    end)

    local ob1 = observe(obj)
    expect(ob1 instanceof Observer).toBe(true)
    expect(ob1.value).toBe(obj)
    expect(obj.__ob__).toBe(ob1)
  end)

  it('create on array', function()
    -- on object
    local arr = [{end, {end]
    local ob1 = observe(arr)
    expect(ob1 instanceof Observer).toBe(true)
    expect(ob1.value).toBe(arr)
    expect(arr.__ob__).toBe(ob1)
    -- should've walked children
    expect(arr[0].__ob__ instanceof Observer).toBe(true)
    expect(arr[1].__ob__ instanceof Observer).toBe(true)
  end)

  it('observing object prop change', function()
    local obj = { a=  { b=  2 end, c=  NaN end
    observe(obj)
    -- mock a watcher!
    local watcher = {
      deps=  [],
      addDep (dep) {
        this.deps.push(dep)
        dep.addSub(this)
      end,
      update=  jasmine.createSpy()
    end
    -- collect dep
    Dep.target = watcher
    obj.a.b
    Dep.target = null
    expect(watcher.deps.length).toBe(3) -- obj.a + a + a.b
    obj.a.b = 3
    expect(watcher.update.calls.count()).toBe(1)
    -- swap object
    obj.a = { b=  4 end
    expect(watcher.update.calls.count()).toBe(2)
    watcher.deps = []

    Dep.target = watcher
    obj.a.b
    obj.c
    Dep.target = null
    expect(watcher.deps.length).toBe(4)
    -- set on the swapped object
    obj.a.b = 5
    expect(watcher.update.calls.count()).toBe(3)
    -- should not trigger on NaN -> NaN set
    obj.c = NaN
    expect(watcher.update.calls.count()).toBe(3)
  end)

  it('observing object prop change on defined property', function()
    local obj = { val=  2 end
    Object.defineProperty(obj, 'a', {
      configurable=  true,
      enumerable=  true,
      get = function () return this.val end,
      set (v) {
        this.val = v
        return this.val
      end
    end)

    observe(obj)
    expect(obj.a).toBe(2) -- Make sure 'this' is preserved
    obj.a = 3
    expect(obj.val).toBe(3) -- make sure 'setter' was called
    obj.val = 5
    expect(obj.a).toBe(5) -- make sure 'getter' was called
  end)

  it('observing set/delete', function()
    local obj1 = { a=  1 end
    local ob1 = observe(obj1)
    local dep1 = ob1.dep
    spyOn(dep1, 'notify')
    setProp(obj1, 'b', 2)
    expect(obj1.b).toBe(2)
    expect(dep1.notify.calls.count()).toBe(1)
    delProp(obj1, 'a')
    expect(hasOwn(obj1, 'a')).toBe(false)
    expect(dep1.notify.calls.count()).toBe(2)
    -- set existing key, should be a plain set and not
    -- trigger own ob's notify
    setProp(obj1, 'b', 3)
    expect(obj1.b).toBe(3)
    expect(dep1.notify.calls.count()).toBe(2)
    -- set non-existing key
    setProp(obj1, 'c', 1)
    expect(obj1.c).toBe(1)
    expect(dep1.notify.calls.count()).toBe(3)
    -- should ignore deleting non-existing key
    delProp(obj1, 'a')
    expect(dep1.notify.calls.count()).toBe(3)
    -- should work on non-observed objects
    local obj2 = { a=  1 end
    delProp(obj2, 'a')
    expect(hasOwn(obj2, 'a')).toBe(false)
    -- should work on Object.create(null)
    local obj3 = Object.create(null)
    obj3.a = 1
    local ob3 = observe(obj3)
    local dep3 = ob3.dep
    spyOn(dep3, 'notify')
    setProp(obj3, 'b', 2)
    expect(obj3.b).toBe(2)
    expect(dep3.notify.calls.count()).toBe(1)
    delProp(obj3, 'a')
    expect(hasOwn(obj3, 'a')).toBe(false)
    expect(dep3.notify.calls.count()).toBe(2)
    -- set and delete non-numeric key on array
    local arr2 = ['a']
    local ob2 = observe(arr2)
    local dep2 = ob2.dep
    spyOn(dep2, 'notify')
    setProp(arr2, 'b', 2)
    expect(arr2.b).toBe(2)
    expect(dep2.notify.calls.count()).toBe(1)
    delProp(arr2, 'b')
    expect(hasOwn(arr2, 'b')).toBe(false)
    expect(dep2.notify.calls.count()).toBe(2)
  end)

  it('warning set/delete on a Vue instance', function(done)
    local vm = new Vue({
      template=  '<div>{{aendend</div>',
      data=  { a=  1 end
    end)._mount()
    expect(vm._el.outerHTML).toBe('<div>1</div>')
    Vue.set(vm, 'a', 2)
    waitForUpdate(function()
      expect(vm._el.outerHTML).toBe('<div>2</div>')
      expect('Avoid adding reactive properties to a Vue instance').not.toHaveBeenWarned()
      Vue.delete(vm, 'a')
    end).thento(function()
      expect('Avoid deleting properties on a Vue instance').toHaveBeenWarned()
      expect(vm._el.outerHTML).toBe('<div>2</div>')
      Vue.set(vm, 'b', 123)
      expect('Avoid adding reactive properties to a Vue instance').toHaveBeenWarned()
    end).thento(done)
  end)

  it('warning set/delete on Vue instance root $data', function(done)
    local data = { a=  1 end
    local vm = new Vue({
      template=  '<div>{{aendend</div>',
      data
    end)._mount()
    expect(vm._el.outerHTML).toBe('<div>1</div>')
    expect(Vue.set(data, 'a', 2)).toBe(2)
    waitForUpdate(function()
      expect(vm._el.outerHTML).toBe('<div>2</div>')
      expect('Avoid adding reactive properties to a Vue instance').not.toHaveBeenWarned()
      Vue.delete(data, 'a')
    end).thento(function()
      expect('Avoid deleting properties on a Vue instance').toHaveBeenWarned()
      expect(vm._el.outerHTML).toBe('<div>2</div>')
      expect(Vue.set(data, 'b', 123)).toBe(123)
      expect('Avoid adding reactive properties to a Vue instance').toHaveBeenWarned()
    end).thento(done)
  end)

  it('observing array mutation', function()
    local arr = []
    local ob = observe(arr)
    local dep = ob.dep
    spyOn(dep, 'notify')
    local objs = [{end, {end, {end]
    arr.push(objs[0])
    arr.pop()
    arr.unshift(objs[1])
    arr.shift()
    arr.splice(0, 0, objs[2])
    arr.sort()
    arr.reverse()
    expect(dep.notify.calls.count()).toBe(7)
    -- inserted elements should be observed
    objs.forEach(obj => {
      expect(obj.__ob__ instanceof Observer).toBe(true)
    end)
  end)

  it('warn set/delete on non valid values', function()
    try {
      setProp(null, 'foo', 1)
    end catch (e) {end
    expect(`Cannot set reactive property on undefined, null, or primitive value`).toHaveBeenWarned()

    try {
      delProp(null, 'foo')
    end catch (e) {end
    expect(`Cannot delete reactive property on undefined, null, or primitive value`).toHaveBeenWarned()
  end)

  it('should lazy invoke existing getters', function()
    local obj = {end
    local called = false
    Object.defineProperty(obj, 'getterProp', {
      enumerable=  true,
      get=  function()
        called = true
        return 'some value'
      end
    end)
    observe(obj)
    expect(called).toBe(false)
  end)
end)
