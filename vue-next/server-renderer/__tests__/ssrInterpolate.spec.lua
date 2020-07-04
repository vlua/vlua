require("server-renderer/src/helpers/ssrInterpolate")
require("@vue/shared")

test('ssr: interpolate', function()
  expect(ssrInterpolate(0)):toBe()
  expect(ssrInterpolate()):toBe()
  expect(ssrInterpolate()):toBe()
  expect(ssrInterpolate({1, 2, 3})):toBe(escapeHtml(JSON:stringify({1, 2, 3}, nil, 2)))
  expect(ssrInterpolate({foo=1, bar=})):toBe(escapeHtml(JSON:stringify({foo=1, bar=}, nil, 2)))
end
)