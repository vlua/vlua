require("trycatch")
require("shared/src")

function looseEqual(a, b)
  if a == b then
    return true
  end
  local isObjectA = isObject(a)
  local isObjectB = isObject(b)
  if isObjectA and isObjectB then
    try_catch{
      main = function()
        local isArrayA = isArray(a)
        local isArrayB = isArray(b)
        if isArrayA and isArrayB then
          return #a == #b and a:every(function(e, i)
            looseEqual(e, b[i+1])
          end
          )
        elseif a:instanceof(Date) and b:instanceof(Date) then
          return a:getTime() == b:getTime()
        elseif not isArrayA and not isArrayB then
          local keysA = Object:keys(a)
          local keysB = Object:keys(b)
          return #keysA == #keysB and keysA:every(function(key)
            -- [ts2lua]a下标访问可能不正确
            -- [ts2lua]b下标访问可能不正确
            looseEqual(a[key], b[key])
          end
          )
        else
          return false
        end
      end,
      catch = function(e)
        return false
      end
    }
  elseif not isObjectA and not isObjectB then
    return String(a) == String(b)
  else
    return false
  end
end

function looseIndexOf(arr, val)
  return arr:findIndex(function(item)
    looseEqual(item, val)
  end
  )
end
