require("@vue/compiler-core")
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认

local V_MODEL_RADIO = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local V_MODEL_CHECKBOX = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local V_MODEL_TEXT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local V_MODEL_SELECT = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local V_MODEL_DYNAMIC = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local V_ON_WITH_MODIFIERS = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local V_ON_WITH_KEYS = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local V_SHOW = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local TRANSITION = Symbol((__DEV__ and {} or {})[1])
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
local TRANSITION_GROUP = Symbol((__DEV__ and {} or {})[1])
registerRuntimeHelpers({V_MODEL_RADIO=, V_MODEL_CHECKBOX=, V_MODEL_TEXT=, V_MODEL_SELECT=, V_MODEL_DYNAMIC=, V_ON_WITH_MODIFIERS=, V_ON_WITH_KEYS=, V_SHOW=, TRANSITION=, TRANSITION_GROUP=})