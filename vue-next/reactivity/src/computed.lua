require("reactivity/src/effect")
require("reactivity/src/operations/TriggerOpTypes")
require("reactivity/src/operations/TrackOpTypes")
require("@vue/shared")
-- [ts2lua]请手动处理DeclareFunction


-- [ts2lua]请手动处理DeclareFunction

function computed(getterOrOptions)
  local getter = nil
  local setter = nil
  if isFunction(getterOrOptions) then
    getter = getterOrOptions
    setter = (__DEV__ and {function()
      console:warn('Write operation failed: computed value is readonly')
    end
    -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
    } or {NOOP})[1]
  else
    getter = getterOrOptions.get
    setter = getterOrOptions.set
  end
  local dirty = true
  local value = nil
  local computed = nil
  local runner = effect(getter, {lazy=true, scheduler=function()
    if not dirty then
      dirty = true
      trigger(computed, TriggerOpTypes.SET, 'value')
    end
  end
  })
  computed = {__v_isRef=true, effect=runner, value=function()
    if dirty then
      value = runner()
      dirty = false
    end
    track(computed, TrackOpTypes.GET, 'value')
    return value
  end
  , value=function(newValue)
    setter(newValue)
  end
  }
  return computed
end
