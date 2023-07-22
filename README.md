# telescope-cmdline.nvim

Telescope extension to use command line in a floating window, rather
than in bottom-left corner.

![Alt Text](.docs/demo.gif)

**Intended behaviour:**
- Show command history when no input is provided (to go up&down in
  history using telescope keybindings)
- Typing doesn't filter command history, it starts a new command and
  autocompletes.
- Use `<CR>` to trigger the selected command.
- Use `<C-e>` to pass selection to input field and edit it.

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
include any mapping by default.

> I aim to replace `:`, but there are some caveats and I recommend to
> use another mapping instead. If you want to give it a try, add this
> line in your config:

```lua
vim.api.nvim_set_keymap('n', '<leader><leader>', ':silent Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
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
