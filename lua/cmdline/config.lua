local defaults = {
  highlights  = {
    icon = "Include",
  },
  icons       = {
    history = " ",
    command = " ", -- 󰣿 󰴲 󰏤 
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
  output_pane = {
    enabled = false
  }
}

local config = {
  values = {
    mappings = {}
  }
}

-- @param user_defaults table: user options
function config.set_defaults(user_defaults)
  user_defaults = vim.F.if_nil(user_defaults, {})
  config.values = vim.tbl_deep_extend("keep", user_defaults, defaults)
end

config.namespace_id = vim.api.nvim_create_namespace('cmdline')

return config
