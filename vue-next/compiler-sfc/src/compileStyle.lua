require("trycatch")
require("postcss")
require("compiler-sfc/src/stylePluginTrim")
require("compiler-sfc/src/stylePluginScoped")
require("compiler-sfc/src/stylePreprocessors")

function compileStyle(options)
  return doCompileStyle({..., isAsync=false})
end

function compileStyleAsync(options)
  return doCompileStyle({..., isAsync=true})
end

function doCompileStyle(options)
  local  = options
  -- [ts2lua]processors下标访问可能不正确
  local preprocessor = preprocessLang and processors[preprocessLang]
  local preProcessedSource = preprocessor and preprocess(options, preprocessor)
  -- [ts2lua]lua中0和空字符串也是true，此处preProcessedSource需要确认
  local map = (preProcessedSource and {preProcessedSource.map} or {options.map})[1]
  -- [ts2lua]lua中0和空字符串也是true，此处preProcessedSource需要确认
  local source = (preProcessedSource and {preProcessedSource.code} or {options.source})[1]
  local plugins = (postcssPlugins or {}):slice()
  if trim then
    table.insert(plugins, trimPlugin())
  end
  if scoped then
    table.insert(plugins, scopedPlugin(id))
  end
  local cssModules = nil
  if modules then
    if __GLOBAL__ or __ESM_BROWSER__ then
      error(Error('[@vue/compiler-sfc] `modules` option is not supported in the browser build.'))
    end
    if not options.isAsync then
      error(Error('[@vue/compiler-sfc] `modules` option can only be used with compileStyleAsync().'))
    end
    table.insert(plugins, require('postcss-modules')({..., getJSON=function(_cssFileName, json)
      cssModules = json
    end
    }))
  end
  local postCSSOptions = {..., to=filename, from=filename}
  if map then
    postCSSOptions.map = {inline=false, annotation=false, prev=map}
  end
  local result = nil
  local code = nil
  local outMap = nil
  local errors = {}
  if preProcessedSource and #preProcessedSource.errors then
    table.insert(errors, ...)
  end
  try_catch{
    main = function()
      result = postcss(plugins):process(source, postCSSOptions)
      if options.isAsync then
        return result:tsvar_then(function(result)
          {code=result.css or '', map=result.map and result.map:toJSON(), errors=errors, modules=cssModules, rawResult=result}
        end
        ):catch(function(error)
          {code='', map=undefined, errors={..., error}, rawResult=undefined}
        end
        )
      end
      code = result.css
      outMap = result.map
    end,
    catch = function(e)
      table.insert(errors, e)
    end
  }
  return {code=code or , map=outMap and outMap:toJSON(), errors=errors, rawResult=result}
end

function preprocess(options, preprocessor)
  if (__ESM_BROWSER__ or __GLOBAL__) and not options.preprocessCustomRequire then
    error(Error( +  + ))
  end
  return preprocessor:render(options.source, options.map, {filename=options.filename, ...}, options.preprocessCustomRequire)
end
