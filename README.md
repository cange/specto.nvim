<div align="center">

# Specto.nvim

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

Specto is a Neovim plugin that enables dynamic test control through modifier
toggles. It provides framework-specific controls to mark tests as "only",
"skip", or "todo" across different programming languages.

  <figure>
    <video src="https://github.com/cange/specto.nvim/assets/28717/a665e41c-6d09-4a1e-92c0-5db9ad513773" type="video/mp4"></video>
    <figcaption>
      Move to a certain code block and use one of the provided toggles (see 
      <a href="#usage">Usage</a>).
    </figcaption>
  </figure>
</div>

## Features

- Toggle test modifiers in JavaScript/TypeScript test files

  - `it()` ⟷ `it.only()`
  - `it()` ⟷ `it.skip()`
  - `it()` ⟷ `it.todo()`
  - Works with `describe()` and `test()` blocks too

- Support for Ruby RSpec files

  - Toggle skip prefix: `it()` ⟷ `xit()`
  - Works with `context`, `describe`, `example`, `scenario`, `specify`, and
    `test` blocks

- Navigation between active feature flags

  - Jump to next/previous active flag (e.g. `it.only`, `describe.skip`)
  - Circular navigation (wraps around buffer)

- Smart detection of common test files (e.g. `*.spec.js`, `*_spec.rb`, etc.)
- Dot-repeat previous actions

### Scope

Triggering a toggle only applies to the block in which the cursor is currently
located.

```js
describe('context', () => {
  // ↓ toggle applies here
  it.skip('something', () => {
    expect(|)
    //     ^ cursor here
  })
})
```

## Getting Started

### Requirements

- Neovim >= 0.9.0
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

### Installation

Install the plugin with your preferred package manager:

```lua
-- lazy.nvim
{
  "cange/specto.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  ---@type specto.Config
  opts = {
    -- your configuration comes here or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
```

## Configuration

Specto comes with the following defaults:

```lua
---@type specto.Config
{
  ---@type specto.Exclude
  exclude = {
    filetypes = { -- exclude certain files by default
      "help",
    }
  },
  ---@type specto.Languages
  languages = {
    -- set default config for all defined languages
  }
})
```

See also [config.lua](./lua/specto/config.lua) and
[types.lua](./lua/specto/types.lua) declaration.

### Language Settings

Each language can define an individual set for `only` and `skip` features.

```lua
javascript = { -- example: "ruby", etc.
  filetypes = { "javascript", "typescript" }, -- a subset of supported language

  -- Files or directories where tests can be found.
  -- Expects an array of string patterns that can be used with `string.match`.
  file_patterns = {  }, -- eg. `{ "__tests__/", "%.?spec%." }`

  features = {
    -- subset of criteria of each feature
    only = { -- or skip, todo
      flag = "only", -- Defines the actual flag name to be toggled
      keywords = { "it", "describe", "test" }, -- Defines on which blocks it can be attached to
      prefix = false, -- Defines position of flag, false adds flag at the end of a keyword
      separator = ".", -- Defines the separator between keyword and flag
    },
  },
}
```

### Commands

```lua
:Specto toggle skip
:Specto toggle only
:Specto toggle todo
:Specto jump next
:Specto jump prev
```

> [!NOTE]
> The feature set depends on the respective language and its testing framework.

### Keybindings

The provided commands can either be called directly via `:Specto toggle *` within
a test block or used via keybinding.

```lua
-- Toggle bindings
vim.keymap.set("n", "<leader>to", "<cmd>Specto toggle only<CR>", { desc = "Toggle test only" })
vim.keymap.set("n", "<leader>ts", "<cmd>Specto toggle skip<CR>", { desc = "Toggle test skip" })
vim.keymap.set("n", "<leader>tt", "<cmd>Specto toggle todo<CR>", { desc = "Toggle test todo" })

-- Navigation bindings
vim.keymap.set("n", "]t", "<cmd>Specto jump next<CR>", { desc = "Go to next toggle" })
vim.keymap.set("n", "[t", "<cmd>Specto jump prev<CR>", { desc = "Go to previous toggle" })
```

## Contributing

All contributions are welcome! Just open a pull request. Please read
[CONTRIBUTING.md](./CONTRIBUTING.md).
