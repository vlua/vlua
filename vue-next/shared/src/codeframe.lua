require("stringutil")
local range = 2
function generateCodeFrame(source, start, tsvar_end)
  if start == nil then
    start=0
  end
  if tsvar_end == nil then
    tsvar_end=#source
  end
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local lines = source:split(/\r?\n/)
  local count = 0
  local res = {}
  local i = 0
  repeat
    repeat
      count = count + #lines[i+1] + 1
      if count >= start then
        local j = i - range
        repeat
          repeat
            if j < 0 or j >= #lines then
              break
            end
            local line = j + 1
            table.insert(res)
            local lineLength = #lines[j+1]
            if j == i then
              local pad = start - count - lineLength + 1
              -- [ts2lua]lua中0和空字符串也是true，此处tsvar_end > count需要确认
              local length = Math:max(1, (tsvar_end > count and {lineLength - pad} or {tsvar_end - start})[1])
              table.insert(res,  + (' '):tsvar_repeat(pad) + ('^'):tsvar_repeat(length))
            elseif j > i then
              if tsvar_end > count then
                local length = Math:max(Math:min(tsvar_end - count, lineLength), 1)
                table.insert(res,  + ('^'):tsvar_repeat(length))
              end
              count = count + lineLength + 1
            end
          until true
          j=j+1
        until not(j <= i + range or tsvar_end > count)
        break
      end
    until true
    i=i+1
  until not(i < #lines)
  return res:join('\n')
end
