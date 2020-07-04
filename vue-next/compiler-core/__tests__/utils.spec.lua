require("compiler-core/src/utils")

function p(line, column, offset)
  return {column=column, line=line, offset=offset}
end

describe('advancePositionWithClone', function()
  test('same line', function()
    local pos = p(1, 1, 0)
    local newPos = advancePositionWithClone(pos, 'foo\nbar', 2)
    expect(newPos.column):toBe(3)
    expect(newPos.line):toBe(1)
    expect(newPos.offset):toBe(2)
  end
  )
  test('same line', function()
    local pos = p(1, 1, 0)
    local newPos = advancePositionWithClone(pos, 'foo\nbar', 4)
    expect(newPos.column):toBe(1)
    expect(newPos.line):toBe(2)
    expect(newPos.offset):toBe(4)
  end
  )
  test('multiple lines', function()
    local pos = p(1, 1, 0)
    local newPos = advancePositionWithClone(pos, 'foo\nbar\nbaz', 10)
    expect(newPos.column):toBe(3)
    expect(newPos.line):toBe(3)
    expect(newPos.offset):toBe(10)
  end
  )
end
)
describe('getInnerRange', function()
  local loc1 = {source='foo\nbar\nbaz', start=p(1, 1, 0), tsvar_end=p(3, 3, 11)}
  test('at start', function()
    local loc2 = getInnerRange(loc1, 0, 4)
    expect(loc2.start):toEqual(loc1.start)
    expect(loc2.tsvar_end.column):toBe(1)
    expect(loc2.tsvar_end.line):toBe(2)
    expect(loc2.tsvar_end.offset):toBe(4)
  end
  )
  test('at end', function()
    local loc2 = getInnerRange(loc1, 4)
    expect(loc2.start.column):toBe(1)
    expect(loc2.start.line):toBe(2)
    expect(loc2.start.offset):toBe(4)
    expect(loc2.tsvar_end):toEqual(loc1.tsvar_end)
  end
  )
  test('in between', function()
    local loc2 = getInnerRange(loc1, 4, 3)
    expect(loc2.start.column):toBe(1)
    expect(loc2.start.line):toBe(2)
    expect(loc2.start.offset):toBe(4)
    expect(loc2.tsvar_end.column):toBe(4)
    expect(loc2.tsvar_end.line):toBe(2)
    expect(loc2.tsvar_end.offset):toBe(7)
  end
  )
end
)