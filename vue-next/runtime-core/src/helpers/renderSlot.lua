require("runtime-core/src/vnode")
require("@vue/shared/PatchFlags")
require("runtime-core/src/warning")

function renderSlot(slots, name, props, fallback)
  if props == nil then
    props={}
  end
  -- [ts2lua]slots下标访问可能不正确
  local slot = slots[name]
  if (__DEV__ and slot) and #slot > 1 then
    warn( +  + )
    slot = function()
      {}
    end
    
  
  end
  -- [ts2lua]lua中0和空字符串也是true，此处fallback需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处slot需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处slots._需要确认
  return openBlock(); createBlock(Fragment, {key=props.key}, (slot and {slot(props)} or {(fallback and {fallback()} or {{}})[1]})[1], (slots._ and {PatchFlags.STABLE_FRAGMENT} or {PatchFlags.BAIL})[1])
end
