local decoder = nil
function decodeHtmlBrowser(raw)
  
  (decoder or (decoder = document:createElement('div'))).innerHTML = raw
  return decoder.textContent
end
