local Util = require("util.util")
local vlua = require("vlua.vlua")

local Component = Util.class("Component")

function Component:setup(...)
    local args = {...}
    vlua.new(function()
        local binder = vlua.newBinder(self)
        self:onSetup(binder, table.unpack(args))
    end)
end

---@param binder Binder
function Component:onSetup(binder, ...)
end

return Component