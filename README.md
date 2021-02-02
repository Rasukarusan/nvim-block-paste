Nvim-Block-Paste
====

You can insert visual-block to anywhere!

## Demo
![demo2.gif](https://user-images.githubusercontent.com/17779386/106469918-42713000-64e3-11eb-87df-b6a2dcd505c4.gif)

Remove spaces after pasted
![demo.gif](https://user-images.githubusercontent.com/17779386/106455970-49427780-64d0-11eb-9d67-eb34d2abcef0.gif)

## Requirement

- Neim >= 0.4

## Install

You can use the plugin manager. e.g. dein.vim
```vim
[[plugins]]
repo = 'Rasukarusan/vim-block-paste'
```

## Usage

Select blockwise by `C-v` and execute `:Block`

```vim
:'<,'>Block
```

| keybind | description |
| ------ | ------ |
| h   | move left the block  |
| j   | move down the block  |
| k   | move up the block  |
| l   | move right the block  |
| p   | put the block  |
| u   | undo  |

## Settings

You can set whether to delete the selected block or replace it with a space.  
Default 0 (replace with a space).
```vim
let g:block_paste_fill_blank = 1
```

You can toggle by `ToggleBlockPasteFillBlank ` command.
```vim
:ToggleBlockPasteFillBlank 
```

|  |  |
| ------ | ------ |
| ![delete selected block](https://user-images.githubusercontent.com/17779386/106456476-ebfaf600-64d0-11eb-8c1d-934d41548349.gif)   | ![not delete selected block](https://user-images.githubusercontent.com/17779386/106456497-f0271380-64d0-11eb-9e66-8bec4d08e26e.gif)   |
| `g:block_paste_fill_blank = 0`   | `g:block_paste_fill_blank = 1`  |

