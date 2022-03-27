function editor#create()
  nnoremap <A-o> :call editor#close_buffer()<CR>

  augroup editor
    au QuitPre * call editor#event_quit()
  augroup END

  let win = nvim_get_current_win()

  return #{win: win}
endfunction

function editor#close_buffer()
  let win = nvim_get_current_win()
  let buf = nvim_win_get_buf(win)

  if nvim_buf_get_option(buf, 'modified')
    if helper#input_yesno('Do you want to save before closing?', 1)
      write
    else
      nvim_buf_set_option(buf, 'modified', 0)
    endif
  endif

  " just in case
  if nvim_buf_get_option(buf, 'modified')
    echoerr 'Buffer is modified'
    return
  endif

  bprev
  split
  bnext
  bdelete
endfunction

function editor#quit()
  quitall
endfunction

function editor#event_quit()
  if exists('w:qall')
    call editor#quit()
  endif
endfunction
