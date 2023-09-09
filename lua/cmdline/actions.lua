local config = require("cmdline.config")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Get selected input from prompt
local get_user_input = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local lines = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, -1, false)
  if #lines == 0 then return "" end
  return string.gsub(lines[1], picker.prompt_prefix, '', 1)
end

-- TODO: Print long messages in split buffer??
local print_output = function(lines)
  vim.cmd('split')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.o.number = false
  vim.o.relativenumber = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_exec2('resize 10', {})
end

-- Runs user input as neovim command, keeping command in history. Uses
-- overseer plugin if enabled for system commands (starting with !)
local run = function(cmd)
  if tonumber(cmd) then
    vim.api.nvim_exec2(cmd , {})
    return
  else
    vim.fn.histadd("cmd", cmd)
  end

  local cmd_ok, nvim_cmd = pcall(vim.api.nvim_parse_cmd, cmd, {})
  if not cmd_ok then
    vim.notify('Invalid command: ' .. cmd, vim.log.levels.ERROR, {})
    return
  end

  if config.values.overseer.enabled and string.sub(cmd, 1, 1) == '!' then
    vim.api.nvim_exec2('OverseerRunCmd ' .. cmd:sub(2), {})
    return
  end

  local output = vim.api.nvim_cmd(nvim_cmd, { output = true })
  local lines = 0

  for _ in output:gmatch("([^\n]*)\n?") do
    lines = lines + 1
  end

  -- TODO: Check better way to avoid long messages
  if #output > 0 and lines <= 7 then
    vim.notify(output, vim.log.levels.INFO, {})
  else
    print_output(vim.split(output, '\n'))
  end
end

local A = {}

A.complete_input = function(prompt_bufnr)
  local command = action_state.get_selected_entry()
  if not command then return end
  local picker = action_state.get_current_picker(prompt_bufnr)
  picker:set_prompt(command.cmd)
end

A.edit = function(prompt_bufnr)
  local command = action_state.get_selected_entry()
  local picker = action_state.get_current_picker(prompt_bufnr)
  picker:set_prompt(command.cmd)
end

-- Runs input if user has entered, otherwise runs first selection
-- from command history (to repeat last action)
A.run_input = function(prompt_bufnr)
  local input = get_user_input(prompt_bufnr)

  if input ~= nil and string.len(input) > 0 then
    actions.close(prompt_bufnr)
    run(input)
  else
    A.run_selection(prompt_bufnr)
  end
end

A.run_selection = function(prompt_bufnr)
  local command = action_state.get_selected_entry()
  if not command then
    command = { id = 1, cmd = get_user_input(prompt_bufnr) }
  end

  if string.len(command.cmd) == 0 then return end
  actions.close(prompt_bufnr)
  run(command.cmd)
end

return A
