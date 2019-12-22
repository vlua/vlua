local Lang = require("util.Lang")
local vlua = require("vlua")

local Component = Lang.class("Component")

function Component:setup(...)
    local args = {...}
    vlua.new(function()
        local binder = vlua.createBinder(self)
        self:onSetup(binder, table.unpack(args))
    end)
end

---@param binder Binder
function Component:onSetup(binder, ...)
end

return Component