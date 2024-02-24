local Util = require("specto.util")

---@param type SpectoType
---@param features SpectoFeature[]
---@param active_only? boolean|nil Expose only active keywords (xit, xdescribe, etc.)
---@return SpectoFeatureKeywords
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

---@class SpectoTree
---@field type SpectoType
---@field keywords string[]
local Tree = {}

Tree.__index = Tree

---@param type SpectoType
---@param ft_config SpectoFiletype
---@return SpectoTree
function Tree:new(type, ft_config)
  local keywords = get_keywords(type, ft_config.features)
  assert(keywords, "[specto] keywords are not defined!")
  return setmetatable({ type = type, keywords = keywords }, self)
end

---@class SpectoColumnRange
---@field start_col number
---@field end_col number

-- luacheck: push ignore 212

---@param node TSNode
---@param content string
---@param range? SpectoColumnRange
function Tree:replace_text(node, content, range)
  local start_row, start_col, end_row, end_col = node:range()
  start_col = range and range.start_col or start_col
  end_col = range and range.end_col or end_col
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { content })
end

---@param node TSNode
---@return string
function Tree:get_node_name(node) return vim.treesitter.get_node_text(node, 0) end

-- luacheck: pop

---@param node TSNode
---@return boolean
function Tree:matches(node)
  if not node or not self.keywords then return false end
  return vim.tbl_contains(self.keywords, self:get_node_name(node))
end

---@param node TSNode
---@return TSNode|nil
function Tree:walker(node)
  if not node then
    return nil
  elseif self:matches(node) then
    return node
  elseif node:child_count() > 0 and self:matches(node:child()) then
    return node:child()
  end
  local target = self:walker(node:parent())
  if not target then Util.notify(string.format("%q no target found!", self.type)) end
  return target
end

---@return TSNode|nil
function Tree:get_node() return self:walker(vim.treesitter.get_node()) end

return Tree
