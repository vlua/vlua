print("a")
package.path = package.path .. ";luaexe/?.lua"
require("LuaPanda").start("127.0.0.1", 8818)

local reactive = require("reactivity.reactive")
local watch = require("reactivity.apiWatch").watch
local Effect = require("reactivity.effect")
local effect = Effect.effect
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")

local data = {
    name = "abc",
    actor = {
        aname = "aname123",
        aid = 444
    },
    id = 123,
    _watchers = {}
}

local obData = reactive.reactive(data)

obData.actor.aname = "a1"
obData.actor.aname = "a2"

effect(function(effect, target, type, key, newValue, oldValue)
   print("onEffect", effect, target, type, key, newValue, oldValue)
   Effect.track(obData.actor, TrackOpTypes.ITERATE, Effect.ITERATE_KEY)
end)

obData.actor.b = 123
obData.actor.c = 1
obData.actor.d = 2
obData.actor.e = "123"
obData.actor.d = nil
obData.actor.c = 3
obData.actor.c = 123
obData.actor.c = nil
obData.actor = nil
obData.actor = {
    aname = "aname123",
    aid = 444
}

obData.actor.b = 123
obData.actor.c = 1
obData.actor.d = 2
obData.actor.e = "123"
obData.actor.d = nil
obData.actor.c = 3
obData.actor.c = 123
obData.actor.c = nil

local w =
watch(
function()return obData.actor.aname end,
    function(vm, value, old)
        print(string.format("onValueChanged : %s -> %s", old, value))
    end,
    {flush = "sync"}
)

local ff =
watch(
function()return obData.actor.ff end,
    function(vm, value, old)
        print(string.format("onValueChanged : %s -> %s", old, value))
    end,
    {flush = "sync"}
)

local dd =
watch(
function()
    local new = {}
    for i,v in pairs(obData.actor) do
        new[i] = v
     end
     return new
 end,
    function(vm, value, old)
        print(string.format("onValueChanged : %s -> %s", old, value))
    end,
    {flush = "sync"}
)

obData.actor.aname = "a3"

obData.actor.aname = nil
obData.actor.aname = "a4"
obData.actor.ff = "fff"

obData.actor = {aname = "ffe"}

-- local newActor1 = {aname = "new1", aid = 666}
-- Observer.observe(newActor1)
-- local w =
--     Watcher.new(
--     data,
--     function(vm)
--         return newActor1.aname
--     end,
--     function(vm, value, old)
--         print(string.format("onValueChanged1 : %s -> %s", old, value))
--     end,
--     {sync = true}
-- )

-- local newActor2 = {aname = "new2", aid = 666}
-- Observer.observe(newActor2)
-- local w =
--     Watcher.new(
--     data,
--     function(vm)
--         return newActor2.aname
--     end,
--     function(vm, value, old)
--         print(string.format("onValueChanged1 : %s -> %s", old, value))
--     end,
--     {sync = true}
-- )

-- local newActor3 = {aname = "new3", aid = 666}
-- Observer.observe(newActor3)
-- local w =
--     Watcher.new(
--     data,
--     function(vm)
--         return newActor3.aname
--     end,
--     function(vm, value, old)
--         print(string.format("onValueChanged3 : %s -> %s", old, value))
--     end,
--     {sync = true}
-- )

-- data.actor.aname = "abc"
-- data.actor.aname = "def"

-- data.actor.aid = 123
-- data.actor.aid = 444

-- data.actor.aid = 777
-- data.actor = newActor1
-- data.actor = newActor2
-- data.actor = newActor3

-- newActor1.aname = "fuck1"
-- newActor2.aname = "fuck2"
-- newActor3.aname = "fuck3"

-- data.actor.aid = 999
-- print(ob)

-- local Vue = require("instance.Vue")

-- ---@class MyVueComponent : Component
-- local instance =
--     Vue.new(
--     {
--         el = {},
--         ---@type MyVueComponent
--         data = {
--             mydata = data
--         },
--         computed = {
--             name = {
--                 get = function(vm)
--                     print("call computed name")
--                     return vm.mydata.name
--                 end,
--                 set = function(vm, value)
--                     vm.mydata.name = value
--                 end
--             },
--             name1 = function(vm)
--                 return vm.name .. "_1"
--             end
--         },
--         w = {
--             name = function(vm, value, old)
--                 print("namechanged;", value, old)
--             end
--         },
--         methods = {
--             ---@param vm Component
--             add = function(vm, a, b, c)
--                 print("called add", a, b, c)
--                 vm:_on(
--                     "evtTest",
--                     function(p1, p2)
--                         print("on evtTest ", p1, p2)
--                     end
--                 )
--                 vm.name = "aaa"
--                 vm.mydata.name = "bbb"
--                 vm:_once(
--                     "evtTest",
--                     function(p1, p2)
--                         print("once evtTest ", p1, p2)
--                     end
--                 )
--             end
--         },
--         ---@param vm MyVueComponent
--         created = function(vm)
--             print(vm.name)
--             print(vm.name1)
--             print(vm.name1)
--             print(vm.name)
--             vm:add(1, 2, 3)
--             vm:_emit("evtTest", "a1", "b", "c")
--             vm:_emit("evtTest", "a2", "b", "c")
--             vm:_emit("evtTest", "a3", "b", "c")
--         end,
--         beforeCreate = function(vm)
--         end
--     }
-- )

-- print(instance)
