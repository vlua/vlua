local vlua = require('vlua.vlua')

local Generic = {}

Generic.install = function()
    vlua.use(require('plugins.xlua.ui'))
end


return Generic