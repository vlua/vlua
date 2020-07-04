require("vue")

describe('ssr: attr fallthrough', function()
  test('basic', function()
    local Child = {template=}
    local Parent = {components={Child=Child}, template=}
    local app = createApp(Parent)
    expect():toBe()
  end
  )
  test('with v-if', function()
    local Child = {props={'ok'}, template=}
    local Parent = {props={'ok'}, components={Child=Child}, template=}
    expect():toBe()
    expect():toBe()
  end
  )
  test('with v-model', function()
    local Child = {props={'text'}, template=}
    local Parent = {components={Child=Child}, template=}
    expect():toBe()
  end
  )
  test('with v-bind', function()
    local Child = {props={'obj'}, template=}
    local Parent = {components={Child=Child}, template=}
    expect():toBe()
  end
  )
  test('nested fallthrough', function()
    local Child = {props={'id'}, template=}
    local Parent = {components={Child=Child}, template=}
    local app = createApp(Parent, {class='baz'})
    expect():toBe()
  end
  )
end
)