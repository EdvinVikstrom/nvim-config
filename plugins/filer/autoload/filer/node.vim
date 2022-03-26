function filer#node#new(name, path, type, rtype, perm, time, parent = {})
  return #{name: a:name, path: a:path, type: a:type, rtype: a:rtype, perm: a:perm, time: a:time, hidden: helper#is_hidden(a:name), parent: a:parent, children: [], loaded: 0, expanded: 0}
  " return #{path: a:file['path'], name: a:file['name'], type: a:file['type'], time: a:file['time'], parent: a:parent, children: [], loaded: 0, expanded: 0}
endfunction

function filer#node#create(path, parent = {})
  let name = helper#basename(a:path)
  let type = getftype(a:path)

  if type == 'link'
    let path = resolve(a:path)
    let rtype = getftype(path)
  else
    let rtype = type
  endif

  let perm = 0
  if filereadable(a:path)
    let perm += 1
  endif
  if filewritable(a:path)
    let perm += 2
  endif
  let time = getftime(a:path)

  return filer#node#new(name, a:path, type, rtype, perm, time, a:parent)
endfunction
