require("compiler-dom/src/namedChars.json")

local maxCRNameLength = nil
local decodeHtml = function(rawText, asAttr)
  local offset = 0
  local tsvar_end = #rawText
  local decodedText = ''
  function advance(length)
    offset = offset + length
    rawText = rawText:slice(length)
  end
  
  while(offset < tsvar_end)
  do
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local head = (/&(?:#x?)?/i):exec(rawText)
  if not head or offset + head.index >= tsvar_end then
    local remaining = tsvar_end - offset
    decodedText = decodedText + rawText:slice(0, remaining)
    advance(remaining)
    break
  end
  decodedText = decodedText + rawText:slice(0, head.index)
  advance(head.index)
  if head[0+1] == '&' then
    local name = ''
    local value = undefined
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    if (/[0-9a-z]/i):test(rawText[1+1]) then
      if not maxCRNameLength then
        maxCRNameLength = Object:keys(namedCharacterReferences):reduce(function(max, name)
          Math:max(max, #name)
        end
        , 0)
      end
      local length = maxCRNameLength
      repeat
        name = rawText:substr(1, length)
        -- [ts2lua]namedCharacterReferences下标访问可能不正确
        value = namedCharacterReferences[name]
        length=length-1
      until not(not value and length > 0)
      if value then
        local semi = name:endsWith(';')
        -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
        -- [ts2lua]rawText下标访问可能不正确
        if (asAttr and not semi) and (/[=a-z0-9]/i):test(rawText[#name + 1] or '') then
          decodedText = decodedText .. '&' .. name
          advance(1 + #name)
        else
          decodedText = decodedText + value
          advance(1 + #name)
        end
      else
        decodedText = decodedText .. '&' .. name
        advance(1 + #name)
      end
    else
      decodedText = decodedText .. '&'
      advance(1)
    end
  else
    local hex = head[0+1] == '&#x'
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    -- [ts2lua]lua中0和空字符串也是true，此处hex需要确认
    local pattern = (hex and {/^&#x([0-9a-f]+);?/i} or {/^&#([0-9]+);?/})[1]
    local body = pattern:exec(rawText)
    if not body then
      decodedText = decodedText + head[0+1]
      advance(#head[0+1])
    else
      -- [ts2lua]lua中0和空字符串也是true，此处hex需要确认
      local cp = Number:parseInt(body[1+1], (hex and {16} or {10})[1])
      if cp == 0 then
        cp = 0xfffd
      elseif cp > 0x10ffff then
        cp = 0xfffd
      elseif cp >= 0xd800 and cp <= 0xdfff then
        cp = 0xfffd
      elseif cp >= 0xfdd0 and cp <= 0xfdef or cp & 0xfffe == 0xfffe then
        
      elseif ((cp >= 0x01 and cp <= 0x08 or cp == 0x0b) or cp >= 0x0d and cp <= 0x1f) or cp >= 0x7f and cp <= 0x9f then
        -- [ts2lua]CCR_REPLACEMENTS下标访问可能不正确
        cp = CCR_REPLACEMENTS[cp] or cp
      end
      decodedText = decodedText + String:fromCodePoint(cp)
      advance(#body[0+1])
    end
  end
  end
  return decodedText
end

local CCR_REPLACEMENTS = {128=0x20ac, 130=0x201a, 131=0x0192, 132=0x201e, 133=0x2026, 134=0x2020, 135=0x2021, 136=0x02c6, 137=0x2030, 138=0x0160, 139=0x2039, 140=0x0152, 142=0x017d, 145=0x2018, 146=0x2019, 147=0x201c, 148=0x201d, 149=0x2022, 150=0x2013, 151=0x2014, 152=0x02dc, 153=0x2122, 154=0x0161, 155=0x203a, 156=0x0153, 158=0x017e, 159=0x0178}