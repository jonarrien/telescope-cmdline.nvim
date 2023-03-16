# telescope-cmdline.nvim

This is a Telescope extension to use command line in telescope. Now that we can set `commandheight=0`, I prefer to type commands in a floating window, rather in the bottom-left corner.

Telescope provides pickers for commands and command history, but editing the command is done outside telescope. Wouldn't be much simpler joining both and have a vscode-like panel for commands?

> NOTE: This is an alpha version done in relative short time. May need further improvements or customizations, but it's working pretty well for me and thought sharing with community.

![Alt Text](.docs/demo.gif)

## Installation

```lua
use { 'jonarrien/telescope-cmdline.nvim' }
```

## Configuration

Add this line to your neovim configuration to lod the extension:

```lua
require("telescope").load_extension('cmdline')
```

## Mappings

- `<CR>` Select current entry or input
- `<TAB>` complete current input (useful for :e, :split, :vsplit, :tabnew)
- `<C-r>` run prompt input instead of current selection
- `<C-e>` edit current selection in prompt

## Acknowledgements

- Everyone who contributes in Neovim, this is getting better every day!
- Neovim team for adding lua, it really rocks!
- Telescope for facilitating extension creation 💪
