local Util = require("specto.util")
local Config = require("specto.config")
local Tree = require("specto.tree")

---@param patterns string[]|nil
---@return boolean
local function has_file_name_support(patterns)
  if patterns == nil then return false end
  for _, p in ipairs(patterns) do
    if vim.fn.expand("%"):match(p) then return true end
  end
  return false
end

---@param type SpectoType
---@return boolean
local function supported(type)
  local filetype = vim.bo.filetype
  local config = Config.filetype_config
  local has_features = config ~= nil and config.features ~= nil
  local msg = not has_features and string.format("%q is not supported!", filetype) or ""

  if #msg == 0 and not has_file_name_support(config.file_patterns) then
    msg = string.format("File name %q is not supported!", vim.fn.expand("%:t"))
  end
  if #msg == 0 and not config.features[type] then msg = string.format('"%s()" does not support %q!', type, filetype) end

  local is_supported = #msg == 0
  if not is_supported then Util.notify(msg) end
  return is_supported
end

---@class SpectoToggler
local Toggle = {}
Toggle.__index = Toggle

function Toggle:new()
  return setmetatable({
    feature = {},
    flag = "",
    name = "",
    node = nil,
    tree = nil,
  }, self)
end

function Toggle:handle_prefix()
  local content = self.name:find("^" .. self.flag) == 1 and self.name:sub(2) or self.feature.flag .. self.name
  self.tree:replace_text(self.node, content)
end

function Toggle:handle_suffix()
  local range = {}
  local next_text = self.tree:get_text(self.node:next_sibling())
  local separator = self.feature.separator
  local active_ecol = 0
  local active = self.name:match(self.flag .. "$") ~= nil
  local content = active and vim.split(self.name, self.flag)[1] or self.name .. self.flag

  if not active and #separator and next_text == separator then
    active = true
    content = self.name
    active_ecol = #self.flag
  end

  if active then
    local _, scol, _, ecol = self.node:range()
    range = { start_col = scol, end_col = ecol + active_ecol }
  end

  self.tree:replace_text(self.node, content, range)
end

---@param type SpectoType
function Toggle:setup(type)
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

---@class SpectoToggle
local M = {}
local toggle = Toggle:new()

---@example it() => it.only() => it()
function M.only() toggle:setup("only") end

---@example it.skip() => it() => it.skip()
function M.skip() toggle:setup("skip") end

return M
