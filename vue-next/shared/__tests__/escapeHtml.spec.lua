require("shared/src")

test('ssr: escapeHTML', function()
  expect(escapeHtml()):toBe()
  expect(escapeHtml(true)):toBe()
  expect(escapeHtml(false)):toBe()
  expect(escapeHtml()):toBe()
  expect(escapeHtml()):toBe()
  expect(escapeHtml()):toBe()
  expect(escapeHtml()):toBe()
end
)