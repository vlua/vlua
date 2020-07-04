require("runtime-test/src/nodeOps")
require("runtime-test/src/nodeOps/NodeOpTypes")
require("@vue/shared")

function patchProp(el, key, prevValue, nextValue)
  logNodeOp({type=NodeOpTypes.PATCH, targetNode=el, propKey=key, propPrevValue=prevValue, propNextValue=nextValue})
  -- [ts2lua]el.props下标访问可能不正确
  el.props[key] = nextValue
  if isOn(key) then
    local event = key:slice(2):toLowerCase()
    -- [ts2lua](el.eventListeners or (el.eventListeners = {}))下标访问可能不正确
    (el.eventListeners or (el.eventListeners = {}))[event] = nextValue
  end
end
