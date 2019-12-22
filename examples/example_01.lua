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

-- 创建用来绑定函数的绑定器
local binder = vlua.createBinder(data)

print(string.format("fullname : %s" , data.fullName))
-- 绑定一个字段与函数回调
binder:watch('firstName' , function(data, value, old)
    print(string.format("firstName Changed : %s -> %s" , old, value))
end)

binder:watch('lastName' , function(data, value, old)
    print(string.format("lastName Changed : %s -> %s" , old, value))
end)

binder:watch('fullName' , function(data, value, old)
    print(string.format("fullName Changed : %s -> %s" , old, value))
end)

-- 调用后会回调打印
data.firstName = 'wang'
data.lastName = 'jiangjun'
