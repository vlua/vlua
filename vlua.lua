local Computed = require("observer.Computed")
local Observer = require("observer.Observer")
local Ref = require("observer.Ref")
local ReactiveEval = require("observer.ReactiveEval")
local observe = Observer.observe
local function reactive(value)
    observe(value)
    return value
end
return {
    ref = Ref.ref,
    computed = Computed.computed,
    reactive = reactive,
    reactiveEval = ReactiveEval.reactiveEval
}
