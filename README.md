Nvim-Block-Paste
====

You can insert visual-block to anywhere!

## Demo
<img width="600" src="https://user-images.githubusercontent.com/17779386/106469918-42713000-64e3-11eb-87df-b6a2dcd505c4.gif">

Remove spaces after pasted(toggle by `:BlockPasteFillBlank`)

<img width="600" src="https://user-images.githubusercontent.com/17779386/106455970-49427780-64d0-11eb-9d67-eb34d2abcef0.gif" >

Only copy(`:'<,'>Block!`)

<img width="600" src="https://user-images.githubusercontent.com/17779386/112155541-bfd63880-8c28-11eb-84ce-c7f59904e240.gif" >

## Requirement

- Neovim >= 0.4

## Install

You can use the plugin manager. e.g. dein.vim
```vim
[[plugins]]
repo = 'Rasukarusan/nvim-block-paste'
```

## Usage

Select blockwise by <kbd>Ctrl-v</kbd> and execute `:Block`

```vim
:Block
```
or if you want only copy, use `!`.
```vim
:Block!
```

| keybind | description |
| ------ | ------ |
| h/H   | move left the block  |
| j/J   | move down the block  |
| k/K   | move up the block  |
| l/L   | move right the block  |
| p   | put the block  |
| u   | undo  |

## Settings

You can set whether to delete the selected block or replace it with a space.  
Default 0 (replace with a space).
```vim
let g:block_paste_fill_blank = 1
```

You can toggle by `BlockPasteFillBlank ` command.
```vim
:BlockPasteFillBlank 
```

|  |  |
| ------ | ------ |
| ![delete selected block](https://user-images.githubusercontent.com/17779386/106456476-ebfaf600-64d0-11eb-8c1d-934d41548349.gif)   | ![not delete selected block](https://user-images.githubusercontent.com/17779386/106456497-f0271380-64d0-11eb-9e66-8bec4d08e26e.gif)   |
| `g:block_paste_fill_blank = 0`   | `g:block_paste_fill_blank = 1`  |

