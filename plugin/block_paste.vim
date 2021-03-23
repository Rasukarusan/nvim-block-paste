if exists("g:loaded_block_paste")
  finish
endif
let g:loaded_block_paste = 1

command! -bang -range Block call block_paste#create_block(<bang>0)
command! ToggleBlockPasteFillBlank call block_paste#toggle_fill_blank()
