" Gruvbox
  let g:gruvbox_improved_strings = 1
  let g:gruvbox_improved_warnings = 1
  let g:gruvbox_termcolors = 256
  let g:gruvbox_contrast_dark = 'medium'

  colorscheme gruvbox

" Airline
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffer_nr_show = 0
  
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
  
  let g:airline_left_sep = 'Β»'
  let g:airline_left_sep = 'βΆ'
  let g:airline_right_sep = 'Β«'
  let g:airline_right_sep = 'β'
  let g:airline_symbols.crypt = 'π'
  let g:airline_symbols.linenr = 'β°'
  let g:airline_symbols.linenr = 'β'
  let g:airline_symbols.linenr = 'β€'
  let g:airline_symbols.linenr = 'ΒΆ'
  let g:airline_symbols.maxlinenr = ''
  let g:airline_symbols.maxlinenr = 'γ'
  let g:airline_symbols.branch = 'β'
  let g:airline_symbols.paste = 'Ο'
  let g:airline_symbols.paste = 'Γ'
  let g:airline_symbols.paste = 'β₯'
  let g:airline_symbols.spell = 'κ¨'
  let g:airline_symbols.notexists = 'Ι'
  let g:airline_symbols.whitespace = 'Ξ'
  
  let g:airline_left_sep = 'ξ°'
  let g:airline_left_alt_sep = 'ξ±'
  let g:airline_right_sep = 'ξ²'
  let g:airline_right_alt_sep = 'ξ³'
  let g:airline_symbols.branch = 'ξ '
  let g:airline_symbols.readonly = 'ξ’'
  let g:airline_symbols.linenr = 'β°'
  let g:airline_symbols.maxlinenr = 'ξ‘'
  
  let g:airline_powerline_fonts = 1

" Floaterm
  let g:floaterm_wintype = 'split'
  let g:floaterm_height = 0.2

" Cmp
  set completeopt=menu,menuone,noselect

" Filer
  let g:filer_symbols_file = filer#symbols#get()

" Mappings
  command Bd bp|sp|bn|bd

  inoremap " ""<left>
  inoremap ( ()<left>
  inoremap ' ''<left>
  inoremap [ []<left>
  inoremap { {}<left>
  inoremap {<CR> {<CR>}<ESC>O
  inoremap {;<CR> {<CR>};<ESC>O

  nnoremap <A-h> :bprevious<CR>
  nnoremap <A-l> :bnext<CR>
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
  nnoremap <A-j> :+5<CR>
  nnoremap <A-k> :-5<CR>
  nnoremap <A-S-j> :+10<CR>
  nnoremap <A-S-k> :-10<CR>
  nnoremap <Space> :FZF<CR>

" Other
  set shiftwidth=2
  set relativenumber
  set number

  cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
  cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
