require("compiler-core/src/parse")
require("compiler-core/src/transform")
require("compiler-core/src/codegen")
require("@vue/shared")
require("compiler-core/src/transforms/vIf")
require("compiler-core/src/transforms/vFor")
require("compiler-core/src/transforms/transformSlotOutlet")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/transforms/vOn")
require("compiler-core/src/transforms/vBind")
require("compiler-core/src/transforms/vSlot")
require("compiler-core/src/transforms/transformText")
require("compiler-core/src/transforms/vOnce")
require("compiler-core/src/transforms/vModel")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")

function getBaseTransformPreset(prefixIdentifiers)
  return {{transformOnce, transformIf, transformFor, ..., transformSlotOutlet, transformElement, trackSlotScopes, transformText}, {on=transformOn, bind=transformBind, model=transformModel}}
end

function baseCompile(template, options)
  if options == nil then
    options={}
  end
  local onError = options.onError or defaultOnError
  local isModuleMode = options.mode == 'module'
  if __BROWSER__ then
    if options.prefixIdentifiers == true then
      onError(createCompilerError(ErrorCodes.X_PREFIX_ID_NOT_SUPPORTED))
    elseif isModuleMode then
      onError(createCompilerError(ErrorCodes.X_MODULE_MODE_NOT_SUPPORTED))
    end
  end
  local prefixIdentifiers = not __BROWSER__ and (options.prefixIdentifiers == true or isModuleMode)
  if not prefixIdentifiers and options.cacheHandlers then
    onError(createCompilerError(ErrorCodes.X_CACHE_HANDLER_NOT_SUPPORTED))
  end
  if options.scopeId and not isModuleMode then
    onError(createCompilerError(ErrorCodes.X_SCOPE_ID_NOT_SUPPORTED))
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isString(template)需要确认
  local ast = (isString(template) and {baseParse(template, options)} or {template})[1]
  local  = getBaseTransformPreset(prefixIdentifiers)
  transform(ast, extend({}, options, {prefixIdentifiers=prefixIdentifiers, nodeTransforms={..., ...}, directiveTransforms=extend({}, directiveTransforms, options.directiveTransforms or {})}))
  return generate(ast, extend({}, options, {prefixIdentifiers=prefixIdentifiers}))
end
