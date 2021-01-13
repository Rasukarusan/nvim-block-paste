if exists("g:loaded_block_paste")
  finish
endif
let g:loaded_block_paste = 1

command! -range Block call block_paste#create_block()
