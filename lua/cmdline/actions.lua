local config = require("cmdline.config")
local utils = require("cmdline.utils")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Get selected input from prompt
local get_user_input = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local lines = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, -1, false)
  if #lines == 0 then return "" end
  return string.gsub(lines[1], picker.prompt_prefix, '', 1)
end

-- Runs user input as neovim command and keeps in history.
local run = function(cmd)
  if tonumber(cmd) then
    vim.api.nvim_exec2(cmd, {})
    return
  end

  -- History
  vim.fn.histadd("cmd", cmd)

  -- Validate command
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, cmd, {})
  if not ok then
    vim.notify('Invalid command: ' .. cmd, vim.log.levels.ERROR, {})
    return
  end

  -- System command
  if string.sub(cmd, 1, 1) == '!' then
    if config.values.overseer.enabled then
      vim.api.nvim_exec2('OverseerRunCmd ' .. cmd:sub(2), {})
      vim.api.nvim_exec2('OverseerOpen', {})
    else
      vim.cmd.split("term://" .. cmd:sub(2))
    end
    return
  end

  -- Run command and get output
  local executed, data = pcall(vim.api.nvim_exec2, cmd, { output = true })
  if not executed then
    -- Parse the trailing fragment of Vimscript-Lua "bridged" error messages
    -- (i.e. `Vim(COMMAND_NAME):E999: Error message`)
    local msg = data:match('Vim%([^)]*%):(.*)$')
    vim.notify('Error executing command: ' .. cmd .. '\n' .. msg, vim.log.levels.ERROR, {})
    return
  end
  -- local data = vim.api.nvim_exec2(cmd, { output = true })
  local output = data.output

  -- Skip output on silent or custom commands
  if #output == 0 or parsed.mods.silent or utils.command_exists(parsed.cmd) then
    return
  end

  local lines = 0
  for _ in output:gmatch("([^\n]*)\n?") do
    lines = lines + 1
  end

  -- Notify small messages
  if lines < config.values.output_pane.min_lines then
    vim.notify(output, vim.log.levels.INFO, {})
    return
  end

  -- Show output in split buffer
  utils.print_output(vim.split(output, '\n'), config.values.output_pane.max_height)
end

local A = {}

A.complete_input = function(prompt_bufnr)
  local command = action_state.get_selected_entry()
  if not command then return end
  local picker = action_state.get_current_picker(prompt_bufnr)
  picker:set_prompt(vim.trim(command.cmd))
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
