local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
  return
end

local cmdline = require('cmdline')
local config = require('cmdline.config')
local action = require('cmdline.actions')
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")

local sorter = require('cmdline.sorter')

local displayer = entry_display.create({
  separator = " ",
  items = {
    { width = 2 },
    { remaining = true },
  },
})

local make_display = function(entry)
  local c = assert(config.get(), "No config found")
  return displayer({
    { entry.icon, c.highlights.icon },
    { entry.cmd },
  })
end

local make_finder = function(config)
  return finders.new_dynamic({
    fn = cmdline.autocomplete,
    entry_maker = function(entry)
      entry.icon = config.icons[entry.type]
      entry.id = entry.index
      entry.value = entry.cmd
      entry.ordinal = entry.cmd
      entry.display = make_display
      return entry
    end,
  })
end

local make_picker = function(opts)
  local c = assert(config.get(), "No config found")
  return pickers.new(c.picker, {
    prompt_title = "Cmdline",
    prompt_prefix = " : ",
    default_text = opts.default_text or '',
    finder = make_finder(c),
    sorter = sorter(opts),
    attach_mappings = function(_, map)
      -- Autocomplete using <Tab>
      map("i", c.mappings.complete, action.complete_input)
      -- Run selection with <CR>
      map("i", c.mappings.run_selection, action.run_selection)
      -- Run command from input field with <C-CR> (special cases) ??
      map("i", c.mappings.run_input, action.run_input)
      map("i", c.mappings.edit, action.edit)
      -- Close the prompt with <C-c>
      map("i", c.mappings.close, action.close)
      map("i", c.mappings.edit, action.edit)

      -- Allow callbacks after loading (i.e: move cursor)
      if opts.on_load then vim.schedule(opts.on_load) end

      require("telescope.actions").close:enhance {
        post = function()
          cmdline.preview.clean(vim.api.nvim_win_get_buf(0))
        end,
      }
      return true
    end,
  })
end

local telescope_cmdline = function(opts)
  cmdline.preload()
  local picker = make_picker(opts)
  picker:find()
end

local cmdline_visual = function(opts)
  cmdline.preload()
  local picker = make_picker(opts)
  picker:find()
  picker:set_prompt("'<,'> ")
end

-- Telescope extension setup
-- NOTE: It's loads the extension twice (https://github.com/nvim-telescope/telescope.nvim/issues/2659)
local setup = function(ext_config, user_config)
  if vim.fn.has('nvim-0.10') == 0 then
    vim.notify('Cmdline requires Neovim 0.10.0 or higher', vim.log.levels.ERROR, {})
  end

  require("cmdline.config").set_defaults(ext_config)
end

return telescope.register_extension({
  setup   = setup,
  exports = {
    cmdline = telescope_cmdline,
    visual  = cmdline_visual,
  }
})
