local vlua = require('vlua')
local Watcher = require('observer.Watcher')
local CallContext = require('observer.CallContext')
local HookIds = CallContext.HookIds
local tinsert = table.insert

local Generic = {}

Generic.install = function()
    vlua.use(require('xlua_ui'))
end


return Generic