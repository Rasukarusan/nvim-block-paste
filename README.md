Vim-Block-Paste
====

You can insert visual-block to anywhere!

## Demo
![demo.gif](https://user-images.githubusercontent.com/17779386/104421594-e63f7e00-55be-11eb-825b-5d5fd89e92db.gif)

## Requirement

- NeoVim >= 0.4

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
" delete selected block
let g:block_paste_fill_blank = 1
```

You can toggle by `ToggleBlockPasteFillBlank ` command.
```vim
:ToggleBlockPasteFillBlank 

": echo g:block_paste_fill_blank
```

