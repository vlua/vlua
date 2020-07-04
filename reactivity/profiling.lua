
local supported = nil
local perf = nil
function startMeasure(instance, type)
  if instance.appContext.config.performance and isSupported() then
    perf:mark()
  end
end

function endMeasure(instance, type)
  if instance.appContext.config.performance and isSupported() then
    local startTag = nil
    local endTag = startTag + 
    perf:mark(endTag)
    perf:measure(startTag, endTag)
    perf:clearMarks(startTag)
    perf:clearMarks(endTag)
  end
end

function isSupported()
  if supported ~= undefined then
    return supported
  end
  if type(window) ~= 'undefined' and window.performance then
    supported = true
    perf = window.performance
  else
    supported = false
  end
  return supported
end
