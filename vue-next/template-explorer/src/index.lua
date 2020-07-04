require("trycatch")
require("@vue/compiler-dom")
require("@vue/compiler-ssr")
require("template-explorer/src/options")
require("@vue/runtime-dom")
require("source-map")
local ssrCompile = compile

global = {}

window.init = function()
  local monaco = window.monaco
  local persistedState = JSON:parse((decodeURIComponent(window.location.hash:slice(1)) or localStorage:getItem('state')) or )
  ssrMode.value = persistedState.ssr
  Object:assign(compilerOptions, persistedState.options)
  local lastSuccessfulCode = nil
  local lastSuccessfulMap = undefined
  function compileCode(source)
    console:clear()
    try_catch{
      main = function()
        local errors = {}
        -- [ts2lua]lua中0和空字符串也是true，此处ssrMode.value需要确认
        local compileFn = (ssrMode.value and {ssrCompile} or {compile})[1]
        local start = performance:now()
        local  = compileFn(source, {filename='template.vue', ..., sourceMap=true, onError=function(err)
          table.insert(errors, err)
        end
        })
        print()
        monaco.editor:setModelMarkers(errors:filter(function(e)
          e.loc
        end
        ):map(formatError))
        print(ast)
        lastSuccessfulCode = code + 
        lastSuccessfulMap = SourceMapConsumer()
        ():computeColumnSpans()
      end,
      catch = function(e)
        lastSuccessfulCode = 
        console:error(e)
      end
    }
    return lastSuccessfulCode
  end
  
  function formatError(err)
    local loc = nil
    return {severity=monaco.MarkerSeverity.Error, startLineNumber=loc.start.line, startColumn=loc.start.column, endLineNumber=loc.tsvar_end.line, endColumn=loc.tsvar_end.column, message=, code=String(err.code)}
  end
  
  function reCompile()
    local src = editor:getValue()
    local state = JSON:stringify({src=src, ssr=ssrMode.value, options=compilerOptions})
    localStorage:setItem('state', state)
    window.location.hash = encodeURIComponent(state)
    local res = compileCode(src)
    if res then
      output:setValue(res)
    end
  end
  
  local sharedEditorOptions = {theme='vs-dark', fontSize=14, wordWrap='on', scrollBeyondLastLine=false, renderWhitespace='selection', contextmenu=false, minimap={enabled=false}}
  local editor = monaco.editor:create({value=persistedState.src or , language='html', ...})
  ():updateOptions({tabSize=2})
  local output = monaco.editor:create({value='', language='javascript', readOnly=true, ...})
  ():updateOptions({tabSize=2})
  window:addEventListener('resize', function()
    editor:layout()
    output:layout()
  end
  )
  editor:onDidChangeModelContent(debounce(reCompile))
  local prevOutputDecos = {}
  function clearOutputDecos()
    prevOutputDecos = output:deltaDecorations(prevOutputDecos, {})
  end
  
  editor:onDidChangeCursorPosition(debounce(function(e)
    clearEditorDecos()
    if lastSuccessfulMap then
      local pos = lastSuccessfulMap:generatedPositionFor({source='template.vue', line=e.position.lineNumber, column=e.position.column - 1})
      if pos.line ~= nil and pos.column ~= nil then
        -- [ts2lua]lua中0和空字符串也是true，此处pos.lastColumn需要确认
        prevOutputDecos = output:deltaDecorations(prevOutputDecos, {{range=monaco.Range(pos.line, pos.column + 1, pos.line, (pos.lastColumn and {pos.lastColumn + 2} or {pos.column + 2})[1]), options={inlineClassName=}}})
        output:revealPositionInCenter({lineNumber=pos.line, column=pos.column + 1})
      else
        clearOutputDecos()
      end
    end
  end
  , 100))
  local previousEditorDecos = {}
  function clearEditorDecos()
    previousEditorDecos = editor:deltaDecorations(previousEditorDecos, {})
  end
  
  output:onDidChangeCursorPosition(debounce(function(e)
    clearOutputDecos()
    if lastSuccessfulMap then
      local pos = lastSuccessfulMap:originalPositionFor({line=e.position.lineNumber, column=e.position.column - 1})
      if (pos.line ~= nil and pos.column ~= nil) and not (pos.line == 1 and pos.column == 0) then
        local translatedPos = {column=pos.column + 1, lineNumber=pos.line}
        previousEditorDecos = editor:deltaDecorations(previousEditorDecos, {{range=monaco.Range(pos.line, pos.column + 1, pos.line, pos.column + 1), options={isWholeLine=true, className=}}})
        editor:revealPositionInCenter(translatedPos)
      else
        clearEditorDecos()
      end
    end
  end
  , 100))
  initOptions()
  watchEffect(reCompile)
end

function debounce(fn, delay)
  if delay == nil then
    delay=300
  end
  local prevTimer = nil
  return function(...)
    if prevTimer then
      clearTimeout(prevTimer)
    end
    prevTimer = window:setTimeout(function()
      fn(...)
      prevTimer = nil
    end
    , delay)
  end
  

end
