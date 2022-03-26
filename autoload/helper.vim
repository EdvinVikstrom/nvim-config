" params: ['name': string]
" return: string
function helper#realpath(name)
  return trim(system('realpath "'.a:name.'"'))
endfunction

" params: ['path': string]
" return: string
function helper#basename(path)
  let last = strlen(a:path)
  while last >= 0
    if a:path[last] == '/'
      break
    endif
    let last -= 1
  endwhile
  let last += 1
  return strpart(a:path, last, strlen(a:path) - last)
endfunction

" params: ['path': string]
" return: string
function helper#parent(path)
  let parent = strpart(a:path, 0, strlen(a:path) - strlen(helper#basename(a:path)))
  if empty(parent)
    return '/'
  endif
  return helper#realpath(parent)
endfunction

" params: ['path': string]
" return: boolean
function helper#is_hidden(path)
  let name = helper#basename(a:path)
  return strlen(name) != 0 ? name[0] == '.' : 0
endfunction

" params: ['path': string]
" return: string
function helper#extension(path)
  let dot = -1

  let index = strlen(a:path) - 1
  while index >= 0
    if a:path[index] == '.'
      let dot = index
      break
    endif
    let index -= 1
  endwhile

  if dot != -1
    return strpart(a:path, dot + 1, strlen(a:path) - dot)
  endif
  return ''
endfunction

" params: ['parent': string, 'name': string]
" return: string
function helper#child(parent, name)
  if a:parent[strlen(a:parent) - 1] == '/'
    return a:parent.a:name
  endif
  return a:parent.'/'.a:name
endfunction

" params: ['path': string, 'name': string]
" return: string
function helper#rename(path, name)
  return helper#child(helper#parent(a:path), a:name)
endfunction

" params: ['text': string]
" return: list<string>
function helper#input_list(text)
  let str = input(a:text." (comma separated): ")
  return split(str, ',')
endfunction

" params: ['text': string, 'def': int]
" return: boolean
function helper#input_yesno(text, def)
  if a:def == 1
    let str = input(#{prompt: a:text." [Y/n]: ", cancelreturn: 'N'})
    return str ==? 'N' ? 0 : 1
  elseif a:def == -1
    let str = input(#{prompt: a:text." [y/N]: ", cancelreturn: 'N'})
    return str ==? 'Y' ? 1 : 0
  endif

  while 1
    let str = input(#{prompt: a:text." [y/n]: ", cancelreturn: 'N'})
    if str ==? 'Y'
      return 1
    elseif str ==? 'N'
      return 0
    endif
    continue
  endwhile
endfunction

function helper#input(text, val = '', def = '')
  let str = input(#{prompt: a:text.": ",  default: a:val, cancelreturn: a:def})
  return str
endfunction

" params: ['text': string]
function helper#input_wait(text)
  let res = input(a:text)
endfunction
