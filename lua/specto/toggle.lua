local Util = require("specto.util")
local Config = require("specto.config")
local Tree = require("specto.tree")

---@param patterns string[]|nil
---@return boolean
local function has_filen_ame_support(patterns)
  if patterns == nil then return false end
  for _, p in ipairs(patterns) do
    if vim.fn.expand("%"):match(p) then return true end
  end
  return false
end

---@param type SpectoType
---@return boolean
local function supported(type)
  local language = Util.get_buf_lang()
  local config = Config.lang_config
  local has_features = config ~= nil and config.features ~= nil
  local msg = not has_features and string.format("%q is not supported!", language) or ""

  if #msg == 0 and not has_filen_ame_support(config.file_patterns) then
    msg = string.format("File name %q is not supported!", vim.fn.expand("%:t"))
  end
  if #msg == 0 and not config.features[type] then msg = string.format('"%s()" does not support %q!', type, language) end

  local is_supported = #msg == 0
  if not is_supported then Util.notify(msg) end
  return is_supported
end

---@param type SpectoType
local function setup(type)
  Config.set_config(Util.get_buf_lang(), Config.languages)
  if not supported(type) then return end

  local lang_config = Config.lang_config
  local feature = lang_config.features[type]
  local tree = Tree:new(type, lang_config)
  local node = tree:get_node()
  if not node then return end

  local flag = Util.generate_flag(feature)
  local name = tree:get_node_name(node)

  if feature.prefix then
    local content = name:find("^" .. flag) == 1 and name:sub(2) or feature.flag .. name
    tree:replace_text(node, content)
  else
    local active = name:match(flag .. "$") ~= nil
    local content = active and vim.split(name, flag)[1] or name .. flag
    if active then
      local _, scol, _, ecol = node:range()
      tree:replace_text(node, content, { start_col = scol, end_col = ecol })
    else
      tree:replace_text(node, content)
    end
  end
end

---@class SpectoToggle
local M = {}

---@example it() => it.only() => it()
function M.only() setup("only") end

---@example it.skip() => it() => it.skip()
function M.skip() setup("skip") end

return M
