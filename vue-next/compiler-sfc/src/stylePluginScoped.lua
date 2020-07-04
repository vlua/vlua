
function isSpaceCombinator(node)
  return node.type == 'combinator' and ('^%s+$'):test(node.value)
end
