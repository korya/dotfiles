
if exists('loaded_kwbd')
  finish
endif

let loaded_kwbd = 1
if !hasmapto('<Plug>Kwbd')
  map <unique> <Leader>bd <Plug>Kwbd
endif

noremap <unique> <script> <Plug>Kwbd  :call <SID>Kwbd(1)<CR>:<BS>

"delete the buffer; keep windows
function <SID>Kwbd(kwbdStage)
  if(a:kwbdStage == 1)
    let g:kwbdBufNum = bufnr("%")
    let g:kwbdWinNum = winnr()
    windo call <SID>Kwbd(2)
    execute "bd! " . g:kwbdBufNum
    execute "normal " . g:kwbdWinNum . ""
  else
    if(bufnr("%") == g:kwbdBufNum)
      let prevbufvar = bufnr("#")
      if(prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != g:kwbdBufNum)
        b #
      else
        bn
      endif
    endif
  endif
endfunction

