require("runtime-core/src/component")
require("runtime-core/src/directives")
require("@vue/shared")
require("runtime-core/src/warning")
require("runtime-core/src/vnode")
require(".")

function createAppContext()
  return {config={isNativeTag=NO, devtools=true, performance=false, globalProperties={}, optionMergeStrategies={}, isCustomElement=NO, errorHandler=undefined, warnHandler=undefined}, mixins={}, components={}, directives={}, provides=Object:create(nil)}
end

function createAppAPI(render, hydrate)
  return function createApp(rootComponent, rootProps)
    if rootProps == nil then
      rootProps=nil
    end
    if rootProps ~= nil and not isObject(rootProps) then
      __DEV__ and warn()
      rootProps = nil
    end
    local context = createAppContext()
    local installedPlugins = Set()
    local isMounted = false
    local app = {_component=rootComponent, _props=rootProps, _container=nil, _context=context, version=version, config=function()
      return context.config
    end
    , config=function(v)
      if __DEV__ then
        warn()
      end
    end
    , use=function(plugin, ...)
      if installedPlugins:has(plugin) then
        __DEV__ and warn()
      elseif plugin and isFunction(plugin.install) then
        installedPlugins:add(plugin)
        plugin:install(app, ...)
      elseif isFunction(plugin) then
        installedPlugins:add(plugin)
        plugin(app, ...)
      elseif __DEV__ then
        warn( + )
      end
      return app
    end
    , mixin=function(mixin)
      if __FEATURE_OPTIONS__ then
        if not context.mixins:includes(mixin) then
          table.insert(context.mixins, mixin)
        elseif __DEV__ then
          -- [ts2lua]lua中0和空字符串也是true，此处mixin.name需要确认
          warn('Mixin has already been applied to target app' .. (mixin.name and {} or {''})[1])
        end
      elseif __DEV__ then
        warn('Mixins are only available in builds supporting Options API')
      end
      return app
    end
    , component=function(name, component)
      if __DEV__ then
        validateComponentName(name, context.config)
      end
      if not component then
        -- [ts2lua]context.components下标访问可能不正确
        return context.components[name]
      end
      -- [ts2lua]context.components下标访问可能不正确
      if __DEV__ and context.components[name] then
        warn()
      end
      -- [ts2lua]context.components下标访问可能不正确
      context.components[name] = component
      return app
    end
    , directive=function(name, directive)
      if __DEV__ then
        validateDirectiveName(name)
      end
      if not directive then
        -- [ts2lua]context.directives下标访问可能不正确
        return context.directives[name]
      end
      -- [ts2lua]context.directives下标访问可能不正确
      if __DEV__ and context.directives[name] then
        warn()
      end
      -- [ts2lua]context.directives下标访问可能不正确
      context.directives[name] = directive
      return app
    end
    , mount=function(rootContainer, isHydrate)
      if not isMounted then
        local vnode = createVNode(rootComponent, rootProps)
        vnode.appContext = context
        if __DEV__ then
          context.reload = function()
            render(cloneVNode(vnode), rootContainer)
          end
          
        
        end
        if isHydrate and hydrate then
          hydrate(vnode, rootContainer)
        else
          render(vnode, rootContainer)
        end
        isMounted = true
        app._container = rootContainer
        return ().proxy
      elseif __DEV__ then
        warn( +  +  + )
      end
    end
    , unmount=function()
      if isMounted then
        render(nil, app._container)
      elseif __DEV__ then
        warn()
      end
    end
    , provide=function(key, value)
      if __DEV__ and context.provides[key] then
        warn( + )
      end
      -- [ts2lua]context.provides下标访问可能不正确
      context.provides[key] = value
      return app
    end
    }
    return app
  end
  

end
