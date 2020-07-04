global = {}
jest = {}

local mockError = function()
  mockWarn(true)
end

function mockWarn(asError)
  if asError == nil then
    asError=false
  end
  expect:extend({toHaveBeenWarned=function(received)
    asserted:add(received)
    local passed = warn.mock.calls:some(function(args)
      args[0+1]:find(received) > -1
    end
    )
    if passed then
      return {pass=true, message=function()
        
      end
      }
    else
      local msgs = warn.mock.calls:map(function(args)
        args[0+1]
      end
      ):join('\n - ')
      return {pass=false, message=function()
        
      end
      }
    end
  end
  , toHaveBeenWarnedLast=function(received)
    asserted:add(received)
    -- [ts2lua]warn.mock.calls下标访问可能不正确
    local passed = warn.mock.calls[#warn.mock.calls - 1][0+1]:find(received) > -1
    if passed then
      return {pass=true, message=function()
        
      end
      }
    else
      local msgs = warn.mock.calls:map(function(args)
        args[0+1]
      end
      ):join('\n - ')
      return {pass=false, message=function()
        
      end
      }
    end
  end
  , toHaveBeenWarnedTimes=function(received, n)
    asserted:add(received)
    local found = 0
    warn.mock.calls:forEach(function(args)
      if args[0+1]:find(received) > -1 then
        found=found+1
      end
    end
    )
    if found == n then
      return {pass=true, message=function()
        
      end
      }
    else
      return {pass=false, message=function()
        
      end
      }
    end
  end
  })
  local warn = nil
  local asserted = Set()
  beforeEach(function()
    asserted:clear()
    -- [ts2lua]lua中0和空字符串也是true，此处asError需要确认
    warn = jest:spyOn(console, (asError and {'error'} or {'warn'})[1])
    warn:mockImplementation(function()
      
    end
    )
  end
  )
  afterEach(function()
    local assertedArray = Array:from(asserted)
    local nonAssertedWarnings = warn.mock.calls:map(function(args)
      args[0+1]
    end
    ):filter(function(received)
      return not assertedArray:some(function(assertedMsg)
        return received:find(assertedMsg) > -1
      end
      )
    end
    )
    warn:mockRestore()
    if #nonAssertedWarnings then
      nonAssertedWarnings:forEach(function(warning)
        console:warn(warning)
      end
      )
      error(Error())
    end
  end
  )
end
