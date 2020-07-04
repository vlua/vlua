if __BROWSER__ and __DEV__ then
  -- [ts2lua]lua中0和空字符串也是true，此处console.info需要确认
  -- [ts2lua]console下标访问可能不正确
  console[(console.info and {'info'} or {'log'})[1]]( + )
end