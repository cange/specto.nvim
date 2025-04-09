local M = {}
M._debug = false

---@param feature specto.Feature
---@param keyword? string
---@return string
function M.generate_flag(feature, keyword)
  local k = keyword or ""
  return feature.prefix and feature.flag .. feature.separator .. k or k .. feature.separator .. feature.flag
end

function M.warn(msg) vim.notify(msg, vim.log.levels.WARN, { title = "Specto" }) end
function M.debug(msg)
  if M._debug then vim.notify(msg, vim.log.levels.DEBUG, { title = "Specto" }) end
end
function M.info(msg) vim.notify(msg, vim.log.levels.INFO, { title = "Specto" }) end

return M
