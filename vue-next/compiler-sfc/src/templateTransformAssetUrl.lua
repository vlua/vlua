require("tableutil")
require("path")
require("@vue/compiler-core")
require("@vue/compiler-core/NodeTypes")
require("compiler-sfc/src/templateUtils")
require("@vue/shared")

local defaultAssetUrlOptions = {base=nil, includeAbsolute=false, tags={video={'src', 'poster'}, source={'src'}, img={'src'}, image={'xlink:href', 'href'}, use={'xlink:href', 'href'}}}
local normalizeOptions = function(options)
  if Object:keys(options):some(function(key)
    -- [ts2lua]options下标访问可能不正确
    isArray(options[key])
  end
  ) then
    return {..., tags=options}
  end
  return {..., ...}
end

local createAssetUrlTransformWithOptions = function(options)
  return function(node, context)
    transformAssetUrl(node, context, options)
  end
  

end

local transformAssetUrl = function(node, context, options = defaultAssetUrlOptions)
  if options == nil then
    options=defaultAssetUrlOptions
  end
  if node.type == NodeTypes.ELEMENT then
    if not #node.props then
      return
    end
    local tags = options.tags or defaultAssetUrlOptions.tags
    -- [ts2lua]tags下标访问可能不正确
    local attrs = tags[node.tag]
    -- [ts2lua]tags下标访问可能不正确
    local wildCardAttrs = tags['*']
    if not attrs and not wildCardAttrs then
      return
    end
    local assetAttrs = table.merge((attrs or {}), wildCardAttrs or {})
    node.props:forEach(function(attr, index)
      if (((((attr.type ~= NodeTypes.ATTRIBUTE or not assetAttrs:includes(attr.name)) or not attr.value) or isExternalUrl(attr.value.content)) or isDataUrl(attr.value.content)) or attr.value.content[0+1] == '#') or not options.includeAbsolute and not isRelativeUrl(attr.value.content) then
        return
      end
      local url = parseUrl(attr.value.content)
      if options.base then
        if attr.value.content[0+1] ~= '@' and isRelativeUrl(attr.value.content) then
          attr.value.content = (path.posix or path):join(options.base, url.path + url.hash or '')
        end
        return
      end
      local exp = getImportsExpressionExp(url.path, url.hash, attr.loc, context)
      -- [ts2lua]node.props下标访问可能不正确
      node.props[index] = {type=NodeTypes.DIRECTIVE, name='bind', arg=createSimpleExpression(attr.name, true, attr.loc), exp=exp, modifiers={}, loc=attr.loc}
    end
    )
  end
end

function getImportsExpressionExp(path, hash, loc, context)
  if path then
    local importsArray = Array:from(context.imports)
    local existing = importsArray:find(function(i)
      i.path == path
    end
    )
    if existing then
      return existing.exp
    end
    local name = nil
    local exp = createSimpleExpression(name, false, loc, true)
    exp.isRuntimeConstant = true
    context.imports:add({exp=exp, path=path})
    if hash and path then
      local ret = context:hoist(createSimpleExpression(false, loc, true))
      ret.isRuntimeConstant = true
      return ret
    else
      return exp
    end
  else
    return createSimpleExpression(false, loc, true)
  end
end
