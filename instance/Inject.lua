local config = require("config")
local Util = require("util.Util")
local Observer = require("observer.Observer")
local hasOwn, warn, hasSymbol, createObject = Util.hasOwn, Util.warn, Util.hasSymbol, Util.createObject
local defineReactive, toggleObserving = Observer.defineReactive, Observer.toggleObserving
local type = type
local pairs = pairs

local resolveInject

---@param vm Component
local function initProvide(vm)
    local provide = vm._options.provide
    if (provide) then
        vm._provided = type(provide) == "function" and provide(vm) or provide
    end
end

---@param vm Component
local function initInjections(vm)
    local result = resolveInject(vm._options.inject, vm)
    if (result) then
        toggleObserving(false)
        for key, value in pairs(result) do
            if (config.env ~= "production") then
                defineReactive(
                    vm,
                    key,
                    value,
                    function()
                        warn(
                            "Avoid mutating an injected value directly since the changes will be " +
                                "overwritten whenever the provided component re-renders. " +
                                'injection being mutated: "${key}"',
                            vm
                        )
                    end
                )
            else
                defineReactive(vm, key, value)
            end
        end
        toggleObserving(true)
    end
end

---@param inject any
---@param vm Component
---@return Object
resolveInject = function(inject, vm)
    if (inject) then
        -- inject is :any because flow is not smart enough to figure out cached
        local result = {}
        for key in inject do
            -- #6574 in case the inject object is observed...
            if (key ~= "__ob__") then
                local provideKey = inject[key].from
                local source = vm
                while (source) do
                    if (source._provided and hasOwn(source._provided, provideKey)) then
                        result[key] = source._provided[provideKey]
                        break
                    end
                    source = source._parent
                end
                if (not source) then
                    if (inject[key]["default"]) then
                        local provideDefault = inject[key].default
                        result[key] = type(provideDefault) == "function" and provideDefault(vm) or provideDefault
                    elseif (config.env ~= "production") then
                        warn('Injection "${key}" not found', vm)
                    end
                end
            end
        end
        return result
    end
end
return {
    initProvide = initProvide,
    initInjections = initInjections
}
