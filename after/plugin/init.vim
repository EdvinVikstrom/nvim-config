let g:editor = editor#create()
let g:filer = filer#create()

call nvim_win_set_var(g:editor.win, 'qall', 1)
call nvim_win_set_var(g:filer.view.win, 'qall', 1)

call filer#load_directory(g:filer, getcwd())
