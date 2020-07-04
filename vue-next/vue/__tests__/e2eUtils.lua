
local E2E_TIMEOUT = 30 * 1000
-- [ts2lua]lua中0和空字符串也是true，此处process.env.CI需要确认
local puppeteerOptions = (process.env.CI and {{args={'--no-sandbox', '--disable-setuid-sandbox'}}} or {{}})[1]
function setupPuppeteer()
  local browser = nil
  local page = nil
  beforeEach(function()
    browser = 
    page = 
    page:on('console', function(e)
      if e:type() == 'error' then
        local err = e:args()[0+1]
        console:error(err._remoteObject.description)
      end
    end
    )
  end
  )
  afterEach(function()
    
  end
  )
  function click(selector, options) end
  function count(selector)
    return #()
  end
  
  function text(selector)
    return 
  end
  
  function value(selector)
    return 
  end
  
  function html(selector)
    return 
  end
  
  function classList(selector)
    return 
  end
  
  function children(selector)
    return 
  end
  
  function isVisible(selector)
    local display = nil
    return display ~= 'none'
  end
  
  function isChecked(selector)
    return 
  end
  
  function isFocused(selector)
    return 
  end
  
  function setValue(selector, value) end
  function typeValue(selector, value)
    local el = nil
  end
  
  function enterValue(selector, value)
    local el = nil
  end
  
  function clearValue(selector)
    return 
  end
  
  function timeout(time)
    return page:evaluate(function(time)
      return Promise(function(r)
        setTimeout(r, time)
      end
      )
    end
    , time)
  end
  
  function nextFrame()
    return page:evaluate(function()
      return Promise(function(resolve)
        requestAnimationFrame(function()
          requestAnimationFrame(resolve)
        end
        )
      end
      )
    end
    )
  end
  
  return {page=function()
    page
  end
  , click=click, count=count, text=text, value=value, html=html, classList=classList, children=children, isVisible=isVisible, isChecked=isChecked, isFocused=isFocused, setValue=setValue, typeValue=typeValue, enterValue=enterValue, clearValue=clearValue, timeout=timeout, nextFrame=nextFrame}
end
