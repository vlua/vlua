require("@vue/shared")
require("runtime-core/src/warning")
require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/errorHandling")
require("runtime-core/src/errorHandling/ErrorCodes")

local isBuiltInDirective = makeMap('bind,cloak,else-if,else,for,html,if,model,on,once,pre,show,slot,text')
function validateDirectiveName(name)
  if isBuiltInDirective(name) then
    warn('Do not use built-in directive ids as custom directive id: ' .. name)
  end
end

function withDirectives(vnode, directives)
  local internalInstance = currentRenderingInstance
  if internalInstance == nil then
    __DEV__ and warn()
    return vnode
  end
  local instance = internalInstance.proxy
  local bindings = vnode.dirs or (vnode.dirs = {})
  local i = 0
  repeat
    local  = directives[i+1]
    if isFunction(dir) then
      dir = {mounted=dir, updated=dir}
    end
    table.insert(bindings, {dir=dir, instance=instance, value=value, oldValue=undefined, arg=arg, modifiers=modifiers})
    i=i+1
  until not(i < #directives)
  return vnode
end

function invokeDirectiveHook(vnode, prevVNode, instance, name)
  local bindings = nil
  local oldBindings = prevVNode and 
  local i = 0
  repeat
    local binding = bindings[i+1]
    if oldBindings then
      binding.oldValue = oldBindings[i+1].value
    end
    -- [ts2lua]binding.dir下标访问可能不正确
    local hook = binding.dir[name]
    if hook then
      callWithAsyncErrorHandling(hook, instance, ErrorCodes.DIRECTIVE_HOOK, {vnode.el, binding, vnode, prevVNode})
    end
    i=i+1
  until not(i < #bindings)
end
