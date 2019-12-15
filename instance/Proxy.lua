local config = require("config")
local Util = require("util.Util")
local warn, makeMap, isNative = Util.warn, Util.makeMap, Util.isNative
--[[ not type checking this file because flow doesn't play well with Proxy ]]
local initProxy

if (config.env ~= "production") then
    local allowedGlobals =
        makeMap(
        "Infinity,undefined,NaN,isFinite,isNaN," ..
            "parseFloat,parseInt,decodeURI,decodeURIComponent,encodeURI,encodeURIComponent," ..
                "Math,Number,Date,Array,Object,Boolean,String,RegExp,Map,Set,JSON,Intl," .. "require" -- for Webpack/Browserify
    )

    local warnNonPresent = function(target, key)
        warn(
            'Property or method "${key}" is not defined on the instance but ' ..
                "referenced during render. Make sure that this property is reactive, " ..
                    "either in the data option, or for class-based components, by " ..
                        "initializing the property. " ..
                            "See: https:--vuejs.org/v2/guide/reactivity.html#Declaring-Reactive-Properties.",
            target
        )
    end

    local warnReservedPrefix = function(target, key)
        warn(
            'Property "${key}" must be accessed with "$data._{key}" because ' ..
                'properties starting with "$" or "_" are not proxied in the Vue instance to ' ..
                    "prevent conflicts with Vue internals. " .. "See: https:--vuejs.org/v2/api/#data",
            target
        )
    end

    -- local hasProxy = Proxy and isNative(Proxy)

    -- if (hasProxy) then
    --     local isBuiltInModifier = makeMap('stop,prevent,self,ctrl,shift,alt,meta,exact')
    --     config.keyCodes = Proxy.new(config.keyCodes, {
    --         set = function(target, key, value)
    --         if (isBuiltInModifier(key)) then
    --             warn('Avoid overwriting built-in modifier in config.keyCodes: ._{key}')
    --             return false
    --         else
    --             target[key] = value
    --             return true
    --         end
    --     end
    --     })
    -- end

    -- local hasHandler = {
    --     has = function(target, key)
    --         local has = target[key] ~= nil
    --         local isAllowed = allowedGlobals(key) or
    --         (type(key) == 'string' and key.charAt(0) == '_' and target._data[key] == nil)
    --         if (not has and not isAllowed) then
    --             if (target._data[key] ~= nil) then
    --                 warnReservedPrefix(target, key)
    --             else
    --                 warnNonPresent(target, key)
    --             end
    --         end
    --         return has or not isAllowed
    --     end
    -- }

    -- local getHandler = {
    --     get = function(target, key)
    --         if (type(key) == 'string' and target[key] == nil) then
    --             if (target._data[key] ~= nil) then
    --                 warnReservedPrefix(target, key)
    --             else
    --                 warnNonPresent(target, key)
    --             end
    --         end
    --         return target[key]
    --     end
    -- }

    initProxy = function(vm)
        -- if (hasProxy) then
        --     -- determine which proxy handler to use
        --     local options = vm._options
        --     local handlers = (options.render and options.render._withStripped)
        --         and getHandler
        --         or hasHandler
        --     vm._renderProxy = Proxy.new(vm, handlers)
        -- else
        vm._renderProxy = vm
        -- end
    end
end

return {
    initProxy = initProxy
}
