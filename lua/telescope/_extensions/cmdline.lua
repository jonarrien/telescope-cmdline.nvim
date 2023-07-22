local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local cmdline = require('cmdline')
local state = require('cmdline.state')
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorter = require("telescope.sorters")
local entry_display = require("telescope.pickers.entry_display")

-- Notify user if `setup()` was not called
local get_config = function()
  local config = require('cmdline.config')
  if config.values == nil or config.values == {} then
    vim.notify("Please, run `setup()` first.", vim.log.levels.ERROR, {})
    return config.defaults
  else
    return config.values
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
      entry.icon = get_config().icon
      entry.id = entry.index
      entry.value = entry.cmd
      entry.ordinal = entry.cmd
      entry.display = make_display
      return entry
    end,
  })
end

local telescope_cmdline = function(opts)
  local config = get_config()
  opts = vim.tbl_deep_extend("keep", config.picker, opts)

  state.command_history = cmdline.load_cmd_history()
  state.picker = pickers.new(opts, {
    prompt_title = "Cmdline",
    prompt_prefix = " : ",
    finder = make_finder(),
    sorter = sorter.get_fzy_sorter(opts),
    attach_mappings = function(_, map)
      local action = require('cmdline.actions')
      map("i", "<cr>", action.select_item)
      map("i", "<tab>", action.complete_input)
      map("i", "<C-e>", action.edit)
      map("i", "<C-r>", action.run_input)
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
