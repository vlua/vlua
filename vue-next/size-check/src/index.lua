require("@vue/runtime-dom")

createApp({render=function()
  h('div', 'hello world!')
end
}):mount('#app')