require("stringutil")
require("path")
require("@vue/compiler-core")
require("@vue/compiler-core/NodeTypes")
require("compiler-sfc/src/templateUtils")
require("compiler-sfc/src/templateTransformAssetUrl")

local srcsetTags = {'img', 'source'}
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local escapedSpaceCharacters = /( |\\t|\\n|\\f|\\r)+/g
local createSrcsetTransformWithOptions = function(options)
  return function(node, context)
    transformSrcset(node, context, options)
  end
  

end

local transformSrcset = function(node, context, options = defaultAssetUrlOptions)
  if options == nil then
    options=defaultAssetUrlOptions
  end
  if node.type == NodeTypes.ELEMENT then
    if srcsetTags:includes(node.tag) and #node.props then
      node.props:forEach(function(attr, index)
        if attr.name == 'srcset' and attr.type == NodeTypes.ATTRIBUTE then
          if not attr.value then
            return
          end
          local value = attr.value.content
          local imageCandidates = value:split(','):map(function(s)
            local  = s:gsub(escapedSpaceCharacters, ' '):trim():split(' ', 2)
            return {url=url, descriptor=descriptor}
          end
          )
          local i = 0
          repeat
            if imageCandidates[i+1].url:trim():startsWith('data:') then
              -- [ts2lua]imageCandidates下标访问可能不正确
              -- [ts2lua]imageCandidates下标访问可能不正确
              imageCandidates[i + 1].url = imageCandidates[i+1].url .. ',' .. imageCandidates[i + 1].url
              imageCandidates:splice(i, 1)
            end
            i=i+1
          until not(i < #imageCandidates)
          if not options.includeAbsolute and not imageCandidates:some(function()
            isRelativeUrl(url)
          end
          ) then
            return
          end
          if options.base then
            local base = options.base
            local set = {}
            imageCandidates:forEach(function()
              -- [ts2lua]lua中0和空字符串也是true，此处descriptor需要确认
              descriptor = (descriptor and {} or {})[1]
              if isRelativeUrl(url) then
                table.insert(set, (path.posix or path):join(base, url) + descriptor)
              else
                table.insert(set, url + descriptor)
              end
            end
            )
            attr.value.content = set:join(', ')
            return
          end
          local compoundExpression = createCompoundExpression({}, attr.loc)
          imageCandidates:forEach(function(, index)
            if (not isExternalUrl(url) and not isDataUrl(url)) and (options.includeAbsolute or isRelativeUrl(url)) then
              local  = parseUrl(url)
              local exp = nil
              if path then
                local importsArray = Array:from(context.imports)
                local existingImportsIndex = importsArray:findIndex(function(i)
                  i.path == path
                end
                )
                if existingImportsIndex > -1 then
                  exp = createSimpleExpression(false, attr.loc, true)
                else
                  exp = createSimpleExpression(false, attr.loc, true)
                  context.imports:add({exp=exp, path=path})
                end
                table.insert(compoundExpression.children, exp)
              end
            else
              local exp = createSimpleExpression(false, attr.loc, true)
              table.insert(compoundExpression.children, exp)
            end
            local isNotLast = #imageCandidates - 1 > index
            if descriptor and isNotLast then
              table.insert(compoundExpression.children)
            elseif descriptor then
              table.insert(compoundExpression.children)
            elseif isNotLast then
              table.insert(compoundExpression.children)
            end
          end
          )
          local hoisted = context:hoist(compoundExpression)
          hoisted.isRuntimeConstant = true
          -- [ts2lua]node.props下标访问可能不正确
          node.props[index] = {type=NodeTypes.DIRECTIVE, name='bind', arg=createSimpleExpression('srcset', true, attr.loc), exp=hoisted, modifiers={}, loc=attr.loc}
        end
      end
      )
    end
  end
end
