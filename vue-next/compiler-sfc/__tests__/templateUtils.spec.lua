require("compiler-sfc/src/templateUtils")

describe('compiler sfc:templateUtils isRelativeUrl', function()
  test('should return true when The first character of the string path is .', function()
    local url = './**.vue'
    local result = isRelativeUrl(url)
    expect(result):toBe(true)
  end
  )
  test('should return true when The first character of the string path is ~', function()
    local url = '~/xx.vue'
    local result = isRelativeUrl(url)
    expect(result):toBe(true)
  end
  )
  test('should return true when The first character of the string path is @', function()
    local url = '@/xx.vue'
    local result = isRelativeUrl(url)
    expect(result):toBe(true)
  end
  )
end
)
describe('compiler sfc:templateUtils isExternalUrl', function()
  test('should return true when String starts with http://', function()
    local url = 'http://vuejs.org/'
    local result = isExternalUrl(url)
    expect(result):toBe(true)
  end
  )
  test('should return true when String starts with https://', function()
    local url = 'https://vuejs.org/'
    local result = isExternalUrl(url)
    expect(result):toBe(true)
  end
  )
end
)
describe('compiler sfc:templateUtils isDataUrl', function()
  test('should return true w/ hasn`t media type and encode', function()
    expect(isDataUrl('data:,i')):toBe(true)
  end
  )
  test('should return true w/ media type + encode', function()
    expect(isDataUrl('data:image/png;base64,i')):toBe(true)
  end
  )
  test('should return true w/ media type + hasn`t encode', function()
    expect(isDataUrl('data:image/png,i')):toBe(true)
  end
  )
end
)