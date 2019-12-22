require('test.unittest')(function()
    require("test.dep_spec")
    require("test.watcher_spec")
    require("test.observer_spec")

    require("test.init_spec")
    require("test.reactiveEval_spec")
    require("test.computed_spec")
end)