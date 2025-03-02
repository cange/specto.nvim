local Util = require("specto.util")
local Config = require("specto.config")
local Tree = require("specto.tree")

---@class specto.Toggle
---@field private _toggle specto.Toggler
---@field private _last_toggle_type specto.ToggleType|nil
local M = {}

-- Keep filename cache local to module
local function get_expanded_filename() return vim.fn.expand("%") end
M._filename_cache = nil

---Check if current filename matches any of the given patterns
---@param patterns string[]|nil
---@return boolean
local function has_file_name_support(patterns)
  if patterns == nil then return false end
  if not M._filename_cache then M._filename_cache = get_expanded_filename() end

  for _, p in ipairs(patterns) do
    if M._filename_cache:match(p) then return true end
  end
  return false
end

---Checks if the given toggle type is supported for current file
---@param type specto.ToggleType The type of toggle to check
---@return boolean Whether the toggle type is supported
---@error "Unsupported filetype" when filetype or feature not supported
local function supported(type)
  local filetype = vim.bo.filetype
  local config = Config.filetype_config

  -- Check if filetype has feature support
  local has_feature_support = config ~= nil and config.features ~= nil
  if not has_feature_support then
    Util.notify(string.format("%q is not supported!", filetype))
    return false
  end

  -- Check filename pattern support
  if not has_file_name_support(config.file_patterns) then
    Util.notify(string.format("File name %q is not supported!", vim.fn.expand("%:t")))
    return false
  end

  -- Check specific feature support
  if not config.features[type] then
    Util.notify(string.format('"%s()" does not support %q!', type, filetype))
    return false
  end

  return true
end

---@class specto.Toggler
local Toggle = {}
Toggle.__index = Toggle

---Creates a new Toggle instance
---@return specto.Toggler
function Toggle:new()
  local instance = {
    feature = {},
    flag = "",
    name = "",
    node = nil,
    tree = nil,
  }
  return setmetatable(instance, self)
end

---Handles prefix-based toggle functionality
---@return nil
---@error "Missing feature flag" when feature flag not configured
function Toggle:handle_prefix()
  if not self.feature.flag then
    Util.notify("Missing feature flag configuration")
    return
  end

  local has_prefix = self.name:find("^" .. self.flag) == 1
  local content = has_prefix and self.name:sub(2) or self.feature.flag .. self.name
  self.tree:replace_text(self.node, content)
end

---Get the active state and content for suffix toggle
---@param name string Current node name
---@param flag string Toggle flag
---@param next_text string Text of next sibling
---@param separator string Separator configuration
---@return boolean is_active
---@return string content
---@return number active_col_offset
local function get_suffix_state(name, flag, next_text, separator)
  local active = has_flag_suffix(name, flag)
  local content = active and vim.split(name, flag)[1] or name .. flag
  local active_ecol = 0

  if not active and #separator > 0 and next_text == separator then
    active = true
    content = name
    active_ecol = #flag
  end

  return active, content, active_ecol
end

---Calculate range for suffix replacement
---@param node userdata TSNode
---@param is_active boolean
---@param col_offset number
---@return table range
local function calculate_suffix_range(node, is_active, col_offset)
  if not is_active then return {} end

  local _, scol, _, ecol = node:range()
  return { start_col = scol, end_col = ecol + col_offset }
end

---Handles suffix-based toggle functionality
---@return nil
function Toggle:handle_suffix()
  local next_text = self.tree:get_text(self.node:next_sibling())
  local active, content, active_ecol = get_suffix_state(self.name, self.flag, next_text, self.feature.separator)
  local range = calculate_suffix_range(self.node, active, active_ecol)
  self.tree:replace_text(self.node, content, range)
end

---Executes the toggle action
---@param type specto.ToggleType
function Toggle:trigger(type)
  if not supported(type) then return end

  local ft_config = Config.filetype_config
  self.feature = ft_config.features[type]
  self.tree = Tree:new(type, ft_config)
  self.node = self.tree:get_node()
  if not self.node then return end

  self.flag = Util.generate_flag(self.feature)
  self.name = self.tree:get_text(self.node)

  if self.feature.prefix then
    self:handle_prefix()
  else
    self:handle_suffix()
  end
end

M._toggle = Toggle:new()
M._last_toggle_type = nil

---Make the last toggle repeatable
---@param type specto.ToggleType
local function dot_repeat(type)
  M._last_toggle_type = type
  vim.go.operatorfunc = "v:lua.require'specto.toggle'.repeat_toggle"
  vim.api.nvim_feedkeys("g@l", "n", false)
end

---@private
function M.repeat_toggle()
  if M._last_toggle_type then M._toggle:trigger(M._last_toggle_type) end
end

---Toggle a test to run exclusively
---@description Toggles between it() and it.only()
---@since 0.1.0
function M.only() dot_repeat("only") end

---Toggle skipping a test
---@description Toggles between it() and it.skip()
---@since 0.1.0
function M.skip() dot_repeat("skip") end

---Toggle marking test as todo
---@description Toggles between it() and it.todo()
---@since 0.2.0
function M.todo() dot_repeat("todo") end

return M
