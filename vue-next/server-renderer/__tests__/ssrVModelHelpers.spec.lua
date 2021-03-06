require("server-renderer/src/helpers/ssrVModelHelpers")

describe('ssr: v-model helpers', function()
  test('ssrRenderDynamicModel', function()
    expect(ssrRenderDynamicModel(nil, 'foo', nil)):toBe()
    expect(ssrRenderDynamicModel('text', 'foo', nil)):toBe()
    expect(ssrRenderDynamicModel('email', 'foo', nil)):toBe()
    expect(ssrRenderDynamicModel('checkbox', true, nil)):toBe()
    expect(ssrRenderDynamicModel('checkbox', false, nil)):toBe()
    expect(ssrRenderDynamicModel('checkbox', {1}, '1')):toBe()
    expect(ssrRenderDynamicModel('checkbox', {1}, 1)):toBe()
    expect(ssrRenderDynamicModel('checkbox', {1}, 0)):toBe()
    expect(ssrRenderDynamicModel('radio', 'foo', 'foo')):toBe()
    expect(ssrRenderDynamicModel('radio', 1, '1')):toBe()
    expect(ssrRenderDynamicModel('radio', 1, 0)):toBe()
  end
  )
  test('ssrGetDynamicModelProps', function()
    expect(ssrGetDynamicModelProps({}, 'foo')):toMatchObject({value='foo'})
    expect(ssrGetDynamicModelProps({type='text'}, 'foo')):toMatchObject({value='foo'})
    expect(ssrGetDynamicModelProps({type='email'}, 'foo')):toMatchObject({value='foo'})
    expect(ssrGetDynamicModelProps({type='checkbox'}, true)):toMatchObject({checked=true})
    expect(ssrGetDynamicModelProps({type='checkbox'}, false)):toBe(nil)
    expect(ssrGetDynamicModelProps({type='checkbox', value='1'}, {1})):toMatchObject({checked=true})
    expect(ssrGetDynamicModelProps({type='checkbox', value=1}, {1})):toMatchObject({checked=true})
    expect(ssrGetDynamicModelProps({type='checkbox', value=0}, {1})):toBe(nil)
    expect(ssrGetDynamicModelProps({type='radio', value='foo'}, 'foo')):toMatchObject({checked=true})
    expect(ssrGetDynamicModelProps({type='radio', value='1'}, 1)):toMatchObject({checked=true})
    expect(ssrGetDynamicModelProps({type='radio', value=0}, 1)):toBe(nil)
  end
  )
end
)