require('test.unittest')(function()
    require("reactivity.__tests__.effect_spec")
    require("test.dep_spec")
    require("test.watcher_spec")
    require("test.observer_spec")

    require("test.init_spec")
    require("test.reactiveEval_spec")
    require("test.computed_spec")
    require("test.scheduler_spec")
end)

require('examples.example_01')
require('examples.example_02')