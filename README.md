<div align="center">

# Specto.nvim

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

</div>

Specto makes it easy to switch certain test blocks on and off depending on the
language and test framework functionality, so that they can be "only" executed
or "skipped".

## Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "cange/specto.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  opts = {}
}
```

## Usage

Allows to toggle certain tests blocks with a `only` or `skip` flag
(see [Supported Language](#supported-languages)).

Calling one of the following within a spec block such as `it(…)`

### skip()

```lua
:lua require('specto.toggle').skip()
-- or
:Specto toggle skip
```

Toggles `it(…)` -> `it.skip(…)` in JavaScript

### only()

```lua
:lua require('specto.toggle').only()
-- or
:Specto toggle only
```

Toggles `it(…)` -> `it.only(…)` in JavaScript

> [!NOTE]
> The feature set depends on the respective language and its testing framework.

### Keybindings

The provided commands can either be called directly via `:Specto toggle *` within
a test block or used via keybinding.

```lua
vim.keymap.set("n", "<leader>to", "<cmd>Specto toggle only<CR>" )
vim.keymap.set("n", "<leader>ts", "<cmd>Specto toggle skip<CR>" )
```

### Scope

Triggering a toggle only applies to the block in which the cursor is currently
located.

```js
describe('context', () => {
  // ↓ toggle applies here
  it.skip('something', () => {
    expect(█)
    //     ↳  cursor here
  })
})
```

## Configuration

Specto comes with the following defaults:

```lua
require("specto").setup({ -- BEGIN_DEFAULT_OPTS
  exclude = {
    filetypes = { -- exclude certain files by default
      "",
      "help",
    }
  },
  languages = {
    -- set default config for all defined languages
    ["*"] = {
      filetypes = {},
      file_patterns = {},
      features = {},
    },
    -- ... other languages
  }
})
```

See [config.lua](./lua/specto/config.lua) for more details.

### Language Settings

Each language can be define an individual set for `only` and `skip` features.

```lua
<LANUGAGE_NAME> = { -- eg. javascript
  filetypes = { "javascript", "typescript" }, -- a subset of supported language

  -- Files or directories where tests can be found.
  -- Expects an array of string patterns that can be used with `string.match`.
  file_patterns = {  }, -- eg. `{ "__tests__/", "%.?spec%." }`

  features = {
    -- subset of criteria of each feature
    only { -- or skip
      flag = "only", -- identfier name
      keywords = { "it", "describe", "test" }, -- defines on which blocks it can be attached to
      prefix = false, -- position of flag, false adds flag at the end of a keyword
      separator = ".", -- defines if an flag came with a certain mark eg. `describe.only`
  },
}
```

### Supported Languages

List of supported languages and their dedicated DSLs (eg. `it`, `describe`, `test`).

| Language                  |  DSL  | Features   | Examples            |
| ------------------------- | :---: | ---------- | ------------------- |
| `javascript`/`typescript` | jest  | only, skip | `it.only`,`it.skip` |
| `ryby`                    | rspec | skip       | `xit`               |
