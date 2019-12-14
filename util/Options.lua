local config = require('config')
local Util = require('util.Util')
local set = require('observer.Observer').set
local unicodeRegExp = require('util.Lang').unicodeRegExp
local type = type
local Env = require('util.Env')
local nativeWatch, hasSymbol = Env.nativeWatch, Env.hasSymbol
local tinsert = table.insert

local Constants = require('util.Constants')
local
  ASSET_TYPES,
  LIFECYCLE_HOOKS
= Constants.ASSET_TYPES , Constants.LIFECYCLE_HOOKS

local Util = require('util.Util')
local
warn,
  extend,
  hasOwn,
  camelize,
  toRawType,
  capitalize,
  isBuiltInTag,
  isPlainObject,
  isArray,
  createObject,
  concat,
  indexOf
= Util.warn,
Util.extend,
Util.hasOwn,
Util.camelize,
Util.toRawType,
Util.capitalize,
Util.isBuiltInTag,
Util.isPlainObject,
Util.isArray,
Util.createObject,
Util.concat,
Util.indexOf

local dedupeHooks
local defaultStrat
local assertObjectType
local validateComponentName

--[[*
 * Option overwriting strategies are functions that handle
 * how to merge a parent option value and a child option
 * value into the final value.
 ]]
local strats = config.optionMergeStrategies

--[[*
 * Options with restrictions
 ]]
if (config.env ~= 'production') then
    strats.el = function (parent, child, vm, key)
        if (not vm) then
            warn(
            'option "$thenkeyend" can only be used during instance ' +
            "creation with the 'new' keyword."
            )
        end
        return defaultStrat(parent, child)
    end
    strats.propsData = strats.el
end

--[[*
 * Helper that recursively merges two data objects together.
 ]]
 ---@param to table
 ---@param from table
 ---@return table
local function mergeData (to, from)
    if (not from) then return to end
    local toVal

    for key, fromVal in pairs(from) do
        -- in case the object is already observed...
        if (key ~= '__ob__') then
            toVal = to[key]
            if (not hasOwn(to, key)) then
                set(to, key, fromVal)
            elseif (
                toVal ~= fromVal and
                isPlainObject(toVal) and
                isPlainObject(fromVal)
            ) then
                mergeData(toVal, fromVal)
            end
        end
    end
    return to
end

--[[*
 * Data
 ]]
---@param parentVal any
---@param childVal any
---@param vm Component
---@return Function
local function mergeDataOrFn (
  parentVal,
  childVal,
  vm
)
    if (not vm) then
        -- in a Vue.extend merge, both should be functions
        if (not childVal) then
            return parentVal
        end
        if (not parentVal) then
            return childVal
        end
        -- when parentVal & childVal are both present,
        -- we need to return a function that returns the
        -- merged result of both functions... no need to
        -- check if parentVal is a function here because
        -- it has to be a function to pass previous merges.
        return function (self)
            return mergeData(
            type(childVal == 'function') and childVal(self) or childVal,
            type(parentVal == 'function') and parentVal(self) or parentVal
            )
        end
    else
        return function ()
            -- instance merge
            local instanceData = type(childVal) == 'function'
                and childVal(vm)
                or childVal
            local defaultData = type(parentVal) == 'function'
                and parentVal(vm)
                or parentVal
            if (instanceData) then
                return mergeData(instanceData, defaultData)
            else
                return defaultData
            end
        end
    end
end

---@param parentVal any
---@param childVal any
---@param vm Component
---@return Function
strats.data = function (
  parentVal,
  childVal,
  vm
)
    if (not vm) then
        if (childVal and type(childVal) ~= 'function') then
            if config.env ~= 'production' then
                warn(
                    'The "data" option should be a function ' +
                    'that returns a per-instance value in component ' +
                    'definitions.',
                    vm
                )
            end

            return parentVal
        end
        return mergeDataOrFn(parentVal, childVal)
    end

    return mergeDataOrFn(parentVal, childVal, vm)
end

--[[*
 * Hooks and props are merged as arrays.
 ]]
---@param parentVal Function[]
---@param childVal Function | Function[]
---@return Function[]
local function mergeHook (
    parentVal,
    childVal
)
    local res = (childVal
        and (parentVal
            and concat(parentVal, childVal)
            or (type(childVal) == "table"
            and childVal
            or {childVal}))
        or parentVal)
    return res
        and dedupeHooks(res)
        or res
