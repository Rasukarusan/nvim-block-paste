" @thanks https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
function! s:get_buffer_width()
  let width = winwidth(0)
  let numberwidth = max([&numberwidth, strlen(line('$')) + 1])
  let numwidth = (&number || &relativenumber) ? numberwidth : 0
  let foldwidth = &foldcolumn

  if &signcolumn == 'yes'
    let signwidth = 2
  elseif &signcolumn =~ 'yes'
    let signwidth = &signcolumn
    let signwidth = split(signwidth, ':')[1]
    let signwidth *= 2
  elseif &signcolumn == 'auto'
    let supports_sign_groups = has('nvim-0.4.2') || has('patch-8.1.614')
    let signlist = execute(printf('sign place ' . (supports_sign_groups ? 'group=* ' : '') . 'buffer=%d', bufnr('')))
    let signlist = split(signlist, "\n")
    let signwidth = len(signlist) > 2 ? 2 : 0
  elseif &signcolumn =~ 'auto'
    let signwidth = 0
    if len(sign_getplaced(bufnr(),{'group':'*'})[0].signs)
      let signwidth = 0
      for l:sign in sign_getplaced(bufnr(),{'group':'*'})[0].signs
        let lnum = l:sign.lnum
        let signs = len(sign_getplaced(bufnr(),{'group':'*', 'lnum':lnum})[0].signs)
        let signwidth = (signs > signwidth ? signs : signwidth)
      endfor
    endif
    let signwidth *= 2
  else
    let signwidth = 0
  endif
  return width - numwidth - foldwidth - signwidth
endfunction

function! s:get_tabline_height()
  let is_show_tabline = &showtabline != 0
  let tab_page_count = tabpagenr('$')
  return tab_page_count > 1 && is_show_tabline == 1 ? 1 : 0
endfunction

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
  if s:pos.y + s:moving_y <= s:buffer_min_row && a:direction == -1
    return
  endif
  let config = nvim_win_get_config(s:block_win_id)
  let config.row += a:direction
  call nvim_win_set_config(s:block_win_id, config)

  " for calculate the block movement
  let s:moving_y += a:direction
endfunction

function! s:move_x(direction)
  " control not to go too far to the left
  if s:pos.x + s:moving_x == 1 && a:direction == -1
    return
  endif
  " control not to go too far to the right
  if s:pos.x + s:moving_x + s:width == s:buffer_width && a:direction == 1
    return
  endif
  let config = nvim_win_get_config(s:block_win_id)
  let config.col += a:direction
  call nvim_win_set_config(s:block_win_id, config)

  " for calculate the block movement
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

  " If the y-coordinate of the destination exceeds the last line, make the excess with a line break.
  let last_line = line('$')
  if dest.y > last_line || (dest.y == last_line && len(selected_line_numbers) > 1)
    for l in range(last_line, dest.y + len(selected_line_numbers) - 2)
      execute l . 's/$/\r/g'
    endfor
  endif

  " Enter the selected string line by line
  for lnum in selected_line_numbers
    let dest_x = dest.x < 0 ? 1 : dest.x
    call cursor(lnum, dest_x)
    " If the x coordinate of the destination is larger than the end of the line, padding
    if dest.x >= col('$')
      let line_len = dest.x - col('$')
      execute ':normal i' . repeat(' ', line_len)
      call cursor(lnum, dest_x)
    endif
    execute ':normal i' . selected[index]
    let index += 1
  endfor

  " removed the floating window and selected string
  if get(g:, 'block_paste_fill_blank', 0)
    silent '<,'>s/\%V.//g
  else
    silent '<,'>s/\%V./ /g
  endif
  call s:close_window()

  " move cursor to destination and support re-select
  call cursor(selected_line_numbers[0], dest_x)
  execute "normal \<C-v>" . (s:height - 1). "j" . s:width . "l\<ESC>"
  call cursor(selected_line_numbers[0], dest_x)
endfunction

function! block_paste#create_block()
  let s:buffer_width = s:get_buffer_width()
  let s:buffer_min_row = line('w0')

  " Get the start / end rows and columns of the selection
  normal `<
  let s:pos = {'x': col('.'), 'y': line('.')}
  let start = {'x': wincol(), 'y': winline()}
  normal `>
  let end = {'x': wincol(), 'y': winline()}

  " Get the selection string
  let tmp = @@
  silent normal gvy
  let s:selected = @@
  let @@ = tmp

  " Create a floating window in the selection
  let s:width = abs(end.x - start.x) + 1
  let s:height = abs(end.y - start.y) + 1
  let row = start.y - 1 + s:get_tabline_height()
  let col = start.x - 1
  let config = {'relative': 'editor', 'row': row, 'col': col, 'width':s:width, 'height': s:height, 'anchor': 'NW', 'style': 'minimal'}
  let s:back_win_id = s:create_window(config, 'Normal:NonText')
  let s:block_win_id = s:create_window(config, 'Normal:Visual')

  " To prevent the '^@' character from being inserted, execute setline() one line at a time
  let selected = split(s:selected, '\n')
  for i in range(len(selected))
    call setline(i + 1, selected[i])
  endfor

  " for calculating the amount of block movement
  let s:moving_x = 0
  let s:moving_y = 0

  " keybinds of the block
  nnoremap <buffer><nowait><silent> j :call <SID>move_y(1)<CR>
  nnoremap <buffer><nowait><silent> k :call <SID>move_y(-1)<CR>
  nnoremap <buffer><nowait><silent> l :call <SID>move_x(1)<CR>
  nnoremap <buffer><nowait><silent> h :call <SID>move_x(-1)<CR>
  nnoremap <buffer><nowait><silent> p :call <SID>put()<CR>
  nnoremap <buffer><nowait><silent> u :call <SID>restore()<CR>
endfunction

function! block_paste#toggle_fill_blank()
  let value = get(g:, 'block_paste_fill_blank', 0) ? 0 : 1
  let g:block_paste_fill_blank = value
  echo value
endfunction
