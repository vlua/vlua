require("shared/src/makeMap")

local GLOBALS_WHITE_LISTED = 'Infinity,undefined,NaN,isFinite,isNaN,parseFloat,parseInt,decodeURI,' .. 'decodeURIComponent,encodeURI,encodeURIComponent,Math,Number,Date,Array,' .. 'Object,Boolean,String,RegExp,Map,Set,JSON,Intl'
local isGloballyWhitelisted = makeMap(GLOBALS_WHITE_LISTED)