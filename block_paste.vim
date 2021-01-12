function! s:close_window()
  if exists('g:block_win_id ')
  call nvim_win_close(g:win_id, v:true)
  unlet g:win_id
  augroup my_function
    autocmd!
  augroup END
  endif
endfunction

function! s:create_window(config)
  let window_width = nvim_win_get_width(0)
  let window_height = nvim_win_get_height(0)
  let width = float2nr(window_width*0.4)
  let buf = nvim_create_buf(v:false, v:true)
  let win_id = nvim_open_win(buf, v:true, a:config)
  call nvim_win_set_option(win_id, 'winhighlight', 'Normal:Visual')
  " call nvim_win_set_option(win_id, 'winblend', 60)
  call nvim_win_set_config(win_id, a:config)
  return win_id
endfunction

function! s:focus_to_main_window()
   execute "0windo :"
endfunction

function! s:move_y(direction)
  let config = nvim_win_get_config(g:block_win_id)
  let config.row += a:direction
  call nvim_win_set_config(g:block_win_id, config)
endfunction

function! s:move_x(direction)
  let config = nvim_win_get_config(g:block_win_id)
  let config.col += a:direction
  call nvim_win_set_config(g:block_win_id, config)
endfunction

function! s:make_block()
  " 選択範囲の開始/終了の行と列を取得
  normal `<
  let start = {'x': wincol(), 'y': winline()}
  normal `>
  let end = {'x': wincol(), 'y': winline()}

  " 選択範囲の文字列を取得
  let tmp = @@
  silent normal gvy
  let selected = @@
  let @@ = tmp

  " 削除分をスペースで埋める
  let padding = abs(end.x - start.x) + 1
  for lnum in range(start.y + line('w0') - 1, end.y + line('w0') - 1)
    call cursor(lnum, start.x)
    execute ':normal i' . repeat(' ', padding)
  endfor

  " 選択範囲の文字列を削除
  silent normal gvd

  " 選択範囲にFloatingWindowを作成
  let width = abs(end.x - start.x) + 1
  let height = abs(end.y - start.y) + 1
  let row = start.y - 1
  let col = start.x - 1
  let config = {'relative': 'editor', 'row': row, 'col': col, 'width':width, 'height': height, 'anchor': 'NW', 'style': 'minimal'}
  let g:block_win_id = s:create_window(config)
  normal p

  " ブロック移動
  nnoremap <buffer><nowait> j :call <SID>move_y(1)<CR>
  nnoremap <buffer><nowait> k :call <SID>move_y(-1)<CR>
  nnoremap <buffer><nowait> l :call <SID>move_x(1)<CR>
  nnoremap <buffer><nowait> h :call <SID>move_x(-1)<CR>
  " nnoremap <buffer><nowait> p :call <SID>put()<CR>
  " nnoremap <buffer><nowait> u :call <SID>restore()<CR>
endfunction

function! s:main()
  call s:make_block()
  let config = { 
    \'relative': 'editor',
    \ 'row': 10,
    \ 'col': 40,
    \ 'width':20,
    \ 'height': 10,
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
  \}
  " let g:block_win_id = s:create_window(config)
  " nnoremap <buffer><nowait> j :call <SID>move_y(1)<CR>
  " nnoremap <buffer><nowait> k :call <SID>move_y(-1)<CR>
  " nnoremap <buffer><nowait> l :call <SID>move_x(1)<CR>
  " nnoremap <buffer><nowait> h :call <SID>move_x(-1)<CR>

  " call s:focus_to_main_window()
  " augroup my_function
  "   autocmd!
  "   autocmd CursorMoved,CursorMovedI,InsertEnter <buffer> call s:close_window()
  " augroup END
endfunction

call s:main()
command! -range Block call s:make_block()
