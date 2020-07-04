
function patchClass(el, value, isSVG)
  if value == nil then
    value = ''
  end
  if isSVG then
    el:setAttribute('class', value)
  else
    local transitionClasses = el._vtc
    if transitionClasses then
      -- [ts2lua]lua中0和空字符串也是true，此处value需要确认
      value = ((value and {{value, ...}} or {{...}})[1]):join(' ')
    end
    el.className = value
  end
end
