---@class SpectoLanguage
---@field file_patterns string[] expects a table of *string-match* patterns.
---@field features table<SpectoFeature>

---@class SpectoFeature
---@field keywords SpectoFeatureKeywords
---@field flag string
---@field separator string
---@field prefix boolean

---@alias SpectoFeatureKeywords string[]
---@alias SpectoType '"only"'|'"skip"'

---@class SpectoConfig
local M = {}

local defaults = {
  languages = {
    ["*"] = {
      file_patterns = {},
      features = {},
    },
    javascript = {
      file_patterns = { "__tests__/", "%.?test%.", "%.?spec%." },
      features = {
        skip = {
          flag = "skip",
          keywords = { "it", "describe", "test" },
          prefix = false,
          separator = ".",
        },
        only = {
          flag = "only",
          keywords = { "it", "describe", "test" },
          prefix = false,
          separator = ".",
        },
      },
    },
    typescript = {
      file_patterns = { "__tests__/", "%.?test%.", "%.?spec%." },
      features = {
        skip = {
          flag = "skip",
          keywords = { "it", "describe", "test" },
          prefix = false,
          separator = ".",
        },
        only = {
          flag = "only",
          keywords = { "it", "describe", "test" },
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

---@type SpectoConfig
local options

---@param opts? SpectoConfig
function M.setup(opts)
  opts = opts or {}
  options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

---@return SpectoLanguage|nil
M.lang_config = nil

---Set the language configuration.
---@param lang_name string
---@param lang_configs SpectoLanguage[]
function M.set_config(lang_name, lang_configs)
  local lang_config = lang_configs[lang_name]
  if not lang_config then return end

  M.lang_config = {
    file_patterns = lang_config.file_patterns or nil,
    features = vim.tbl_deep_extend("force", lang_configs["*"].features, lang_config.features),
  }
end

return setmetatable(M, {
  __index = function(_, key)
    if not options then M.setup() end
    return options[key]
  end,
})
