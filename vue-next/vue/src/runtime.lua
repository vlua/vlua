require("@vue/runtime-dom")

local compile = function()
  if __DEV__ then
    -- [ts2lua]lua中0和空字符串也是true，此处__GLOBAL__需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处__ESM_BROWSER__需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处__ESM_BUNDLER__需要确认
    warn( + (__ESM_BUNDLER__ and {} or {(__ESM_BROWSER__ and {} or {(__GLOBAL__ and {} or {})[1]})[1]})[1])
  end
end
