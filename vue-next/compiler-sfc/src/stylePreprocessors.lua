require("trycatch")
require("merge-source-map")

local scss = {render=function(source, map, options, load)
  if load == nil then
    load=require
  end
  local nodeSass = load('sass')
  local finalOptions = {..., data=source, file=options.filename, outFile=options.filename, sourceMap=not (not map)}
  try_catch{
    main = function()
      local result = nodeSass:renderSync(finalOptions)
      if map then
        return {code=result.css:toString(), map=merge(map, JSON:parse(result.map:toString())), errors={}}
      end
      return {code=result.css:toString(), errors={}}
    end,
    catch = function(e)
      return {code='', errors={e}}
    end
  }
end
}
local sass = {render=function(source, map, options, load)
  return scss:render(source, map, {..., indentedSyntax=true}, load)
end
}
local less = {render=function(source, map, options, load)
  if load == nil then
    load=require
  end
  local nodeLess = load('less')
  local result = nil
  local error = nil
  nodeLess:render(source, {..., syncImport=true}, function(err, output)
    error = err
    result = output
  end
  )
  if error then
    return {code='', errors={error}}
  end
  if map then
    return {code=result.css:toString(), map=merge(map, result.map), errors={}}
  end
  return {code=result.css:toString(), errors={}}
end
}
local styl = {render=function(source, map, options, load)
  if load == nil then
    load=require
  end
  local nodeStylus = load('stylus')
  try_catch{
    main = function()
      local ref = nodeStylus(source)
      Object:keys(options):forEach(function(key)
        -- [ts2lua]options下标访问可能不正确
        ref:set(key, options[key])
      end
      )
      if map then
        ref:set('sourcemap', {inline=false, comment=false})
      end
      local result = ref:render()
      if map then
        return {code=result, map=merge(map, ref.sourcemap), errors={}}
      end
      return {code=result, errors={}}
    end,
    catch = function(e)
      return {code='', errors={e}}
    end
  }
end
}
local processors = {less=less, sass=sass, scss=scss, styl=styl, stylus=styl}