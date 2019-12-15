
package.path = package.path .. ";luaexe/?.lua"
require("LuaPanda").start("127.0.0.1",8818);
local print = print
_G.print = function(n, ...)
   print(n, ...) 
end
local lu = require('luaunit')

local function noop()
end

local TestDescribe = {children = {}}

function TestDescribe.testRun()
    for i,v in pairs(TestDescribe.children) do
        v.run()
    end
end
_G.TestDescribe = TestDescribe

local stacks = {TestDescribe}
local indent = 0

local sortedPairs = lu.private.sortedPairs

function describe(name, fn)
    local testunit = {
        children = {},
        its = {},
        beforeEach = noop,
        afterEach = noop,
        beforeAll = noop,
        afterAll = noop,
        }

    testunit.run = function()
        testunit.beforeAll()
        for i,v in sortedPairs(testunit.its) do
            print(string.rep("    ", indent) .. "begin it ", i)
            indent = indent + 1
            testunit.beforeEach()
            v()
            testunit.afterEach()
            indent = indent - 1
            print(string.rep("    ", indent) .. "end it ", i)
        end

        for i,v in sortedPairs(testunit.children) do
            print(string.rep("    ", indent) .. "begin describe ", i)
            indent = indent + 1
            testunit.beforeEach()
            v.run()
            testunit.afterEach()
            indent = indent - 1
            print(string.rep("    ", indent) .. "end describe ", i)
        end
        testunit.afterAll()
    end
    local parent = stacks[#stacks]
    parent.children[name] = testunit
    table.insert(stacks, testunit)
    fn()
    table.remove(stacks)
end

function beforeEach(fn)
    local parent = stacks[#stacks]
    parent.beforeEach = fn
end

function afterEach(fn)
    local parent = stacks[#stacks]
    parent.afterEach = fn
end


function beforeAll(fn)
    local parent = stacks[#stacks]
    parent.beforeAll = fn
end

function afterAll(fn)
    local parent = stacks[#stacks]
    parent.afterAll = fn
end

function it(name, fn)
    local parent = stacks[#stacks]
    parent.its[name] = fn
end


function lu.createSpyObj(name, fields)
    local spy = {}
    spy.__calls = {}

    function spy:toHaveBeenCalledWith(fn, ...)
        local call = self.__calls[fn]
        lu.assertIsTrue(call ~= nil , "cannot found fn")
        lu.assertNotEquals(call.called, 0, "not called with name:" .. name)
        local args = {...}
        lu.assertEquals(#args , #call.args, "arg count not match with name:" .. name)
        for i, v in ipairs(args) do
            lu.assertEquals(v , call.args[i], "arg not match with name:" .. name .. " arg :" .. i)
        end
    end
    
    function spy:toHaveBeenMembberCalledWith(fn, ...)
        spy:toHaveBeenCalledWith(fn, spy, ...)
    end

    function spy:toHaveBeenCalled(fn)
        local call = self.__calls[fn]
        lu.assertIsTrue(call ~= nil , "cannot found fn")
        lu.assertNotEquals(call.called, 0, "not called with name:" .. name)
    end
    function spy:toHaventBeenCalled(fn)
        local call = self.__calls[fn]
        lu.assertIsTrue(call ~= nil , "cannot found fn")
        lu.assertEquals(call.called, 0, "but called with name:" .. name)
    end

    for i,name in ipairs(fields) do
        local call = {called = 0, args = nil}
        local fn = function(...)
            call.args = {...}
            call.called = call.called + 1
        end
        spy.__calls[fn] = call
        spy[name] = fn
    end
    return spy
end

function lu.createSpy(name)

end

require("test.unit.modules.observer.Dep")
require("test.unit.modules.observer.Watcher")

local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
runner.verbosity = lu.VERBOSITY_DEFAULT
os.exit( runner:runSuite() )
