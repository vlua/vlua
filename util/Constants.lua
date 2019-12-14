local SSR_ATTR = 'data-server-rendered'

local ASSET_TYPES = {
  'component',
  'directive',
  'filter'
}

local LIFECYCLE_HOOKS = {
  'beforeCreate',
  'created',
  'beforeMount',
  'mounted',
  'beforeUpdate',
  'updated',
  'beforeDestroy',
  'destroyed',
  'activated',
  'deactivated',
  'errorCaptured',
  'serverPrefetch'
}

return {
  SSR_ATTR = SSR_ATTR,
  ASSET_TYPES = ASSET_TYPES,
  LIFECYCLE_HOOKS = LIFECYCLE_HOOKS
}