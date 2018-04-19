set textwidth=80
exec 'match Todo /\%>' . &textwidth . 'v.\+/'

set shiftwidth=2
set makeprg=make
nnoremap <F10> :w<CR>:make<CR>:silent execute "!evince " . expand("%:t:r") . ".pdf &"<CR>
