
function ssrRenderSuspense(push, )
  if renderContent then
    push()
    renderContent()
    push()
  else
    push()
  end
end
