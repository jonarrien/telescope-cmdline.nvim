local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local cmdline = require('cmdline')
local config = require('cmdline.config')
local action = require('cmdline.actions')
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorter = require("telescope.sorters")
local entry_display = require("telescope.pickers.entry_display")

-- Notify user if `setup()` was not called
local get_config = function()
  if config.values == nil or config.values == {} then
    vim.notify("Please, run `setup()` first.", vim.log.levels.ERROR, {})
    return config.defaults
  else
    return config.values
  end
end

local type_icon = function(entry)
  if entry.type == 'history' then
    return config.values.icons.history
  elseif entry.type == 'number' then
    return config.values.icons.number
  elseif entry.type == 'command' then
    return config.values.icons.command
  elseif entry.type == 'system' then
    return config.values.icons.system
  else
    return config.values.icons.unknown
  end
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
    { entry.cmd,  "Debug" },
  })
end

local make_finder = function()
  return finders.new_dynamic({
    fn = cmdline.load_completion,
    entry_maker = function(entry)
      entry.icon = type_icon(entry)
      entry.id = entry.index
      entry.value = entry.cmd
      entry.ordinal = entry.cmd
      entry.display = make_display
      return entry
    end,
  })
end

local telescope_cmdline = function(opts)
  local picker = pickers.new(config.values.picker, {
    prompt_title = "Cmdline",
    prompt_prefix = " : ",
    finder = make_finder(),
    sorter = sorter.get_fzy_sorter(opts),
    attach_mappings = function(_, map)
      -- <CR>
      map("i", config.values.mappings.run_selection, action.select_item)
      -- <Tab>
      map("i", config.values.mappings.complete, action.complete_input)
      -- <C-CR>
      map("i", config.values.mappings.run_input, action.run_input)
      -- Others
      map("i", "<C-e>", action.edit)
      map("i", "<C-r>", action.run_input)
      return true
    end,
  })
  picker:find()
end

return telescope.register_extension({
  exports = {
    cmdline = telescope_cmdline,
  }
})
