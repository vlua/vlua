local Computed = require("observer.Computed")
local Observer = require("observer.Observer")
local Ref = require("observer.Ref")
local ReactiveCall = require("observer.ReactiveCall")
local observe = Observer.observe
local function reactive(value)
    observe(value)
    return value
end
return {
    ref = Ref.ref,
    computed = Computed.computed,
    reactive = reactive,
    reactiveCall = ReactiveCall.reactiveCall
}
