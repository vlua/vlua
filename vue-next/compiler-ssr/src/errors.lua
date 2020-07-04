require("@vue/compiler-dom")
require("@vue/compiler-dom/DOMErrorCodes")
require("compiler-ssr/src/errors/SSRErrorCodes")

function createSSRCompilerError(code, loc)
  return createCompilerError(code, loc, SSRErrorMessages)
end

local SSRErrorMessages = {SSRErrorCodes.X_SSR_CUSTOM_DIRECTIVE_NO_TRANSFORM=, SSRErrorCodes.X_SSR_UNSAFE_ATTR_NAME=, SSRErrorCodes.X_SSR_NO_TELEPORT_TARGET=, SSRErrorCodes.X_SSR_INVALID_AST_NODE=}