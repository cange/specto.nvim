local M = {}

---@param feature specto.Feature
---@param keyword? string
---@return string
function M.generate_flag(feature, keyword)
  local k = keyword or ""
  return feature.prefix and feature.flag .. feature.separator .. k or k .. feature.separator .. feature.flag
end

function M.notify(msg) vim.notify(msg, 2, { title = "Specto" }) end

return M
