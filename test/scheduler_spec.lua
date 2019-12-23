local lu = require("test.luaunit")
local config = require("vlua.config")
local Scheduler = require("vlua.scheduler")
local _queueWatcher, MAX_UPDATE_COUNT = Scheduler.queueWatcher, Scheduler.MAX_UPDATE_COUNT
local vlua = require("vlua.vlua")

local function queueWatcher(watcher)
    watcher.vm = {} -- mock vm
    _queueWatcher(watcher)
end

describe(
    "Scheduler",
    function()
        local spyObj, spy
        beforeEach(
            function()
                config.async = true
                spyObj, spy = lu.createSpy("scheduler")
            end
        )

        afterEach(
            function()
                config.async = false
                lu.clearWarn()
            end
        )

        it(
            "queueWatcher",
            function()
                queueWatcher(
                    {
                        run = spy,
                        id = 1,
                    }
                )
                waitForUpdate()
                lu.assertEquals(#spyObj.calls, 1)
                waitForUpdate()
            end
        )

        it(
            "dedup",
            function()
                queueWatcher(
                    {
                        id = 1,
                        run = spy
                    }
                )
                queueWatcher(
                    {
                        id = 1,
                        run = spy
                    }
                )
                waitForUpdate()
                lu.assertEquals(#spyObj.calls, 1)
                waitForUpdate()
            end
        )

        it(
            "allow duplicate when flushing",
            function()
                local job = {
                    id = 1,
                    run = spy
                }
                queueWatcher(job)
                queueWatcher(
                    {
                        id = 2,
                        run = function()
                            queueWatcher(job)
                        end
                    }
                )
                waitForUpdate()
                lu.assertEquals(#spyObj.calls, 2)
                waitForUpdate()
            end
        )

        it(
            "warn against infinite update loops",
            function()
                local count = 0
                local job
                job = {
                    id = 1,
                    run = function()
                        count = count + 1
                        queueWatcher(job)
                    end
                }
                queueWatcher(job)
                waitForUpdate()
                lu.assertEquals(count, MAX_UPDATE_COUNT + 1)
                lu.toHaveBeenWarned("infinite update loop")

                waitForUpdate()
            end
        )

        it(
            "should call newly pushed watcher after current watcher is done",
            function()
                local callOrder = {}
                queueWatcher(
                    {
                        id = 1,
                        user = true,
                        run = function()
                            table.insert(callOrder, 1)
                            queueWatcher(
                                {
                                    id = 2,
                                    run = function()
                                        table.insert(callOrder, 3)
                                    end
                                }
                            )
                            table.insert(callOrder, 2)
                        end
                    }
                )
                waitForUpdate()
                lu.assertEquals(callOrder, {1, 2, 3})

                waitForUpdate()
            end
        )
    end
)