end

dedupeHooks = function (hooks)
    local res = {}
    for i = 1, #hooks do
        if (indexOf(res, hooks[i]) == 0) then
            tinsert(res, hooks[i])
        end
    end
    return res
end

for _, hook in pairs(LIFECYCLE_HOOKS) do
    strats[hook] = mergeHook
end

--[[*
 * Assets
 *
 * When a vm is present (instance creation), we need to do
 * a three-way merge between constructor options, instance
 * options and parent options.
 ]]
 ---@param parentVal Object
 ---@param childVal Object
 ---@param vm Component
 ---@param key string
 local function mergeAssets (
    parentVal,
    childVal,
    vm,
    key
)
    local res = createObject(parentVal or nil)
    if (childVal) then
        if config.env ~= 'production' then
            assertObjectType(key, childVal, vm)
        end
        return extend(res, childVal)
    else
        return res
    end
end

for _, type in pairs(ASSET_TYPES) do
    strats[type .. 's'] = mergeAssets
end

--[[*
 * Watchers.
 *
 * Watchers hashes should not overwrite one
 * another, so we merge them as arrays.
 ]]
 ---@param parentVal Object
 ---@param childVal Object
 ---@param vm Component
 ---@param key string
 strats.watch = function (
    parentVal,
    childVal,
    vm,
    key
)
    -- work around Firefox's Object.prototype.watch...
    if (parentVal == nativeWatch) then parentVal = nil end
    if (childVal == nativeWatch) then childVal = nil end
    --[[ istanbul ignore if ]]
    if (not childVal) then return createObject(parentVal or nil) end
    if (config.env ~= 'production') then
        assertObjectType(key, childVal, vm)
    end
    if (not parentVal) then return childVal end
    local ret = {}
    extend(ret, parentVal)
    for key, child in pairs(childVal) do
        local parent = ret[key]
        if (parent and not isArray(parent)) then
        parent = {parent}
        end
        ret[key] = parent
            and parent.concat(child)
            or (isArray(child) and child or {child})
    end
    return ret
end

--[[*
 * Other object hashes.
 ]]
 ---@param parentVal Object
 ---@param childVal Object
 ---@param vm Component
 ---@param key string
strats.computed = function (
    parentVal,
    childVal,
    vm,
    key
)
    if (childVal and config.env ~= 'production') then
        assertObjectType(key, childVal, vm)
    end
    if (not parentVal) then return childVal end
    local ret = createObject(nil) 
    extend(ret, parentVal)
    if (childVal)then  extend(ret, childVal) end
    return ret
end

strats.props = strats.computed
strats.methods = strats.computed
strats.inject = strats.computed
strats.provide = mergeDataOrFn

--[[*
 * Default strategy.
 ]]
defaultStrat = function (parentVal, childVal)
    return childVal == nil
        and parentVal
        or childVal
end

--[[*
 * Validate component names
 ]]
 local function checkComponents (options)
    for key in pairs(options.components) do
        validateComponentName(key)
    end
end

---@param name string
validateComponentName = function (name)
    if (not RegExp('^[a-zA-Z][\\-\\.0-9_${unicodeRegExp.sourceend]*$').test(name)) then
        warn(
            'Invalid component name: "' + name + '". Component names ' +
            'should conform to valid custom element name in html5 specification.'
        )
    end
    if (isBuiltInTag(name) or config.isReservedTag(name)) then
        warn(
            'Do not use built-in or reserved HTML elements as component ' +
            'id: ' + name
        )
    end
end

--[[*
 * Ensure all props option syntax are normalized into the
 * Object-based format.
 ]]
 ---@param vm Component
local function normalizeProps (options, vm)
    local props = options.props
    if (not props) then return end
    local res = {}
    local val, name
    if (isArray(props)) then
        for i = #props, 1 , -1 do
            val = props[i]
            if (type(val) == 'string') then
            name = camelize(val)
            res[name] = { type= nil }
            elseif (config.env ~= 'production') then
            warn('props must be strings when using array syntax.')
            end
        end
    elseif (isPlainObject(props)) then
        for key, val in pairs(props) do
            name = camelize(key)
            res[name] = isPlainObject(val)
            and val
            or { type = val }
        end
    elseif (config.env ~= 'production') then
        warn(
            'Invalid value for option "props": expected an Array or an Object, ' +
            'but got ${toRawType(props)end.',
            vm
        )
    end
    options.props = res
