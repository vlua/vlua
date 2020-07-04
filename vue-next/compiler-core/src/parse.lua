require("stringutil")
require("@vue/shared")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/errors")
require("compiler-core/src/utils")
require("compiler-core/src/ast/Namespaces")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/parse/TextModes")
local TagType = {
  Start = 0,
  End = 1
}
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。

local decodeRE = /&(gt|lt|amp|apos|quot);/g
local decodeMap = {gt='>', lt='<', amp='&', apos="'", quot='"'}
local defaultParserOptions = {delimiters={}, getNamespace=function()
  Namespaces.HTML
end
, getTextMode=function()
  TextModes.DATA
end
, isVoidTag=NO, isPreTag=NO, isCustomElement=NO, decodeEntities=function(rawText)
  rawText:gsub(decodeRE, function(_, p1)
    -- [ts2lua]decodeMap下标访问可能不正确
    decodeMap[p1]
  end
  )
end
, onError=defaultOnError}
function baseParse(content, options)
  if options == nil then
    options={}
  end
  local context = createParserContext(content, options)
  local start = getCursor(context)
  return createRoot(parseChildren(context, TextModes.DATA, {}), getSelection(context, start))
end

function createParserContext(content, options)
  return {options=extend({}, defaultParserOptions, options), column=1, line=1, offset=0, originalSource=content, source=content, inPre=false, inVPre=false}
end

