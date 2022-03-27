call plugins#begin()
call plugins#add_git('airline', 'https://github.com/vim-airline/vim-airline.git')
call plugins#add_git('gruvbox', 'https://github.com/morhetz/gruvbox.git')

call plugins#add_git('nvim-lspconfig', 'https://github.com/neovim/nvim-lspconfig.git')
call plugins#add_git('cmp-nvim-lsp', 'https://github.com/hrsh7th/cmp-nvim-lsp.git')
call plugins#add_git('cmp-buffer', 'https://github.com/hrsh7th/cmp-buffer.git')
call plugins#add_git('cmp-look', 'https://github.com/hrsh7th/cmp-look.git')
call plugins#add_git('cmp-path', 'https://github.com/hrsh7th/cmp-path.git')
call plugins#add_git('cmp-cmdline', 'https://github.com/hrsh7th/cmp-cmdline.git')
call plugins#add_git('lspkind-nvim', 'https://github.com/onsails/lspkind-nvim.git')

call plugins#add_git('cmp-vsnip', 'https://github.com/hrsh7th/cmp-vsnip.git')
call plugins#add_git('vim-vsnip', 'https://github.com/hrsh7th/vim-vsnip.git')

call plugins#add_git('nvim-cmp', 'https://github.com/hrsh7th/nvim-cmp.git')

call plugins#add_local('/home/edvin/Projekt/nvim/plugins/filer')
call plugins#end()

runtime config.vim
lua require('cmp_config')

let g:editor = editor#create()
let g:filer = filer#create()

call nvim_win_set_var(g:editor.win, 'qall', 1)
call nvim_win_set_var(g:filer.view.win, 'qall', 1)

call filer#load_directory(g:filer, getcwd())
