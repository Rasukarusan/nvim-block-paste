function! s:close_window()
  if exists('s:block_win_id ')
    call nvim_win_close(s:block_win_id, v:true)
    unlet s:block_win_id
  endif
  if exists('s:back_win_id ')
    call nvim_win_close(s:back_win_id, v:true)
    unlet s:back_win_id
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
  let config = nvim_win_get_config(s:block_win_id)
  let config.row += a:direction
  call nvim_win_set_config(s:block_win_id, config)

  " 移動した分を計算しておく
  let s:moving_y += a:direction
endfunction

function! s:move_x(direction)
  if s:pos.x + s:moving_x == 1 && a:direction == -1
    return
  endif
  let config = nvim_win_get_config(s:block_win_id)
  let config.col += a:direction
  call nvim_win_set_config(s:block_win_id, config)

  " 移動した分を計算しておく
  let s:moving_x += a:direction
endfunction

function! s:restore()
  call s:focus_to_main_window()
  call s:close_window()
endfunction

function! s:put()
  let dest = {'x': s:pos.x + s:moving_x, 'y': s:pos.y + s:moving_y}
  let selected = split(s:selected, '\n')
  let index = 0
  let selected_line_numbers = range(dest.y, dest.y + winheight(0) - 1)

  call s:focus_to_main_window()

  " 移動先のy座標が最終行を超えている場合、超過分を改行で作っておく
  let last_line = line('$')
  if dest.y > last_line || (dest.y == last_line && len(selected_line_numbers) > 1)
    for l in range(last_line, dest.y + len(selected_line_numbers) - 2)
      execute l . 's/$/\r/g'
    endfor
  endif

  " 選択した文字列を1行ずつ入力
  for lnum in selected_line_numbers
    let dest_x = dest.x < 0 ? 1 : dest.x
    call cursor(lnum, dest_x)
    " 移動先のx座標が行末より大きい場合、パディングする
    if dest.x >= col('$')
      let line_len = dest.x - col('$')
      execute ':normal i' . repeat(' ', line_len)
      call cursor(lnum, dest_x)
    endif
    execute ':normal i' . selected[index]
    let index += 1
  endfor

  " 選択範囲の文字列、FloatingWindowを削除
  :silent '<,'>s/\%V./ /g
  call s:close_window()
endfunction

function! s:make_block()
  " 選択範囲の開始/終了の行と列を取得
  normal `<
  let s:pos = {'x': col('.'), 'y': line('.')}
  let start = {'x': wincol(), 'y': winline()}
  normal `>
  let end = {'x': wincol(), 'y': winline()}

  " 選択範囲の文字列を取得
  let tmp = @@
  silent normal gvy
  let s:selected = @@
  let @@ = tmp

  " 選択範囲にFloatingWindowを作成
  let width = abs(end.x - start.x) + 1
  let height = abs(end.y - start.y) + 1
  let row = start.y - 1
  let col = start.x - 1
  let config = {'relative': 'editor', 'row': row, 'col': col, 'width':width, 'height': height, 'anchor': 'NW', 'style': 'minimal'}
  let s:back_win_id = s:create_window(config, 'Normal:NonText')
  let s:block_win_id = s:create_window(config, 'Normal:Visual')
  call setline(1, s:selected)
  if height > 1
    " ^@を削除
    :%s/[\x0]//g
  endif

  " ブロックを移動した分を計算するための変数
  let s:moving_x = 0
  let s:moving_y = 0

  " ブロック移動
  nnoremap <buffer><nowait><silent> j :call <SID>move_y(1)<CR>
  nnoremap <buffer><nowait><silent> k :call <SID>move_y(-1)<CR>
  nnoremap <buffer><nowait><silent> l :call <SID>move_x(1)<CR>
  nnoremap <buffer><nowait><silent> h :call <SID>move_x(-1)<CR>
  nnoremap <buffer><nowait><silent> p :call <SID>put()<CR>
  nnoremap <buffer><nowait><silent> u :call <SID>restore()<CR>
endfunction

command! -range Bmw call s:make_block()
