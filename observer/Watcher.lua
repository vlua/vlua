local config = require("config")
local Utils = require("observer.Utils")
local Dep = require("observer.Dep")
local Traverse = require("observer.Traverse")
local Scheduler = require("observer.Scheduler")
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local warn = print
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local parsePath = Utils.parsePath
local removeArrayItem = Utils.removeArrayItem
local pushTarget = Dep.pushTarget
local popTarget = Dep.popTarget
local traverse = Traverse.traverse
local class = Utils.class
local queueWatcher = Scheduler.queueWatcher


local uid = 0

---@class WatcherOptions
---@field deep boolean
---@field user boolean
---@field lazy boolean
---@field sync boolean
---@field before Function

---@alias SimpleSet table
---@alias Function fun():nil
--[[
 * A watcher parses an expression, collects dependencies,
 * and fires callback when the expression value changes.
 * This is used for both the $watch() api and directives.
--]]
---@class Watcher
---@field vm Component
---@field expression string
---@field cb Function
---@field id number
---@field deep boolean
---@field user boolean
---@field lazy boolean
---@field sync boolean
---@field dirty boolean
---@field active boolean
---@field deps Dep[]
---@field newDeps Dep[]
---@field depIds SimpleSet
---@field newDepIds SimpleSet
---@field before Function
---@field getter Function
---@field value any
local Watcher = class("Watcher")

local function _()
    Watcher.new = Watcher.constructor
end
---@param vm Component
---@param expOrFn string | Function
---@param cb Function
---@param options WatcherOptions
---@param isRenderWatcher boolean
---@return Watcher
function Watcher:constructor(
    vm,
    expOrFn,
    cb,
    options,
    isRenderWatcher
  )
    self.vm = vm
    if (isRenderWatcher) then
      vm._watcher = self
    end
    tinsert(vm._watchers, self)
    -- options
    if (options) then
      self.deep = options.deep
      self.user = options.user
      self.lazy = options.lazy
      self.sync = options.sync
      self.before = options.before
     else
      self.deep = false
      self.user = false
      self.lazy = false
      self.sync = false
     end
    self.cb = cb
    uid = uid + 1
    self.id = uid -- uid for batching
    self.active = true
    self.dirty = self.lazy -- for lazy watchers
    self.deps = {}
    self.newDeps = {}
    self.depIds = {}
    self.newDepIds = {}
    self.expression = config.env ~= 'production'
      and expOrFn
      or ''
    -- parse expression for getter
    if (type(expOrFn) == 'function') then
      self.getter = expOrFn
    else
      self.getter = parsePath(expOrFn)
      if (not self.getter) then
        self.getter = function()end
        if config.env ~= 'production' then
            warn(
          'Failed watching path: "${expOrFn}" ' +
          'Watcher only accepts simple dot-delimited paths. ' +
          'For full control, use a function instead.',
          vm
        )
          end
        end
    end
    self.value = self.lazy or self:get()
end

-- Evaluate the getter, and re-collect dependencies.
function Watcher:get()
    pushTarget(self)
    local value
    local vm = self.vm
    -- try {
        value = self.getter(vm)
    -- } catch (e) {
    --   if (self.user) {
    --     handleError(e, vm, 'getter for watcher "${self.expression}"')
    --   else
    --     throw e
    --   }
    -- } finally {
        -- "touch" every property so they are all tracked as
        -- dependencies for deep watching
        if (self.deep) then
            traverse(value)
        end
        popTarget()
        self:cleanupDeps()
    -- }
    return value
end

-- Add a dependency to self directive.
---@param dep Dep
function Watcher:addDep(dep) 
    local id = dep.id
    if (not self.newDepIds[id]) then
        self.newDepIds[id] = true
        tinsert(self.newDeps, dep)
        if (not self.depIds[id]) then
        dep:addSub(self)
        end
    end
end

--[[
* Clean up for dependency collection.
--]]
function Watcher:cleanupDeps() 
    for i = #self.deps , 1, -1 do
        local dep = self.deps[i]
        if (not self.newDepIds[dep.id]) then
        dep:removeSub(self)
        end
    end
    local tmp = self.depIds
    self.depIds = self.newDepIds
    self.newDepIds = tmp
    self.newDepIds = {}
    tmp = self.deps
    self.deps = self.newDeps
    self.newDeps = tmp
    self.newDeps = {}
end

--[[
* Subscriber interface.
* Will be called when a dependency changes.
--]]
function Watcher:update()
    if (self.lazy) then
        self.dirty = true
    elseif (self.sync) then
        self:run()
    else
        queueWatcher(self)
    end
end

--[[
* Scheduler job interface.
* Will be called by the scheduler.
--]]
function Watcher:run()
    if (self.active) then
        local value = self:get()
        if (
            value ~= self.value or
            -- Deep watchers and watchers on Object/Arrays should fire even
            -- when the value is the same, because the value may
            -- have mutated.
            type(value) == "table" or
            self.deep
        ) then
            -- set new value
            local oldValue = self.value
            self.value = value
            if (self.user) then
            --   try {
                self.cb(self.vm, value, oldValue)
            --   } catch (e) {
            --     handleError(e, self.vm, 'callback for watcher "${self.expression}"')
            --   }
            else
                self.cb(self.vm, value, oldValue)
            end
        end
    end
end

--[[
* Evaluate the value of the watcher.
* This only gets called for lazy watchers.
--]]
function Watcher:evaluate ()
    self.value = self:get()
    self.dirty = false
end

--- Depend on all deps collected by self watcher.
function Watcher:depend ()
    for i = #self.deps, 1, -1 do
        self.deps[i]:depend()
    end
end

--- Remove self from all dependencies' subscriber list.
function Watcher:teardown ()
    if (self.active) then
        -- remove self from vm's watcher list
        -- self is a somewhat expensive operation so we skip it
        -- if the vm is being destroyed.
        if (not self.vm._isBeingDestroyed) then
            removeArrayItem(self.vm._watchers, self)
        end
        for i = #self.deps, 1, -1 do
            self.deps[i]:removeSub(self)
        end
        self.active = false
    end
end

return Watcher