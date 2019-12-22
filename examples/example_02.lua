local vlua = require('vlua.vlua')

-- 创建可响应的数据
local data = vlua.reactive({
    firstName = 'li',
    lastName = 'jinjun',
    -- 简化的computed函数
    fullName = function(self)
        return self.firstName .. ' ' .. self.lastName
    end
})

-- 创建响应式函数，以一个函数作为响应式函数，当函数中任何一个可响应数据发生改变时，就会触发重新运行整个响应函数
vlua.new(function()
    -- fullName用到了firstName和lastName，所以任意一个改变都会触发
    print(string.format("fullName : %s" , data.fullName))
end)

-- 响应式函数，仅当这个响应式函数中用到的变量改变时，才会触发，父亲触发则会导致字响应函数一起触发
vlua.new(function()
    print(string.format("firstName : %s" , data.firstName))
end)
-- 响应式函数
vlua.new(function()
    print(string.format("lastName : %s" , data.lastName))
end)

-- 调用后会回调打印
print("----------try set firstName")
data.firstName = 'wang'
print("----------try set lastName")
data.lastName = 'jiangjun'
