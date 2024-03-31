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

local config = require("cmdline.config")
local state = require("cmdline.state")
local utils = require("cmdline.utils")

local C = {}

-- Autoomplete user input
--
-- 1. Numbers  => Go to line
-- 2. No input => Show command history to pick latest commands easily
-- 3. System   => Detect commands starting with !
-- 4. When no space is provided:
--    * fuzzy find history
--    * fuzzy find all commands
-- 5. When last character is triggerable:
--    * Use command completion for next batch of results
-- 6 Otherwise, cache last results
--
-- @param text string: user input
C.autocomplete = function(text)
  if tonumber(text) then
    return { { type = 'number', index = 1, cmd = text, desc = 'Go to line ' .. text } }
  end

  local history = state.command_history()
  if #text == 0 then return history end

  -- System commands
  if string.sub(text, 1, 1) == '!' then
    local system_commands = state.system_command(text)
    return utils.merge_results(system_commands, history)
  end

  -- Substitute command
  if string.sub(text, 1, 3) == '%s/' then
    local payload = string.sub(text, 4)
    local components = vim.split(payload, '/')
    local pattern = components[1] or ''
    local replacement = components[2] or ''
    local flags = components[3] or 'g'

    local commands = state.preview_substitute(pattern, replacement, flags)
    return utils.merge_results(commands, history)
  end

  local commands = state.autocomplete(text)
  return utils.merge_results(commands, history)
end

C.preload = function()
  state.preload()
end

C.preview = {
  clean = function(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, config.namespace_id, 0, -1)
  end
}

return C
