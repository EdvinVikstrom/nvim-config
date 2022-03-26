" 'Filer' is swedish for 'Files' ;)

let g:filer_directory_sort = get(g:, 'filer_directory_sort', 1)
let g:filer_close_children = get(g:, 'filer_close_children', 1)
let g:filer_view = #{
  \ name: get(g:, 'filer_view.name', 'filer'),
  \ width: get(g:, 'filer_view.width', 40),
  \ position: get(g:, 'filer_view.position', 'right'),
  \ show_hidden: get(g:, 'filer_view.show_hidden', 0),
  \ file_icon: get(g:, 'filer_view.file_icon', '-'),
  \ link_icon: get(g:, 'filer_view.link_icon', '@'),
  \ bdev_icon: get(g:, 'filer_view.bdev_icon', '#'),
  \ cdev_icon: get(g:, 'filer_view.cdev_icon', '%'),
  \ socket_icon: get(g:, 'filer_view.socket_icon', '='),
  \ fifo_icon: get(g:, 'filer_view.fifo_icon', '|'),
  \ priv_icon: get(g:, 'filer_view.privfile_icon', '~'),
  \ tree_opened_icon: get(g:, 'filer_view.tree_opened_icon', '▾'),
  \ tree_closed_icon: get(g:, 'filer_view.tree_closed_icon', '▸')
  \ }

let g:filer#default_config = #{
      \ directory_sort: g:filer_directory_sort,
      \ close_children: g:filer_close_children,
      \ view: #{
      \ 	name: g:filer_view.name,
      \ 	width: g:filer_view.width,
      \ 	position: g:filer_view.position,
      \ 	show_hidden: g:filer_view.show_hidden,
      \ 	file_icon: g:filer_view.file_icon,
      \ 	link_icon: g:filer_view.link_icon,
      \ 	bdev_icon: g:filer_view.bdev_icon,
      \ 	cdev_icon: g:filer_view.cdev_icon,
      \ 	socket_icon: g:filer_view.socket_icon,
      \ 	fifo_icon: g:filer_view.fifo_icon,
      \ 	priv_icon: g:filer_view.priv_icon,
      \ 	tree_opened_icon: g:filer_view.tree_opened_icon,
      \ 	tree_closed_icon: g:filer_view.tree_closed_icon
      \ },
      \ input: #{
      \ }
      \ }

" params: ['conf': config]
" return: filer
function filer#create()
  let conf = copy(g:filer#default_config)
  let filer = #{view: {}, input: {}, tree: {}, conf: conf}
  call filer#init_view(filer, conf)
  call filer#init_input(filer, conf)
  call filer#init_autocmds(filer, conf)
  return filer
endfunction

function filer#destroy(filer)
  call filer#view#destroy(a:filer.view)
  call filer#input#destroy(a:filer.input)
endfunction

function filer#init_view(filer, conf)
  let a:filer.view = filer#view#create(a:filer, a:conf.view)
endfunction

function filer#init_input(filer, conf)
  let a:filer.input = filer#input#create(a:filer, a:conf.input)
endfunction

function filer#init_autocmds(filer, conf)
  augroup filer
    autocmd DirChanged * call filer#load_directory(a:filer, getcwd())
  augroup END
endfunction

function filer#load_directory(filer, dir)
  let a:filer.tree = filer#tree#create(a:dir)
  call filer#tree#sort(a:filer.tree, a:filer.conf.directory_sort)

  call filer#view#redraw(a:filer.view, a:filer.tree)
  call filer#view#select(a:filer.view, 0)
endfunction

function filer#edit_file(filer, file)
  let wins = nvim_list_wins()

  let suggestions = []
  for win in wins
    if win == a:filer.view.win
      continue
    endif
    call add(suggestions, win)
  endfor

  if empty(suggestions)
    let win = a:filer.view.win
  elseif len(suggestions) == 1
    let win = suggestions[0]
  else
    let i = 0
    for win in suggestions
      let sec = airline#section#create_right(['file', 'A'])

    endfor
  endif

  call nvim_set_current_win(win)
  call nvim_command(':edit '.a:file)
endfunction
