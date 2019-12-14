local tinsert = table.insert
local isUsingMicroTask = false

local callbacks = {}
local pending = false

local function flushCallbacks ()
  pending = false
  local copies = callbacks
  callbacks = {}
  for i = 1, #copies do
    copies[i]()
  end
end

---@param cb Function
---@param ctx Object
local function nextTick (cb, ctx)
  tinsert(callbacks, function()
    if (cb) then
    --   try {
        cb(ctx)
    --   } catch (e) {
    --     handleError(e, ctx, 'nextTick')
    --   }
     end
    end)
end

return {
  flushCallbacks = flushCallbacks,
  nextTick = nextTick
}