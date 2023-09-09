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

local icon = function(entry)
  return config.values.icons[entry.type] or config.values.icons.unknown
end

local displayer = entry_display.create({
  separator = " ",
  items = {
    { width = 2 },
    { remaining = true },
  },
})

local make_display = function(entry)
  return displayer({
    { entry.icon, "Comment" },
    { entry.cmd,  "Debug" },
  })
end

local make_finder = function()
  return finders.new_dynamic({
    fn = cmdline.autocomplete,
    entry_maker = function(entry)
      entry.icon = icon(entry)
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
      map("i", config.values.mappings.run_selection, action.run_selection)
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
