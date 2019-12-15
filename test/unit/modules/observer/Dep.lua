local lu = require('luaunit')

local Dep = require('observer.Dep')

describe('Dep', function()
    ---@type Dep
    local dep

    beforeEach(function()
        dep = Dep.new()
    end)

    describe('instance', function()
        it('should be created with correct properties', function()
            lu.assertEquals(#dep.subs, 0)
            lu.assertEquals(Dep.new().id, dep.id + 1)
        end)
    end)

    describe('addSub()', function()
        it('should add sub', function()
            local watcher = {}
            dep:addSub(watcher)
            lu.assertEquals(#dep.subs, 1)
            lu.assertEquals(dep.subs[1], watcher)
        end)
    end)

    describe('removeSub()', function()
        it('should remove sub', function()
            local watcher = {}
            table.insert(dep.subs, watcher)
            dep:removeSub(watcher)
            lu.assertEquals(#dep.subs, 0)
        end)
    end)

    describe('depend()', function()
        local _target

        beforeAll(function()
            _target = Dep.target
        end)

        afterAll(function()
            Dep.target = _target
        end)

        it('should do nothing if no target', function()
            Dep.target = nil
            dep:depend()
        end)

        it('should add itself to target', function()
            local spy = lu.createSpyObj('TARGET', {'addDep'})
            Dep.target = spy
            dep:depend()
            spy:toHaveBeenMembberCalledWith(Dep.target.addDep, dep)
        end)
        end)

        describe('notify()', function()
            it('should notify subs', function()
                local spy = lu.createSpyObj('SUB', {'update'})
                table.insert(dep.subs, spy)
                dep:notify()
                spy:toHaveBeenCalled(dep.subs[1].update)
        end)
    end)
end)
