require("@vue/shared")

function createSlots(slots, dynamicSlots)
  local i = 0
  repeat
    local slot = dynamicSlots[i+1]
    if isArray(slot) then
      local j = 0
      repeat
        -- [ts2lua]slots下标访问可能不正确
        slots[slot[j+1].name] = slot[j+1].fn
        j=j+1
      until not(j < #slot)
    elseif slot then
      -- [ts2lua]slots下标访问可能不正确
      slots[slot.name] = slot.fn
    end
    i=i+1
  until not(i < #dynamicSlots)
  return slots
end
