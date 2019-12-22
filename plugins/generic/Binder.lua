local Lang = require("util.Lang")
local Watcher = require("observer.Watcher")
local pairs = pairs

---@class Binder
---@field watchers Watcher[]
local Binder = Lang.class("Binder")
function Binder:constructor(source, parent)
    self.source = source
    self.parent = parent
end

function Binder:teardown()
    if self.watchers then
        for i,v in pairs(self.watchers) do
            v:teardown()
        end
        self.watchers = nil
    end
end

function Binder:createChild(source)
    local child = Binder.new(source, self)
    self.watchers[child] = child
    return child
end

function Binder:autoTeardown(teardownFn)
    local child = {
        teardown = teardownFn
    }
    self.watchers[child] = child
end

--- call cb when expr changed
---@param expOrFn string | Function
---@param cb Function
---@param immediacy boolean @call cb when start
function Binder:watch(expOrFn, cb, immediacy)
    -- watch and run one time
    local watcher = Watcher.new(self.source, expOrFn, cb)
    self.watchers[watcher] = watcher
    if immediacy then
        cb(self.source, watcher.value, watcher.value)
    end
end
return Binder