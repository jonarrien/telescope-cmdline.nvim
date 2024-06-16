local M = {}

-- Utility function to merge results and deduplicate from history
-- @param table1 table: first table
-- @param table2 table: second table
M.merge_results = function(table1, table2)
  for _, v in ipairs(table2) do
    table.insert(table1, v)
  end

  local seen = {}
  for index, item in ipairs(table1) do
    if seen[item.cmd] then
      table.remove(table1, index)
    else
      seen[item.cmd] = true
    end
  end
  return table1
end

-- Prints command output in split view
-- @param lines table: list of lines to print
M.print_output = function(lines, max_height)
  vim.cmd.split()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].filetype = 'sh'
  vim.bo[buf].swapfile = false
  vim.api.nvim_win_set_buf(win, buf)
  vim.cmd.resize(#lines < max_height and #lines or max_height)
end

-- Function to check if a command exists
M.command_exists = function(name)
  local commands = vim.api.nvim_get_commands({})
  return commands[name] ~= nil
end


return M
