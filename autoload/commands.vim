function commands#put_block(b, e)
  let line = strpart(getline('.'), col('.') - 1)

  let d = 0
  for chr in line
    if chr == a:b
      let d += 1
    elseif chr == a:e
      let d -= 1
      if d == -1
	break
      endif
    endif
  endfor

  if d == -1
    call nvim_put([''.a:b], 'c', 1, 0)
  else
    call nvim_put([''.a:b.a:e], 'c', 1, 0)
  endif


endfunction
