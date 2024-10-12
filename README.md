# telescope-cmdline.nvim

Telescope extension to use command line in a floating window, rather
than in bottom-left corner.

![Alt Text](.docs/demo.gif)

**Intended behaviour:**
- Show command history by default (to go up&down in history)
- Use input text to: 
    - autocomplete a new command
    - fuzzy search command history
- Use `<CR>` to trigger the selected command.
- Use `<Tab>` to complete current completion
- Use `<C-e>` to pass selection to input field and edit it.

> NOTE: This is an alpha version done in relative short time. May need
> further improvements or customizations, but it's working pretty well
> for me and thought sharing with community.

## Installation

⚠️ Make sure to load the `cmdline` extension after telescope, otherwise
`Telescope cmdline` command won't be available.

<details>
<summary>Packer</summary>

```lua
use { 'jonarrien/telescope-cmdline.nvim' }

```lua
require("telescope").setup({})
require("telescope").load_extension('cmdline')
```

</details>

<details>
<summary>Lazy</summary>

Install package as telescope dependency

```lua
{
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'jonarrien/telescope-cmdline.nvim',
  },
  keys = {
    { ':', '<cmd>Telescope cmdline<cr>', desc = 'Cmdline' }
  },
  opts = {
    ...
    extensions = {
      cmdline = {
        ... plugin settings ...
      },
    }
    ...
  }, 
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension('cmdline')
  end,
}
```

</details>


## Configuration

You can customise cmdline settings in telescope configuration.

```lua
require("telescope").setup({
  -- ...
  extensions = {
    cmdline = {
      -- Adjust telescope picker size and layout
      picker = {
        layout_config = {
          width  = 120,
          height = 25,
        }
      },
      -- Adjust your mappings 
      mappings    = {
        complete      = '<Tab>',
        run_selection = '<C-CR>',
        run_input     = '<CR>',
      },
      -- Triggers any shell command using overseer.nvim (`:!`)
      overseer    = {
        enabled = true,
      },
    },
  }
  -- ...
})
```

> Default configuration can be found in `lua/cmdline/config.lua` file.

## Mappings

- `<CR>`  Runs selected command from completion, otherwise runs user input
- `<TAB>` complete current selection into input (useful for :e, :split, :vsplit, :tabnew)
- `<C-e>` edit current selection in prompt

Cmdline can be executed using `:Telescope cmdline<CR>`, but it doesn't
include any mapping by default. Normally I suggest using ':' to
trigger it, but it's true there are some caveats or edge cases.
Please, configure the mapping which suits best for you:

```lua
vim.api.nvim_set_keymap('n', ':', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
vim.api.nvim_set_keymap('n', '<leader><leader>', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
```

## Notes

- [x] Support normal mode
- [ ] Support visual mode
- [x] Support fuzzy finding (Thanks to @sc0)

## Acknowledgements

- Everyone who contributes in Neovim, this is getting better every day!
- Neovim team for adding lua, it really rocks!
- Telescope for facilitating extension creation 💪
