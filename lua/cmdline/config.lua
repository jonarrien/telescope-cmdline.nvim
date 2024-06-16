local defaults = {
  highlights  = {
    icon = "Include",
  },
  icons       = {
    history = " ",
    command = " ",
    number  = "󰴍 ",
    system  = "",
    unknown = "",
  },
  picker      = {
    layout_config = {
      width  = 70,
      height = 15,
    }
  },
  completions = {
    'command',
  },
  mappings    = {
    complete      = '<Tab>',
    run_selection = '<C-CR>',
    run_input     = '<CR>',
  },
  overseer    = {
    enabled = true,
  },
  output_pane = {
    enabled = false,
    min_lines = 5,
    max_height = 25,
  }
}

local config = {
  namespace_id = vim.api.nvim_create_namespace('cmdline'),
  values = {
    mappings = {}
  }
}

-- @param user_defaults table: user options
function config.set_defaults(user_defaults)
  user_defaults = vim.F.if_nil(user_defaults, {})
  config.values = vim.tbl_deep_extend("keep", user_defaults, defaults)
end

-- Retreives custom configuration or default setings
function config.get()
  if config.values == nil or config.values == {} then
    return config.defaults
  else
    return config.values
  end
end

return config
