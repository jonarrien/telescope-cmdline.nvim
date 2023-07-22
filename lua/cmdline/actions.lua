local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Get selected input from prompt
local get_user_input = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then return "" end
  return string.gsub(lines[1], _G.cmdline.prompt_prefix, '', 1)
end

-- Add to history and run
local run = function(cmd)
  if not tonumber(cmd) then vim.fn.histadd("cmd", cmd) end
  vim.api.nvim_command(cmd)
end

local A = {}

A.complete_input = function(_)
  local command = action_state.get_selected_entry()
  if not command then return end
  _G.cmdline:set_prompt(command.cmd)
end

A.edit = function(_)
  local command = action_state.get_selected_entry()
  _G.cmdline:set_prompt(command.cmd)
end

A.run_input = function(prompt_bufnr)
  local input = get_user_input(prompt_bufnr)
  actions.close(prompt_bufnr)
  run(input)
end

A.select_item = function(prompt_bufnr)
  local command = action_state.get_selected_entry()
  if not command then
    command = { id = 1, cmd = get_user_input(prompt_bufnr) }
  end

  if string.len(command.cmd) == 0 then return end
  actions.close(prompt_bufnr)
  run(command.cmd)
end

return A
