local M = {}

---@type specto.Config
local defaults = {
  exclude = {
    filetypes = {
      "",
      "help",
    },
  },
  languages = {
    ["*"] = {
      filetypes = {},
      file_patterns = {},
      features = {},
    },
    javascript = {
      filetypes = { "javascript", "typescript" },
      file_patterns = { "__tests__/", "%.?test%.", "%.?spec%." },
      features = {
        only = {
          flag = "only",
          keywords = { "it", "describe", "test" },
          prefix = false,
          separator = ".",
        },
        skip = {
          flag = "skip",
          keywords = { "it", "describe", "test" },
          prefix = false,
          separator = ".",
        },
        todo = {
          flag = "todo",
          keywords = { "it", "describe", "test", "bench" },
          prefix = false,
          separator = ".",
        },
      },
    },
    ruby = {
      file_patterns = { "%w_spec.rb$" },
      features = {
        skip = {
          flag = "x",
          keywords = { "context", "describe", "example", "it", "scenario", "specify", "test" },
          prefix = true,
          separator = "",
        },
      },
    },
  },
}

local options = defaults
local augroup_id

---Provides the configuration for a given filetype.
---@param filetype string
---@return specto.ConfigFiletype|nil
function M.get_config(filetype)
  for lang, config in pairs(options.languages) do
    if lang == filetype or vim.tbl_contains(config.filetypes or {}, filetype) then return config end
  end
  return nil
end

---Updates configuration for the current buffer's filetype.
function M.refresh()
  local ft = vim.bo.filetype
  if #ft == 0 or vim.tbl_contains(options.exclude.filetypes, ft) then return end

  local config = M.get_config(ft)
  if not config then return end

  M.filetype_config = {
    file_patterns = config.file_patterns or nil,
    features = vim.tbl_deep_extend("force", options.languages["*"].features, config.features),
    config,
  }
end

---Evaluates the current buffer's filetype and refreshes the configuration.
function M.auto_detection()
  M.refresh()
  augroup_id = vim.api.nvim_create_augroup("SpectoSetup", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = augroup_id,
    desc = "Refresh Specto config on BufEnter",
    callback = function() M.refresh() end,
  })
end

---@return specto.ConfigFiletype|nil
M.filetype_config = nil

---Sets up the configuration for Specto.
---@param opts? specto.Config
function M.setup(opts)
  opts = opts or {}
  options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  M.auto_detection()
end

return setmetatable(M, {
  __index = function(_, key)
    if not options then M.setup() end
    return options[key]
  end,
})
