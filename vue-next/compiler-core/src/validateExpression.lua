require("stringutil")
require("trycatch")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")

local prohibitedKeywordRE = '\\b' .. ('do,if,for,let,new,try,var,case,else,with,await,break,catch,class,const,' .. 'super,throw,while,yield,delete,export,import,return,switch,default,' .. 'extends,finally,continue,debugger,function,arguments,typeof,void'):split(','):join('\\b|\\b') .. '\\b'
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local stripStringRE = /'(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*"|`(?:[^`\\]|\\.)*\$\{|\}(?:[^`\\]|\\.)*`|`(?:[^`\\]|\\.)*`/g
function validateBrowserExpression(node, context, asParams, asRawStatements)
  if asParams == nil then
    asParams=false
  end
  if asRawStatements == nil then
    asRawStatements=false
  end
  local exp = node.content
  if not exp:trim() then
    return
  end
  try_catch{
    main = function()
      -- [ts2lua]lua中0和空字符串也是true，此处asRawStatements需要确认
      Function((asRawStatements and {} or {})[1])
    end,
    catch = function(e)
      local message = e.message
      local keywordMatch = exp:gsub(stripStringRE, ''):match(prohibitedKeywordRE)
      if keywordMatch then
        message = 
      end
      context:onError(createCompilerError(ErrorCodes.X_INVALID_EXPRESSION, node.loc, undefined, message))
    end
  }
end
