require("@vue/compiler-core")
require("@vue/compiler-core/ErrorCodes")
require("compiler-dom/src/errors/DOMErrorCodes")

function createDOMCompilerError(code, loc)
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__ or not __BROWSER__需要确认
  return createCompilerError(code, loc, (__DEV__ or not __BROWSER__ and {DOMErrorMessages} or {undefined})[1])
end

local DOMErrorMessages = {DOMErrorCodes.X_V_HTML_NO_EXPRESSION=, DOMErrorCodes.X_V_HTML_WITH_CHILDREN=, DOMErrorCodes.X_V_TEXT_NO_EXPRESSION=, DOMErrorCodes.X_V_TEXT_WITH_CHILDREN=, DOMErrorCodes.X_V_MODEL_ON_INVALID_ELEMENT=, DOMErrorCodes.X_V_MODEL_ARG_ON_ELEMENT=, DOMErrorCodes.X_V_MODEL_ON_FILE_INPUT_ELEMENT=, DOMErrorCodes.X_V_MODEL_UNNECESSARY_VALUE=, DOMErrorCodes.X_V_SHOW_NO_EXPRESSION=, DOMErrorCodes.X_TRANSITION_INVALID_CHILDREN=}