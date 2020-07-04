
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local escapeRE = /["'&<>]/
function escapeHtml(string)
  local str = '' .. string
  local match = escapeRE:exec(str)
  if not match then
    return str
  end
  local html = ''
  local escaped = nil
  local index = nil
  local lastIndex = 0
  index = match.index
  repeat
    repeat
      local switch = {
        [34] = function()
          escaped = '&quot;'
        end,
        [38] = function()
          escaped = '&amp;'
        end,
        [39] = function()
          escaped = '&#39;'
        end,
        [60] = function()
          escaped = '&lt;'
        end,
        [62] = function()
          escaped = '&gt;'
        end,
        ["default"] = function()
          break
        end
      }
      local casef = switch[str:charCodeAt(index)]
      if not casef then casef = switch["default"] end
      if casef then casef() end
      if lastIndex ~= index then
        html = html + str:substring(lastIndex, index)
      end
      lastIndex = index + 1
      html = html + escaped
    until true
    index=index+1
  until not(index < #str)
  -- [ts2lua]lua中0和空字符串也是true，此处lastIndex ~= index需要确认
  return (lastIndex ~= index and {html + str:substring(lastIndex, index)} or {html})[1]
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local commentStripRE = /^-?>|<!--|-->|--!>|<!-$/g
function escapeHtmlComment(src)
  return src:gsub(commentStripRE, '')
end
