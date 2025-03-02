---@meta

---@class specto.ConfigFiletype
---@field file_patterns string[] expects a table of *string-match* patterns.
---@field features table<specto.ConfigFeature>
---@field filetypes? string[]

---@class specto.ConfigExclude
---@field filetypes string[]

---@class specto.Config
---@field exclude specto.ConfigExclude
---@field languages table<string, specto.ConfigFiletype>

---@class specto.ConfigFeature
---@field keywords specto.ConfigFeatureKeywords
---@field flag string
---@field separator string
---@field prefix boolean

---@alias specto.FeatureKeywords string[]
---@alias specto.ConfigFeatureKeywords string[]
---@alias specto.ToggleType '"only"'|'"skip"'|'"todo"'

---@class specto.Tree
---@field type specto.ToggleType
---@field keywords string[]
---@field get_node fun(self: specto.Tree): TSNode|nil
---@field get_text fun(self: specto.Tree, node: TSNode): string
---@field replace_text fun(self: specto.Tree, node: TSNode, content: string, range?: specto.ColumnRange)

---@class specto.ColumnRange
---@field start_col number
---@field end_col number
