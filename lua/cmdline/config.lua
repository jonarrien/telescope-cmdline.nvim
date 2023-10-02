local config = {}

config.defaults = {
  icons       = {
    history = " ",
    command = " ", -- 󰣿 󰏤 
    number  = "󰴍 ",
    system  = "",
    unknown = "",
  },
  picker      = {
    layout_config = {
      width  = 100,
      height = 25,
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
  output      = {
    enabled = false
  }
}

config.values = {
  mappings = {}
}

-- @param user_defaults table: user options
function config.set_defaults(user_defaults)
  user_defaults = vim.F.if_nil(user_defaults, {})
  config.values = vim.tbl_deep_extend("keep", user_defaults, config.defaults)
end

return config
