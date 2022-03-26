" params: ['bufnr': int]
" return: view
function filer#view#create(filer, conf)
  let view = #{filer: a:filer, win: 0, winnr: 0, buf: 0, bufnr: 0, offset: 1, marking: 0, marked: [], nodes: [], conf: a:conf}
  call filer#view#init_window(view, a:conf)
  call filer#view#init_buffer(view, a:conf)
  return view
endfunction

" params: ['view': view]
function filer#view#destroy(view)
endfunction

" params: ['view': view]
function filer#view#init_window(view, conf)
  vsplit
  let a:view.winnr = 1 " TODO: '1'
  let a:view.win = win_getid(a:view.winnr)
  call nvim_win_set_width(a:view.win, a:conf.width)

  if a:conf.position ==? 'right'
    execute a:view.winnr.'wincmd r'
  endif
endfunction

" params: ['view': view]
function filer#view#init_buffer(view, conf)
  let a:view.buf = bufadd(a:conf.name)
  let a:view.bufnr = bufnr(a:view.buf)
  call nvim_buf_set_option(a:view.bufnr, 'modifiable', v:false)
  call nvim_buf_set_option(a:view.bufnr, 'buflisted', v:false)
  call nvim_buf_set_option(a:view.bufnr, 'buftype', 'nofile')
  call nvim_buf_set_option(a:view.bufnr, 'syntax', 'filer')
  "call nvim_buf_set_var(a:view.buf, 'filer', a:view.filer)
  call nvim_win_set_buf(a:view.win, a:view.buf)
endfunction

" params: ['index': int, 'node': node, 'parent': node_view, 'nest': int', line': string]
" return: node_view
function filer#view#create_node(index, node, parent, nest, line)
  return #{index: a:index, node: a:node, parent: a:parent, nest: a:nest, line: a:line, marked: 0}
endfunction

" params: ['view': view, 'tree': node]
function filer#view#redraw(view, tree)
  let a:view.nodes = []
  call filer#view#render(a:view, a:tree, {}, 0)
  call filer#view#draw(a:view)
endfunction

" params: ['view': view, 'tree': node]
function filer#view#draw(view)
  let lines = []
  for node in a:view.nodes
    if node.marked
      call add(lines, node.line.' *')
    else
      call add(lines, node.line)
    endif
  endfor

  call nvim_buf_set_option(a:view.buf, 'modifiable', v:true)
  call nvim_buf_set_lines(a:view.buf, 0, -1, 0, lines)
  call nvim_buf_set_option(a:view.buf, 'modifiable', v:false)
endfunction

" params: ['view': view, 'tree': node, 'parent': node_view, 'nest': int]
function filer#view#render(view, tree, parent, nest)
  if a:view.conf.show_hidden
    for child in a:tree.children
      call filer#view#render_node(a:view, child, a:parent, a:nest)
    endfor
  else
    for child in a:tree.children
      if child.hidden
	continue
      endif
      call filer#view#render_node(a:view, child, a:parent, a:nest)
    endfor
  endif
endfunction

" params: ['view': view, 'node': node, 'parent': node_view, 'nest': int]
function filer#view#render_node(view, node, parent, nest)
  let line = repeat(' ', a:nest)

  if a:node.rtype == 'dir'
    call filer#view#render_dir_node(a:view, a:node, a:parent, a:nest, line)
  else
    call filer#view#render_file_node(a:view, a:node, a:parent, a:nest, line)
  endif
endfunction

" params: ['view': view, 'node': node]
function filer#view#render_dir_node(view, node, parent, nest, line)
  if a:node.expanded
    let line = a:line.a:view.conf.tree_opened_icon.' '.a:node.name.'/'
    call add(a:view.nodes, filer#view#create_node(len(a:view.nodes), a:node, a:parent, a:nest, line))
    call filer#view#render(a:view, a:node, a:view.nodes[-1], a:nest + 1)
  else
    let line = a:line.a:view.conf.tree_closed_icon.' '.a:node.name.'/'
    call add(a:view.nodes, filer#view#create_node(len(a:view.nodes), a:node, a:parent, a:nest, line))
  endif
endfunction

" params: ['view': view, 'node': node]
function filer#view#render_file_node(view, node, parent, nest, line)
  if a:node.type == 'link'
    let line = a:line.a:view.conf.file_icon.' '.a:node.name.a:view.conf.link_icon
  elseif a:node.type == 'bdev'
    let line = a:line.a:view.conf.file_icon.' '.a:node.name.a:view.conf.bdev_icon
  elseif a:node.type == 'cdev'
    let line = a:line.a:view.conf.file_icon.' '.a:node.name.a:view.conf.cdev_icon
  elseif a:node.type == 'socket'
    let line = a:line.a:view.conf.file_icon.' '.a:node.name.a:view.conf.socket_icon
  elseif a:node.type == 'fifo'
    let line = a:line.a:view.conf.file_icon.' '.a:node.name.a:view.conf.fifo_icon
  elseif a:node.perm == 3
    let line = a:line.a:view.conf.file_icon.' '.a:node.name
  else
    let line = a:line.a:view.conf.file_icon.' '.a:node.name.a:view.conf.priv_icon
  endif
  call add(a:view.nodes, filer#view#create_node(len(a:view.nodes), a:node, a:parent, a:nest, line))
endfunction

" params: ['view': view, 'path': string]
" return: node_view
function filer#view#find_by_path(view, path)
  for item in a:view.nodes
    if item.node.path == a:path
      return item
    endif
  endfor
  return {}
endfunction

" params: ['view': view]
" return: node_view
function filer#view#selected(view)
  let linenr = line('.')
  let index = linenr - a:view.offset
  if index < 0 || empty(a:view.nodes)
    return {}
  endif
  return a:view.nodes[index]
endfunction

" params: ['view': view, 'index': int]
function filer#view#select(view, index)
  call cursor(a:view.offset + a:index, 0)
endfunction

" params: ['view': view]
" return: List<node_view>
function filer#view#marked(view)
  return a:view.marked
endfunction

" params: ['view': view, 'index': int]
function filer#view#mark(view, index)
  let node = a:view.nodes[a:index]
  if node.marked
    let node.marked = 0
    call remove(a:view.marked, index(a:view.marked, node))
  else
    let node.marked = 1
    call add(a:view.marked, node)
  endif
  call filer#view#draw(a:view)
endfunction

" params: ['view': view]
function filer#view#clear_marked(view)
  if !empty(a:view.marked)
    for node in a:view.marked
      let node.marked = 0
    endfor
    call remove(a:view.marked, 0, -1)
  endif
  call filer#view#draw(a:view)
endfunction

" params: ['view': view]
function filer#view#toggle_selection(view)
  if a:view.marking
    let a:view.marking = 0
  else
    let a:view.marking = 1
  endif
endfunction
