" 'Filer' is swedish for 'Files' ;)

function filer#get_config()
  return #{
      \ directory_sort: get(g:, 'filer_directory_sort', 1),
      \ close_children: get(g:, 'filer_close_children', 1),
      \ view: #{
      \ 	name: get(g:, 'filer_name', 'filer'),
      \ 	width: get(g:, 'filer_width', 40),
      \ 	position: get(g:, 'filer_position', 'right'),
      \ 	show_hidden: get(g:, 'filer_show_hidden', 0),
      \		symbols: #{
      \			file: get(g:, 'filer_symbols_file', '-'),
      \			link: get(g:, 'filer_symbols_link', '@'),
      \			bdev: get(g:, 'filer_symbols_bdev', '#'),
      \			cdev: get(g:, 'filer_symbols_cdev', '%'),
      \			socket: get(g:, 'filer_symbols_socket', '='),
      \			fifo: get(g:, 'filer_symbols_fifo', '|'),
      \			priv: get(g:, 'filer_symbols_priv', '~'),
      \			tree_closed: get(g:, 'filer_symbols_tree_closed', '▸'),
      \			tree_expanded: get(g:, 'filer_symbols_tree_expanded', '▾')
      \		}
      \ },
      \ input: #{
      \ }
      \ }
endfunction

" params: ['conf': config]
" return: filer
function filer#create()
  let conf = filer#get_config()
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
