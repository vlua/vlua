require("stringutil")
require("@vue/compiler-core/NodeTypes")
require("@vue/compiler-core/TextModes")
require("source-map")
require("@vue/shared")

local SFC_CACHE_MAX_SIZE = 500
-- [ts2lua]lua中0和空字符串也是true，此处__GLOBAL__ or __ESM_BROWSER__需要确认
local sourceToSFC = (__GLOBAL__ or __ESM_BROWSER__ and {Map()} or {require('lru-cache')(SFC_CACHE_MAX_SIZE)})[1]
function parse(source, )
  if  == nil then
    ={}
  end
  local sourceKey = source + sourceMap + filename + sourceRoot + pad + compiler.parse
  local cache = sourceToSFC:get(sourceKey)
  if cache then
    return cache
  end
  local descriptor = {filename=filename, template=nil, script=nil, styles={}, customBlocks={}}
  local errors = {}
  local ast = compiler:parse(source, {isNativeTag=function()
    true
  end
  , isPreTag=function()
    true
  end
  , getTextMode=function(, parent)
    if not parent and tag ~= 'template' or props:some(function(p)
      ((p.type == NodeTypes.ATTRIBUTE and p.name == 'lang') and p.value) and p.value.content ~= 'html'
    end
    ) then
      return TextModes.RAWTEXT
    else
      return TextModes.DATA
    end
  end
  , onError=function(e)
    table.insert(errors, e)
  end
  })
  ast.children:forEach(function(node)
    if node.type ~= NodeTypes.ELEMENT then
      return
    end
    if not #node.children and not hasSrc(node) then
      return
    end
    local switch = {
      ['template'] = function()
        if not descriptor.template then
          descriptor.template = createBlock(node, source, false)
        else
          warnDuplicateBlock(source, filename, node)
        end
      end,
      ['script'] = function()
        if not descriptor.script then
          descriptor.script = createBlock(node, source, pad)
        else
          warnDuplicateBlock(source, filename, node)
        end
      end,
      ['style'] = function()
        table.insert(descriptor.styles, createBlock(node, source, pad))
      end,
      ["default"] = function()
        table.insert(descriptor.customBlocks, createBlock(node, source, pad))
      end
    }
    local casef = switch[node.tag]
    if not casef then casef = switch["default"] end
    if casef then casef() end
  end
  )
  if sourceMap then
    local genMap = function(block)
      if block and not block.src then
        -- [ts2lua]lua中0和空字符串也是true，此处not pad or block.type == 'template'需要确认
        block.map = generateSourceMap(filename, source, block.content, sourceRoot, (not pad or block.type == 'template' and {block.loc.start.line - 1} or {0})[1])
      end
    end
    
    genMap(descriptor.template)
    genMap(descriptor.script)
    descriptor.styles:forEach(genMap)
  end
  local result = {descriptor=descriptor, errors=errors}
  sourceToSFC:set(sourceKey, result)
  return result
end

function warnDuplicateBlock(source, filename, node)
  local codeFrame = generateCodeFrame(source, node.loc.start.offset, node.loc.tsvar_end.offset)
  local location = nil
  console:warn()
end

function createBlock(node, source, pad)
  local type = node.tag
  local  = node.loc
  local content = ''
  if #node.children then
    start = node.children[0+1].loc.start
    -- [ts2lua]node.children下标访问可能不正确
    tsvar_end = node.children[#node.children - 1].loc.tsvar_end
    content = source:slice(start.offset, tsvar_end.offset)
  end
  local loc = {source=content, start=start, tsvar_end=tsvar_end}
  local attrs = {}
  local block = {type=type, content=content, loc=loc, attrs=attrs}
  if pad then
    block.content = padContent(source, block, pad) + block.content
  end
  node.props:forEach(function(p)
    if p.type == NodeTypes.ATTRIBUTE then
      -- [ts2lua]attrs下标访问可能不正确
      -- [ts2lua]lua中0和空字符串也是true，此处p.value需要确认
      attrs[p.name] = (p.value and {p.value.content or true} or {true})[1]
      if p.name == 'lang' then
        block.lang = p.value and p.value.content
      elseif p.name == 'src' then
        block.src = p.value and p.value.content
      elseif type == 'style' then
        if p.name == 'scoped' then
          
          block.scoped = true
        elseif p.name == 'module' then
          
          -- [ts2lua]attrs下标访问可能不正确
          block.module = attrs[p.name]
        end
      elseif type == 'template' and p.name == 'functional' then
        
        block.functional = true
      end
    end
  end
  )
  return block
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local splitRE = /\r?\n/g
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local emptyRE = /^(?:\/\/)?\s*$/
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local replaceRE = /./g
function generateSourceMap(filename, source, generated, sourceRoot, lineOffset)
  local map = SourceMapGenerator({file=filename:gsub('\\', '/'), sourceRoot=sourceRoot:gsub('\\', '/')})
  map:setSourceContent(filename, source)
  generated:split(splitRE):forEach(function(line, index)
    if not emptyRE:test(line) then
      local originalLine = index + 1 + lineOffset
      local generatedLine = index + 1
      local i = 0
      repeat
        if not ('%s'):test(line[i+1]) then
          map:addMapping({source=filename, original={line=originalLine, column=i}, generated={line=generatedLine, column=i}})
        end
        i=i+1
      until not(i < #line)
    end
  end
  )
  return JSON:parse(map:toString())
end

function padContent(content, block, pad)
  content = content:slice(0, block.loc.start.offset)
  if pad == 'space' then
    return content:gsub(replaceRE, ' ')
  else
    local offset = #content:split(splitRE)
    -- [ts2lua]lua中0和空字符串也是true，此处block.type == 'script' and not block.lang需要确认
    local padChar = (block.type == 'script' and not block.lang and {'//\n'} or {'\n'})[1]
    return Array(offset):join(padChar)
  end
end

function hasSrc(node)
  return node.props:some(function(p)
    if p.type ~= NodeTypes.ATTRIBUTE then
      return false
    end
    return p.name == 'src'
  end
  )
end
