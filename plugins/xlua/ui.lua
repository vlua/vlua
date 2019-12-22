local Binder = require("vlua.binder")

local ui = {}

ui.install = function()
    --- auto bind all uievent
    ---@param cb Function
    function Binder:bindUIEvent(event, cb)
        event:AddListener(cb)
        self:autoTeardown(
            function()
                event:RemoveListener(cb)
            end
        )
    end

    --- one way bind to text
    ---@param text UnityEngine.ui.Text
    ---@param expOrFn fun():string | string
    function Binder:bindText(text, expOrFn)
        self:watch(expOrFn, function(source, value, oldValue)
            text.text = value
        end, true)
    end

    --- double way binding to inputfield
    function Binder:bindInputField(inputField, exp)
        -- one way to text
        self:watch(exp, function(source, value, oldValue)
            inputField.text = value
        end, true)
        -- one way to source
        self:bindUIEvent(inputField.onValueChanged, function(text)
            self.source[exp] = text
        end)
    end
end
return ui

