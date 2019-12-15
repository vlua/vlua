local lu = require("luaunit")
local Vue = require("instance.Vue")

describe('Initialization', function()
  it('with new', function()
    lu.assertEquals(Vue.new().__proto, Vue.prototype)
  end)
end)
