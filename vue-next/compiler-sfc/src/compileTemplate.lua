require("trycatch")
require("tableutil")
require("stringutil")
require("source-map")
require("compiler-sfc/src/templateTransformAssetUrl")
require("compiler-sfc/src/templateTransformSrcset")
require("@vue/shared")

function preprocess(, preprocessor)
  local res = ''
  local err = nil
  preprocessor:render(source, {filename=filename, ...}, function(_err, _res)
    if _err then
      err = _err
    end
    res = _res
  end
  )
  if err then
    error(err)
  end
  return res
end

function compileTemplate(options)
  local  = options
  if ((__ESM_BROWSER__ or __GLOBAL__) and preprocessLang) and not preprocessCustomRequire then
    error(Error( +  + ))
  end
  -- [ts2lua]require('consolidate')下标访问可能不正确
  -- [ts2lua]lua中0和空字符串也是true，此处preprocessCustomRequire需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处preprocessLang需要确认
  local preprocessor = (preprocessLang and {(preprocessCustomRequire and {preprocessCustomRequire(preprocessLang)} or {require('consolidate')[preprocessLang]})[1]} or {false})[1]
  if preprocessor then
    try_catch{
      main = function()
        return doCompileTemplate({..., source=preprocess(options, preprocessor)})
      end,
      catch = function(e)
        return {code=, source=options.source, tips={}, errors={e}}
      end
    }
  elseif preprocessLang then
    return {code=, source=options.source, tips={}, errors={}}
  else
    return doCompileTemplate(options)
  end
end

function doCompileTemplate()
  local errors = {}
  local nodeTransforms = {}
  if isObject(transformAssetUrls) then
    local assetOptions = normalizeOptions(transformAssetUrls)
    nodeTransforms = {createAssetUrlTransformWithOptions(assetOptions), createSrcsetTransformWithOptions(assetOptions)}
  elseif transformAssetUrls ~= false then
    nodeTransforms = {transformAssetUrl, transformSrcset}
  end
  local  = compiler:compile(source, {mode='module', prefixIdentifiers=true, hoistStatic=true, cacheHandlers=true, ..., nodeTransforms=table.merge(nodeTransforms, compilerOptions.nodeTransforms or {}), filename=filename, sourceMap=true, onError=function(e)
    table.insert(errors, e)
  end
  })
  if inMap then
    if map then
      map = mapLines(inMap, map)
    end
    if #errors then
      patchErrors(errors, source, inMap)
    end
  end
  return {code=code, source=source, errors=errors, tips={}, map=map}
end

function mapLines(oldMap, newMap)
  if not oldMap then
    return newMap
  end
  if not newMap then
    return oldMap
  end
  local oldMapConsumer = SourceMapConsumer(oldMap)
  local newMapConsumer = SourceMapConsumer(newMap)
  local mergedMapGenerator = SourceMapGenerator()
  newMapConsumer:eachMapping(function(m)
    if m.originalLine == nil then
      return
    end
    local origPosInOldMap = oldMapConsumer:originalPositionFor({line=m.originalLine, column=m.originalColumn})
    if origPosInOldMap.source == nil then
      return
    end
    mergedMapGenerator:addMapping({generated={line=m.generatedLine, column=m.generatedColumn}, original={line=origPosInOldMap.line, column=m.originalColumn}, source=origPosInOldMap.source, name=origPosInOldMap.name})
  end
  )
  local generator = mergedMapGenerator
  oldMapConsumer.sources:forEach(function(sourceFile)
    generator._sources:add(sourceFile)
    local sourceContent = oldMapConsumer:sourceContentFor(sourceFile)
    if sourceContent ~= nil then
      mergedMapGenerator:setSourceContent(sourceFile, sourceContent)
    end
  end
  )
  generator._sourceRoot = oldMap.sourceRoot
  generator._file = oldMap.file
  return generator:toJSON()
end

function patchErrors(errors, source, inMap)
  local originalSource = ()[0+1]
  local offset = originalSource:find(source)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  local lineOffset = #originalSource:slice(0, offset):split(/\r?\n/) - 1
  errors:forEach(function(err)
    if err.loc then
      err.loc.start.line = err.loc.start.line + lineOffset
      err.loc.start.offset = err.loc.start.offset + offset
      if err.loc.tsvar_end ~= err.loc.start then
        err.loc.tsvar_end.line = err.loc.tsvar_end.line + lineOffset
        err.loc.tsvar_end.offset = err.loc.tsvar_end.offset + offset
      end
    end
  end
  )
end
