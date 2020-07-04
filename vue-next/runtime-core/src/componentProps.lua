require("@vue/reactivity")
require("@vue/reactivity/TriggerOpTypes")
require("@vue/shared")
require("@vue/shared/PatchFlags")
require("runtime-core/src/warning")
require("runtime-core/src/componentEmits")
require("runtime-core/src/vnode")
local BooleanFlags = {
  shouldCast = 0,
  shouldCastTrue = 1
}

function initProps(instance, rawProps, isStateful, isSSR)
  if isSSR == nil then
    isSSR=false
  end
  local props = {}
  local attrs = {}
  def(attrs, InternalObjectKey, 1)
  setFullProps(instance, rawProps, props, attrs)
  if __DEV__ then
    validateProps(props, instance.type)
  end
  if isStateful then
    -- [ts2lua]lua中0和空字符串也是true，此处isSSR需要确认
    instance.props = (isSSR and {props} or {shallowReactive(props)})[1]
  else
    if not instance.type.props then
      instance.props = attrs
    else
      instance.props = props
    end
  end
  instance.attrs = attrs
end

function updateProps(instance, rawProps, rawPrevProps, optimized)
  local  = instance
  local rawCurrentProps = toRaw(props)
  local  = normalizePropsOptions(instance.type)
  if (optimized or patchFlag > 0) and not (patchFlag & PatchFlags.FULL_PROPS) then
    if patchFlag & PatchFlags.PROPS then
      local propsToUpdate = nil
      local i = 0
      repeat
        local key = propsToUpdate[i+1]
        -- [ts2lua]()下标访问可能不正确
        local value = ()[key]
        if options then
          if hasOwn(attrs, key) then
            -- [ts2lua]attrs下标访问可能不正确
            attrs[key] = value
          else
            local camelizedKey = camelize(key)
            -- [ts2lua]props下标访问可能不正确
            props[camelizedKey] = resolvePropValue(options, rawCurrentProps, camelizedKey, value)
          end
        else
          -- [ts2lua]attrs下标访问可能不正确
          attrs[key] = value
        end
        i=i+1
      until not(i < #propsToUpdate)
    end
  else
    setFullProps(instance, rawProps, props, attrs)
    local kebabKey = nil
    for key in pairs(rawCurrentProps) do
      if not rawProps or not hasOwn(rawProps, key) and (kebabKey = hyphenate(key) == key or not hasOwn(rawProps, kebabKey)) then
        if options then
          -- [ts2lua]rawPrevProps下标访问可能不正确
          -- [ts2lua]rawPrevProps下标访问可能不正确
          if rawPrevProps and (rawPrevProps[key] ~= undefined or rawPrevProps[] ~= undefined) then
            -- [ts2lua]props下标访问可能不正确
            props[key] = resolvePropValue(options, rawProps or EMPTY_OBJ, key, undefined)
          end
        else
          -- [ts2lua]props下标访问可能不正确
          props[key] = nil
        end
      end
    end
    if attrs ~= rawCurrentProps then
      for key in pairs(attrs) do
        if not rawProps or not hasOwn(rawProps, key) then
          -- [ts2lua]attrs下标访问可能不正确
          attrs[key] = nil
        end
      end
    end
  end
  trigger(instance, TriggerOpTypes.SET, '$attrs')
  if __DEV__ and rawProps then
    validateProps(props, instance.type)
  end
end

function setFullProps(instance, rawProps, props, attrs)
  local  = normalizePropsOptions(instance.type)
  local emits = instance.type.emits
  if rawProps then
    for key in pairs(rawProps) do
      -- [ts2lua]rawProps下标访问可能不正确
      local value = rawProps[key]
      if isReservedProp(key) then
        break
      end
      local camelKey = nil
      if options and hasOwn(options, camelKey) then
        -- [ts2lua]props下标访问可能不正确
        props[camelKey] = value
      elseif not emits or not isEmitListener(emits, key) then
        -- [ts2lua]attrs下标访问可能不正确
        attrs[key] = value
      end
    end
  end
  if needCastKeys then
    local rawCurrentProps = toRaw(props)
    local i = 0
    repeat
      local key = needCastKeys[i+1]
      -- [ts2lua]props下标访问可能不正确
      -- [ts2lua]rawCurrentProps下标访问可能不正确
      props[key] = resolvePropValue(rawCurrentProps, key, rawCurrentProps[key])
      i=i+1
    until not(i < #needCastKeys)
  end
end

function resolvePropValue(options, props, key, value)
  -- [ts2lua]options下标访问可能不正确
  local opt = options[key]
  if opt ~= nil then
    local hasDefault = hasOwn(opt, 'default')
    if hasDefault and value == undefined then
      local defaultValue = opt.default
      -- [ts2lua]lua中0和空字符串也是true，此处opt.type ~= Function and isFunction(defaultValue)需要确认
      value = (opt.type ~= Function and isFunction(defaultValue) and {defaultValue()} or {defaultValue})[1]
    end
    -- [ts2lua]opt下标访问可能不正确
    if opt[BooleanFlags.shouldCast] then
      if not hasOwn(props, key) and not hasDefault then
        value = false
      -- [ts2lua]opt下标访问可能不正确
      elseif opt[BooleanFlags.shouldCastTrue] and (value == '' or value == hyphenate(key)) then
        value = true
      end
    end
  end
  return value
end

function normalizePropsOptions(comp)
  if comp.__props then
    return comp.__props
  end
  local raw = comp.props
  local normalized = {}
  local needCastKeys = {}
  local hasExtends = false
  if __FEATURE_OPTIONS__ and not isFunction(comp) then
    local extendProps = function(raw)
      local  = normalizePropsOptions(raw)
      extend(normalized, props)
      if keys then
        table.insert(needCastKeys, ...)
      end
    end
    
    if comp.extends then
      hasExtends = true
      extendProps(comp.extends)
    end
    if comp.mixins then
      hasExtends = true
      comp.mixins:forEach(extendProps)
    end
  end
  if not raw and not hasExtends then
    return comp.__props = EMPTY_ARR
  end
  if isArray(raw) then
    local i = 0
    repeat
      if __DEV__ and not isString(raw[i+1]) then
        warn(raw[i+1])
      end
      local normalizedKey = camelize(raw[i+1])
      if validatePropName(normalizedKey) then
        -- [ts2lua]normalized下标访问可能不正确
        normalized[normalizedKey] = EMPTY_OBJ
      end
      i=i+1
    until not(i < #raw)
  elseif raw then
    if __DEV__ and not isObject(raw) then
      warn(raw)
    end
    for key in pairs(raw) do
      local normalizedKey = camelize(key)
      if validatePropName(normalizedKey) then
        -- [ts2lua]raw下标访问可能不正确
        local opt = raw[key]
        -- [ts2lua]normalized下标访问可能不正确
        -- [ts2lua]lua中0和空字符串也是true，此处isArray(opt) or isFunction(opt)需要确认
        normalized[normalizedKey] = (isArray(opt) or isFunction(opt) and {{type=opt}} or {opt})[1]
        -- [ts2lua]normalized下标访问可能不正确
        local prop = normalized[normalizedKey]
        if prop then
          local booleanIndex = getTypeIndex(Boolean, prop.type)
          local stringIndex = getTypeIndex(String, prop.type)
          -- [ts2lua]prop下标访问可能不正确
          prop[BooleanFlags.shouldCast] = booleanIndex > -1
          -- [ts2lua]prop下标访问可能不正确
          prop[BooleanFlags.shouldCastTrue] = stringIndex < 0 or booleanIndex < stringIndex
          if booleanIndex > -1 or hasOwn(prop, 'default') then
            table.insert(needCastKeys, normalizedKey)
          end
        end
      end
    end
  end
  local normalizedEntry = {normalized, needCastKeys}
  comp.__props = normalizedEntry
  return normalizedEntry
end

function getType(ctor)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local match = ctor and ctor:toString():match(/^\s*function (\w+)/)
  -- [ts2lua]lua中0和空字符串也是true，此处match需要确认
  return (match and {match[1+1]} or {''})[1]
end

function isSameType(a, b)
  return getType(a) == getType(b)
end

function getTypeIndex(type, expectedTypes)
  if isArray(expectedTypes) then
    local i = 0
    local len = #expectedTypes
    repeat
      if isSameType(expectedTypes[i+1], type) then
        return i
      end
      i=i+1
    until not(i < len)
  elseif isFunction(expectedTypes) then
    -- [ts2lua]lua中0和空字符串也是true，此处isSameType(expectedTypes, type)需要确认
    return (isSameType(expectedTypes, type) and {0} or {-1})[1]
  end
  return -1
end

function validateProps(props, comp)
  local rawValues = toRaw(props)
  local options = normalizePropsOptions(comp)[0+1]
  for key in pairs(options) do
    -- [ts2lua]options下标访问可能不正确
    local opt = options[key]
    if opt == nil then
      break
    end
    -- [ts2lua]rawValues下标访问可能不正确
    validateProp(key, rawValues[key], opt, not hasOwn(rawValues, key))
  end
end

function validatePropName(key)
  if key[0+1] ~= '$' then
    return true
  elseif __DEV__ then
    warn()
  end
  return false
end

function validateProp(name, value, prop, isAbsent)
  local  = prop
  if required and isAbsent then
    warn('Missing required prop: "' .. name .. '"')
    return
  end
  if value == nil and not prop.required then
    return
  end
  if type ~= nil and type ~= true then
    local isValid = false
    -- [ts2lua]lua中0和空字符串也是true，此处isArray(type)需要确认
    local types = (isArray(type) and {type} or {{type}})[1]
    local expectedTypes = {}
    local i = 0
    repeat
      local  = assertType(value, types[i+1])
      table.insert(expectedTypes, expectedType or '')
      isValid = valid
      i=i+1
    until not(i < #types and not isValid)
    if not isValid then
      warn(getInvalidTypeMessage(name, value, expectedTypes))
      return
    end
  end
  if validator and not validator(value) then
    warn('Invalid prop: custom validator check failed for prop "' .. name .. '".')
  end
end

local isSimpleType = makeMap('String,Number,Boolean,Function,Symbol')
function assertType(value, type)
  local valid = nil
  local expectedType = getType(type)
  if isSimpleType(expectedType) then
    local t = type(value)
    valid = t == expectedType:toLowerCase()
    if not valid and t == 'object' then
      valid = value:instanceof(type)
    end
  elseif expectedType == 'Object' then
    valid = toRawType(value) == 'Object'
  elseif expectedType == 'Array' then
    valid = isArray(value)
  else
    valid = value:instanceof(type)
  end
  return {valid=valid, expectedType=expectedType}
end

function getInvalidTypeMessage(name, value, expectedTypes)
  local message =  + 
  local expectedType = expectedTypes[0+1]
  local receivedType = toRawType(value)
  local expectedValue = styleValue(value, expectedType)
  local receivedValue = styleValue(value, receivedType)
  if (#expectedTypes == 1 and isExplicable(expectedType)) and not isBoolean(expectedType, receivedType) then
    message = message + 
  end
  message = message + 
  if isExplicable(receivedType) then
    message = message + 
  end
  return message
end

function styleValue(value, type)
  if type == 'String' then
    return 
  elseif type == 'Number' then
    return 
  else
    return 
  end
end

function isExplicable(type)
  local explicitTypes = {'string', 'number', 'boolean'}
  return explicitTypes:some(function(elem)
    type:toLowerCase() == elem
  end
  )
end

function isBoolean(...)
  return args:some(function(elem)
    elem:toLowerCase() == 'boolean'
  end
  )
end
