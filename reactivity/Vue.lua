local Reactive = require("reactivity.reactive")
local Computed = require("reactivity.apiComputed")
local Ref = require("reactivity.ref")(Reactive)
local Effect = require("reactivity.effect")
local Binder = require("reactivity.binder")
local Watcher = require("reactivity.apiWatch")

---@class vlua
local vlua = {
    -- 响应式
    reactive = Reactive.reactive,
    readonly = Reactive.readonly,
    shallowReadonly = Reactive.shallowReadonly,
    shallowReactive = Reactive.shallowReactive,
    isReadonly = Reactive.isReadonly,
    isReactive = Reactive.isReactive,
    isShallow = Reactive.isShallow,
    markRaw = Reactive.markRaw,
    -- 引用
    isRef = Ref.isRef,
    ref = Ref.ref,
    shallowRef = Ref.shallowRef,
    readonlyRef = Ref.readonlyRef,
    readonlyShallowRef = Ref.readonlyShallowRef,
    triggerRef = Ref.triggerRef,
    unref = Ref.unref,
    -- 计算属性
    computed = Computed.computed,
    -- 其他
    newBinder = Binder.apiNewBinder,
    newEffect = Effect.effect
}

return vlua
