require("@vue/compiler-dom")
require("@vue/compiler-dom/NodeTypes")
require("compiler-ssr/src/ssrCodegenTransform")
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。

local ssrTransformIf = createStructuralDirectiveTransform(/^(if|else|else-if)$/, processIf)
function ssrProcessIf(node, context)
  local  = node.branches
  local ifStatement = createIfStatement(processIfBranch(rootBranch, context))
  context:pushStatement(ifStatement)
  local currentIf = ifStatement
  local i = 1
  repeat
    local branch = node.branches[i+1]
    local branchBlockStatement = processIfBranch(branch, context)
    if branch.condition then
      currentIf.alternate = createIfStatement(branch.condition, branchBlockStatement)
      currentIf = currentIf.alternate
    else
      currentIf.alternate = branchBlockStatement
    end
    i=i+1
  until not(i < #node.branches)
  if not currentIf.alternate then
    currentIf.alternate = createBlockStatement({createCallExpression({'`<!---->`'})})
  end
end

function processIfBranch(branch, context)
  local  = branch
  local needFragmentWrapper = (#children ~= 1 or children[0+1].type ~= NodeTypes.ELEMENT) and not (#children == 1 and children[0+1].type == NodeTypes.FOR)
  return processChildrenAsStatement(children, context, needFragmentWrapper)
end
