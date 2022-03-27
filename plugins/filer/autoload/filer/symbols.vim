let g:filer#symbols#list =
      \ [
	\ #{symbol: '', pattern: '^.*\.\(c\|h\)$'},
	\ #{symbol: '', pattern: '^.*\.\(cpp\|cxx\|cc\|hpp\|hxx\|hh\)$'},
	\ #{symbol: '', pattern: '^.*\.\(vim\|nvim\)$'},
	\ #{symbol: '', pattern: '^.*\.\(lua\)$'},
	\ #{symbol: '', pattern: '^.*\.\(md\)$'},
	\ #{symbol: '', pattern: '^\(Makefile\)$'},
	\ #{symbol: '', pattern: '.*'}
      \ ]

" return: list
function filer#symbols#get()
  return g:filer#symbols#list
endfunction

" params: ['node': node]
" return: bool
function filer#symbols#extension(exts, node)
  if type(a:exts) == v:t_list
    for ext in a:exts
      if match(a:node.name, '^.*\.'.ext.'$') != -1
	return 1
      endif
    endfor
  else
    if match(a:node.name, '^.*\.'.a:exts.'$') != -1
      return 1
    endif
  endif
  return 0
endfunction
