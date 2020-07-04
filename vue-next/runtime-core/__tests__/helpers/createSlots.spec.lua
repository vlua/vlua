require("runtime-core/src/helpers/createSlots")

describe('createSlot', function()
  local slot = function()
    {}
  end
  
  local record = nil
  beforeEach(function()
    record = {}
  end
  )
  it('should return a slot', function()
    local dynamicSlot = {{name='descriptor', fn=slot}}
    local actual = createSlots(record, dynamicSlot)
    expect(actual):toEqual({descriptor=slot})
  end
  )
  it('should add all slots to the record', function()
    local dynamicSlot = {{name='descriptor', fn=slot}, {name='descriptor2', fn=slot}}
    local actual = createSlots(record, dynamicSlot)
    expect(actual):toEqual({descriptor=slot, descriptor2=slot})
  end
  )
  it('should add slot to the record when given slot is an array', function()
    local dynamicSlot = {{name='descriptor', fn=slot}, {{name='descriptor2', fn=slot}}}
    local actual = createSlots(record, dynamicSlot)
    expect(actual):toEqual({descriptor=slot, descriptor2=slot})
  end
  )
  it('should add each slot to the record when given slot is an array', function()
    local dynamicSlot = {{name='descriptor', fn=slot}, {{name='descriptor2', fn=slot}, {name='descriptor3', fn=slot}}}
    local actual = createSlots(record, dynamicSlot)
    expect(actual):toEqual({descriptor=slot, descriptor2=slot, descriptor3=slot})
  end
  )
end
)