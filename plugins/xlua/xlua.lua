local vlua = require('vlua')
local Watcher = require('vlua.watcher')
local CallContext = require('vlua.callContext')
local HookIds = CallContext.HookIds
local tinsert = table.insert

local Generic = {}

Generic.install = function()
    vlua.use(require('plugins.xlua.ui'))
end


return Generic