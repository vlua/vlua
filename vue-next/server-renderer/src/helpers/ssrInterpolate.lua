require("@vue/shared")

function ssrInterpolate(value)
  return escapeHtml(toDisplayString(value))
end
