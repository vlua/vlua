
local vShow = {beforeMount=function(el, , )
  -- [ts2lua]lua中0和空字符串也是true，此处el.style.display == 'none'需要确认
  el._vod = (el.style.display == 'none' and {''} or {el.style.display})[1]
  if transition and value then
    transition:beforeEnter(el)
  else
    setDisplay(el, value)
  end
end
, mounted=function(el, , )
  if transition and value then
    transition:enter(el)
  end
end
, updated=function(el, , )
  if not value == not oldValue then
    return
  end
  if transition then
    if value then
      transition:beforeEnter(el)
      setDisplay(el, true)
      transition:enter(el)
    else
      transition:leave(el, function()
        setDisplay(el, false)
      end
      )
    end
  else
    setDisplay(el, value)
  end
end
, beforeUnmount=function(el, )
  setDisplay(el, value)
end
}
if __NODE_JS__ then
  vShow.getSSRProps = function()
    if not value then
      return {style={display='none'}}
    end
  end
  

end
function setDisplay(el, value)
  -- [ts2lua]lua中0和空字符串也是true，此处value需要确认
  el.style.display = (value and {el._vod} or {'none'})[1]
end