end

--[[*
 * Normalize all injections into Object-based format
 ]]
 ---@param vm Component
local function normalizeInject (options, vm) 
    local inject = options.inject
    if (not inject) then return end
    local normalized = {}
    options.inject = normalized
    if (isArray(inject))  then
        for i = 1, #inject do
            normalized[inject[i]] = { from = inject[i] }
        end
    elseif (isPlainObject(inject)) then
        for key, val in pairs(inject) do
            normalized[key] = isPlainObject(val)
            and extend({ from = key }, val)
            or { from = val }
        end
    elseif (config.env ~= 'production')  then
        warn(
            'Invalid value for option "inject": expected an Array or an Object, ' +
            'but got ${toRawType(inject)end.',
            vm
        )
    end
end

--[[*
 * Normalize raw function directives into object format.
 ]]
local function normalizeDirectives (options) 
    local dirs = options.directives
    if (dirs) then
        for key, def in pairs(dirs) do
            if (type(def) == 'function') then
            dirs[key] = { bind = def, update = def }
            end
        end
    end
end
---@param name string
---@param vm Component
assertObjectType = function  (name, value, vm) 
    if (not isPlainObject(value)) then
        warn(
            'Invalid value for option "${nameend": expected an Object, ' +
            'but got ${toRawType(value)end.',
            vm
        )
    end
end

--[[*
 * Merge two option objects into a new one.
 * Core utility used in both instantiation and inheritance.
 ]]
 ---@param vm Component
local function mergeOptions (
    parent,
    child,
    vm
)
    -- if (config.env ~= 'production') then
    --     checkComponents(child)
    -- end

    if (type(child) == 'function') then
        child = child.options
    end

    normalizeProps(child, vm)
    normalizeInject(child, vm)
    normalizeDirectives(child)

    -- Apply extends and mixins on the child options,
    -- but only if it is a raw options object that isn't
    -- the result of another mergeOptions call.
    -- Only merged options has the _base property.
    if (not child._base) then
        if (child.extends) then
            parent = mergeOptions(parent, child.extends, vm)
        end
        if (child.mixins) then
            for i = 1, #child.mixins.length do
            parent = mergeOptions(parent, child.mixins[i], vm)
            end
        end
    end

    local options = {}

    local function mergeField (key) 
        local strat = strats[key] or defaultStrat
        options[key] = strat(parent[key], child[key], vm, key)
    end

    for key in pairs(parent) do
        mergeField(key)
    end
    for key in pairs(child) do
        if (not hasOwn(parent, key)) then
            mergeField(key)
        end
    end
    return options
end

--[[*
 * Resolve an asset.
 * This function is used because child instances need access
 * to assets defined in its ancestor chain.
 ]]
 ---@param options Object
 ---@param type string
 ---@param id string
---@param warnMissing boolean
local function resolveAsset (
    options,
    type,
    id,
    warnMissing
)
    if (type(id) ~= 'string') then
        return
    end
    local assets = options[type]
    -- check local registration variations first
    if (hasOwn(assets, id)) then return assets[id] end
    local camelizedId = camelize(id)
    if (hasOwn(assets, camelizedId)) then return assets[camelizedId] end
    local PascalCaseId = capitalize(camelizedId)
    if (hasOwn(assets, PascalCaseId)) then return assets[PascalCaseId] end
    -- fallback to prototype chain
    local res = assets[id] or assets[camelizedId] or assets[PascalCaseId]
    if (config.env ~= 'production' and warnMissing and not res) then
        warn(
        'Failed to resolve ' + type.slice(0, -1) + ': ' + id,
        options
        )
    end
    return res
end

return {
    mergeData = mergeData,
    mergeHook = mergeHook,
    mergeAssets = mergeAssets,
    mergeOptions = mergeOptions,
    resolveAsset = resolveAsset,
    checkComponents = checkComponents,
    normalizeProps = normalizeProps,
    normalizeInject = normalizeInject,
    normalizeDirectives = normalizeDirectives,
    dedupeHooks = dedupeHooks,
    defaultStrat = defaultStrat,
    assertObjectType = assertObjectType,
    validateComponentName = validateComponentName,
}