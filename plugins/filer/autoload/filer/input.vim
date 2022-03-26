" params: ['filer': filer]
function filer#input#create(filer, conf)
  let input = #{filer: a:filer, conf: a:conf}
  call filer#input#init_autocmds(input, a:conf)
  return input
endfunction

" params: ['input': input]
function filer#input#destroy(input)
endfunction

" params: ['input': input, 'conf': input_config]
function filer#input#init_autocmds(input, conf)
  " TODO:
  let g:filer_input = a:input
  let expr = 'g:filer_input'
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'j', ':call filer#input#cursor_down('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'k', ':call filer#input#cursor_up('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', '<Enter>', ':call filer#input#open('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'l', ':call filer#input#expand('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'h', ':call filer#input#close('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'K', ':call filer#input#make_directory('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'N', ':call filer#input#make_file('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'r', ':call filer#input#rename('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'm', ':call filer#input#move('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'x', ':call filer#input#delete('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'w', ':call filer#input#mark('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', 'v', ':call filer#input#toggle_mark('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', '.', ':call filer#input#toggle_hidden('.expr.')<CR>', #{silent: v:true})
  call nvim_buf_set_keymap(a:input.filer.view.bufnr, 'n', '<Escape>', ':call filer#input#cancel('.expr.')<CR>', #{silent: v:true})
endfunction

function filer#input#selected(input, cursor)
  if empty(filer#view#marked(a:input.filer.view)) && a:cursor
    let item = filer#view#selected(a:input.filer.view)
    if empty(item)
      let items = []
    else
      let items = [filer#view#selected(a:input.filer.view)]
    endif
  else
    let items = filer#view#marked(a:input.filer.view)
  endif

  if empty(items)
    echo 'No files selected'
    return items
  endif

  let files = []

  for item in items

    if item.node.type == 'dir'
      if !isdirectory(item.node.path)
	echoerr 'directory does not exists ['.item.node.path.']'
	continue
      endif
    elseif !filereadable(item.node.path)
      echoerr 'file does not exists ['.item.node.path.']'
      continue
    endif

    call add(files, item.node)
  endfor
  return files
endfunction

function filer#input#cursor_down(input)
  let line = line('.')
  let column = col('.')
  let line = line >= nvim_buf_line_count(a:input.filer.view.bufnr) ? 1 : line + 1
  call cursor(line, column)

endfunction

function filer#input#cursor_up(input)
  let line = line('.')
  let column = col('.')
  let line = line <= 1 ? nvim_buf_line_count(a:input.filer.view.bufnr) : line - 1
  call cursor(line, column)

endfunction

function filer#input#open(input)
  let selected = filer#view#selected(a:input.filer.view)
  if empty(selected)
    return
  endif

  if selected.node.rtype == 'dir'
    call filer#load_directory(a:input.filer, selected.node.path)
  else
    call filer#edit_file(a:input.filer, selected.node.path)
  endif
endfunction

function filer#input#expand(input)
  let selected = filer#view#selected(a:input.filer.view)
  if empty(selected)
    return
  endif

  let linenr = line('.')

  if selected.node.rtype == 'dir'
    if selected.node.expanded
      call filer#tree#close(selected.node, a:input.filer.conf.close_children)
      call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
    else
      call filer#tree#expand(selected.node)
      call filer#tree#sort(selected.node, a:input.filer.conf.directory_sort)
      call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
      call cursor(linenr + 1, 0)
    endif
  else
    call filer#edit_file(a:input.filer, selected.node.path)
  endif
endfunction

function filer#input#close(input)
  let selected = filer#view#selected(a:input.filer.view)
  if empty(selected)
    return
  endif

  if selected.node.expanded
    call filer#tree#close(selected.node, a:input.filer.conf.close_children)
    call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
  else
    if !empty(selected.parent)
      call filer#view#select(a:input.filer.view, selected.parent.index)
      call filer#tree#close(selected.node.parent, a:input.filer.conf.close_children)
      call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
    else
      call filer#load_directory(a:input.filer, helper#parent(selected.node.parent.path))
    endif
  endif
endfunction

function filer#input#make_directory(input)
  let selected = filer#view#selected(a:input.filer.view)
  
  if empty(selected)
    let node = a:input.filer.tree
  elseif selected.node.expanded
    let node = selected.node
  else
    let node = selected.node.parent
  endif

  let names = helper#input_list('New directory names')
  for name in names
    let path = helper#child(node.path, name)
    if isdirectory(path)
      echoerr 'directory already exists ['.path.']'
      continue
    endif
    call mkdir(path, 'p')
  endfor

  call filer#tree#reload(node)
  call filer#tree#sort(node, a:input.filer.conf.directory_sort)
  call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
endfunction

function filer#input#make_file(input)
  let selected = filer#view#selected(a:input.filer.view)
  
  if empty(selected)
    let node = a:input.filer.tree
  elseif selected.node.expanded
    let node = selected.node
  else
    let node = selected.node.parent
  endif

  let names = helper#input_list('New file names')
  let path = ''
  for name in names
    let path = helper#child(node.path, name)
    if filereadable(path)
      echoerr 'file already exists ['.path.']'
      continue
    endif

    " if !filewritable(path)
    "   echo 'cannot write file ['.path.']'
    "   continue
    " endif

    call writefile([], path, 'b')
  endfor

  call filer#tree#reload(node)
  call filer#tree#sort(node, a:input.filer.conf.directory_sort)
  call filer#view#redraw(a:input.filer.view, a:input.filer.tree)

  if !empty(path)
    let added_node = filer#view#find_by_path(a:input.filer.view, path)
    if !empty(added_node)
      call filer#view#select(a:input.filer.view, added_node.index)
    endif
  endif
endfunction

function filer#input#rename(input)
  let selected = filer#view#selected(a:input.filer.view)
  if empty(selected)
    echoerr 'No file selected'
    return
  endif

  let name = helper#input('Enter new name', selected.node.name)
  if empty(name)
    return
  endif

  let path = helper#rename(selected.node.path, name)

  if filereadable(path) || isdirectory(path)
    echoerr 'file already exists ['.path.']'
    return
  endif

  call rename(selected.node.path, path)

  call filer#tree#reload(selected.node.parent)
  call filer#tree#sort(selected.node.parent, a:input.filer.conf.directory_sort)
  call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
endfunction

function filer#input#move(input)
  let tomove = filer#input#selected(a:input, 0)
  let selected = filer#view#selected(a:input.filer.view)

  if empty(selected)
    echoerr 'No target selected'
    return
  endif

  " TODO: abort if trying to move a directory inside a sub directory

  if selected.marked == 1
    echoerr 'Cannot move a file to it self'
    return
  endif

  if selected.node.expanded
    let target = selected.node
  else
    let target = selected.node.parent
  endif

  " Just in case ;)
  if target.type != 'dir'
    echo 'Target must be a directory'
    return
  endif

  if len(tomove) == 0
    return
  endif

  let moved = 0
  for item in tomove
    let new_path = helper#child(target.path, item.name)

    if filereadable(new_path)
      let overwrite = helper#input_yesno(new_path.' already exists. Do you want to overwrite it?', -1)
      if !overwrite
	continue
      endif
      call filer#tree#remove(target, new_path)
    endif

    if rename(item.path, new_path) == 0
      call filer#tree#remove(item.parent, item.path)
      call filer#tree#add_file(target, new_path)
      call filer#tree#sort(target, a:input.filer.conf.directory_sort)
    endif
    let moved += 1
  endfor
  echo moved.' file(s) moved.'
  call filer#input#cancel(a:input)
  call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
endfunction

function filer#input#delete(input)
  let todelete = filer#input#selected(a:input, 1)
  if empty(todelete)
    return
  endif

  if len(todelete) == 0
    return
  endif

  if !helper#input_yesno('Sure you want to remove '.len(todelete).' file(s)?', -1)
    return
  endif

  let deleted = 0
  for item in todelete
    if delete(item.path, 'rf') == 0
      call filer#tree#remove(item.parent, item.path)
    endif
    let deleted += 1
  endfor
  echo deleted.' file(s) removed.'
  call filer#input#cancel(a:input)
  call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
endfunction

function filer#input#mark(input)
  let selected = filer#view#selected(a:input.filer.view)
  if empty(selected)
    echoerr 'No file selected'
    return
  endif

  call filer#view#mark(a:input.filer.view, selected.index)
  call filer#input#cursor_down(a:input)
endfunction

function filer#input#clear_marked(input)
  call filer#view#clear_marked(a:input.filer.view)
endfunction

function filer#input#toggle_mark(input)
  call filer#view#toggle_selection(a:input.filer.view)
endfunction

function filer#input#toggle_hidden(input)
  let a:input.filer.view.conf.show_hidden = 1 - a:input.filer.view.conf.show_hidden
  call filer#view#redraw(a:input.filer.view, a:input.filer.tree)
endfunction

function filer#input#cancel(input)
  call filer#input#clear_marked(a:input)
endfunction
