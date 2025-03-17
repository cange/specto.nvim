# Specto.nvim Project Context

## Project Overview

- Neovim plugin for dynamic test control through modifier toggles
- Supports JavaScript/TypeScript and Ruby RSpec test frameworks
- Uses nvim-treesitter for parsing

## Key Dependencies

- Neovim >= 0.9.0
- nvim-treesitter

## Core Files

- `/lua/specto/init.lua` - Main plugin entry
- `/lua/specto/config.lua` - Configuration handling
- `/lua/specto/types.lua` - Type definitions
- `/lua/specto/languages/` - Language specific implementations

## Coding Conventions

- Uses LuaLS/lua-language-server type annotations
- Follows Neovim Lua style guide
- Tests located in `tests/` directory
- Fixtures located in `fixutres/` directory

## Configuration Schema

```lua
---@type specto.Config
{
  exclude = {
    filetypes = { "help" }
  },
  languages = {
    -- language specific configs
  }
}
```
