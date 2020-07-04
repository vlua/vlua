require("@vue/runtime-core")
require("runtime-test/src/nodeOps")
require("runtime-test/src/patchProp")
require("runtime-test/src/serialize")
require("@vue/shared")

local  = createRenderer(extend({patchProp=patchProp}, nodeOps))
local render = baseRender
local createApp = baseCreateApp
function renderToString(vnode)
  local root = nodeOps:createElement('div')
  render(vnode, root)
  return serializeInner(root)
end
