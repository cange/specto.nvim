local Util = require("specto.util")

---@param type specto.ToggleType
---@param features specto.Feature[]
---@param active_only? boolean | nil Expose only active keywords (xit, xdescribe, etc.)
---@return specto.FeatureKeywords
local function get_keywords(type, features, active_only)
  assert(features, "[specto] language features are not defined!")
  local feature = features[type]
  local keywords = {}
  for _, k in ipairs(feature.keywords) do
    local flagged_k = Util.generate_flag(feature, k)
    if not active_only then table.insert(keywords, k) end
    if not vim.tbl_contains(keywords, flagged_k) then table.insert(keywords, flagged_k) end
  end
  return keywords
end

---@class specto.Tree
local Tree = {}

Tree.__index = Tree

---@param type specto.ToggleType
---@param ft_config specto.Language
---@return specto.Tree
function Tree:new(type, ft_config)
  local keywords = get_keywords(type, ft_config.features)
  assert(keywords, "[specto] keywords are not defined!")
  return setmetatable({
    type = type,
    keywords = keywords,
    _logged = false,
  }, self)
end

---Replaces node text
---@param node TSNode
---@param content string
---@param range? specto.ColumnRange
function Tree:replace_text(node, content, range)
  local start_row, start_col, end_row, end_col = node:range()
  start_col = range and range.start_col or start_col
  end_col = range and range.end_col or end_col
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { content })
end

---Gets text content of a node
---@param node TSNode | nil
---@return string
function Tree:get_text(node)
  if node == nil then return "" end
  return vim.treesitter.get_node_text(node, 0)
end

---@param node TSNode | nil
---@return boolean
function Tree:matches(node)
  if not node or not self.keywords then return false end
  return vim.tbl_contains(self.keywords, self:get_text(node))
end

---@param node TSNode | nil
---@return TSNode | nil
function Tree:next(node)
  if not node then
    return nil
  elseif self:matches(node) then
    return node
  elseif node:child_count() > 0 and self:matches(node:child(0)) then
    return node:child(0)
  end
  local target = self:next(node:parent())
  if not target and not self._notified then
    Util.notify(string.format("%q no target found!", self.type))
    self._notified = true
  end
  return target
end

---Gets the current tree node
---@return TSNode | nil
function Tree:get_node()
  self._notified = false
  return self:next(vim.treesitter.get_node())
end

return Tree
