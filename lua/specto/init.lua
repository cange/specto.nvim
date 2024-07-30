if not rawget(vim, "treesitter") then
  error('[specto] "treesitter" is not defined!')
  return
end

---@class Specto
local M = {}

---@param opts? specto.Config
function M.setup(opts)
  opts = opts or {}
  require("specto.config").setup(opts)
  require("specto.commands").setup()
end

return M
