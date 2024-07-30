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

---@alias specto.ConfigFeatureKeywords string[]
---@alias specto.ToggleType '"only"'|'"skip"'

---@class specto.Tree
---@field type specto.ToggleType
---@field keywords string[]

---@class specto.ColumnRange
---@field start_col number
---@field end_col number
