# vue.lua
vue.js for lua
# 尚在开发中
* 这个库用来提供给游戏lua中使用类似于vue.js 3.0的渐进式框架，设计上可以适用于任何游戏引擎(unity / ue4 / cocos2d-x 等等）或UI库，跟[vue.js 3.0][https://zhuanlan.zhihu.com/p/68477600]的核心思想一样，基于函数式编程思想。

* 因为游戏中渲染机制跟web渲染机制完全不一样，不打算支持template机制。

* 编写了一些示例：
1. [example_01](examples/example_01.lua): 展示基础的可响应数据用法
2. [example_02](examples/example_02.lua): 展示基础的可响应函数用法


* 运行单元测试：
lua test.lua 或者在windows上运行test.bat



* 通过插件形式提供各个游戏引擎的专属支持，各引擎实现在plugins目录中，同时fork各引擎并编写一些示例：
1. [xlua](https://github.com/vlua/vlua.xLua)

