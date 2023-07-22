local C = {}

-- @param opts table: user settings
C.setup = function(opts)
  opts = opts or {}
  require("cmdline.config").set_defaults(opts)
end

-- Load command history
C.load_cmd_history = function()
  local history_string = vim.fn.execute('history cmd')
  local history_list = vim.split(history_string, '\n')

  local results = {}
  for i = #history_list, 3, -1 do
    local item = history_list[i]
    local d1, d2 = string.find(item, '%d+')
    local digit = string.sub(item, d1, d2)
    local _, finish = string.find(item, '%d+ +')
    local cmd = string.sub(item, finish + 1)
    table.insert(results, { index = digit, cmd = cmd })
  end
  return results
end

-- Complete based on user input
C.load_completion = function(text)
  -- Load history if no input is provided
  if string.len(text) == 0 then return C.load_cmd_history() end

  -- Numbers => Go to line
  if tonumber(text) then return { { index = 1, cmd = text } } end

  -- Split input parts
  local split = vim.split(text, ' ')
  table.remove(split)
  local input_start = table.concat(split, ' ')

  -- load completions
  local state = require('cmdline.state')
  state.completions = vim.fn.getcompletion(text, 'cmdline')

  -- return results
  local results = {}
  for i = #state.completions, 1, -1 do
    local suggestion = table.concat({ input_start, state.completions[i] }, ' ')
    table.insert(results, 1, { index = i, cmd = suggestion })
  end
  return results
end

return C
