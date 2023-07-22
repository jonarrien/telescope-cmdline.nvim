# telescope-cmdline.nvim

Telescope extension to use command line in a floating window, rather
than in bottom-left corner. Telescope provides **commands** and
**command history**, but editing the command is done outside
telescope. Wouldn't be much simpler having a single vscode-like panel?

![Alt Text](.docs/demo.gif)

**Intended behaviour:**
- Command history is displayed if no input is provided (to go up&down in history)
- Typing doesn't filter command history, it composes a new command.
- `<CR>` triggers the selected command. If you wish to adjust the
  command, use `<C-e>` to pass selection to prompt.

> NOTE: This is an alpha version done in relative short time. May need
> further improvements or customizations, but it's working pretty well
> for me and thought sharing with community.

## Installation

<details>
<summary>Packer</summary>

```lua
use { 'jonarrien/telescope-cmdline.nvim' }
```

</details>

<details>
<summary>Lazy</summary>

```lua
{ 'jonarrien/telescope-cmdline.nvim', opts = {} }
```

</details>


## Configuration

Add this line to your neovim configuration to lod the extension:

```lua
require("telescope").load_extension('cmdline')
```

<details>
<summary>Default configuration</summary>

```lua
{
  icon = "󰣿 ",
  picker = {
    layout_config = {
      width = 80,
      height = 20,
    }
  }
}
```

</details>

## Trigger

Cmdline can be executed using `:Telescope cmdline<CR>`, but it doesn't
include any mapping by default. I aim to replace `:`, but there are
some caveats and I recommend to use your own mapping instead. If you
want to give it a try, add this line in your config:

```lua
vim.api.nvim_set_keymap('n', ':', ':silent Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
```

## Mappings

- `<CR>` Select current entry or input
- `<TAB>` complete current input (useful for :e, :split, :vsplit, :tabnew)
- `<C-r>` run prompt input instead of current selection
- `<C-e>` edit current selection in prompt

## Notes

- [x] Support normal mode
- [ ] Support visual mode

## Acknowledgements

- Everyone who contributes in Neovim, this is getting better every day!
- Neovim team for adding lua, it really rocks!
- Telescope for facilitating extension creation 💪
