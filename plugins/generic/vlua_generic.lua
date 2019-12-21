local vlua = require('vlua')
local Watcher = require('observer.Watcher')
local CallContext = require('observer.CallContext')
local tinsert = table.insert

local Generic = {}

Generic.install = function()
    --- call cb when expr changed
    ---@param expOrFn string | Function
    ---@param cb Function
    ---@param options WatcherOptions
    function CallContext:watch(expOrFn, cb, options)
        -- watch and run one time
        return Watcher.new(self, expOrFn, cb, options)
    end

    --- call when CallContext teardown
    function CallContext:onMount(callback)
        tinsert(self._watchers, {teardown = callback})
    end
    --- call when CallContext teardown
    function CallContext:onUnmount(callback)
        tinsert(self._watchers, {teardown = callback})
    end

end


return Generic