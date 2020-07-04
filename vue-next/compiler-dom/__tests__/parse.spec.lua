require("@vue/compiler-core")
require("@vue/compiler-core/NodeTypes")
require("@vue/compiler-core/ErrorCodes")
require("@vue/compiler-core/ElementTypes")
require("compiler-dom/src/parserOptions")
require("compiler-dom/src/parserOptions/DOMNamespaces")
local parse = baseParse

describe('DOM parser', function()
  describe('Text', function()
    test('textarea handles comments/elements as just text', function()
      local ast = parse('<textarea>some<div>text</div>and<!--comment--></textarea>', parserOptions)
      local element = ast.children[0+1]
      local text = element.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='some<div>text</div>and<!--comment-->', loc={start={offset=10, line=1, column=11}, tsvar_end={offset=46, line=1, column=47}, source='some<div>text</div>and<!--comment-->'}})
    end
    )
    test('textarea handles character references', function()
      local ast = parse('<textarea>&amp;</textarea>', parserOptions)
      local element = ast.children[0+1]
      local text = element.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='&', loc={start={offset=10, line=1, column=11}, tsvar_end={offset=15, line=1, column=16}, source='&amp;'}})
    end
    )
    test('textarea support interpolation', function()
      local ast = parse('<textarea><div>{{ foo }}</textarea>', parserOptions)
      local element = ast.children[0+1]
      expect(element.children):toMatchObject({{type=NodeTypes.TEXT, content=}, {type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false}}})
    end
    )
    test('style handles comments/elements as just a text', function()
      local ast = parse('<style>some<div>text</div>and<!--comment--></style>', parserOptions)
      local element = ast.children[0+1]
      local text = element.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='some<div>text</div>and<!--comment-->', loc={start={offset=7, line=1, column=8}, tsvar_end={offset=43, line=1, column=44}, source='some<div>text</div>and<!--comment-->'}})
    end
    )
    test("style doesn't handle character references", function()
      local ast = parse('<style>&amp;</style>', parserOptions)
      local element = ast.children[0+1]
      local text = element.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='&amp;', loc={start={offset=7, line=1, column=8}, tsvar_end={offset=12, line=1, column=13}, source='&amp;'}})
    end
    )
    test('CDATA', function()
      local ast = parse('<svg><![CDATA[some text]]></svg>', parserOptions)
      local text = ()[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='some text', loc={start={offset=14, line=1, column=15}, tsvar_end={offset=23, line=1, column=24}, source='some text'}})
    end
    )
    test('<pre> tag should preserve raw whitespace', function()
      local rawText = nil
      local ast = parse(parserOptions)
      expect(ast.children[0+1].children):toMatchObject({{type=NodeTypes.TEXT, content=}, {type=NodeTypes.ELEMENT, children={{type=NodeTypes.TEXT, content=}}}, {type=NodeTypes.TEXT, content=}})
    end
    )
    test('<pre> tag should remove leading newline', function()
      local rawText = nil
      local ast = parse(parserOptions)
      expect(ast.children[0+1].children):toMatchObject({{type=NodeTypes.TEXT, content=}, {type=NodeTypes.ELEMENT, children={{type=NodeTypes.TEXT, content=}}}})
    end
    )
    test('&nbsp; should not be condensed', function()
      local nbsp = String:fromCharCode(160)
      local ast = parse(parserOptions)
      expect(ast.children[0+1]):toMatchObject({type=NodeTypes.TEXT, content=})
    end
    )
    test('HTML entities compatibility in text', function()
      local ast = parse('&ampersand;', parserOptions)
      local text = ast.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='&ersand;', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=11, line=1, column=12}, source='&ampersand;'}})
    end
    )
    test('HTML entities compatibility in attribute', function()
      local ast = parse('<div a="&ampersand;" b="&amp;ersand;" c="&amp!"></div>', parserOptions)
      local element = ast.children[0+1]
      local text1 = element.props[0+1].value
      local text2 = element.props[1+1].value
      local text3 = element.props[2+1].value
      expect(text1):toStrictEqual({type=NodeTypes.TEXT, content='&ampersand;', loc={start={offset=7, line=1, column=8}, tsvar_end={offset=20, line=1, column=21}, source='"&ampersand;"'}})
      expect(text2):toStrictEqual({type=NodeTypes.TEXT, content='&ersand;', loc={start={offset=23, line=1, column=24}, tsvar_end={offset=37, line=1, column=38}, source='"&amp;ersand;"'}})
      expect(text3):toStrictEqual({type=NodeTypes.TEXT, content='&!', loc={start={offset=40, line=1, column=41}, tsvar_end={offset=47, line=1, column=48}, source='"&amp!"'}})
    end
    )
    test('Some control character reference should be replaced.', function()
      local ast = parse('&#x86;', parserOptions)
      local text = ast.children[0+1]
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='†', loc={start={offset=0, line=1, column=1}, tsvar_end={offset=6, line=1, column=7}, source='&#x86;'}})
    end
    )
  end
  )
  describe('Interpolation', function()
    test('HTML entities in interpolation should be translated for backward compatibility.', function()
      local ast = parse('<div>{{ a &lt; b }}</div>', parserOptions)
      local element = ast.children[0+1]
      local interpolation = element.children[0+1]
      expect(interpolation):toStrictEqual({type=NodeTypes.INTERPOLATION, content={type=NodeTypes.SIMPLE_EXPRESSION, content=, isStatic=false, isConstant=false, loc={start={offset=8, line=1, column=9}, tsvar_end={offset=16, line=1, column=17}, source='a &lt; b'}}, loc={start={offset=5, line=1, column=6}, tsvar_end={offset=19, line=1, column=20}, source='{{ a &lt; b }}'}})
    end
    )
  end
  )
  describe('Element', function()
    test('void element', function()
      local ast = parse('<img>after', parserOptions)
      local element = ast.children[0+1]
      expect(element):toStrictEqual({type=NodeTypes.ELEMENT, ns=DOMNamespaces.HTML, tag='img', tagType=ElementTypes.ELEMENT, props={}, isSelfClosing=false, children={}, loc={start={offset=0, line=1, column=1}, tsvar_end={offset=5, line=1, column=6}, source='<img>'}, codegenNode=undefined})
    end
    )
    test('native element', function()
      local ast = parse('<div></div><comp></comp><Comp></Comp>', parserOptions)
      expect(ast.children[0+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div', tagType=ElementTypes.ELEMENT})
      expect(ast.children[1+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='comp', tagType=ElementTypes.COMPONENT})
      expect(ast.children[2+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='Comp', tagType=ElementTypes.COMPONENT})
    end
    )
    test('Strict end tag detection for textarea.', function()
      local ast = parse('<textarea>hello</textarea</textarea0></texTArea a="<>">', {..., onError=function(err)
        if err.code ~= ErrorCodes.END_TAG_WITH_ATTRIBUTES then
          error(err)
        end
      end
      })
      local element = ast.children[0+1]
      local text = element.children[0+1]
      expect(#ast.children):toBe(1)
      expect(text):toStrictEqual({type=NodeTypes.TEXT, content='hello</textarea</textarea0>', loc={start={offset=10, line=1, column=11}, tsvar_end={offset=37, line=1, column=38}, source='hello</textarea</textarea0>'}})
    end
    )
  end
  )
  describe('Namespaces', function()
    test('HTML namespace', function()
      local ast = parse('<html>test</html>', parserOptions)
      local element = ast.children[0+1]
      expect(element.ns):toBe(DOMNamespaces.HTML)
    end
    )
    test('SVG namespace', function()
      local ast = parse('<svg>test</svg>', parserOptions)
      local element = ast.children[0+1]
      expect(element.ns):toBe(DOMNamespaces.SVG)
    end
    )
    test('MATH_ML namespace', function()
      local ast = parse('<math>test</math>', parserOptions)
      local element = ast.children[0+1]
      expect(element.ns):toBe(DOMNamespaces.MATH_ML)
    end
    )
    test('SVG in MATH_ML namespace', function()
      local ast = parse('<math><annotation-xml><svg></svg></annotation-xml></math>', parserOptions)
      local elementMath = ast.children[0+1]
      local elementAnnotation = elementMath.children[0+1]
      local elementSvg = elementAnnotation.children[0+1]
      expect(elementMath.ns):toBe(DOMNamespaces.MATH_ML)
      expect(elementSvg.ns):toBe(DOMNamespaces.SVG)
    end
    )
    test('html text/html in MATH_ML namespace', function()
      local ast = parse('<math><annotation-xml encoding="text/html"><test/></annotation-xml></math>', parserOptions)
      local elementMath = ast.children[0+1]
      local elementAnnotation = elementMath.children[0+1]
      local element = elementAnnotation.children[0+1]
      expect(elementMath.ns):toBe(DOMNamespaces.MATH_ML)
      expect(element.ns):toBe(DOMNamespaces.HTML)
    end
    )
    test('html application/xhtml+xml in MATH_ML namespace', function()
      local ast = parse('<math><annotation-xml encoding="application/xhtml+xml"><test/></annotation-xml></math>', parserOptions)
      local elementMath = ast.children[0+1]
      local elementAnnotation = elementMath.children[0+1]
      local element = elementAnnotation.children[0+1]
      expect(elementMath.ns):toBe(DOMNamespaces.MATH_ML)
      expect(element.ns):toBe(DOMNamespaces.HTML)
    end
    )
    test('mtext malignmark in MATH_ML namespace', function()
      local ast = parse('<math><mtext><malignmark/></mtext></math>', parserOptions)
      local elementMath = ast.children[0+1]
      local elementText = elementMath.children[0+1]
      local element = elementText.children[0+1]
      expect(elementMath.ns):toBe(DOMNamespaces.MATH_ML)
      expect(element.ns):toBe(DOMNamespaces.MATH_ML)
    end
    )
    test('mtext and not malignmark tag in MATH_ML namespace', function()
      local ast = parse('<math><mtext><test/></mtext></math>', parserOptions)
      local elementMath = ast.children[0+1]
      local elementText = elementMath.children[0+1]
      local element = elementText.children[0+1]
      expect(elementMath.ns):toBe(DOMNamespaces.MATH_ML)
      expect(element.ns):toBe(DOMNamespaces.HTML)
    end
    )
    test('foreignObject tag in SVG namespace', function()
      local ast = parse('<svg><foreignObject><test/></foreignObject></svg>', parserOptions)
      local elementSvg = ast.children[0+1]
      local elementForeignObject = elementSvg.children[0+1]
      local element = elementForeignObject.children[0+1]
      expect(elementSvg.ns):toBe(DOMNamespaces.SVG)
      expect(element.ns):toBe(DOMNamespaces.HTML)
    end
    )
    test('desc tag in SVG namespace', function()
      local ast = parse('<svg><desc><test/></desc></svg>', parserOptions)
      local elementSvg = ast.children[0+1]
      local elementDesc = elementSvg.children[0+1]
      local element = elementDesc.children[0+1]
      expect(elementSvg.ns):toBe(DOMNamespaces.SVG)
      expect(element.ns):toBe(DOMNamespaces.HTML)
    end
    )
    test('title tag in SVG namespace', function()
      local ast = parse('<svg><title><test/></title></svg>', parserOptions)
      local elementSvg = ast.children[0+1]
      local elementTitle = elementSvg.children[0+1]
      local element = elementTitle.children[0+1]
      expect(elementSvg.ns):toBe(DOMNamespaces.SVG)
      expect(element.ns):toBe(DOMNamespaces.HTML)
    end
    )
    test('SVG in HTML namespace', function()
      local ast = parse('<html><svg></svg></html>', parserOptions)
      local elementHtml = ast.children[0+1]
      local element = elementHtml.children[0+1]
      expect(elementHtml.ns):toBe(DOMNamespaces.HTML)
      expect(element.ns):toBe(DOMNamespaces.SVG)
    end
    )
    test('MATH in HTML namespace', function()
      local ast = parse('<html><math></math></html>', parserOptions)
      local elementHtml = ast.children[0+1]
      local element = elementHtml.children[0+1]
      expect(elementHtml.ns):toBe(DOMNamespaces.HTML)
      expect(element.ns):toBe(DOMNamespaces.MATH_ML)
    end
    )
  end
  )
end
)