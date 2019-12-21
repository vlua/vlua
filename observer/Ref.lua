local Computed = require("observer.Computed").Computed

---@param value any
local function ref(value)
    local function getter(self)
        return value
    end

    local function setter(self, newValue)
        value = newValue
    end

    return Computed(getter, setter)
end

return {
    ref = ref
}
