local lu = require("test.luaunit")
local vlua = require("vlua.vlua")
local warn = print

local function isUndef(v)
    return v == nil
end
local function isDef(a)
    return a ~= nil
end

local function isTrue(a)
    return a == true
end

local function sameNode(a, b)
    return a == b
end

local function sameVnode(a, b)
    return (a.key == b.key and
        ((a.tag == b.tag and a.isComment == b.isComment and isDef(a.data) == isDef(b.data) and sameInputType(a, b)) or
            (isTrue(a.isAsyncPlaceholder) and a.asyncFactory == b.asyncFactory and isUndef(b.asyncFactory.error))))
end

local function checkDuplicateKeys(children)
    local seenKeys = {}
    for i = 1, #children do
        local vnode = children[i]
        local key = vnode.key
        if (isDef(key)) then
            if (seenKeys[key]) then
                warn("Duplicate keys detected: {" .. key .. "}. This may cause an update error.", vnode.context)
            else
                seenKeys[key] = true
            end
        end
    end
end

local function findIdxInOld(node, oldCh, start, endi)
    for i = start, endi do
        local c = oldCh[i]
        if (isDef(c) and sameNode(node, c)) then
            return i
        end
    end
end
local function createKeyToOldIdx(children, beginIdx, endIdx)
    local key
    local map = {}
    for i = beginIdx, endIdx do
        key = children[i].key
        if (isDef(key)) then
            map[key] = i
        end
    end
    return map
end

local function patchVnode(oldVnode, vnode, insertedVnodeQueue, ownerArray, index, removeOnly)
    if (oldVnode == vnode) then
        return
    end
    print("patchVnode" , oldVnode.elm, vnode.elm, index)
end
local function insertBefore(parent, node, before)
    print("insertBefore" , node, before)
end

local function nextSibling(node)

end
local function createElm(vnode, insertedVnodeQueue, parentElm, refElm, nested, ownerArray, index)

    print("createElm" , vnode.elm , index)
end

local function removeElm(elm)

    print("removeElm" , elm)
end

local function addVnodes(parentElm, refElm, vnodes, startIdx, endIdx, insertedVnodeQueue)
    for i = startIdx, endIdx do
        createElm(vnodes[i], insertedVnodeQueue, parentElm, refElm, false, vnodes, i)
    end
end

local function removeVnodes(vnodes, startIdx, endIdx)
    for i = startIdx, endIdx do
        local ch = vnodes[i]
        if (isDef(ch)) then
            removeElm(ch.elm)
        end
    end
end

