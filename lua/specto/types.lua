-- Contains shared type declaration.

---@meta

---@alias specto.FeatureKeywords string[]
---@alias specto.Features table<string, specto.Feature>

---@class specto.Feature
---@field keywords specto.FeatureKeywords Defines on which blocks it can be attached to
---@field flag string Defines the actual flag name to be toggled
---@field separator string Defines the separator between keyword and flag
---@field prefix boolean Defines position of flag, false adds flag at the end of a keyword

---@class specto.Language
---@field file_patterns string[]
---@field features specto.Features
---@field filetypes? string[]

---@alias specto.Languages table<string, specto.Language>

---@class specto.Exclude
---@field filetypes string[]

---@class specto.Config
---@field exclude specto.Exclude
---@field languages specto.Languages

---@alias specto.ToggleType '"only"' | '"skip"' | '"todo"'
---@alias specto.JumpType '"next"' | '"prev"'

---@class specto.Tree
---@field type specto.ToggleType
---@field keywords string[]
---@field get_node fun(self: specto.Tree, line?: number): TSNode | nil
---@field get_text fun(self: specto.Tree, node: TSNode): string
---@field replace_text fun(self: specto.Tree, node: TSNode, content: string, range?: specto.ColumnRange)

---@class specto.ColumnRange
---@field start_col number
---@field end_col number
