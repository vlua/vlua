require("@vue/shared")
require("runtime-core/src/component")
require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/vnode")
require("runtime-core/src/components/Suspense")
local version = __VERSION__
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
'@vue/reactivity' = {}

undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
undefined
local _toDisplayString = toDisplayString
local _camelize = camelize
undefined
undefined
local _ssrUtils = {createComponentInstance=createComponentInstance, setupComponent=setupComponent, renderComponentRoot=renderComponentRoot, setCurrentRenderingInstance=setCurrentRenderingInstance, isVNode=isVNode, normalizeVNode=normalizeVNode, normalizeSuspenseChildren=normalizeSuspenseChildren}
-- [ts2lua]lua中0和空字符串也是true，此处__NODE_JS__需要确认
local ssrUtils = (__NODE_JS__ and {_ssrUtils} or {nil})[1]