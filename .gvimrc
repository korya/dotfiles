set guifont=Monaco:h12
colorscheme solarized

set guioptions=aegit

" Set default initial window size
set lines=40 columns=90

" Mappings {{{

map <F1> :sil exe ':!cvsdiff <cfile>&'<CR>

inoremap <S-Insert> <C-O>"*p
nnoremap <S-Insert> "*p
vnoremap <S-Insert> "-d"*p
vnoremap <C-Insert> "*y
vnoremap <S-Del> "*d
vnoremap <C-Del> "*d

nnoremap <C-h> gT
nnoremap <C-Left> gT
nnoremap <C-l> gt
nnoremap <C-Right> gt

" }}}

" DIFF mode {{{ 

if &diff
"   set guifont=-schumacher-clean-medium-r-normal--13-130-75-75-c-60-iso646.1991-irv
   "set guifont=-B&H-LucidaTypewriter-Medium-R-Normal-Sans-12-120-75-75-M-70-ISO8859-9
"  set guifont=-cronyx-fixed-medium-r-semicondensed-*-13-*-*-*-c-*-koi8-r
  set co=165
  exe "normal \<c-w>="
  set lines=42
  set guioptions-=rRlL
endif

" }}}

" Unite {{{

" Browse for a file in the current working dorectory
nnoremap <leader>uf :<C-u>Unite -start-insert file<CR>

" Recursive file search, start insert automatically, use fuzzy file matching
" call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <leader>ur :<C-u>Unite -start-insert file_rec/async:!<CR>

" Most recently used files:
nnoremap <leader>um :<C-u>Unite file_mru<CR>

" Buffer switching like LustyJuggler
nnoremap <leader>ub :Unite -quick-match buffer<cr>

" Content searching like ack.vim (or ag.vim)
nnoremap <leader>ug :Unite grep:.<cr>

" Search through yank history.
" First, this must be enabled to track yank history, then the mapping set.
let g:unite_source_history_yank_enable = 1
nnoremap <leader>uy :<C-u>Unite history/yank<CR>

" Like ctrlp.vim settings.
let g:unite_enable_start_insert = 1
let g:unite_winheight = 10
let g:unite_split_rule = 'botright'

" }}}

" VimFiler {{{

:let g:vimfiler_as_default_explorer = 1

" }}}

" VimProc {{{

"
"  WARNING:
"
"    Don't forget to build it:
"    $ make -C .vim/bundle/vimproc/
"

" }}}

" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=80
