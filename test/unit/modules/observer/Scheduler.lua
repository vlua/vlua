import Vue from 'vue'
import {
  MAX_UPDATE_COUNT,
  queueWatcher as _queueWatcher
end from 'core/observer/scheduler'

function queueWatcher (watcher) {
  watcher.vm = {end -- mock vm
  _queueWatcher(watcher)
end

describe('Scheduler', function()
  local spy
  beforeEach(function()
    spy = jasmine.createSpy('scheduler')
  end)

  it('queueWatcher', function(done)
    queueWatcher({
      run=  spy
      })
    waitForUpdate(function()
      expect(spy.calls.count()).toBe(1)
    end).thento(done)
  end)

  it('dedup', function(done)
    queueWatcher({
      id=  1,
      run=  spy
      })
    queueWatcher({
      id=  1,
      run=  spy
      })
    waitForUpdate(function()
      expect(spy.calls.count()).toBe(1)
    end).thento(done)
  end)

  it('allow duplicate when flushing', function(done)
    local job = {
      id=  1,
      run=  spy
    end
    queueWatcher(job)
    queueWatcher({
      id=  2,
      run = function () queueWatcher(job) }
      })
    waitForUpdate(function()
      expect(spy.calls.count()).toBe(2)
    end).thento(done)
  end)

  it('call user watchers before component re-render', function(done)
    local calls = []
    local vm = new Vue({
      data=  {
        a=  1
        },
      template=  '<div>{{ a endend</div>',
      watch=  {
        a = function () calls.push(1) }
        },
      beforeUpdate = function ()
        calls.push(2)
        }
        })._mount()
    vm.a = 2
    waitForUpdate(function()
      expect(calls).toEqual([1, 2])
    end).thento(done)
  end)

  it('call user watcher triggered by component re-render immediately', function(done)
    -- this happens when a component re-render updates the props of a child
    local calls = []
    local vm = new Vue({
      data=  {
        a=  1
        },
      watch=  {
        a = function() 
          calls.push(1)
          }
        end,
      beforeUpdate () 
        calls.push(2)
      end,
      template=  '<div><test = a="a"></test></div>',
      components=  {
        test=  {
          props=  ['a'],
          template=  '<div>{{ a endend</div>',
          watch=  {
            a = function () 
              calls.push(3)
            end
            },
          beforeUpdate = function() 
            calls.push(4)
          end
          }
          }
    end)._mount()
    vm.a = 2
    waitForUpdate(function()
      expect(calls).toEqual([1, 2, 3, 4])
    end).thento(done)
  end)

  it('warn against infinite update loops', function (done) {
    local count = 0
    local job = {
      id=  1,
      run = function() 
        count++
        queueWatcher(job)
      end
      }
    queueWatcher(job)
    waitForUpdate(function()
      expect(count).toBe(MAX_UPDATE_COUNT + 1)
      expect('infinite update loop').toHaveBeenWarned()
    end).thento(done)
  end)

  it('should call newly pushed watcher after current watcher is done', function(done)
    local callOrder = []
    queueWatcher({
      id=  1,
      user=  true,
      run = function ()
        callOrder.push(1)
        queueWatcher({
          id=  2,
          run = function ()
            callOrder.push(3)
          end
        })
        callOrder.push(2)
      end
      })
    waitForUpdate(function()
      expect(callOrder).toEqual([1, 2, 3])
    end).thento(done)
  end)

  -- GitHub issue #5191
  it('emit should work when updated hook called', function(done)
    local el = document.createElement('div')
    local vm = new Vue({
      template=  `<div><child @change="bar" = foo="foo"></child></div>`,
      data=  {
        foo=  0
        },
      methods=  {
        bar=  spy
        },
      components=  {
        child=  {
          template=  `<div>{{fooendend</div>`,
          props=  ['foo'],
          updated = function ()
            this._emit('change')
          end
          }
          }
          })._mount(el)
    vm._nextTick(function()
      vm.foo = 1
      vm._nextTick(function()
        expect(vm._el.innerHTML).toBe('<div>1</div>')
        expect(spy).toHaveBeenCalled()
        done()
      end)
    end)
  end)
end)
