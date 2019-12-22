local vlua = require('vlua.vlua')
local ui = require('plugins.xlua.ui')

local Generic = {}

Generic.install = function()
    vlua.use(ui)
end


return Generic