require("@vue/runtime-test")
require("@vue/runtime-test/NodeTypes")
require("@vue/shared")

mockWarn()
function toSpan(content)
  if type(content) == 'string' then
    return h('span', content:toString())
  else
    return h('span', {key=content}, content:toString())
  end
end

local inner = function(c)
  serializeInner(c)
end

function shuffle(array)
  local currentIndex = #array
  local temporaryValue = nil
  local randomIndex = nil
  while(currentIndex ~= 0)
  do
  randomIndex = Math:floor(Math:random() * currentIndex)
  currentIndex = currentIndex - 1
  -- [ts2lua]array下标访问可能不正确
  temporaryValue = array[currentIndex]
  -- [ts2lua]array下标访问可能不正确
  -- [ts2lua]array下标访问可能不正确
  array[currentIndex] = array[randomIndex]
  -- [ts2lua]array下标访问可能不正确
  array[randomIndex] = temporaryValue
  end
  return array
end

it('should patch previously empty children', function()
  local root = nodeOps:createElement('div')
  render(h('div', {}), root)
  expect(inner(root)):toBe('<div></div>')
  render(h('div', {'hello'}), root)
  expect(inner(root)):toBe('<div>hello</div>')
end
)
it('should patch previously null children', function()
  local root = nodeOps:createElement('div')
  render(h('div'), root)
  expect(inner(root)):toBe('<div></div>')
  render(h('div', {'hello'}), root)
  expect(inner(root)):toBe('<div>hello</div>')
end
)
describe('renderer: keyed children', function()
  local root = nil
  local elm = nil
  local renderChildren = function(arr)
    render(h('div', arr:map(toSpan)), root)
    return root.children[0+1]
  end
  
  beforeEach(function()
    root = nodeOps:createElement('div')
    render(h('div', {id=1}, 'hello'), root)
  end
  )
  test('append', function()
    elm = renderChildren({1})
    expect(#elm.children):toBe(1)
    elm = renderChildren({1, 2, 3})
    expect(#elm.children):toBe(3)
    expect(serialize(elm.children[1+1])):toBe('<span>2</span>')
    expect(serialize(elm.children[2+1])):toBe('<span>3</span>')
  end
  )
  test('prepend', function()
    elm = renderChildren({4, 5})
    expect(#elm.children):toBe(2)
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    expect(elm.children:map(inner)):toEqual({'1', '2', '3', '4', '5'})
  end
  )
  test('insert in middle', function()
    elm = renderChildren({1, 2, 4, 5})
    expect(#elm.children):toBe(4)
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    expect(elm.children:map(inner)):toEqual({'1', '2', '3', '4', '5'})
  end
  )
  test('insert at beginning and end', function()
    elm = renderChildren({2, 3, 4})
    expect(#elm.children):toBe(3)
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    expect(elm.children:map(inner)):toEqual({'1', '2', '3', '4', '5'})
  end
  )
  test('insert to empty parent', function()
    elm = renderChildren({})
    expect(#elm.children):toBe(0)
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    expect(elm.children:map(inner)):toEqual({'1', '2', '3', '4', '5'})
  end
  )
  test('remove all children from parent', function()
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    expect(elm.children:map(inner)):toEqual({'1', '2', '3', '4', '5'})
    render(h('div'), root)
    expect(#elm.children):toBe(0)
  end
  )
  test('remove from beginning', function()
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    elm = renderChildren({3, 4, 5})
    expect(#elm.children):toBe(3)
    expect(elm.children:map(inner)):toEqual({'3', '4', '5'})
  end
  )
  test('remove from end', function()
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    elm = renderChildren({1, 2, 3})
    expect(#elm.children):toBe(3)
    expect(elm.children:map(inner)):toEqual({'1', '2', '3'})
  end
  )
  test('remove from middle', function()
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    elm = renderChildren({1, 2, 4, 5})
    expect(#elm.children):toBe(4)
    expect(elm.children:map(inner)):toEqual({'1', '2', '4', '5'})
  end
  )
  test('moving single child forward', function()
    elm = renderChildren({1, 2, 3, 4})
    expect(#elm.children):toBe(4)
    elm = renderChildren({2, 3, 1, 4})
    expect(#elm.children):toBe(4)
    expect(elm.children:map(inner)):toEqual({'2', '3', '1', '4'})
  end
  )
  test('moving single child backwards', function()
    elm = renderChildren({1, 2, 3, 4})
    expect(#elm.children):toBe(4)
    elm = renderChildren({1, 4, 2, 3})
    expect(#elm.children):toBe(4)
    expect(elm.children:map(inner)):toEqual({'1', '4', '2', '3'})
  end
  )
  test('moving single child to end', function()
    elm = renderChildren({1, 2, 3})
    expect(#elm.children):toBe(3)
    elm = renderChildren({2, 3, 1})
    expect(#elm.children):toBe(3)
    expect(elm.children:map(inner)):toEqual({'2', '3', '1'})
  end
  )
  test('swap first and last', function()
    elm = renderChildren({1, 2, 3, 4})
    expect(#elm.children):toBe(4)
    elm = renderChildren({4, 2, 3, 1})
    expect(#elm.children):toBe(4)
    expect(elm.children:map(inner)):toEqual({'4', '2', '3', '1'})
  end
  )
  test('move to left & replace', function()
    elm = renderChildren({1, 2, 3, 4, 5})
    expect(#elm.children):toBe(5)
    elm = renderChildren({4, 1, 2, 3, 6})
    expect(#elm.children):toBe(5)
    expect(elm.children:map(inner)):toEqual({'4', '1', '2', '3', '6'})
  end
  )
  test('move to left and leaves hold', function()
    elm = renderChildren({1, 4, 5})
    expect(#elm.children):toBe(3)
    elm = renderChildren({4, 6})
    expect(elm.children:map(inner)):toEqual({'4', '6'})
  end
  )
  test('moved and set to undefined element ending at the end', function()
    elm = renderChildren({2, 4, 5})
    expect(#elm.children):toBe(3)
    elm = renderChildren({4, 5, 3})
    expect(#elm.children):toBe(3)
    expect(elm.children:map(inner)):toEqual({'4', '5', '3'})
  end
  )
  test('reverse element', function()
    elm = renderChildren({1, 2, 3, 4, 5, 6, 7, 8})
    expect(#elm.children):toBe(8)
    elm = renderChildren({8, 7, 6, 5, 4, 3, 2, 1})
    expect(elm.children:map(inner)):toEqual({'8', '7', '6', '5', '4', '3', '2', '1'})
  end
  )
  test('something', function()
    elm = renderChildren({0, 1, 2, 3, 4, 5})
    expect(#elm.children):toBe(6)
    elm = renderChildren({4, 3, 2, 1, 5, 0})
    expect(elm.children:map(inner)):toEqual({'4', '3', '2', '1', '5', '0'})
  end
  )
  test('random shuffle', function()
    local elms = 14
    local samples = 5
    local arr = {...}
    local opacities = {}
    function spanNumWithOpacity(n, o)
      return h('span', {key=n, style={opacity=o}}, n:toString())
    end
    
    local n = 0
    repeat
      render(h('span', arr:map(function(n)
        spanNumWithOpacity(n, '1')
      end
      )), root)
      elm = root.children[0+1]
      local i = 0
      repeat
        expect(serializeInner(elm.children[i+1])):toBe(i:toString())
        opacities[i+1] = Math:random():toFixed(5):toString()
        i=i+1
      until not(i < elms)
      local shufArr = shuffle(arr:slice(0))
      render(h('span', arr:map(function(n)
        spanNumWithOpacity(shufArr[n+1], opacities[n+1])
      end
      )), root)
      elm = root.children[0+1]
      local i = 0
      repeat
        expect(serializeInner(elm.children[i+1])):toBe(shufArr[i+1]:toString())
        expect(elm.children[i+1]):toMatchObject({props={style={opacity=opacities[i+1]}}})
        i=i+1
      until not(i < elms)
      n=n+1
    until not(n < samples)
  end
  )
  test('children with the same key but with different tag', function()
    render(h('div', {h('div', {key=1}, 'one'), h('div', {key=2}, 'two'), h('div', {key=3}, 'three'), h('div', {key=4}, 'four')}), root)
    elm = root.children[0+1]
    expect(elm.children:map(function(c)
      c.tag
    end
    )):toEqual({'div', 'div', 'div', 'div'})
    expect(elm.children:map(inner)):toEqual({'one', 'two', 'three', 'four'})
    render(h('div', {h('div', {key=4}, 'four'), h('span', {key=3}, 'three'), h('span', {key=2}, 'two'), h('div', {key=1}, 'one')}), root)
    expect(elm.children:map(function(c)
      c.tag
    end
    )):toEqual({'div', 'span', 'span', 'div'})
    expect(elm.children:map(inner)):toEqual({'four', 'three', 'two', 'one'})
  end
  )
  test('children with the same tag, same key, but one with data and one without data', function()
    render(h('div', {h('div', {class='hi'}, 'one')}), root)
    elm = root.children[0+1]
    expect(elm.children[0+1]):toMatchObject({props={class='hi'}})
    render(h('div', {h('div', 'four')}), root)
    elm = root.children[0+1]
    expect(elm.children[0+1]):toMatchObject({props={class=nil}})
    expect(serialize(elm.children[0+1])):toBe()
  end
  )
  test('should warn with duplicate keys', function()
    renderChildren({1, 2, 3, 4, 5})
    renderChildren({1, 6, 6, 3, 5})
    expect():toHaveBeenWarned()
  end
  )
end
)
describe('renderer: unkeyed children', function()
  local root = nil
  local elm = nil
  local renderChildren = function(arr)
    render(h('div', arr:map(toSpan)), root)
    return root.children[0+1]
  end
  
  beforeEach(function()
    root = nodeOps:createElement('div')
    render(h('div', {id=1}, 'hello'), root)
  end
  )
  test('move a key in non-keyed nodes with a size up', function()
    elm = renderChildren({1, 'a', 'b', 'c'})
    expect(#elm.children):toBe(4)
    expect(elm.children:map(inner)):toEqual({'1', 'a', 'b', 'c'})
    elm = renderChildren({'d', 'a', 'b', 'c', 1, 'e'})
    expect(#elm.children):toBe(6)
    expect(elm.children:map(inner)):toEqual({'d', 'a', 'b', 'c', '1', 'e'})
  end
  )
  test('append elements with updating children without keys', function()
    elm = renderChildren({'hello'})
    expect(elm.children:map(inner)):toEqual({'hello'})
    elm = renderChildren({'hello', 'world'})
    expect(elm.children:map(inner)):toEqual({'hello', 'world'})
  end
  )
  test('unmoved text nodes with updating children without keys', function()
    render(h('div', {'text', h('span', {'hello'})}), root)
    elm = root.children[0+1]
    expect(elm.children[0+1]):toMatchObject({type=NodeTypes.TEXT, text='text'})
    render(h('div', {'text', h('span', {'hello'})}), root)
    elm = root.children[0+1]
    expect(elm.children[0+1]):toMatchObject({type=NodeTypes.TEXT, text='text'})
  end
  )
  test('changing text children with updating children without keys', function()
    render(h('div', {'text', h('span', {'hello'})}), root)
    elm = root.children[0+1]
    expect(elm.children[0+1]):toMatchObject({type=NodeTypes.TEXT, text='text'})
    render(h('div', {'text2', h('span', {'hello'})}), root)
    elm = root.children[0+1]
    expect(elm.children[0+1]):toMatchObject({type=NodeTypes.TEXT, text='text2'})
  end
  )
  test('prepend element with updating children without keys', function()
    render(h('div', {h('span', {'world'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(inner)):toEqual({'world'})
    render(h('div', {h('span', {'hello'}), h('span', {'world'})}), root)
    expect(elm.children:map(inner)):toEqual({'hello', 'world'})
  end
  )
  test('prepend element of different tag type with updating children without keys', function()
    render(h('div', {h('span', {'world'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(inner)):toEqual({'world'})
    render(h('div', {h('div', {'hello'}), h('span', {'world'})}), root)
    expect(elm.children:map(function(c)
      c.tag
    end
    )):toEqual({'div', 'span'})
    expect(elm.children:map(inner)):toEqual({'hello', 'world'})
  end
  )
  test('remove elements with updating children without keys', function()
    render(h('div', {h('span', {'one'}), h('span', {'two'}), h('span', {'three'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(inner)):toEqual({'one', 'two', 'three'})
    render(h('div', {h('span', {'one'}), h('span', {'three'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(inner)):toEqual({'one', 'three'})
  end
  )
  test('remove a single text node with updating children without keys', function()
    render(h('div', {'one'}), root)
    elm = root.children[0+1]
    expect(serializeInner(elm)):toBe('one')
    render(h('div'), root)
    expect(serializeInner(elm)):toBe('')
  end
  )
  test('remove a single text node when children are updated', function()
    render(h('div', {'one'}), root)
    elm = root.children[0+1]
    expect(serializeInner(elm)):toBe('one')
    render(h('div', {h('div', {'two'}), h('span', {'three'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(inner)):toEqual({'two', 'three'})
  end
  )
  test('remove a text node among other elements', function()
    render(h('div', {'one', h('span', {'two'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(function(c)
      serialize(c)
    end
    )):toEqual({'one', '<span>two</span>'})
    render(h('div', {h('div', {'three'})}), root)
    elm = root.children[0+1]
    expect(#elm.children):toBe(1)
    expect(serialize(elm.children[0+1])):toBe('<div>three</div>')
  end
  )
  test('reorder elements', function()
    render(h('div', {h('span', {'one'}), h('div', {'two'}), h('b', {'three'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(inner)):toEqual({'one', 'two', 'three'})
    render(h('div', {h('b', {'three'}), h('div', {'two'}), h('span', {'one'})}), root)
    elm = root.children[0+1]
    expect(elm.children:map(inner)):toEqual({'three', 'two', 'one'})
  end
  )
  test('should not de-opt when both head and tail change', function()
    render(h('div', {nil, h('div'), nil}), root)
    elm = root.children[0+1]
    local original = elm.children[1+1]
    render(h('div', {h('p'), h('div'), h('p')}), root)
    elm = root.children[0+1]
    local postPatch = elm.children[1+1]
    expect(postPatch):toBe(original)
  end
  )
end
)