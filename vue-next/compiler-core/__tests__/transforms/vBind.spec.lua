require("compiler-core/src")
require("compiler-core/src/ErrorCodes")
require("compiler-core/src/transforms/vBind")
require("compiler-core/src/transforms/transformElement")
local parse = baseParse

function parseWithVBind(template, options)
  if options == nil then
    options={}
  end
  local ast = parse(template)
  transform(ast, {nodeTransforms={..., transformElement}, directiveTransforms={bind=transformBind}, ...})
  return ast.children[0+1]
end

describe('compiler: transform v-bind', function()
  test('basic', function()
    local node = parseWithVBind()
    local props = node.codegenNode.props
    expect(props.properties[0+1]):toMatchObject({key={content=, isStatic=true, loc={start={line=1, column=13}, tsvar_end={line=1, column=15}}}, value={content=, isStatic=false, loc={start={line=1, column=17}, tsvar_end={line=1, column=19}}}})
  end
  )
  test('dynamic arg', function()
    local node = parseWithVBind()
    local props = node.codegenNode.props
    expect(props.properties[0+1]):toMatchObject({key={content=, isStatic=false}, value={content=, isStatic=false}})
  end
  )
  test('should error if no expression', function()
    local onError = jest:fn()
    parseWithVBind({onError=onError})
    expect(onError.mock.calls[0+1][0+1]):toMatchObject({code=ErrorCodes.X_V_BIND_NO_EXPRESSION, loc={start={line=1, column=6}, tsvar_end={line=1, column=16}}})
  end
  )
  test('.camel modifier', function()
    local node = parseWithVBind()
    local props = node.codegenNode.props
    expect(props.properties[0+1]):toMatchObject({key={content=, isStatic=true}, value={content=, isStatic=false}})
  end
  )
  test('.camel modifier w/ dynamic arg', function()
    local node = parseWithVBind()
    local props = node.codegenNode.props
    expect(props.properties[0+1]):toMatchObject({key={content=, isStatic=false}, value={content=, isStatic=false}})
  end
  )
  test('.camel modifier w/ dynamic arg + prefixIdentifiers', function()
    local node = parseWithVBind({prefixIdentifiers=true})
    local props = node.codegenNode.props
    expect(props.properties[0+1]):toMatchObject({key={children={{content=}, , {content=}, , }}, value={content=, isStatic=false}})
  end
  )
end
)