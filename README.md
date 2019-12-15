# vue.lua
vue for lua
尚在开发中
这个库用来提供给游戏lua中使用类似于vue.js的渐进式框架，设计上可以适用于任何游戏引擎(unity / ue4 / cocos2d-x 等等）或UI库，跟vue.js的核心思想一样。
核心解决mvvm中的vm层，同时提供model层
因为游戏中渲染机制跟web渲染机制完全不一样，不打算支持template机制。
当前已经实现的特性：
observer
data
computed
hook
events

已经通过单元测试的特性：
observer


已实现但尚未测试的特性:
lifecycle
inject
provide

不打算支持的特性：
render
renderProxy
template