local function updateChildren(parentElm, oldCh, newCh, insertedVnodeQueue, removeOnly)
    local oldStartIdx = 1
    local newStartIdx = 1
    local oldEndIdx = #oldCh
    local oldStartVnode = oldCh[1]
    local oldEndVnode = oldCh[oldEndIdx]
    local newEndIdx = #newCh
    local newStartVnode = newCh[1]
    local newEndVnode = newCh[newEndIdx]
    local oldKeyToIdx, idxInOld, vnodeToMove, refElm

    -- removeOnly is a special flag used only by <transition-group>
    -- to ensure removed elements stay in correct relative positions
    -- during leaving transitions
    local canMove = not removeOnly

    -- if (process.env.NODE_ENV !== 'production') {
    --   checkDuplicateKeys(newCh)
    -- }

    while (oldStartIdx <= oldEndIdx and newStartIdx <= newEndIdx) do
        if (isUndef(oldStartVnode)) then
            oldStartIdx = oldStartIdx + 1
            oldStartVnode = oldCh[oldStartIdx] -- Vnode has been moved left
        elseif (isUndef(oldEndVnode)) then
            oldEndIdx = oldEndIdx - 1
            oldEndVnode = oldCh[oldEndIdx]
        elseif (sameNode(oldStartVnode, newStartVnode)) then
            patchVnode(oldStartVnode, newStartVnode, insertedVnodeQueue, newCh, newStartIdx)
            oldStartIdx = oldStartIdx + 1
            oldStartVnode = oldCh[oldStartIdx]
            newStartIdx = newStartIdx + 1
            newStartVnode = newCh[newStartIdx]
        elseif (sameNode(oldEndVnode, newEndVnode)) then
            patchVnode(oldEndVnode, newEndVnode, insertedVnodeQueue, newCh, newEndIdx)
            oldEndIdx = oldEndIdx - 1
            oldEndVnode = oldCh[oldEndIdx]
            newEndIdx = newEndIdx - 1
            newEndVnode = newCh[newEndIdx]
        elseif (sameNode(oldStartVnode, newEndVnode)) then -- Vnode moved right
            patchVnode(oldStartVnode, newEndVnode, insertedVnodeQueue, newCh, newEndIdx)
            if canMove then
                insertBefore(parentElm, oldStartVnode.elm, oldEndVnode.elm)
            end
            oldStartIdx = oldStartIdx + 1
            oldStartVnode = oldCh[oldStartIdx]
            newEndIdx = newEndIdx - 1
            newEndVnode = newCh[newEndIdx]
        elseif (sameNode(oldEndVnode, newStartVnode)) then -- Vnode moved left
            patchVnode(oldEndVnode, newStartVnode, insertedVnodeQueue, newCh, newStartIdx)
            if canMove then
                insertBefore(parentElm, oldEndVnode.elm, oldStartVnode.elm)
            end
            oldEndIdx = oldEndIdx
            oldEndVnode = oldCh[oldEndIdx]
            newStartIdx = newStartIdx + 1
            newStartVnode = newCh[newStartIdx]
        else
            if (isUndef(oldKeyToIdx)) then
                oldKeyToIdx = createKeyToOldIdx(oldCh, oldStartIdx, oldEndIdx)
            end
            idxInOld =
                isDef(newStartVnode.key) and oldKeyToIdx[newStartVnode.key] or
                findIdxInOld(newStartVnode, oldCh, oldStartIdx, oldEndIdx)
            if (isUndef(idxInOld)) then -- New element
                createElm(newStartVnode, insertedVnodeQueue, parentElm, oldStartVnode.elm, false, newCh, newStartIdx)
            else
                vnodeToMove = oldCh[idxInOld]
                if (sameNode(vnodeToMove, newStartVnode)) then
                    patchVnode(vnodeToMove, newStartVnode, insertedVnodeQueue, newCh, newStartIdx)
                    oldCh[idxInOld] = nil
                    if canMove then
                        insertBefore(parentElm, vnodeToMove.elm, oldStartVnode.elm)
                    end
                else
                    -- same key but different element. treat as new element
                    createElm(
                        newStartVnode,
                        insertedVnodeQueue,
                        parentElm,
                        oldStartVnode.elm,
                        false,
                        newCh,
                        newStartIdx
                    )
                end
            end
            newStartIdx = newStartIdx + 1
            newStartVnode = newCh[newStartIdx]
        end
    end
    if (oldStartIdx > oldEndIdx) then
        refElm = isUndef(newCh[newEndIdx + 1]) or newCh[newEndIdx + 1].elm
        addVnodes(parentElm, refElm, newCh, newStartIdx, newEndIdx, insertedVnodeQueue)
    elseif (newStartIdx > newEndIdx) then
        removeVnodes(oldCh, oldStartIdx, oldEndIdx)
    end
end

describe(
    "Initialization",
    function()
        it(
            "with new",
            function()

                local elements = {
                    {elm = "1"},
                    {elm = "2"},
                    {elm = "3"},
                    {elm = "4"},
                    {elm = "5"}
                }

                local oldElements = {
                    elements[1],
                    elements[2],
                    elements[4],
                    elements[5],
                    elements[4],
                    elements[5],
                    elements[4],
                    elements[5],
                    elements[4],
                    elements[5],
                    elements[3],
                }
                local newElements = {
                    elements[1],
                    elements[3],
                    elements[3],
                    elements[2],
                    elements[3],
                    elements[2],
                    elements[3],
                    elements[2],
                    elements[3],
                    elements[2],
                    elements[3],
                    elements[2],
                }

                updateChildren(nil, oldElements, newElements)
                print(newElements)
            end
        )
    end
)
