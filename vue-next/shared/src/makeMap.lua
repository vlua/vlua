require("stringutil")
function makeMap(str, expectsLowerCase)
  local map = Object:create(nil)
  local list = str:split(',')
  local i = 0
  repeat
    -- [ts2lua]map下标访问可能不正确
    map[list[i+1]] = true
    i=i+1
  until not(i < #list)
  return (expectsLowerCase and {function(val)
    -- [ts2lua]map下标访问可能不正确
    not (not map[val:toLowerCase()])
  end
  } or {function(val)
    -- [ts2lua]map下标访问可能不正确
    not (not map[val])
  end
  -- [ts2lua]lua中0和空字符串也是true，此处expectsLowerCase需要确认
  })[1]
end
