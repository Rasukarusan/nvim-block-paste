function! s:close_window()
  if exists('g:block_win_id ')
    call nvim_win_close(g:block_win_id, v:true)
    unlet g:block_win_id
  endif
  if exists('g:back_win_id ')
    call nvim_win_close(g:back_win_id, v:true)
    unlet g:back_win_id
  endif
endfunction

function! s:create_window(config, hi_group)
  let window_width = nvim_win_get_width(0)
  let window_height = nvim_win_get_height(0)
  let width = float2nr(window_width*0.4)
  let buf = nvim_create_buf(v:false, v:true)
  let win_id = nvim_open_win(buf, v:true, a:config)
  call nvim_win_set_option(win_id, 'winhighlight', a:hi_group)
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

  " 移動した分を計算しておく
  let g:moving_y += a:direction
endfunction

function! s:move_x(direction)
  let config = nvim_win_get_config(g:block_win_id)
  let config.col += a:direction
  call nvim_win_set_config(g:block_win_id, config)

  " 移動した分を計算しておく
  let g:moving_x += a:direction
endfunction

function! s:restore()
  call s:focus_to_main_window()
  call s:close_window()
endfunction

function! s:put()
  echo 'x: '.g:moving_x.' y: '.g:moving_y
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

  " 選択範囲にFloatingWindowを作成
  let width = abs(end.x - start.x) + 1
  let height = abs(end.y - start.y) + 1
  let row = start.y - 1
  let col = start.x - 1
  let config = {'relative': 'editor', 'row': row, 'col': col, 'width':width, 'height': height, 'anchor': 'NW', 'style': 'minimal'}
  let g:back_win_id = s:create_window(config, 'Normal:NonText')
  let g:block_win_id = s:create_window(config, 'Normal:Visual')
  call setline(1, selected)
  :%s/[\x0]//g

  " ブロックを移動した分を計算するための変数
  let g:moving_x = 0
  let g:moving_y = 0

  " ブロック移動
  nnoremap <buffer><nowait><silent> j :call <SID>move_y(1)<CR>
  nnoremap <buffer><nowait><silent> k :call <SID>move_y(-1)<CR>
  nnoremap <buffer><nowait><silent> l :call <SID>move_x(1)<CR>
  nnoremap <buffer><nowait><silent> h :call <SID>move_x(-1)<CR>
  nnoremap <buffer><nowait><silent> p :call <SID>put()<CR>
  nnoremap <buffer><nowait><silent> u :call <SID>restore()<CR>
endfunction

" call s:make_block()
command! -range Block call s:make_block()
