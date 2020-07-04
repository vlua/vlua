require("vue")

local ssrMode = ref(false)
local compilerOptions = reactive({mode='module', prefixIdentifiers=false, optimizeBindings=false, hoistStatic=false, cacheHandlers=false, scopeId=nil})
local App = {setup=function()
  return function()
    local isSSR = ssrMode.value
    local isModule = compilerOptions.mode == 'module'
    local usePrefix = compilerOptions.prefixIdentifiers or compilerOptions.mode == 'module'
    return {h('h1', ), h('a', {href=, target=}, ), ' | ', h('a', {href='https://app.netlify.com/sites/vue-next-template-explorer/deploys', target=}, 'History'), h('div', {id='options-wrapper'}, {h('div', {id='options-label'}, 'Options ↘'), h('ul', {id='options'}, {h('li', {id='mode'}, {h('span', {class='label'}, 'Mode: '), h('input', {type='radio', id='mode-module', name='mode', checked=isModule, onChange=function()
      compilerOptions.mode = 'module'
    end
    }), h('label', {tsvar_for='mode-module'}, 'module'), ' ', h('input', {type='radio', id='mode-function', name='mode', checked=not isModule, onChange=function()
      compilerOptions.mode = 'function'
    end
    }), h('label', {tsvar_for='mode-function'}, 'function')}), h('li', {h('input', {type='checkbox', id='ssr', name='ssr', checked=ssrMode.value, onChange=function(e)
      ssrMode.value = e.target.checked
    end
    }), h('label', {tsvar_for='ssr'}, 'SSR')}), h('li', {h('input', {type='checkbox', id='prefix', disabled=isModule or isSSR, checked=usePrefix or isSSR, onChange=function(e)
      compilerOptions.prefixIdentifiers = e.target.checked or isModule
    end
    }), h('label', {tsvar_for='prefix'}, 'prefixIdentifiers')}), h('li', {h('input', {type='checkbox', id='hoist', checked=compilerOptions.hoistStatic and not isSSR, disabled=isSSR, onChange=function(e)
      compilerOptions.hoistStatic = e.target.checked
    end
    }), h('label', {tsvar_for='hoist'}, 'hoistStatic')}), h('li', {h('input', {type='checkbox', id='cache', checked=(usePrefix and compilerOptions.cacheHandlers) and not isSSR, disabled=not usePrefix or isSSR, onChange=function(e)
      compilerOptions.cacheHandlers = e.target.checked
    end
    }), h('label', {tsvar_for='cache'}, 'cacheHandlers')}), h('li', {h('input', {type='checkbox', id='scope-id', disabled=not isModule, checked=isModule and compilerOptions.scopeId, onChange=function(e)
      -- [ts2lua]lua中0和空字符串也是true，此处isModule and e.target.checked需要确认
      compilerOptions.scopeId = (isModule and e.target.checked and {'scope-id'} or {nil})[1]
    end
    }), h('label', {tsvar_for='scope-id'}, 'scopeId')}), h('li', {h('input', {type='checkbox', id='optimize-bindings', disabled=not isModule or isSSR, checked=(isModule and not isSSR) and compilerOptions.optimizeBindings, onChange=function(e)
      compilerOptions.optimizeBindings = e.target.checked
    end
    }), h('label', {tsvar_for='optimize-bindings'}, 'optimizeBindings')})})})}
  end
  

end
}
function initOptions()
  createApp(App):mount()
end
