local function compare(a, b)
  return a.cmd < b.cmd
end

-- Arrays to store results
local cache           = {}
cache.commands        = {}
cache.history         = {}
cache.system          = {}

-- Search
local previous_search = ""

local fn              = {}

fn.add_command        = function(index, cmd)
  table.insert(cache.commands, { id = 1000 + index, cmd = cmd, type = 'command' })
end

fn.add_history        = function(index, cmd)
  table.insert(cache.history, { id = index, cmd = cmd, type = 'history' })
end

fn.add_system         = function(index, cmd)
  table.insert(cache.system, { id = index, cmd = "!" .. cmd, type = 'system' })
end

fn.parse_history      = function(entry)
  local d1, d2 = string.find(entry, '%d+')
  local digit = string.sub(entry, d1, d2)
  local _, finish = string.find(entry, '%d+ +')
  return digit, string.sub(entry, finish + 1)
end

-- Public

local M               = {}

M.autocomplete        = function(text)
  if #previous_search == 0 or text:sub(-1) == " " or #text <= #previous_search then
    local split = vim.split(text, " ")
    table.remove(split)
    local input_start = table.concat(split, " ")
    local completions = assert(vim.fn.getcompletion(text, "cmdline"), "No completions found")
    cache.commands = {}

    for i = #completions, 1, -1 do
      local suggestion = table.concat({ input_start, completions[i] }, " ")
      fn.add_command(i, vim.trim(suggestion))
    end
    previous_search = text
  end

  return cache.commands
end

M.system_command      = function(text)
  local split = vim.split(text, ' ')
  local parts = #split
  local input_start = ''

  if parts > 1 then
    table.remove(split)
    input_start = table.concat(split, ' ')
    input_start = string.gsub(input_start, "!", "", 1)
  end

  cache.system = {}
  local completions = assert(vim.fn.getcompletion(text, 'cmdline'), 'No completions found')

  for i = #completions, 1, -1 do
    if parts > 1 then
      local suggestion = table.concat({ input_start, vim.trim(completions[i]) }, ' ')
      fn.add_system(i, suggestion)
    else
      fn.add_system(i, completions[i])
    end
  end

  return cache.system
end

-- Loads full history when no text is provided and matches when text is provided
M.command_history     = function(text)
  local history_string = assert(vim.fn.execute('history cmd'), 'History is empty')
  local history_list = vim.split(history_string, '\n')
  cache.history = {}

  for i = #history_list, 3, -1 do
    local item = history_list[i]

    if text == nil or text == "" then
      fn.add_history(fn.parse_history(item))
    elseif string.find(item, text) then
      fn.add_history(fn.parse_history(item))
    end
  end
  return cache.history
end

M.sort                = function(table)
  table.sort(table, compare)
end

return M
