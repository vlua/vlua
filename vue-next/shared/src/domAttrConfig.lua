require("shared/src/makeMap")

local specialBooleanAttrs = nil
local isSpecialBooleanAttr = makeMap(specialBooleanAttrs)
local isBooleanAttr = makeMap(specialBooleanAttrs +  +  + )
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local unsafeAttrCharRE = /[>/="'\u0009\u000a\u000c\u0020]/
local attrValidationCache = {}
function isSSRSafeAttrName(name)
  if attrValidationCache:hasOwnProperty(name) then
    -- [ts2lua]attrValidationCache下标访问可能不正确
    return attrValidationCache[name]
  end
  local isUnsafe = unsafeAttrCharRE:test(name)
  if isUnsafe then
    console:error()
  end
  -- [ts2lua]attrValidationCache下标访问可能不正确
  return attrValidationCache[name] = not isUnsafe
end

local propsToAttrMap = {acceptCharset='accept-charset', className='class', htmlFor='for', httpEquiv='http-equiv'}
local isNoUnitNumericStyleProp = makeMap( +  +  +  +  +  +  + )
local isKnownAttr = makeMap( +  +  +  +  +  +  +  +  +  +  +  +  +  + )