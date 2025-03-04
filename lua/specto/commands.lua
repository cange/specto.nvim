local M = {}

---@param opts {args: string}
local function command(opts)
  opts = opts or { args = "" }
  local params = vim.split(opts.args, "%s+", { trimempty = true })

  local context_name, action_name = params[1], params[2]
  context_name = context_name or "toggle"

  local ok, context = pcall(require, "specto." .. context_name)
  if not action_name then
    if context_name == "toggle" then action_name = "only" end
  end
  if ok then context[action_name]() end
end

local options = {
  nargs = "?",
  complete = function(_, cmd_line)
    local store = {
      [""] = { "toggle" },
      toggle = { "only", "skip", "todo" },
    }
    local has_space = string.match(cmd_line, "%s$")
    local params = vim.split(cmd_line, "%s+", { trimempty = true })

    if #params == 1 then
      return store[""]
    elseif #params == 2 and not has_space then
      return vim.tbl_filter(function(cmd) return not not string.find(cmd, "^" .. params[2]) end, store[""])
    end

    if #params >= 2 and store[params[2]] then
      if #params == 2 then
        return store[params[2]]
      elseif #params == 3 and not has_space then
        return vim.tbl_filter(function(cmd) return not not string.find(cmd, "^" .. params[3]) end, store[params[2]])
      end
    end
  end,
}

---Initializes the Specto command.
function M.setup() vim.api.nvim_create_user_command("Specto", command, options) end

return M
