function plugins#begin()
  let g:plugin_dir = $HOME.'/.nvim/plugins'
  let g:plugin_list = []
endfunction

function plugins#end()
  " Make directories
  if !isdirectory($HOME.'/.nvim')
    call mkdir($HOME.'/.nvim')
  endif

  if !isdirectory(g:plugin_dir)
    call mkdir(g:plugin_dir)
  endif

  let plugin_paths = []

  for plugin in g:plugin_list

    " local
    if plugin.type == 0
      let plugin_path = plugin.path

    " git
    elseif plugin.type == 1
      if !isdirectory(g:plugin_dir.'/'.plugin.name)
        call system('git clone '.plugin.url.' '.$HOME.'/.nvim/plugins/'.plugin.name)
      endif
      let plugin_path = g:plugin_dir.'/'.plugin.name
    endif

    call add(plugin_paths, plugin_path)
  endfor

  for path in plugin_paths
    call nvim_set_option('runtimepath', nvim_get_option('runtimepath').','.path)
  endfor

  for path in plugin_paths
    call nvim_set_option('runtimepath', nvim_get_option('runtimepath').','.path.'/after')
  endfor

  command PluginsUpdate call plugins#update()
endfunction

function plugins#add_local(path)
  call add(g:plugin_list, #{type: 0, path: a:path})
endfunction

function plugins#add_git(name, url)
  call add(g:plugin_list, #{type: 1, name: a:name, url: a:url})
endfunction

function plugins#update()
  echo 'Updating...'
  for plugin in g:plugin_list
    if plugin.type == 1
      call system('cd '.g:plugin_dir.'/'.plugin.name.' | git fetch | git pull')
    endif
  endfor
  echo 'Done.'
endfunction
