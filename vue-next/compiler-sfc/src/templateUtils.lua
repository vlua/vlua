require("url")
require("@vue/shared")
local uriParse = parse

function isRelativeUrl(url)
  local firstChar = url:sub(0)
  return (firstChar == '.' or firstChar == '~') or firstChar == '@'
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local externalRE = /^https?:\/\//
function isExternalUrl(url)
  return externalRE:test(url)
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local dataUrlRE = /^\s*data:/i
function isDataUrl(url)
  return dataUrlRE:test(url)
end

function parseUrl(url)
  local firstChar = url:sub(0)
  if firstChar == '~' then
    local secondChar = url:sub(1)
    -- [ts2lua]lua中0和空字符串也是true，此处secondChar == '/'需要确认
    url = url:slice((secondChar == '/' and {2} or {1})[1])
  end
  return parseUriParts(url)
end

function parseUriParts(urlString)
  -- [ts2lua]lua中0和空字符串也是true，此处isString(urlString)需要确认
  return uriParse((isString(urlString) and {urlString} or {''})[1])
end
