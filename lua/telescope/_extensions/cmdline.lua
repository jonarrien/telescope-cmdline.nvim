local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorter = require("telescope.sorters")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local entry_display = require("telescope.pickers.entry_display")

local default_config = {
  icon = "󰣿 ",
  picker = {
    layout_config = {
      width = 80,
      height = 20,
    }
  }
}

local state = {
  picker = nil,
  command_history = nil,
  completiongs = nil,
}

local fn = {}

fn.get_input = function (bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then return "" end
  return string.gsub(lines[1], state.picker.prompt_prefix, '', 1)
end

fn.run = function (cmd)
  vim.api.nvim_command(cmd)
  vim.fn.histadd("cmd", cmd)
end

local action = {}

action.complete_input = function (_)
  local command = action_state.get_selected_entry()
  if not command then return end
  state.picker:set_prompt(command.cmd)
end

action.edit = function (_)
  local command = action_state.get_selected_entry()
  state.picker:set_prompt(command.cmd)
end

action.run_input = function (prompt_bufnr)
  local input = fn.get_input(prompt_bufnr)
  actions.close(prompt_bufnr)
  fn.run(input)
end

action.select_item = function (prompt_bufnr)
  local command = action_state.get_selected_entry()
  if not command then
    command = { id = 1, cmd = fn.get_input(prompt_bufnr) }
  end

  if string.len(command.cmd) == 0 then return end
  actions.close(prompt_bufnr)
  fn.run(command.cmd)
end


local function load_cmd_history()
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


local function load_completion(text)
  -- Show command history to easily select last commands
  if string.len(text) == 0 then
    return load_cmd_history()
  end

  -- Numbers => Go to line
  if tonumber(text) then
    return {{ index = 1, cmd = text }}
  end

  -- Split input parts
  local split = vim.split(text, ' ')
  table.remove(split)
  local input_start = table.concat(split, ' ')

  -- get completions
  state.completions = vim.fn.getcompletion(text, 'cmdline')

  local results = {}
  for i = #state.completions, 1, -1 do
    local suggestion = table.concat({input_start, state.completions[i]}, ' ')
    table.insert(results, 1, { index = i, cmd = suggestion })
  end
  return results
end




local displayer = entry_display.create {
  separator = " ",
  items = {
    { width = 2 },
    { remaining = true },
  },
}

local make_display = function(entry)
  return displayer({
    { entry.icon, "Comment" },
    { entry.cmd, "Debug" },
  })
end

local make_finder = function()
  return finders.new_dynamic({
    fn = load_completion,
    entry_maker = function(entry)
      entry.icon = default_config.icon
      entry.id = entry.index
      entry.value = entry.cmd
      entry.ordinal = entry.cmd
      entry.display = make_display
      return entry
    end,
  })
end

local telescope_cmdline = function(opts)
  if type(next(opts)) == "nil" then
    opts = default_config.picker
  end

  state.command_history = load_cmd_history()

  state.picker = pickers.new(opts, {
    prompt_title = "Cmdline",
    prompt_prefix = " : ",
    finder = make_finder(),
    sorter = sorter.get_fzy_sorter(opts),
    attach_mappings = function(_, map)
      map("i", "<cr>"  , action.select_item)
      map("i", "<tab>" , action.complete_input)
      map("i", "<C-e>" , action.edit)
      map("i", "<C-r>" , action.run_input)
      return true
    end,
  })
  state.picker:find()
end

return telescope.register_extension({
  exports = {
    cmdline = telescope_cmdline,
  }
})

