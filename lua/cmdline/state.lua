-- Characters that trigger new autocompletion
local trigger_characters = { " ", "/" }

-- Arrays to store results
local cache              = {}
cache.all_commands       = {}
cache.commands           = {}
cache.history            = {}
cache.system             = {}

-- Search
local search             = {}
search.previous          = ""
search.current_keyword   = nil

local start_index        = {}
start_index.commands     = 0
start_index.history      = 5000
start_index.system       = 10000

local function compare(a, b)
  return a.cmd < b.cmd
end

local fn            = {}

fn.add_command      = function(index, cmd)
  table.insert(cache.commands, { id = start_index.commands + index, cmd = cmd, type = 'command' })
end

fn.add_history      = function(index, cmd)
  table.insert(cache.history, { id = start_index.history + index, cmd = cmd, type = 'history' })
end

fn.add_system       = function(index, cmd)
  table.insert(cache.system, { id = start_index.system + index, cmd = "!" .. cmd, type = 'system' })
end

fn.parse_history    = function(entry)
  local d1, d2 = string.find(entry, '%d+')
  local digit = string.sub(entry, d1, d2)
  local _, finish = string.find(entry, '%d+ +')
  return digit, string.sub(entry, finish + 1)
end

fn.parse_command    = function(keyword, completions)
  local items = {}
  for i = #completions, 1, -1 do
    local suggestion = table.concat({ keyword, completions[i] }, " ")
    fn.add_command(i, vim.trim(suggestion))
  end
  return items
end

-- Preload existing commands on initialisation
fn.preload_commands = function()
  local list = vim.fn.getcompletion("", "cmdline")
  local completions = assert(list, "No completions found")
  cache.all_commands = {}

  for i = #completions, 1, -1 do
    table.insert(cache.all_commands, {
      id = start_index.commands + i,
      cmd = vim.trim(completions[i]),
      type = 'command'
    })
  end
end


fn.is_trigger_char = function(value)
  for i = 1, #trigger_characters do
    if (trigger_characters[i] == value) then return true end
  end
  return false
end

-- Create a new table, removing duplicates values
-- @param obj {table}
-- @return {table}
fn.uniq            = function(obj)
  local output = {}
  local seen = {}

  for i = 1, #obj do
    local value = obj[i]
    if not seen[value] then
      seen[value] = true
      table.insert(output, value)
    end
  end

  return output
end


-- Public

local M           = {}

-- Autocompletes user input
M.autocomplete    = function(text)
  local splits = vim.split(text, " ")

  if #cache.all_commands == 0 then
    fn.preload_commands()
  end

  if #splits == 0 then return cache.all_commands end

  if #search.previous == 0 or fn.is_trigger_char(text:sub(-1)) or #text < #search.previous then
    table.remove(splits)
    search.current_keyword = vim.trim(table.concat(splits, " "))

    local list = vim.fn.getcompletion(text, "cmdline")
    local completions = assert(list, "No completions found")
    cache.commands = {}

    for i = #completions, 1, -1 do
      local completion = vim.trim(completions[i])
      local suggestion = table.concat({ search.current_keyword, completions[i] }, " ")
      fn.add_command(i, vim.trim(suggestion))
    end
  end

  search.previous = text

  return cache.commands
end

M.preload         = function()
  fn.preload_commands()
end

M.system_command  = function(text)
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

-- Loads full command history
M.command_history = function()
  local history_string = assert(vim.fn.execute('history cmd'), 'History is empty')
  local history_list = vim.split(history_string, '\n')
  cache.history = {}

  for i = #history_list, 3, -1 do
    fn.add_history(fn.parse_history(history_list[i]))
  end
  return fn.uniq(cache.history)
end

M.sort            = function(table)
  table.sort(table, compare)
end

return M
