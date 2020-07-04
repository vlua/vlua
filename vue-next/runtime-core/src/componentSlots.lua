require("runtime-core/src/component")
require("runtime-core/src/vnode")
require("@vue/shared")
require("@vue/shared/ShapeFlags")
require("@vue/shared/PatchFlags")
require("runtime-core/src/warning")
require("runtime-core/src/components/KeepAlive")
require("runtime-core/src/helpers/withRenderContext")
require("runtime-core/src/hmr")

local isInternalKey = function(key)
  key[0+1] == '_' or key == '$stable'
end

local normalizeSlotValue = function(value)
  -- [ts2lua]lua中0和空字符串也是true，此处isArray(value)需要确认
  (isArray(value) and {value:map(normalizeVNode)} or {{normalizeVNode(value)}})[1]
end

local normalizeSlot = function(key, rawSlot, ctx)
  withCtx(function(props)
    if __DEV__ and currentInstance then
      warn( +  + )
    end
    return normalizeSlotValue(rawSlot(props))
  end
  , ctx)
end

local normalizeObjectSlots = function(rawSlots, slots)
  local ctx = rawSlots._ctx
  for key in pairs(rawSlots) do
    if isInternalKey(key) then
      break
    end
    -- [ts2lua]rawSlots下标访问可能不正确
    local value = rawSlots[key]
    if isFunction(value) then
      -- [ts2lua]slots下标访问可能不正确
      slots[key] = normalizeSlot(key, value, ctx)
    elseif value ~= nil then
      if __DEV__ then
        warn( + )
      end
      local normalized = normalizeSlotValue(value)
      -- [ts2lua]slots下标访问可能不正确
      slots[key] = function()
        normalized
      end
      
    
    end
  end
end

local normalizeVNodeSlots = function(instance, children)
  if __DEV__ and not isKeepAlive(instance.vnode) then
    warn( + )
  end
  local normalized = normalizeSlotValue(children)
  instance.slots.default = function()
    normalized
  end
  

end

local initSlots = function(instance, children)
  if instance.vnode.shapeFlag & ShapeFlags.SLOTS_CHILDREN then
    if children._ == 1 then
      instance.slots = children
      def(children, '_', 1)
    else
      normalizeObjectSlots(children, instance.slots)
    end
  else
    instance.slots = {}
    if children then
      normalizeVNodeSlots(instance, children)
    end
  end
  def(instance.slots, InternalObjectKey, 1)
end

local updateSlots = function(instance, children)
  local  = instance
  local needDeletionCheck = true
  local deletionComparisonTarget = EMPTY_OBJ
  if vnode.shapeFlag & ShapeFlags.SLOTS_CHILDREN then
    if children._ == 1 then
      if __DEV__ and isHmrUpdating then
        extend(slots, children)
      elseif not (vnode.patchFlag & PatchFlags.DYNAMIC_SLOTS) then
        needDeletionCheck = false
      else
        extend(slots, children)
      end
    else
      needDeletionCheck = not children.tsvar_stable
      normalizeObjectSlots(children, slots)
    end
    deletionComparisonTarget = children
  elseif children then
    normalizeVNodeSlots(instance, children)
    deletionComparisonTarget = {default=1}
  end
  if needDeletionCheck then
    for key in pairs(slots) do
      if not isInternalKey(key) and not (deletionComparisonTarget[key]) then
        -- [ts2lua]slots下标访问可能不正确
        slots[key] = nil
      end
    end
  end
end
