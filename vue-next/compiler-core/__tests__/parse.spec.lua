require("stringutil")
require("compiler-core/src/parse")
require("compiler-core/src/parse/TextModes")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/ast/Namespaces")
require("compiler-core/src/ast/NodeTypes")

describe('compiler: parse', function()
  describe('Text', function()
    test('simple text', function()
      local ast = baseParse('some text')
      local text = ast.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='some text', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=9, line=1, column=10}, source='some text'}})
    end
    )
    test('simple text with invalid end tag', function()
      local onError = jest:fn()
      local ast = baseParse('some text</div>', {onError=onError})
      local text = ast.children[0+1]
      expect(onError):toBeCalled()
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='some text', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=9, line=1, column=10}, source='some text'}})
    end
    )
    test('text with interpolation', function()
      local ast = baseParse('some {{ foo + bar }} text')
      local text1 = ast.children[0+1]
      local text2 = ast.children[2+1]
      expect(text1):toStrictEqual({type=NodeTypes.TEXT, content='some ', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=5, line=1, column=6}, source='some '}})
      expect(text2):toStrictEqual({type=NodeTypes.TEXT, content=' text', loc={start={offset=20, line=1, column=21}, tsvar_end={offset=25, line=1, column=26}, source=' text'}})
    end
    )
    test('text with interpolation which has `<`', function()
      local ast = baseParse('some {{ a<b && c>d }} text')
      local text1 = ast.children[0+1]
      local text2 = ast.children[2+1]
      expect(text1):toStrictEqual({type=NodeTypes.TEXT, content='some ', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=5, line=1, column=6}, source='some '}})
      expect(text2):toStrictEqual({type=NodeTypes.TEXT, content=' text', loc={start={offset=21, line=1, column=22}, tsvar_end={offset=26, line=1, column=27}, source=' text'}})
    end
    )
    test('text with mix of tags and interpolations', function()
      local ast = baseParse('some <span>{{ foo < bar + foo }} text</span>')
      local text1 = ast.children[0+1]
      local text2 = ()[1+1]
      expect(text1):toStrictEqual({type=NodeTypes.TEXT, content='some ', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=5, line=1, column=6}, source='some '}})
      expect(text2):toStrictEqual({type=NodeTypes.TEXT, content=' text', loc={start={offset=32, line=1, column=33}, tsvar_end={offset=37, line=1, column=38}, source=' text'}})
    end
    )
    test('lonly "<" don\'t separate nodes', function()
      local ast = baseParse('a < b', {onError=function(err)
        if err.code ~= ErrorCodes.INVALID_FIRST_CHARACTER_OF_TAG_NAME then
          error(err)
        end
      end
      })
      local text = ast.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='a < b', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=5, line=1, column=6}, source='a < b'}})
    end
    )
    test('lonly "{{" don\'t separate nodes', function()
      local ast = baseParse('a {{ b', {onError=function(error)
        if error.code ~= ErrorCodes.X_MISSING_INTERPOLATION_END then
          error(error)
        end
      end
      })
      local text = ast.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='a {{ b', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=6, line=1, column=7}, source='a {{ b'}})
    end
    )
  end
  )
  describe('Interpolation', function()
    test('simple interpolation', function()
      local ast = baseParse('{{message}}')
      local interpolation = ast.children[0+1]
      expect(interpolation):toStrictEqual({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false, isConstant=false, loc={start={offset=2, line=1, column=3}, tsvar_end={offset=9, line=1, column=10}, source=}}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=11, line=1, column=12}, source='{{message}}'}})
    end
    )
    test('it can have tag-like notation', function()
      local ast = baseParse('{{ a<b }}')
      local interpolation = ast.children[0+1]
      expect(interpolation):toStrictEqual({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false, isConstant=false, loc={start={offset=3, line=1, column=4}, tsvar_end={offset=6, line=1, column=7}, source='a<b'}}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=9, line=1, column=10}, source='{{ a<b }}'}})
    end
    )
    test('it can have tag-like notation (2)', function()
      local ast = baseParse('{{ a<b }}{{ c>d }}')
      local interpolation1 = ast.children[0+1]
      local interpolation2 = ast.children[1+1]
      expect(interpolation1):toStrictEqual({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false, isConstant=false, loc={start={offset=3, line=1, column=4}, tsvar_end={offset=6, line=1, column=7}, source='a<b'}}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=9, line=1, column=10}, source='{{ a<b }}'}})
      expect(interpolation2):toStrictEqual({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, isStatic=false, isConstant=false, content='c>d', loc={start={offset=12, line=1, column=13}, tsvar_end={offset=15, line=1, column=16}, source='c>d'}}, loc={start={offset=9, line=1, column=10}, tsvar_end={offset=18, line=1, column=19}, source='{{ c>d }}'}})
    end
    )
    test('it can have tag-like notation (3)', function()
      local ast = baseParse('<div>{{ "</div>" }}</div>')
      local element = ast.children[0+1]
      local interpolation = element.children[0+1]
      expect(interpolation):toStrictEqual({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, isStatic=false, isConstant=false, content='"</div>"', loc={start={offset=8, line=1, column=9}, tsvar_end={offset=16, line=1, column=17}, source='"</div>"'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=19, line=1, column=20}, source='{{ "</div>" }}'}})
    end
    )
    test('custom delimiters', function()
      local ast = baseParse('<p>{msg}</p>', {delimiters={'{', '}'}})
      local element = ast.children[0+1]
      local interpolation = element.children[0+1]
      expect(interpolation):toStrictEqual({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false, isConstant=false, loc={start={offset=4, line=1, column=5}, tsvar_end={offset=7, line=1, column=8}, source='msg'}}, loc={start={offset=3, line=1, column=4}, tsvar_end={offset=8, line=1, column=9}, source='{msg}'}})
    end
    )
  end
  )
  describe('Comment', function()
    test('empty comment', function()
      local ast = baseParse('<!---->')
      local comment = ast.children[0+1]
      expect(comment):toStrictEqual({type=NodeTypes.COMMENT, content='', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=7, line=1, column=8}, source='<!---->'}})
    end
    )
    test('simple comment', function()
      local ast = baseParse('<!--abc-->')
      local comment = ast.children[0+1]
      expect(comment):toStrictEqual({type=NodeTypes.COMMENT, content='abc', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=10, line=1, column=11}, source='<!--abc-->'}})
    end
    )
    test('two comments', function()
      local ast = baseParse('<!--abc--><!--def-->')
      local comment1 = ast.children[0+1]
      local comment2 = ast.children[1+1]
      expect(comment1):toStrictEqual({type=NodeTypes.COMMENT, content='abc', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=10, line=1, column=11}, source='<!--abc-->'}})
      expect(comment2):toStrictEqual({type=NodeTypes.COMMENT, content='def', loc={start={offset=10, line=1, column=11}, tsvar_end={offset=20, line=1, column=21}, source='<!--def-->'}})
    end
    )
  end
  )
  describe('Element', function()
    test('simple div', function()
      local ast = baseParse('<div>hello</div>')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={}, isSelfClosing=false, children={{type=NodeTypes.TEXT, content='hello', loc={start={offset=5, line=1, column=6}, tsvar_end={offset=10, line=1, column=11}, source='hello'}}}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=16, line=1, column=17}, source='<div>hello</div>'}})
    end
    )
    test('empty', function()
      local ast = baseParse('<div></div>')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=11, line=1, column=12}, source='<div></div>'}})
    end
    )
    test('self closing', function()
      local ast = baseParse('<div/>after')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={}, isSelfClosing=true, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=6, line=1, column=7}, source='<div/>'}})
    end
    )
    test('void element', function()
      local ast = baseParse('<img>after', {isVoidTag=function(tag)
        tag == 'img'
      end
      })
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='img', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=5, line=1, column=6}, source='<img>'}})
    end
    )
    test('template element with directives', function()
      local ast = baseParse('<template v-if="ok"></template>')
      local element = ast.children[0+1]
      expect(element):toMatchObject({type=NodeTypes.ELEMENT, tagType=ElementTypes.TEMPLATE})
    end
    )
    test('template element without directives', function()
      local ast = baseParse('<template></template>')
      local element = ast.children[0+1]
      expect(element):toMatchObject({type=NodeTypes.ELEMENT, tagType=ElementTypes.ELEMENT})
    end
    )
    test('native element with `isNativeTag`', function()
      local ast = baseParse('<div></div><comp></comp><Comp></Comp>', {isNativeTag=function(tag)
        tag == 'div'
      end
      })
      expect(ast.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.ELEMENT})
      expect(ast.children[1+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='comp', tagType=ElementTypes.COMPONENT})
      expect(ast.children[2+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='Comp', tagType=ElementTypes.COMPONENT})
    end
    )
    test('native element without `isNativeTag`', function()
      local ast = baseParse('<div></div><comp></comp><Comp></Comp>')
      expect(ast.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.ELEMENT})
      expect(ast.children[1+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='comp', tagType=ElementTypes.ELEMENT})
      expect(ast.children[2+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='Comp', tagType=ElementTypes.COMPONENT})
    end
    )
    test('v-is without `isNativeTag`', function()
      local ast = baseParse({isNativeTag=function(tag)
        tag == 'div'
      end
      })
      expect(ast.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.ELEMENT})
      expect(ast.children[1+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.COMPONENT})
      expect(ast.children[2+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='Comp', tagType=ElementTypes.COMPONENT})
    end
    )
    test('v-is with `isNativeTag`', function()
      local ast = baseParse()
      expect(ast.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.ELEMENT})
      expect(ast.children[1+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.COMPONENT})
      expect(ast.children[2+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='Comp', tagType=ElementTypes.COMPONENT})
    end
    )
    test('custom element', function()
      local ast = baseParse('<div></div><comp></comp>', {isNativeTag=function(tag)
        tag == 'div'
      end
      , isCustomElement=function(tag)
        tag == 'comp'
      end
      })
      expect(ast.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.ELEMENT})
      expect(ast.children[1+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='comp', tagType=ElementTypes.ELEMENT})
    end
    )
    test('attribute with no value', function()
      local ast = baseParse('<div id></div>')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={{type=NodeTypes.ATTRIBUTE, name='id', value=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=7, line=1, column=8}, source='id'}}}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=14, line=1, column=15}, source='<div id></div>'}})
    end
    )
    test('attribute with empty value, double quote', function()
      local ast = baseParse('<div id=""></div>')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={{type=NodeTypes.ATTRIBUTE, name='id', value={type=NodeTypes.TEXT, content='', loc={start={offset=8, line=1, column=9}, tsvar_end={offset=10, line=1, column=11}, source='""'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=10, line=1, column=11}, source='id=""'}}}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=17, line=1, column=18}, source='<div id=""></div>'}})
    end
    )
    test('attribute with empty value, single quote', function()
      local ast = baseParse("<div id=''></div>")
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={{type=NodeTypes.ATTRIBUTE, name='id', value={type=NodeTypes.TEXT, content='', loc={start={offset=8, line=1, column=9}, tsvar_end={offset=10, line=1, column=11}, source="''"}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=10, line=1, column=11}, source="id=''"}}}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=17, line=1, column=18}, source="<div id=''></div>"}})
    end
    )
    test('attribute with value, double quote', function()
      local ast = baseParse('<div id=">\'"></div>')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={{type=NodeTypes.ATTRIBUTE, name='id', value={type=NodeTypes.TEXT, content=">'", loc={start={offset=8, line=1, column=9}, tsvar_end={offset=12, line=1, column=13}, source='">\'"'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=12, line=1, column=13}, source='id=">\'"'}}}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=19, line=1, column=20}, source='<div id=">\'"></div>'}})
    end
    )
    test('attribute with value, single quote', function()
      local ast = baseParse("<div id='>\"'></div>")
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={{type=NodeTypes.ATTRIBUTE, name='id', value={type=NodeTypes.TEXT, content='>"', loc={start={offset=8, line=1, column=9}, tsvar_end={offset=12, line=1, column=13}, source="'>\"'"}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=12, line=1, column=13}, source="id='>\"'"}}}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=19, line=1, column=20}, source="<div id='>\"'></div>"}})
    end
    )
    test('attribute with value, unquoted', function()
      local ast = baseParse('<div id=a/></div>')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={{type=NodeTypes.ATTRIBUTE, name='id', value={type=NodeTypes.TEXT, content='a/', loc={start={offset=8, line=1, column=9}, tsvar_end={offset=10, line=1, column=11}, source='a/'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=10, line=1, column=11}, source='id=a/'}}}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=17, line=1, column=18}, source='<div id=a/></div>'}})
    end
    )
    test('multiple attributes', function()
      local ast = baseParse('<div id=a class="c" inert style=\'\'></div>')
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, codegenNode=undefined, props={{type=NodeTypes.ATTRIBUTE, name='id', value={type=NodeTypes.TEXT, content='a', loc={start={offset=8, line=1, column=9}, tsvar_end={offset=9, line=1, column=10}, source='a'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=9, line=1, column=10}, source='id=a'}}, {type=NodeTypes.ATTRIBUTE, name='class', value={type=NodeTypes.TEXT, content='c', loc={start={offset=16, line=1, column=17}, tsvar_end={offset=19, line=1, column=20}, source='"c"'}}, loc={start={offset=10, line=1, column=11}, tsvar_end={offset=19, line=1, column=20}, source='class="c"'}}, {type=NodeTypes.ATTRIBUTE, name='inert', value=undefined, loc={start={offset=20, line=1, column=21}, tsvar_end={offset=25, line=1, column=26}, source='inert'}}, {type=NodeTypes.ATTRIBUTE, name='style', value={type=NodeTypes.TEXT, content='', loc={start={offset=32, line=1, column=33}, tsvar_end={offset=34, line=1, column=35}, source="''"}}, loc={start={offset=26, line=1, column=27}, tsvar_end={offset=34, line=1, column=35}, source="style=''"}}}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=41, line=1, column=42}, source='<div id=a class="c" inert style=\'\'></div>'}})
    end
    )
    test('directive with no value', function()
      local ast = baseParse('<div v-if/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='if', arg=undefined, modifiers={}, exp=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=9, line=1, column=10}, source='v-if'}})
    end
    )
    test('directive with value', function()
      local ast = baseParse('<div v-if="a"/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='if', arg=undefined, modifiers={}, exp={type=NodeTypes.SIMPLE_EXPRESSION, content='a', isStatic=false, isConstant=false, loc={start={offset=11, line=1, column=12}, tsvar_end={offset=12, line=1, column=13}, source='a'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=13, line=1, column=14}, source='v-if="a"'}})
    end
    )
    test('directive with argument', function()
      local ast = baseParse('<div v-on:click/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='click', isStatic=true, isConstant=true, loc={source='click', start={column=11, line=1, offset=10}, tsvar_end={column=16, line=1, offset=15}}}, modifiers={}, exp=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=15, line=1, column=16}, source='v-on:click'}})
    end
    )
    test('directive with dynamic argument', function()
      local ast = baseParse('<div v-on:[event]/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='event', isStatic=false, isConstant=false, loc={source='[event]', start={column=11, line=1, offset=10}, tsvar_end={column=18, line=1, offset=17}}}, modifiers={}, exp=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=17, line=1, column=18}, source='v-on:[event]'}})
    end
    )
    test('directive with a modifier', function()
      local ast = baseParse('<div v-on.enter/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg=undefined, modifiers={'enter'}, exp=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=15, line=1, column=16}, source='v-on.enter'}})
    end
    )
    test('directive with two modifiers', function()
      local ast = baseParse('<div v-on.enter.exact/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg=undefined, modifiers={'enter', 'exact'}, exp=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=21, line=1, column=22}, source='v-on.enter.exact'}})
    end
    )
    test('directive with argument and modifiers', function()
      local ast = baseParse('<div v-on:click.enter.exact/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='click', isStatic=true, isConstant=true, loc={source='click', start={column=11, line=1, offset=10}, tsvar_end={column=16, line=1, offset=15}}}, modifiers={'enter', 'exact'}, exp=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=27, line=1, column=28}, source='v-on:click.enter.exact'}})
    end
    )
    test('directive with dynamic argument and modifiers', function()
      local ast = baseParse('<div v-on:[a.b].camel/>')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='a.b', isStatic=false, isConstant=false, loc={source='[a.b]', start={column=11, line=1, offset=10}, tsvar_end={column=16, line=1, offset=15}}}, modifiers={'camel'}, exp=undefined, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=21, line=1, column=22}, source='v-on:[a.b].camel'}})
    end
    )
    test('v-bind shorthand', function()
      local ast = baseParse('<div :a=b />')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='bind', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='a', isStatic=true, isConstant=true, loc={source='a', start={column=7, line=1, offset=6}, tsvar_end={column=8, line=1, offset=7}}}, modifiers={}, exp={type=NodeTypes.SIMPLE_EXPRESSION, content='b', isStatic=false, isConstant=false, loc={start={offset=8, line=1, column=9}, tsvar_end={offset=9, line=1, column=10}, source='b'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=9, line=1, column=10}, source=':a=b'}})
    end
    )
    test('v-bind shorthand with modifier', function()
      local ast = baseParse('<div :a.sync=b />')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='bind', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='a', isStatic=true, isConstant=true, loc={source='a', start={column=7, line=1, offset=6}, tsvar_end={column=8, line=1, offset=7}}}, modifiers={'sync'}, exp={type=NodeTypes.SIMPLE_EXPRESSION, content='b', isStatic=false, isConstant=false, loc={start={offset=13, line=1, column=14}, tsvar_end={offset=14, line=1, column=15}, source='b'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=14, line=1, column=15}, source=':a.sync=b'}})
    end
    )
    test('v-on shorthand', function()
      local ast = baseParse('<div @a=b />')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='a', isStatic=true, isConstant=true, loc={source='a', start={column=7, line=1, offset=6}, tsvar_end={column=8, line=1, offset=7}}}, modifiers={}, exp={type=NodeTypes.SIMPLE_EXPRESSION, content='b', isStatic=false, isConstant=false, loc={start={offset=8, line=1, column=9}, tsvar_end={offset=9, line=1, column=10}, source='b'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=9, line=1, column=10}, source='@a=b'}})
    end
    )
    test('v-on shorthand with modifier', function()
      local ast = baseParse('<div @a.enter=b />')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='on', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='a', isStatic=true, isConstant=true, loc={source='a', start={column=7, line=1, offset=6}, tsvar_end={column=8, line=1, offset=7}}}, modifiers={'enter'}, exp={type=NodeTypes.SIMPLE_EXPRESSION, content='b', isStatic=false, isConstant=false, loc={start={offset=14, line=1, column=15}, tsvar_end={offset=15, line=1, column=16}, source='b'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=15, line=1, column=16}, source='@a.enter=b'}})
    end
    )
    test('v-slot shorthand', function()
      local ast = baseParse('<Comp #a="{ b }" />')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toStrictEqual({type=NodeTypes.DIRECTIVE, name='slot', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='a', isStatic=true, isConstant=true, loc={source='a', start={column=8, line=1, offset=7}, tsvar_end={column=9, line=1, offset=8}}}, modifiers={}, exp={type=NodeTypes.SIMPLE_EXPRESSION, content='{ b }', isStatic=false, isConstant=false, loc={start={offset=10, line=1, column=11}, tsvar_end={offset=15, line=1, column=16}, source='{ b }'}}, loc={start={offset=6, line=1, column=7}, tsvar_end={offset=16, line=1, column=17}, source='#a="{ b }"'}})
    end
    )
    test('v-slot arg containing dots', function()
      local ast = baseParse('<Comp v-slot:foo.bar="{ a }" />')
      local directive = ast.children[0+1].props[0+1]
      expect(directive):toMatchObject({type=NodeTypes.DIRECTIVE, name='slot', arg={type=NodeTypes.SIMPLE_EXPRESSION, content='foo.bar', isStatic=true, isConstant=true, loc={source='foo.bar', start={column=14, line=1, offset=13}, tsvar_end={column=21, line=1, offset=20}}}})
    end
    )
    test('v-pre', function()
      local ast = baseParse( + )
      local divWithPre = ast.children[0+1]
      expect(divWithPre.props):toMatchObject({{type=NodeTypes.ATTRIBUTE, name=, value={type=NodeTypes.TEXT, content=}, loc={source=, start={line=1, column=12}, tsvar_end={line=1, column=21}}}})
      expect(divWithPre.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tagType=ElementTypes.ELEMENT, tag=})
      expect(divWithPre.children[1+1]):toMatchObject({type=NodeTypes.TEXT, content=})
      local divWithoutPre = ast.children[1+1]
      expect(divWithoutPre.props):toMatchObject({{type=NodeTypes.DIRECTIVE, name=, arg={type=NodeTypes.SIMPLE_EXPRESSION, isStatic=true, content=}, exp={type=NodeTypes.SIMPLE_EXPRESSION, isStatic=false, content=}, loc={source=, start={line=2, column=6}, tsvar_end={line=2, column=15}}}})
      expect(divWithoutPre.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tagType=ElementTypes.COMPONENT, tag=})
      expect(divWithoutPre.children[1+1]):toMatchObject({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}})
    end
    )
    test('end tags are case-insensitive.', function()
      local ast = baseParse('<div>hello</DIV>after')
      local element = ast.children[0+1]
      local text = element.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='hello', loc={start={offset=5, line=1, column=6}, tsvar_end={offset=10, line=1, column=11}, source='hello'}})
    end
    )
  end
  )
  test('self closing single tag', function()
    local ast = baseParse('<div :class="{ some: condition }" />')
    expect(ast.children):toHaveLength(1)
    expect(ast.children[0+1]):toMatchObject({tag='div'})
  end
  )
  test('self closing multiple tag', function()
    local ast = baseParse( + )
    expect(ast):toMatchSnapshot()
    expect(ast.children):toHaveLength(2)
    expect(ast.children[0+1]):toMatchObject({tag='div'})
    expect(ast.children[1+1]):toMatchObject({tag='p'})
  end
  )
  test('valid html', function()
    local ast = baseParse( +  +  + )
    expect(ast):toMatchSnapshot()
    expect(ast.children):toHaveLength(1)
    local el = ast.children[0+1]
    expect(el):toMatchObject({tag='div'})
    expect(el.children):toHaveLength(2)
    expect(el.children[0+1]):toMatchObject({tag='p'})
    expect(el.children[1+1]):toMatchObject({type=NodeTypes.COMMENT})
  end
  )
  test('invalid html', function()
    expect(function()
      baseParse()
    end
    ):toThrow('Element is missing end tag.')
    local spy = jest:fn()
    local ast = baseParse({onError=spy})
    expect(spy.mock.calls):toMatchObject({{{code=ErrorCodes.X_MISSING_END_TAG, loc={start={offset=6, line=2, column=1}}}}, {{code=ErrorCodes.X_INVALID_END_TAG, loc={start={offset=20, line=4, column=1}}}}})
    expect(ast):toMatchSnapshot()
  end
  )
  test('parse with correct location info', function()
    local  = baseParse(():trim()).children
    local offset = 0
    expect(foo.loc.start):toEqual({line=1, column=1, offset=offset})
    -- [ts2lua]修改数组长度需要手动处理。
    offset = offset + foo.loc.source.length
    expect(foo.loc.tsvar_end):toEqual({line=2, column=5, offset=offset})
    expect(bar.loc.start):toEqual({line=2, column=5, offset=offset})
    local barInner = bar.content
    offset = offset + 3
    expect(barInner.loc.start):toEqual({line=2, column=8, offset=offset})
    -- [ts2lua]修改数组长度需要手动处理。
    offset = offset + barInner.loc.source.length
    expect(barInner.loc.tsvar_end):toEqual({line=2, column=11, offset=offset})
    offset = offset + 3
    expect(bar.loc.tsvar_end):toEqual({line=2, column=14, offset=offset})
    expect(but.loc.start):toEqual({line=2, column=14, offset=offset})
    -- [ts2lua]修改数组长度需要手动处理。
    offset = offset + but.loc.source.length
    expect(but.loc.tsvar_end):toEqual({line=2, column=19, offset=offset})
    expect(baz.loc.start):toEqual({line=2, column=19, offset=offset})
    local bazInner = baz.content
    offset = offset + 3
    expect(bazInner.loc.start):toEqual({line=2, column=22, offset=offset})
    -- [ts2lua]修改数组长度需要手动处理。
    offset = offset + bazInner.loc.source.length
    expect(bazInner.loc.tsvar_end):toEqual({line=2, column=25, offset=offset})
    offset = offset + 3
    expect(baz.loc.tsvar_end):toEqual({line=2, column=28, offset=offset})
  end
  )
  describe('decodeEntities option', function()
    test('use the given map', function()
      local ast = baseParse('&amp;&cups;', {decodeEntities=function(text)
        text:gsub('&cups;', '\u222A\uFE00')
      end
      , onError=function()
        
      end
      })
      expect(#ast.children):toBe(1)
      expect(ast.children[0+1].type):toBe(NodeTypes.TEXT)
      expect(ast.children[0+1].content):toBe('&amp;\u222A\uFE00')
    end
    )
  end
  )
  describe('whitespace management', function()
    it('should remove whitespaces at start/end inside an element', function()
      local ast = baseParse()
      expect(#ast.children[0+1].children):toBe(1)
    end
    )
    it('should remove whitespaces w/ newline between elements', function()
      local ast = baseParse()
      expect(#ast.children):toBe(3)
      expect(ast.children:every(function(c)
        c.type == NodeTypes.ELEMENT
      end
      )):toBe(true)
    end
    )
    it('should remove whitespaces adjacent to comments', function()
      local ast = baseParse()
      expect(#ast.children):toBe(3)
      expect(ast.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(ast.children[1+1].type):toBe(NodeTypes.COMMENT)
      expect(ast.children[2+1].type):toBe(NodeTypes.ELEMENT)
    end
    )
    it('should remove whitespaces w/ newline between comments and elements', function()
      local ast = baseParse()
      expect(#ast.children):toBe(3)
      expect(ast.children[0+1].type):toBe(NodeTypes.ELEMENT)
      expect(ast.children[1+1].type):toBe(NodeTypes.COMMENT)
      expect(ast.children[2+1].type):toBe(NodeTypes.ELEMENT)
    end
    )
    it('should NOT remove whitespaces w/ newline between interpolations', function()
      local ast = baseParse()
      expect(#ast.children):toBe(3)
      expect(ast.children[0+1].type):toBe(NodeTypes.INTERPOLATION)
      expect(ast.children[1+1]):toMatchObject({type=NodeTypes.TEXT, content=' '})
      expect(ast.children[2+1].type):toBe(NodeTypes.INTERPOLATION)
    end
    )
    it('should NOT remove whitespaces w/o newline between elements', function()
      local ast = baseParse()
      expect(#ast.children):toBe(5)
      expect(ast.children:map(function(c)
        c.type
      end
      )):toMatchObject({NodeTypes.ELEMENT, NodeTypes.TEXT, NodeTypes.ELEMENT, NodeTypes.TEXT, NodeTypes.ELEMENT})
    end
    )
    it('should condense consecutive whitespaces in text', function()
      local ast = baseParse()
      expect(ast.children[0+1].content):toBe()
    end
    )
  end
  )
  describe('Errors', function()
    local patterns = {ABRUPT_CLOSING_OF_EMPTY_COMMENT={{code='<template><!--></template>', errors={{type=ErrorCodes.ABRUPT_CLOSING_OF_EMPTY_COMMENT, loc={offset=10, line=1, column=11}}}}, {code='<template><!---></template>', errors={{type=ErrorCodes.ABRUPT_CLOSING_OF_EMPTY_COMMENT, loc={offset=10, line=1, column=11}}}}, {code='<template><!----></template>', errors={}}}, CDATA_IN_HTML_CONTENT={{code='<template><![CDATA[cdata]]></template>', errors={{type=ErrorCodes.CDATA_IN_HTML_CONTENT, loc={offset=10, line=1, column=11}}}}, {code='<template><svg><![CDATA[cdata]]></svg></template>', errors={}}}, DUPLICATE_ATTRIBUTE={{code='<template><div id="" id=""></div></template>', errors={{type=ErrorCodes.DUPLICATE_ATTRIBUTE, loc={offset=21, line=1, column=22}}}}}, END_TAG_WITH_ATTRIBUTES={{code='<template><div></div id=""></template>', errors={{type=ErrorCodes.END_TAG_WITH_ATTRIBUTES, loc={offset=21, line=1, column=22}}}}}, END_TAG_WITH_TRAILING_SOLIDUS={{code='<template><div></div/></template>', errors={{type=ErrorCodes.END_TAG_WITH_TRAILING_SOLIDUS, loc={offset=20, line=1, column=21}}}}}, EOF_BEFORE_TAG_NAME={{code='<template><', errors={{type=ErrorCodes.EOF_BEFORE_TAG_NAME, loc={offset=11, line=1, column=12}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template></', errors={{type=ErrorCodes.EOF_BEFORE_TAG_NAME, loc={offset=12, line=1, column=13}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}}, EOF_IN_CDATA={{code='<template><svg><![CDATA[cdata', errors={{type=ErrorCodes.EOF_IN_CDATA, loc={offset=29, line=1, column=30}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><svg><![CDATA[', errors={{type=ErrorCodes.EOF_IN_CDATA, loc={offset=24, line=1, column=25}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}}, EOF_IN_COMMENT={{code='<template><!--comment', errors={{type=ErrorCodes.EOF_IN_COMMENT, loc={offset=21, line=1, column=22}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><!--', errors={{type=ErrorCodes.EOF_IN_COMMENT, loc={offset=14, line=1, column=15}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><!', errors={{type=ErrorCodes.INCORRECTLY_OPENED_COMMENT, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><!-', errors={{type=ErrorCodes.INCORRECTLY_OPENED_COMMENT, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><!abc', errors={{type=ErrorCodes.INCORRECTLY_OPENED_COMMENT, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}}, EOF_IN_SCRIPT_HTML_COMMENT_LIKE_TEXT={{code="<script><!--print('hello')", errors={{type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}, {type=ErrorCodes.EOF_IN_SCRIPT_HTML_COMMENT_LIKE_TEXT, loc={offset=32, line=1, column=33}}}}, {code="<script>print('hello')", errors={{type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}}, EOF_IN_TAG={{code='<template><div', errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=14, line=1, column=15}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div ', errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=15, line=1, column=16}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id', errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=17, line=1, column=18}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id ', errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=18, line=1, column=19}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id =', errors={{type=ErrorCodes.MISSING_ATTRIBUTE_VALUE, loc={offset=19, line=1, column=20}}, {type=ErrorCodes.EOF_IN_TAG, loc={offset=19, line=1, column=20}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code="<template><div id='abc", errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=22, line=1, column=23}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id="abc', errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=22, line=1, column=23}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code="<template><div id='abc'", errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=23, line=1, column=24}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id="abc"', errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=23, line=1, column=24}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id=abc', errors={{type=ErrorCodes.EOF_IN_TAG, loc={offset=21, line=1, column=22}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code="<template><div id='abc'/", errors={{type=ErrorCodes.UNEXPECTED_SOLIDUS_IN_TAG, loc={offset=23, line=1, column=24}}, {type=ErrorCodes.EOF_IN_TAG, loc={offset=24, line=1, column=25}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id="abc"/', errors={{type=ErrorCodes.UNEXPECTED_SOLIDUS_IN_TAG, loc={offset=23, line=1, column=24}}, {type=ErrorCodes.EOF_IN_TAG, loc={offset=24, line=1, column=25}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template><div id=abc /', errors={{type=ErrorCodes.UNEXPECTED_SOLIDUS_IN_TAG, loc={offset=22, line=1, column=23}}, {type=ErrorCodes.EOF_IN_TAG, loc={offset=23, line=1, column=24}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}}, INCORRECTLY_CLOSED_COMMENT={{code='<template><!--comment--!></template>', errors={{type=ErrorCodes.INCORRECTLY_CLOSED_COMMENT, loc={offset=10, line=1, column=11}}}}}, INCORRECTLY_OPENED_COMMENT={{code='<template><!></template>', errors={{type=ErrorCodes.INCORRECTLY_OPENED_COMMENT, loc={offset=10, line=1, column=11}}}}, {code='<template><!-></template>', errors={{type=ErrorCodes.INCORRECTLY_OPENED_COMMENT, loc={offset=10, line=1, column=11}}}}, {code='<template><!ELEMENT br EMPTY></template>', errors={{type=ErrorCodes.INCORRECTLY_OPENED_COMMENT, loc={offset=10, line=1, column=11}}}}, {code='<!DOCTYPE html>', errors={}}}, INVALID_FIRST_CHARACTER_OF_TAG_NAME={{code='<template>a < b</template>', errors={{type=ErrorCodes.INVALID_FIRST_CHARACTER_OF_TAG_NAME, loc={offset=13, line=1, column=14}}}}, {code='<template><�></template>', errors={{type=ErrorCodes.INVALID_FIRST_CHARACTER_OF_TAG_NAME, loc={offset=11, line=1, column=12}}}}, {code='<template>a </ b</template>', errors={{type=ErrorCodes.INVALID_FIRST_CHARACTER_OF_TAG_NAME, loc={offset=14, line=1, column=15}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}, {code='<template></�></template>', errors={{type=ErrorCodes.INVALID_FIRST_CHARACTER_OF_TAG_NAME, loc={offset=12, line=1, column=13}}}}, {code='<template>{{a < b}}</template>', errors={}}}, MISSING_ATTRIBUTE_VALUE={{code='<template><div id=></div></template>', errors={{type=ErrorCodes.MISSING_ATTRIBUTE_VALUE, loc={offset=18, line=1, column=19}}}}, {code='<template><div id= ></div></template>', errors={{type=ErrorCodes.MISSING_ATTRIBUTE_VALUE, loc={offset=19, line=1, column=20}}}}, {code='<template><div id= /></div></template>', errors={}}}, MISSING_END_TAG_NAME={{code='<template></></template>', errors={{type=ErrorCodes.MISSING_END_TAG_NAME, loc={offset=12, line=1, column=13}}}}}, MISSING_WHITESPACE_BETWEEN_ATTRIBUTES={{code='<template><div id="foo"class="bar"></div></template>', errors={{type=ErrorCodes.MISSING_WHITESPACE_BETWEEN_ATTRIBUTES, loc={offset=23, line=1, column=24}}}}, {code='<template><div id="foo"\r\nclass="bar"></div></template>', errors={}}}, NESTED_COMMENT={{code='<template><!--a<!--b--></template>', errors={{type=ErrorCodes.NESTED_COMMENT, loc={offset=15, line=1, column=16}}}}, {code='<template><!--a<!--b<!--c--></template>', errors={{type=ErrorCodes.NESTED_COMMENT, loc={offset=15, line=1, column=16}}, {type=ErrorCodes.NESTED_COMMENT, loc={offset=20, line=1, column=21}}}}, {code='<template><!--a<!--></template>', errors={}}, {code='<template><!--a<!--', errors={{type=ErrorCodes.EOF_IN_COMMENT, loc={offset=19, line=1, column=20}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}}, UNEXPECTED_CHARACTER_IN_ATTRIBUTE_NAME={{code="<template><div a\"bc=''></div></template>", errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_ATTRIBUTE_NAME, loc={offset=16, line=1, column=17}}}}, {code="<template><div a'bc=''></div></template>", errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_ATTRIBUTE_NAME, loc={offset=16, line=1, column=17}}}}, {code="<template><div a<bc=''></div></template>", errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_ATTRIBUTE_NAME, loc={offset=16, line=1, column=17}}}}}, UNEXPECTED_CHARACTER_IN_UNQUOTED_ATTRIBUTE_VALUE={{code='<template><div foo=bar"></div></template>', errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_UNQUOTED_ATTRIBUTE_VALUE, loc={offset=22, line=1, column=23}}}}, {code="<template><div foo=bar'></div></template>", errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_UNQUOTED_ATTRIBUTE_VALUE, loc={offset=22, line=1, column=23}}}}, {code='<template><div foo=bar<div></div></template>', errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_UNQUOTED_ATTRIBUTE_VALUE, loc={offset=22, line=1, column=23}}}}, {code='<template><div foo=bar=baz></div></template>', errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_UNQUOTED_ATTRIBUTE_VALUE, loc={offset=22, line=1, column=23}}}}, {code='<template><div foo=bar`></div></template>', errors={{type=ErrorCodes.UNEXPECTED_CHARACTER_IN_UNQUOTED_ATTRIBUTE_VALUE, loc={offset=22, line=1, column=23}}}}}, UNEXPECTED_EQUALS_SIGN_BEFORE_ATTRIBUTE_NAME={{code='<template><div =foo=bar></div></template>', errors={{type=ErrorCodes.UNEXPECTED_EQUALS_SIGN_BEFORE_ATTRIBUTE_NAME, loc={offset=15, line=1, column=16}}}}, {code='<template><div =></div></template>', errors={{type=ErrorCodes.UNEXPECTED_EQUALS_SIGN_BEFORE_ATTRIBUTE_NAME, loc={offset=15, line=1, column=16}}}}}, UNEXPECTED_QUESTION_MARK_INSTEAD_OF_TAG_NAME={{code='<template><?xml?></template>', errors={{type=ErrorCodes.UNEXPECTED_QUESTION_MARK_INSTEAD_OF_TAG_NAME, loc={offset=11, line=1, column=12}}}}}, UNEXPECTED_SOLIDUS_IN_TAG={{code='<template><div a/b></div></template>', errors={{type=ErrorCodes.UNEXPECTED_SOLIDUS_IN_TAG, loc={offset=16, line=1, column=17}}}}}, X_INVALID_END_TAG={{code='<template></div></template>', errors={{type=ErrorCodes.X_INVALID_END_TAG, loc={offset=10, line=1, column=11}}}}, {code='<template></div></div></template>', errors={{type=ErrorCodes.X_INVALID_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_INVALID_END_TAG, loc={offset=16, line=1, column=17}}}}, {code="<template>{{'</div>'}}</template>", errors={}}, {code='<textarea></div></textarea>', errors={}}, {code='<svg><![CDATA[</div>]]></svg>', errors={}}, {code='<svg><!--</div>--></svg>', errors={}}}, X_MISSING_END_TAG={{code='<template><div></template>', errors={{type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}}}, {code='<template><div>', errors={{type=ErrorCodes.X_MISSING_END_TAG, loc={offset=10, line=1, column=11}}, {type=ErrorCodes.X_MISSING_END_TAG, loc={offset=0, line=1, column=1}}}}}, X_MISSING_INTERPOLATION_END={{code='{{ foo', errors={{type=ErrorCodes.X_MISSING_INTERPOLATION_END, loc={offset=0, line=1, column=1}}}}, {code='{{', errors={{type=ErrorCodes.X_MISSING_INTERPOLATION_END, loc={offset=0, line=1, column=1}}}}, {code='{{}}', errors={}}}, X_MISSING_DYNAMIC_DIRECTIVE_ARGUMENT_END={{code=, errors={{type=ErrorCodes.X_MISSING_DYNAMIC_DIRECTIVE_ARGUMENT_END, loc={offset=15, line=1, column=16}}}}}}
    for _tmpi, key in pairs(Object:keys(patterns)) do
      describe(key, function()
        -- [ts2lua]patterns下标访问可能不正确
        for _tmpi,  in pairs(patterns[key]) do
          -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
          test(code:gsub(/[\r\n]/g, function(c)
            
          end
          ), function()
            local spy = jest:fn()
            local ast = baseParse(code, {getNamespace=function(tag, parent)
              -- [ts2lua]lua中0和空字符串也是true，此处parent需要确认
              local ns = (parent and {parent.ns} or {Namespaces.HTML})[1]
              if ns == Namespaces.HTML then
                if tag == 'svg' then
                  return Namespaces.HTML + 1
                end
              end
              return ns
            end
            , getTextMode=function()
              if tag == 'textarea' then
                return TextModes.RCDATA
              end
              if tag == 'script' then
                return TextModes.RAWTEXT
              end
              return TextModes.DATA
            end
            , ..., onError=spy})
            expect(spy.mock.calls:map(function()
              {type=err.code, loc=err.loc.start}
            end
            )):toMatchObject(errors)
            expect(ast):toMatchSnapshot()
          end
          )
        end
      end
      )
    end
  end
  )
end
)