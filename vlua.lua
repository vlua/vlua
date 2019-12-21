local Computed = require("observer.Computed")
local Observer = require("observer.Observer")
local Ref = require("observer.Ref")
local ReactiveEval = require("observer.ReactiveEval")

return {
    ref = Ref.ref,
    computed = Computed.computed,
    reactive = Observer.observe,
    reactiveEval = ReactiveEval.reactiveEval
}
