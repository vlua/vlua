require("trycatch")
require("@vue/runtime-core")

function patchDOMProp(el, key, value, prevChildren, parentComponent, parentSuspense, unmountChildren)
  if key == 'innerHTML' or key == 'textContent' then
    if prevChildren then
      unmountChildren(prevChildren, parentComponent, parentSuspense)
    end
    -- [ts2lua]el下标访问可能不正确
    -- [ts2lua]lua中0和空字符串也是true，此处value == nil需要确认
    el[key] = (value == nil and {''} or {value})[1]
    return
  end
  if key == 'value' and el.tagName ~= 'PROGRESS' then
    el._value = value
    -- [ts2lua]lua中0和空字符串也是true，此处value == nil需要确认
    el.value = (value == nil and {''} or {value})[1]
    return
  end
  -- [ts2lua]el下标访问可能不正确
  if value == '' and type(el[key]) == 'boolean' then
    -- [ts2lua]el下标访问可能不正确
    el[key] = true
  -- [ts2lua]el下标访问可能不正确
  elseif value == nil and type(el[key]) == 'string' then
    -- [ts2lua]el下标访问可能不正确
    el[key] = ''
  else
    try_catch{
      main = function()
        -- [ts2lua]el下标访问可能不正确
        el[key] = value
      end,
      catch = function(e)
        if __DEV__ then
          warn( + , e)
        end
      end
    }
  end
end
