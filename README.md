# telescope-cmdline.nvim

![tag](https://img.shields.io/github/v/tag/jonarrien/telescope-cmdline.nvim)
![code size](https://img.shields.io/github/languages/code-size/jonarrien/telescope-cmdline.nvim)
![license](https://img.shields.io/github/license/nvim-lualine/lualine.nvim)
![github prs](https://img.shields.io/github/issues-pr/jonarrien/telescope-cmdline.nvim)

Telescope extension to use command line in a floating window, rather
than in bottom-left corner. Allows using fuzzy search to filter neovim commands and command history simultaneously.

![Alt Text](.docs/demo.gif)

## Features

- [x] **Command history** by default. </br>
   Allows picking any previous command quickly.
- [x] **Autocompletion** </br>
    Allows using TAB key to fix spelling mistakes or complete command
    arguments using selected row. It determines next completion level
    by typing Space after the command. 
    - 💡 Use `:vsplit` or  `:tabnew` and press `<Space>` to see folders and filenames.
    - 💡 Type `DiffviewOpen` and press `<Space>` to show git branch names.
- [x] **Fuzzy search** (Thanks to [Kacper Dębowski](https://github.com/sc0))</br>
   Allows filtering commands and command history simultaneously using user's input.
    - 💡 Type `lsprest` and use `<Tab>` to expand `LspRestart`
    - 💡 Typing `dvo` can filter `DiffviewOpen` command.
    - 💡 Typing `gipure` can filter a previously executed `Git pull --rebase` command.
- [x] [overseer.nvim](https://github.com/stevearc/overseer.nvim) integration for shell commands (`:!...`)
- [ ] Support visual mode (PENDING)

## Installation

> [!WARNING]  
> Make sure to load the `cmdline` extension after telescope, otherwise
> `Telescope cmdline` command won't be available.


<details>
<summary>Using Packer</summary>

```lua
use { 'jonarrien/telescope-cmdline.nvim' }
```

```lua
require("telescope").setup({})
require("telescope").load_extension('cmdline')
```

</details>


<details>
<summary>Using Lazy</summary>

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
    { 'Q', '<cmd>Telescope cmdline<cr>', desc = 'Cmdline' }
    { '<leader><leader>', '<cmd>Telescope cmdline<cr>', desc = 'Cmdline' }
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

> Default configuration can be found in [lua/cmdline/config.lua](https://github.com/jonarrien/telescope-cmdline.nvim/blob/main/lua/cmdline/config.lua) file.

## Mappings

> [!CAUTION]
> Neovim's built-in cmdline is triggered with `:` and overriding this
> mapping can have a severe impact in your setup. Therefore it is completely
> discouraged.

> [!TIP]  
> The recommended mapping is `Q`, normally used for `:Ex` mode. It's
> out of use in modern setups and is easily reachable as `:`.
> Alternatively, you could use double leader. Please, use the one that
> suits best for you:

```lua
vim.api.nvim_set_keymap('n', 'Q', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
vim.api.nvim_set_keymap('n', '<leader><leader>', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
```

**Picker mappings**

| Key             | Descrition                                                  |
|---------------- | ----------------------------------------------------------- |
| `<CR>`          | Triggers the selected command in telescope results          |
| `<C-CR>`        | Triggers user input from prompt, ignoring selected result.  |
| `<TAB>`         | Expand selected row into prompt for editing                 |

## Caveats

- Only the first error message of several may be displayed, because the Neovim Lua API
  does not return multiple errors. For example, running `q` or `quit` from the standard
  command line when there are unsaved changes returns multiple errors, the second and
  subsequent errors tell which buffers have unsaved changes, but the first error, the
  only one available to `telescope-cmdline.nvim`, just says "No write since last change".

## Notes

> [!CAUTION]
> This is an alpha version done in relative short time. May need
> further improvements or customizations, but it's working pretty well
> for me and thought sharing with community.

## Contributing

Feel free to create an issue/PR if you want to see anything else implemented, but please read [CONTRIBUTING.md](./CONTRIBUTING.md) before opening a PR.

We enjoy this awesome plugin thanks to these wonderful people:

<a href="https://github.com/jonarrien/telescope-cmdline.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=jonarrien/telescope-cmdline.nvim" />
</a>

## Acknowledgements

- Everyone who contributes in Neovim, this is getting better every day!
- Neovim team for adding lua, it really rocks!
- Telescope for facilitating extension creation 💪