function parseChildren(context, mode, ancestors)
  local parent = last(ancestors)
  -- [ts2lua]lua中0和空字符串也是true，此处parent需要确认
  local ns = (parent and {parent.ns} or {Namespaces.HTML})[1]
  local nodes = {}
  while(not isEnd(context, mode, ancestors))
  do
  __TEST__ and assert(#context.source > 0)
  local s = context.source
  local node = undefined
  if mode == TextModes.DATA or mode == TextModes.RCDATA then
    if not context.inVPre and startsWith(s, context.options.delimiters[0+1]) then
      node = parseInterpolation(context, mode)
    elseif mode == TextModes.DATA and s[0+1] == '<' then
      if #s == 1 then
        emitError(context, ErrorCodes.EOF_BEFORE_TAG_NAME, 1)
      elseif s[1+1] == '!' then
        if startsWith(s, '<!--') then
          node = parseComment(context)
        elseif startsWith(s, '<!DOCTYPE') then
          node = parseBogusComment(context)
        elseif startsWith(s, '<![CDATA[') then
          if ns ~= Namespaces.HTML then
            node = parseCDATA(context, ancestors)
          else
            emitError(context, ErrorCodes.CDATA_IN_HTML_CONTENT)
            node = parseBogusComment(context)
          end
        else
          emitError(context, ErrorCodes.INCORRECTLY_OPENED_COMMENT)
          node = parseBogusComment(context)
        end
      elseif s[1+1] == '/' then
        if #s == 2 then
          emitError(context, ErrorCodes.EOF_BEFORE_TAG_NAME, 2)
        elseif s[2+1] == '>' then
          emitError(context, ErrorCodes.MISSING_END_TAG_NAME, 2)
          advanceBy(context, 3)
          break
        -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
        elseif (/[a-z]/i):test(s[2+1]) then
          emitError(context, ErrorCodes.X_INVALID_END_TAG)
          parseTag(context, TagType.End, parent)
          break
        else
          emitError(context, ErrorCodes.INVALID_FIRST_CHARACTER_OF_TAG_NAME, 2)
          node = parseBogusComment(context)
        end
      -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
      elseif (/[a-z]/i):test(s[1+1]) then
        node = parseElement(context, ancestors)
      elseif s[1+1] == '?' then
        emitError(context, ErrorCodes.UNEXPECTED_QUESTION_MARK_INSTEAD_OF_TAG_NAME, 1)
        node = parseBogusComment(context)
      else
        emitError(context, ErrorCodes.INVALID_FIRST_CHARACTER_OF_TAG_NAME, 1)
      end
    end
  end
  if not node then
    node = parseText(context, mode)
  end
  if isArray(node) then
    local i = 0
    repeat
      pushNode(nodes, node[i+1])
      i=i+1
    until not(i < #node)
  else
    pushNode(nodes, node)
  end
  end
  local removedWhitespace = false
  if mode ~= TextModes.RAWTEXT then
    if not context.inPre then
      local i = 0
      repeat
        local node = nodes[i+1]
        if node.type == NodeTypes.TEXT then
          -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
          if not (/[^\t\r\n\f ]/):test(node.content) then
            -- [ts2lua]nodes下标访问可能不正确
            local prev = nodes[i - 1]
            -- [ts2lua]nodes下标访问可能不正确
            local next = nodes[i + 1]
            -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
            if (((not prev or not next) or prev.type == NodeTypes.COMMENT) or next.type == NodeTypes.COMMENT) or (prev.type == NodeTypes.ELEMENT and next.type == NodeTypes.ELEMENT) and (/[\r\n]/):test(node.content) then
              removedWhitespace = true
              nodes[i+1] = nil
            else
              node.content = ' '
            end
          else
            -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
            node.content = node.content:gsub(/[\t\r\n\f ]+/g, ' ')
          end
        elseif not __DEV__ and node.type == NodeTypes.COMMENT then
          removedWhitespace = true
          nodes[i+1] = nil
        end
        i=i+1
      until not(i < #nodes)
    elseif parent and context.options:isPreTag(parent.tag) then
      local first = nodes[0+1]
      if first and first.type == NodeTypes.TEXT then
        -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
        first.content = first.content:gsub(/^\r?\n/, '')
      end
    end
  end
  -- [ts2lua]lua中0和空字符串也是true，此处removedWhitespace需要确认
  return (removedWhitespace and {nodes:filter(Boolean)} or {nodes})[1]
end

function pushNode(nodes, node)
  if node.type == NodeTypes.TEXT then
    local prev = last(nodes)
    if (prev and prev.type == NodeTypes.TEXT) and prev.loc.tsvar_end.offset == node.loc.start.offset then
      prev.content = prev.content + node.content
      prev.loc.tsvar_end = node.loc.tsvar_end
      prev.loc.source = prev.loc.source + node.loc.source
      return
    end
  end
  table.insert(nodes, node)
end

function parseCDATA(context, ancestors)
  __TEST__ and assert(last(ancestors) == nil or ().ns ~= Namespaces.HTML)
  __TEST__ and assert(startsWith(context.source, '<![CDATA['))
  advanceBy(context, 9)
  local nodes = parseChildren(context, TextModes.CDATA, ancestors)
  if #context.source == 0 then
    emitError(context, ErrorCodes.EOF_IN_CDATA)
  else
    __TEST__ and assert(startsWith(context.source, ']]>'))
    advanceBy(context, 3)
  end
  return nodes
end

function parseComment(context)
  __TEST__ and assert(startsWith(context.source, '<!--'))
  local start = getCursor(context)
  local content = nil
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local match = (/--(\!)?>/):exec(context.source)
  if not match then
    content = context.source:slice(4)
    advanceBy(context, #context.source)
    emitError(context, ErrorCodes.EOF_IN_COMMENT)
  else
    if match.index <= 3 then
      emitError(context, ErrorCodes.ABRUPT_CLOSING_OF_EMPTY_COMMENT)
    end
    if match[1+1] then
      emitError(context, ErrorCodes.INCORRECTLY_CLOSED_COMMENT)
    end
    content = context.source:slice(4, match.index)
    local s = context.source:slice(0, match.index)
    local prevIndex = 1
    local nestedIndex = 0
    while(nestedIndex = s:find('<!--', prevIndex) ~= -1)
    do
    advanceBy(context, nestedIndex - prevIndex + 1)
    if nestedIndex + 4 < #s then
      emitError(context, ErrorCodes.NESTED_COMMENT)
    end
    prevIndex = nestedIndex + 1
    end
    advanceBy(context, match.index + #match[0+1] - prevIndex + 1)
  end
  return {type=NodeTypes.COMMENT, content=content, loc=getSelection(context, start)}
end

function parseBogusComment(context)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  __TEST__ and assert((/^<(?:[\!\?]|\/[^a-z>])/i):test(context.source))
  local start = getCursor(context)
  -- [ts2lua]lua中0和空字符串也是true，此处context.source[1+1] == '?'需要确认
  local contentStart = (context.source[1+1] == '?' and {1} or {2})[1]
  local content = nil
  local closeIndex = context.source:find('>')
  if closeIndex == -1 then
    content = context.source:slice(contentStart)
    advanceBy(context, #context.source)
  else
    content = context.source:slice(contentStart, closeIndex)
    advanceBy(context, closeIndex + 1)
  end
  return {type=NodeTypes.COMMENT, content=content, loc=getSelection(context, start)}
end

function parseElement(context, ancestors)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  __TEST__ and assert((/^<[a-z]/i):test(context.source))
  local wasInPre = context.inPre
  local wasInVPre = context.inVPre
  local parent = last(ancestors)
  local element = parseTag(context, TagType.Start, parent)
  local isPreBoundary = context.inPre and not wasInPre
  local isVPreBoundary = context.inVPre and not wasInVPre
  if element.isSelfClosing or context.options:isVoidTag(element.tag) then
    return element
  end
  table.insert(ancestors, element)
  local mode = context.options:getTextMode(element, parent)
  local children = parseChildren(context, mode, ancestors)
  ancestors:pop()
  element.children = children
  if startsWithEndTagOpen(context.source, element.tag) then
    parseTag(context, TagType.End, parent)
  else
    emitError(context, ErrorCodes.X_MISSING_END_TAG, 0, element.loc.start)
    if #context.source == 0 and element.tag:toLowerCase() == 'script' then
      local first = children[0+1]
      if first and startsWith(first.loc.source, '<!--') then
        emitError(context, ErrorCodes.EOF_IN_SCRIPT_HTML_COMMENT_LIKE_TEXT)
      end
    end
  end
  element.loc = getSelection(context, element.loc.start)
  if isPreBoundary then
    context.inPre = false
  end
  if isVPreBoundary then
    context.inVPre = false
  end
  return element
end

local isSpecialTemplateDirective = makeMap()
function parseTag(context, type, parent)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  __TEST__ and assert((/^<\/?[a-z]/i):test(context.source))
  -- [ts2lua]lua中0和空字符串也是true，此处startsWith(context.source, '</')需要确认
  __TEST__ and assert(type == (startsWith(context.source, '</') and {TagType.End} or {TagType.Start})[1])
  local start = getCursor(context)
  local match = nil
  local tag = match[1+1]
  local ns = context.options:getNamespace(tag, parent)
  advanceBy(context, #match[0+1])
  advanceSpaces(context)
  local cursor = getCursor(context)
  local currentSource = context.source
  local props = parseAttributes(context, type)
  if context.options:isPreTag(tag) then
    context.inPre = true
  end
  if not context.inVPre and props:some(function(p)
    p.type == NodeTypes.DIRECTIVE and p.name == 'pre'
  end
  ) then
    context.inVPre = true
    extend(context, cursor)
    context.source = currentSource
    props = parseAttributes(context, type):filter(function(p)
      p.name ~= 'v-pre'
    end
    )
  end
  local isSelfClosing = false
  if #context.source == 0 then
    emitError(context, ErrorCodes.EOF_IN_TAG)
  else
    isSelfClosing = startsWith(context.source, '/>')
    if type == TagType.End and isSelfClosing then
      emitError(context, ErrorCodes.END_TAG_WITH_TRAILING_SOLIDUS)
    end
    -- [ts2lua]lua中0和空字符串也是true，此处isSelfClosing需要确认
    advanceBy(context, (isSelfClosing and {2} or {1})[1])
  end
  local tagType = ElementTypes.ELEMENT
  local options = context.options
  if not context.inVPre and not options:isCustomElement(tag) then
    local hasVIs = props:some(function(p)
      p.type == NodeTypes.DIRECTIVE and p.name == 'is'
    end
    )
    if options.isNativeTag and not hasVIs then
      if not options:isNativeTag(tag) then
        tagType = ElementTypes.COMPONENT
      end
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    elseif (((hasVIs or isCoreComponent(tag)) or options.isBuiltInComponent and options:isBuiltInComponent(tag)) or (/^[A-Z]/):test(tag)) or tag == 'component' then
      tagType = ElementTypes.COMPONENT
    end
    if tag == 'slot' then
      tagType = ElementTypes.SLOT
    elseif tag == 'template' and props:some(function(p)
      return p.type == NodeTypes.DIRECTIVE and isSpecialTemplateDirective(p.name)
    end
    ) then
      tagType = ElementTypes.TEMPLATE
    end
  end
  return {type=NodeTypes.ELEMENT, ns=ns, tag=tag, tagType=tagType, props=props, isSelfClosing=isSelfClosing, children={}, loc=getSelection(context, start), codegenNode=undefined}
end

function parseAttributes(context, type)
  local props = {}
  local attributeNames = Set()
  while((#context.source > 0 and not startsWith(context.source, '>')) and not startsWith(context.source, '/>'))
  do
  if startsWith(context.source, '/') then
    emitError(context, ErrorCodes.UNEXPECTED_SOLIDUS_IN_TAG)
    advanceBy(context, 1)
    advanceSpaces(context)
    break
  end
  if type == TagType.End then
    emitError(context, ErrorCodes.END_TAG_WITH_ATTRIBUTES)
  end
  local attr = parseAttribute(context, attributeNames)
  if type == TagType.Start then
    table.insert(props, attr)
  end
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  if (/^[^\t\r\n\f />]/):test(context.source) then
    emitError(context, ErrorCodes.MISSING_WHITESPACE_BETWEEN_ATTRIBUTES)
  end
  advanceSpaces(context)
  end
  return props
end

function parseAttribute(context, nameSet)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  __TEST__ and assert((/^[^\t\r\n\f />]/):test(context.source))
  local start = getCursor(context)
  local match = nil
  local name = match[0+1]
  if nameSet:has(name) then
    emitError(context, ErrorCodes.DUPLICATE_ATTRIBUTE)
  end
  nameSet:add(name)
  if name[0+1] == '=' then
    emitError(context, ErrorCodes.UNEXPECTED_EQUALS_SIGN_BEFORE_ATTRIBUTE_NAME)
  end
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local pattern = /["'<]/g
  local m = nil
  while(m = pattern:exec(name))
  do
  emitError(context, ErrorCodes.UNEXPECTED_CHARACTER_IN_ATTRIBUTE_NAME, m.index)
  end
  advanceBy(context, #name)
  local value = undefined
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  if (/^[\t\r\n\f ]*=/):test(context.source) then
    advanceSpaces(context)
    advanceBy(context, 1)
    advanceSpaces(context)
    value = parseAttributeValue(context)
    if not value then
      emitError(context, ErrorCodes.MISSING_ATTRIBUTE_VALUE)
    end
  end
  local loc = getSelection(context, start)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  if not context.inVPre and (/^(v-|:|@|#)/):test(name) then
    local match = nil
    -- [ts2lua]lua中0和空字符串也是true，此处startsWith(name, '@')需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处startsWith(name, ':')需要确认
    local dirName = match[1+1] or ((startsWith(name, ':') and {'bind'} or {(startsWith(name, '@') and {'on'} or {'slot'})[1]})[1])
    local arg = nil
    if match[2+1] then
      local isSlot = dirName == 'slot'
      local startOffset = name:find(match[2+1])
      local loc = getSelection(context, getNewPosition(context, start, startOffset), getNewPosition(context, start, startOffset + #match[2+1] + #(isSlot and match[3+1] or '')))
      local content = match[2+1]
      local isStatic = true
      if content:startsWith('[') then
        isStatic = false
        if not content:endsWith(']') then
          emitError(context, ErrorCodes.X_MISSING_DYNAMIC_DIRECTIVE_ARGUMENT_END)
        end
        content = content:substr(1, #content - 2)
      elseif isSlot then
        content = content + match[3+1] or ''
      end
      arg = {type=NodeTypes.SIMPLE_EXPRESSION, content=content, isStatic=isStatic, isConstant=isStatic, loc=loc}
    end
    if value and value.isQuoted then
      local valueLoc = value.loc
      valueLoc.start.offset=valueLoc.start.offset+1
      valueLoc.start.column=valueLoc.start.column+1
      valueLoc.tsvar_end = advancePositionWithClone(valueLoc.start, value.content)
      valueLoc.source = valueLoc.source:slice(1, -1)
    end
    -- [ts2lua]lua中0和空字符串也是true，此处match[3+1]需要确认
    return {type=NodeTypes.DIRECTIVE, name=dirName, exp=value and {type=NodeTypes.SIMPLE_EXPRESSION, content=value.content, isStatic=false, isConstant=false, loc=value.loc}, arg=arg, modifiers=(match[3+1] and {match[3+1]:substr(1):split('.')} or {{}})[1], loc=loc}
  end
  return {type=NodeTypes.ATTRIBUTE, name=name, value=value and {type=NodeTypes.TEXT, content=value.content, loc=value.loc}, loc=loc}
end

function parseAttributeValue(context)
  local start = getCursor(context)
  local content = nil
  local quote = context.source[0+1]
  local isQuoted = quote ==  or quote == 
  if isQuoted then
    advanceBy(context, 1)
    local endIndex = context.source:find(quote)
    if endIndex == -1 then
      content = parseTextData(context, #context.source, TextModes.ATTRIBUTE_VALUE)
    else
      content = parseTextData(context, endIndex, TextModes.ATTRIBUTE_VALUE)
      advanceBy(context, 1)
    end
  else
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    local match = (/^[^\t\r\n\f >]+/):exec(context.source)
    if not match then
      return undefined
    end
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    local unexpectedChars = /["'<=`]/g
    local m = nil
    while(m = unexpectedChars:exec(match[0+1]))
    do
    emitError(context, ErrorCodes.UNEXPECTED_CHARACTER_IN_UNQUOTED_ATTRIBUTE_VALUE, m.index)
    end
    content = parseTextData(context, #match[0+1], TextModes.ATTRIBUTE_VALUE)
  end
  return {content=content, isQuoted=isQuoted, loc=getSelection(context, start)}
end

function parseInterpolation(context, mode)
  local  = context.options.delimiters
  __TEST__ and assert(startsWith(context.source, open))
  local closeIndex = context.source:find(close, #open)
  if closeIndex == -1 then
    emitError(context, ErrorCodes.X_MISSING_INTERPOLATION_END)
    return undefined
  end
  local start = getCursor(context)
  advanceBy(context, #open)
  local innerStart = getCursor(context)
  local innerEnd = getCursor(context)
  local rawContentLength = closeIndex - #open
  local rawContent = context.source:slice(0, rawContentLength)
  local preTrimContent = parseTextData(context, rawContentLength, mode)
  local content = preTrimContent:trim()
  local startOffset = preTrimContent:find(content)
  if startOffset > 0 then
    advancePositionWithMutation(innerStart, rawContent, startOffset)
  end
  local endOffset = rawContentLength - #preTrimContent - #content - startOffset
  advancePositionWithMutation(innerEnd, rawContent, endOffset)
  advanceBy(context, #close)
  return {type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, isStatic=false, isConstant=false, content=content, loc=getSelection(context, innerStart, innerEnd)}, loc=getSelection(context, start)}
end

function parseText(context, mode)
  __TEST__ and assert(#context.source > 0)
  local endTokens = {'<', context.options.delimiters[0+1]}
  if mode == TextModes.CDATA then
    table.insert(endTokens, ']]>')
  end
  local endIndex = #context.source
  local i = 0
  repeat
    local index = context.source:find(endTokens[i+1], 1)
    if index ~= -1 and endIndex > index then
      endIndex = index
    end
    i=i+1
  until not(i < #endTokens)
  __TEST__ and assert(endIndex > 0)
  local start = getCursor(context)
  local content = parseTextData(context, endIndex, mode)
  return {type=NodeTypes.TEXT, content=content, loc=getSelection(context, start)}
end

function parseTextData(context, length, mode)
  local rawText = context.source:slice(0, length)
  advanceBy(context, length)
  if (mode == TextModes.RAWTEXT or mode == TextModes.CDATA) or rawText:find('&') == -1 then
    return rawText
  else
    return context.options:decodeEntities(rawText, mode == TextModes.ATTRIBUTE_VALUE)
  end
end

function getCursor(context)
  local  = context
  return {column=column, line=line, offset=offset}
end

function getSelection(context, start, tsvar_end)
  tsvar_end = tsvar_end or getCursor(context)
  return {start=start, tsvar_end=tsvar_end, source=context.originalSource:slice(start.offset, tsvar_end.offset)}
end

function last(xs)
  -- [ts2lua]xs下标访问可能不正确
  return xs[#xs - 1]
end

function startsWith(source, searchString)
  return source:startsWith(searchString)
end

function advanceBy(context, numberOfCharacters)
  local  = context
  __TEST__ and assert(numberOfCharacters <= #source)
  advancePositionWithMutation(context, source, numberOfCharacters)
  context.source = source:slice(numberOfCharacters)
end

function advanceSpaces(context)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local match = (/^[\t\r\n\f ]+/):exec(context.source)
  if match then
    advanceBy(context, #match[0+1])
  end
end

function getNewPosition(context, start, numberOfCharacters)
  return advancePositionWithClone(start, context.originalSource:slice(start.offset, numberOfCharacters), numberOfCharacters)
end

function emitError(context, code, offset, loc)
  if loc == nil then
    loc=getCursor(context)
  end
  if offset then
    loc.offset = loc.offset + offset
    loc.column = loc.column + offset
  end
  context.options:onError(createCompilerError(code, {start=loc, tsvar_end=loc, source=''}))
end

function isEnd(context, mode, ancestors)
  local s = context.source
  local switch = {
    [TextModes.DATA] = function()
      if startsWith(s, '</') then
        local i = #ancestors - 1
        repeat
          if startsWithEndTagOpen(s, ancestors[i+1].tag) then
            return true
          end
          i=i-1
        until not(i >= 0)
      end
    end,
    [TextModes.RCDATA] = function()
     end,
    [TextModes.RAWTEXT] = function()
      local parent = last(ancestors)
      if parent and startsWithEndTagOpen(s, parent.tag) then
        return true
      end
      return
    end,
    [TextModes.CDATA] = function()
      if startsWith(s, ']]>') then
        return true
      end
    end
  }
  local casef = switch[mode]
  if not casef then casef = switch["default"] end
  if casef then casef() end
  return not s
end

function startsWithEndTagOpen(source, tag)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  -- [ts2lua]source下标访问可能不正确
  return (startsWith(source, '</') and source:substr(2, #tag):toLowerCase() == tag:toLowerCase()) and (/[\t\n\f />]/):test(source[2 + #tag] or '>')
end
