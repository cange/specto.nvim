-- Provide the repeat logic which can be triggered by Neovim's dot `.` repeat
-- functionallity.

local Util = require("specto.util")
---@class specto.Repeat
---@field private _last_type specto.ToggleType | specto.JumpType | nil
M = {}
M._last_type = nil

---@private
function M.toggle()
  if M._last_type then
    Util.debug(string.format("repeat:toggle: %q", M._last_type))
    require("specto.toggle").toggle(M._last_type --[[@as specto.ToggleType]])
  end
end

function M.jump()
  if M._last_type then
    Util.debug(string.format("repeat:jump %q", M._last_type))
    require("specto.jump").jump(M._last_type --[[@as specto.JumpType]])
  end
end

---Make the last toggle repeatable
---@param type specto.ToggleType | specto.JumpType| nil
function M.dot_repeat(type)
  M._last_type = type

  if vim.tbl_contains({ "next", "prev" }, type) then
    vim.go.operatorfunc = "v:lua.require'specto.repeat'.jump"
  else
    vim.go.operatorfunc = "v:lua.require'specto.repeat'.toggle"
  end
  vim.api.nvim_feedkeys("g@l", "n", false)
end

return M
