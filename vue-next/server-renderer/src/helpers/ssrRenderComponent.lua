require("vue")
require("server-renderer/src/render")

function ssrRenderComponent(comp, props, children, parentComponent)
  if props == nil then
    props=nil
  end
  if children == nil then
    children=nil
  end
  if parentComponent == nil then
    parentComponent=nil
  end
  return renderComponentVNode(createVNode(comp, props, children), parentComponent)
end
