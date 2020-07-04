require("trycatch")
require("runtime-core/src/scheduler")
require("@vue/shared")

local isHmrUpdating = false
local hmrDirtyComponents = Set()
if __DEV__ then
  -- [ts2lua]lua中0和空字符串也是true，此处type(window) ~= 'undefined'需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处type(self) ~= 'undefined'需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处type(global) ~= 'undefined'需要确认
  local globalObject = (type(global) ~= 'undefined' and {global} or {(type(self) ~= 'undefined' and {self} or {(type(window) ~= 'undefined' and {window} or {{}})[1]})[1]})[1]
  globalObject.__VUE_HMR_RUNTIME__ = {createRecord=tryWrap(createRecord), rerender=tryWrap(rerender), reload=tryWrap(reload)}
end
local map = Map()
function registerHMR(instance)
  local id = nil
  local record = map:get(id)
  if not record then
    createRecord(id)
    record = 
  end
  record:add(instance)
end

function unregisterHMR(instance)
  ():delete(instance)
end

function createRecord(id)
  if map:has(id) then
    return false
  end
  map:set(id, Set())
  return true
end

function rerender(id, newRender)
  local record = map:get(id)
  if not record then
    return
  end
  Array:from(record):forEach(function(instance)
    if newRender then
      instance.render = newRender
    end
    instance.renderCache = {}
    isHmrUpdating = true
    instance:update()
    isHmrUpdating = false
  end
  )
end

function reload(id, newComp)
  local record = map:get(id)
  if not record then
    return
  end
  Array:from(record):forEach(function(instance)
    local comp = instance.type
    if not hmrDirtyComponents:has(comp) then
      extend(comp, newComp)
      for key in pairs(comp) do
        if not (newComp[key]) then
          -- [ts2lua]comp下标访问可能不正确
          comp[key] = nil
        end
      end
      hmrDirtyComponents:add(comp)
      queuePostFlushCb(function()
        hmrDirtyComponents:delete(comp)
      end
      )
    end
    if instance.parent then
      queueJob(instance.parent.update)
    elseif instance.appContext.reload then
      instance.appContext:reload()
    elseif type(window) ~= 'undefined' then
      window.location:reload()
    else
      console:warn('[HMR] Root or manually mounted instance modified. Full reload required.')
    end
  end
  )
end

function tryWrap(fn)
  return function(id, arg)
    try_catch{
      main = function()
        return fn(id, arg)
      end,
      catch = function(e)
        console:error(e)
        console:warn( + )
      end
    }
  end
  

end
