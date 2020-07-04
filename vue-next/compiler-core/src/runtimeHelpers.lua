
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local FRAGMENT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local TELEPORT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local SUSPENSE = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local KEEP_ALIVE = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local BASE_TRANSITION = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local OPEN_BLOCK = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local CREATE_BLOCK = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local CREATE_VNODE = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local CREATE_COMMENT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local CREATE_TEXT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local CREATE_STATIC = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local RESOLVE_COMPONENT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local RESOLVE_DYNAMIC_COMPONENT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local RESOLVE_DIRECTIVE = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local WITH_DIRECTIVES = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local RENDER_LIST = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local RENDER_SLOT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local CREATE_SLOTS = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local TO_DISPLAY_STRING = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local MERGE_PROPS = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local TO_HANDLERS = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local CAMELIZE = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local SET_BLOCK_TRACKING = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local PUSH_SCOPE_ID = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local POP_SCOPE_ID = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local WITH_SCOPE_ID = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local WITH_CTX = Symbol((__DEV__ and {} or {})[1])
local helperNameMap = {FRAGMENT=, TELEPORT=, SUSPENSE=, KEEP_ALIVE=, BASE_TRANSITION=, OPEN_BLOCK=, CREATE_BLOCK=, CREATE_VNODE=, CREATE_COMMENT=, CREATE_TEXT=, CREATE_STATIC=, RESOLVE_COMPONENT=, RESOLVE_DYNAMIC_COMPONENT=, RESOLVE_DIRECTIVE=, WITH_DIRECTIVES=, RENDER_LIST=, RENDER_SLOT=, CREATE_SLOTS=, TO_DISPLAY_STRING=, MERGE_PROPS=, TO_HANDLERS=, CAMELIZE=, SET_BLOCK_TRACKING=, PUSH_SCOPE_ID=, POP_SCOPE_ID=, WITH_SCOPE_ID=, WITH_CTX=}
function registerRuntimeHelpers(helpers)
  Object:getOwnPropertySymbols(helpers):forEach(function(s)
    helperNameMap[s+1] = helpers[s+1]
  end
  )
end
