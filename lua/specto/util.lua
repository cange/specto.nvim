local M = {}

function M.get_buf_lang()
  local lang = vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "filetype")
  assert(lang or #lang > 0, '[specto] "lang" is not defined!')
  return lang
end

---@param feature SpectoFeature
---@param keyword? string
---@return string
function M.generate_flag(feature, keyword)
  local k = keyword or ""
  return feature.prefix and feature.flag .. feature.separator .. k or k .. feature.separator .. feature.flag
end

function M.notify(msg) vim.notify(msg, 2, { title = "Specto" }) end

return M
