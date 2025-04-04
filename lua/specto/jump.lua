local Util = require("specto.util")
local Config = require("specto.config")
local Tree = require("specto.tree")
local api = vim.api

---@class specto.Jumper
local M = {}

local Jump = {}
Jump.__index = Jump

-- Handle compatibility between Lua 5.1 and newer versions
local unpack = table.unpack or unpack

---@return specto.Jumper
function Jump:new() return setmetatable({}, self) end

---Find all active feature flag nodes in the current buffer
---@return TSNode[]
function Jump:find_active_flags()
  local config = Config.filetype_config
  if not config then return {} end

  local nodes = {}
  local seen = {} -- Track seen nodes to avoid duplicates

  -- Pre-create trees for all feature types
  local trees = {}
  for feature_type, _ in pairs(config.features) do
    trees[feature_type] = Tree:new(feature_type, config)
  end

  local ok, root = pcall(function() return vim.treesitter.get_node():tree():root() end)
  if not ok then
    Util.warn("TreeSitter not available")
    return {}
  end

  local queue = { root }

  while #queue > 0 do
    local node = table.remove(queue, 1)
    local id = tostring(node:id())

    if not seen[id] then
      seen[id] = true

      if node:child_count() > 0 then
        for i = 0, node:child_count() - 1 do
          table.insert(queue, node:child(i))
        end
      end

      -- Check node against all trees
      for _, tree in pairs(trees) do
        local matched = tree:next(node, true)
        if matched and tree:is_active_flag(matched) then
          table.insert(nodes, matched)
          break -- Found a match, no need to check other trees
        end
      end
    end
  end

  -- Sort nodes by position
  if #nodes > 0 then
    table.sort(nodes, function(a, b)
      local a_start_row, a_start_col = a:range()
      local b_start_row, b_start_col = b:range()
      return a_start_row < b_start_row or (a_start_row == b_start_row and a_start_col < b_start_col)
    end)
  end

  return nodes
end

---Find next/prev node from current position
---@param nodes TSNode[]
---@param type specto.JumpType
---@return TSNode|nil
function Jump:find_target_node(nodes, type)
  if #nodes == 0 then return nil end

  local cursor_row, cursor_col = unpack(api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- Convert to 0-based index

  if type == "next" then
    for _, node in ipairs(nodes) do
      local start_row, start_col = node:range()
      if start_row > cursor_row or (start_row == cursor_row and start_col > cursor_col) then return node end
    end
    return nodes[1] -- Wrap to first
  else
    local prev_node = nil
    for _, node in ipairs(nodes) do
      local start_row, start_col = node:range()
      if start_row < cursor_row or (start_row == cursor_row and start_col < cursor_col) then
        prev_node = node
      else
        break -- We've gone past current position
      end
    end
    return prev_node or nodes[#nodes] -- Return last found node or wrap to last
  end
end

---@param type specto.JumpType
function Jump:trigger(type)
  local config = Config.filetype_config
  if not config then
    Util.warn("No configuration found for current filetype")
    return
  end

  local active_flags = self:find_active_flags()
  if #active_flags == 0 then
    Util.info("No active feature flags found")
    return
  end

  local target = self:find_target_node(active_flags, type)
  if not target then
    Util.warn("Could not find target node")
    return
  end
  local row, col = target:range()
  -- Convert from 0-based (TreeSitter) to 1-based (Neovim) line numbers
  api.nvim_win_set_cursor(0, { row + 1, col })
end

M._jump = Jump:new()

---@param type specto.JumpType
function M.jump(type) M._jump:trigger(type) end

function M.next() require("specto.repeat").dot_repeat("next") end

function M.prev() require("specto.repeat").dot_repeat("prev") end

return M
