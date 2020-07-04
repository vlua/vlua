require("@vue/shared")

local xlinkNS = 'http://www.w3.org/1999/xlink'
function patchAttr(el, key, value, isSVG)
  if isSVG and key:startsWith('xlink:') then
    if value == nil then
      el:removeAttributeNS(xlinkNS, key:slice(6, #key))
    else
      el:setAttributeNS(xlinkNS, key, value)
    end
  else
    local isBoolean = isSpecialBooleanAttr(key)
    if value == nil or isBoolean and value == false then
      el:removeAttribute(key)
    else
      -- [ts2lua]lua中0和空字符串也是true，此处isBoolean需要确认
      el:setAttribute(key, (isBoolean and {''} or {value})[1])
    end
  end
end
