# visual-mode.xplr

## Overview

[visual-mode.xplr](https://github.com/oo-infty/visual-mode.xplr) is a [xplr](https://github.com/sayanarijit/xplr) plugin which adds visual mode support.

Currently, [xplr](https://github.com/sayanarijit/xplr) doesn't have builtin visual mode support. However, this can be done with [visual-mode.xplr](https://github.com/oo-infty/visual-mode.xplr), which offers a Vim-like experience of selecting directory entries on the fly.

[![asciicast](https://asciinema.org/a/672826.svg)](https://asciinema.org/a/672826)

## Installation

### Install manually

- Add the following line in `~/.config/xplr/init.lua`

  ```lua
  local home = os.getenv("HOME")
  package.path = home
    .. "/.config/xplr/plugins/?/init.lua;"
    .. home
    .. "/.config/xplr/plugins/?.lua;"
    .. package.path
  ```

- Clone the plugin

  ```bash
  mkdir -p ~/.config/xplr/plugins

  git clone https://github.com/oo-infty/visual-mode.xplr ~/.config/xplr/plugins/visual-mode
  ```

- Require the module in `~/.config/xplr/init.lua`

  ```lua
  require("visual-mode").setup{
    visual_key = "v",
    exit_visual_key = "v",
    up_keys = { "up", "k" },
    down_keys = { "down", "j" },
    extra_keys = {
      ["K"] = {
        help = "up multi-lines",
        messages = {
          { CallLuaSilently = "custom.visual_mode_up" },
          { CallLuaSilently = "custom.visual_mode_up" },
          { CallLuaSilently = "custom.visual_mode_up" },
          { CallLuaSilently = "custom.visual_mode_up" },
          { CallLuaSilently = "custom.visual_mode_up" },
        },
      },
      ["J"] = {
        help = "down multi-lines",
        messages = {
          { CallLuaSilently = "custom.visual_mode_down" },
          { CallLuaSilently = "custom.visual_mode_down" },
          { CallLuaSilently = "custom.visual_mode_down" },
          { CallLuaSilently = "custom.visual_mode_down" },
          { CallLuaSilently = "custom.visual_mode_down" },
        },
      },
    },
  }
  ```

### Nix with Home Manager

Use the following code as a template for your Home Manager configuration:

```nix
{ pkgs, ... }:

{
  programs.xplr.enable = true;

  programs.xplr.plugins = {
    visual-mode = pkgs.fetchFromGitHub {
      owner = "oo-infty";
      repo = "visual-mode.xplr";
      rev = "..."; # Fill this field with the latest revision.
      hash = "..."; # Fill this field with the hash of the latest revision.
    };

    # ...
  };

  programs.xplr.extraConfig = ''
    -- ...

    require("visual-mode").setup{
      visual_key = "v",
      exit_visual_key = "v",
      up_keys = { "up", "k" },
      down_keys = { "down", "j" },
      extra_keys = {
        ["K"] = {
          help = "up multi-lines",
          messages = {
            { CallLuaSilently = "custom.visual_mode_up" },
            { CallLuaSilently = "custom.visual_mode_up" },
            { CallLuaSilently = "custom.visual_mode_up" },
            { CallLuaSilently = "custom.visual_mode_up" },
            { CallLuaSilently = "custom.visual_mode_up" },
          },
        },
        ["J"] = {
          help = "down multi-lines",
          messages = {
            { CallLuaSilently = "custom.visual_mode_down" },
            { CallLuaSilently = "custom.visual_mode_down" },
            { CallLuaSilently = "custom.visual_mode_down" },
            { CallLuaSilently = "custom.visual_mode_down" },
            { CallLuaSilently = "custom.visual_mode_down" },
          },
        },
      },
    }

    -- ...
  '';
}
```

## API Reference

### `xplr.fn.custom.visual_mode_init(app)`

Initialize the global state and enter the visual mode. Usually, this is used by `setup()` internally and not intended to be called manually.

### `xplr.fn.custom.visual_mode_exit(app)`

Unset the global state and exit the visual mode. Usually, this is used by `setup()` internally and not intended to be called manually.

### `xplr.fn.custom.visual_mode_up(app)`

Move the cursor up and update the selection range. The selection status of the entry across the selection boudnary is not set to a fixed value but toggled. Selection won't change unless the cursor is able to move.

You can use this as the basic building block to set up your own key bindings.

### `xplr.fn.custom.visual_mode_down(app)`

Move the cursor down and update the selection range. This function is similar to `xplr.fn.custom.visual_mode_up`.

### `require("visual-mode").setup(args)`

[visual-mode.xplr](https://github.com/oo-infty/visual-mode.xplr) doesn't make assumption about your key bindings, so you need to pass essential arguments to this function, otherwise manual setup is required. However, it'll do the most stuff for you with the given argument.

`args` contains the following fields:

- `visual_key`: The key used to switch to visual mode in default mode. Don't set key bindings if it's `nil`. 
- `exit_visual_key`: The key used to exit visual mode. Defaults to `visual_key`. Don't set key bindings if it's `nil`. 
- `up_keys`: The keys used to move the cursor up. Defaults to `{}`.
- `down_keys`: The keys used to move the cursor up. Defaults to `{}`.
- `extra_keys`: Extra keys and the corresponding actions to be added to visual mode. Defaults to `{}`.

Detailed example is already presented above.
