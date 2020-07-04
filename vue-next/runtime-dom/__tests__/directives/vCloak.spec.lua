require("@vue/runtime-dom")

describe('vCloak', function()
  test('should be removed after compile', function()
    local root = document:createElement('div')
    root:setAttribute('v-cloak', '')
    createApp({render=function() end}):mount(root)
    expect(root:hasAttribute('v-cloak')):toBe(false)
  end
  )
end
)