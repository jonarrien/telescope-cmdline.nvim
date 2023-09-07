-- ============================================================================
-- Command line configuration
-- ============================================================================
-- Provide all results in a single view. Each entry must have the following
-- attributes:
--
-- {
--  index = number
--  cmd   = string
--  type  = string (history|command|system)
--  desc  = string (optional?)
-- }
--
-- The input is split into components.
-- 1. All, except last part, are used for autocompletion
-- 2. The last part is used to filter the list
--
-- In example: `grep something lua/`, it will use `grep something` to trigger
-- autocompletion and `lua/` to filter the completion list.
--
-- ----------------------------------------------------------------------------

local state = require("cmdline.state")

local C = {}

-- @param opts table: user settings
C.setup = function(opts)
  opts = opts or {}
  require("cmdline.config").set_defaults(opts)
end

-- Complete based on user input
-- 1. Load history if no input is provided
-- 2. Numbers => Go to line
-- 3. Detect terminal commands (starting with !)
-- 4. Load completion
-- @param text string: user input
C.load_completion = function(text)
  if string.len(text) == 0 then
    return state.command_history()
  end

  if tonumber(text) then
    return { { type = 'number', index = 1, cmd = text, desc = 'Go to line ' .. text } }
  end

  if string.sub(text, 1, 1) == '!' then
    return state.system_command(text)
  end

  return state.autocomplete(text)
end

return C
