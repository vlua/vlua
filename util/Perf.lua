local config = require("config")
local mark
local measure

if (config.env ~= "production") then
    mark = function(tag)
    end
    measure = function(name, startTag, endTag)
    end
end

return {
    mark = mark,
    measure = measure
}
