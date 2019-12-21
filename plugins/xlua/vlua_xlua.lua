local vlua = require('vlua')
local Watcher = require('observer.Watcher')
local CallContext = require('observer.CallContext')
local HookIds = CallContext.HookIds
local tinsert = table.insert

local Generic = {}

Generic.install = function()
    --- call cb when expr changed
    ---@param expOrFn string | Function
    ---@param cb Function
    ---@param options WatcherOptions
    function vlua.watch(expOrFn, cb, options)
        -- watch and run one time
        return Watcher.new(CallContext.target, expOrFn, cb, options)
    end

end


return Generic