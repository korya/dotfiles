" Common settings {{{

filetype plugin indent on
" Using mouse as in gvim
" set mouse=a
set nocompatible
set wildmenu
set ttyfast
set nu
set autoindent
set smartindent
set incsearch
set hlsearch
set wrap
set backspace=indent,eol,start
set autoread
set shiftwidth=2
set tabstop=8
set expandtab
set textwidth=80
" Show matching bracket.
set showmatch
set splitbelow
set splitright
set encoding=utf-8
set foldmethod=marker
set hidden
set listchars=precedes:<,extends:>

if has('mac')
  set maxmempattern=5000
endif

" перед вставкой из внешнего clipboard нажимать эту самую <F11>.
" Прощайте, тесты лесенкой.
set pastetoggle=<F11>

" When in screen allowing normal using of function keys
" if $TERM == 'screen'
"     set term=screen
" endif

" }}}

" Nice statusbar {{{

set laststatus=2
set statusline=
set statusline+=%-3.3n\                      " buffer number
set statusline+=%f\                          " file name
set statusline+=%h%m%r%w                     " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
    set statusline+=\ %{VimBuddy()}          " vim buddy
endif
set statusline+=%=                           " right align
set statusline+=%-14.(%l,%c%V%)\             " offset
set statusline+=0x%-8B\ %<%P                 " current char

" }}}

" XXX Move to ftplugin/
au! BufNewFile,BufRead *.h if &ft == 'cpp' | set ft=c | endif
au! BufNewFile,BufRead *.txt set textwidth=80

" Mappings {{{

nnoremap j gj
nnoremap k gk

" Comfortable PageUp PageDown
nnoremap <PageUp> <C-U><C-U>
nnoremap <PageDown> <C-D><C-D>
inoremap <PageUp> <Esc><C-U><C-U>a
inoremap <PageDown> <Esc><C-D><C-D>a
vnoremap <PageDown> <C-D><C-D>
vnoremap <PageUp> <C-U><C-U>
" Navigating windows by C-j C-k C-h C-l
noremap <C-H> <C-W>h<C-W>_
noremap <C-J> <C-W>j<C-W>_
noremap <C-K> <C-W>k<C-W>_
noremap <C-L> <C-W>l<C-W>_
inoremap <C-H> <Esc><C-W>h<C-W>_
inoremap <C-J> <Esc><C-W>j<C-W>_
inoremap <C-K> <Esc><C-W>k<C-W>_
inoremap <C-L> <Esc><C-W>l<C-W>_

function! ConfirmQuit()
  let l:confirmed = confirm("Do you really want to quit?", "&Yes\n&No", 2)
  if l:confirmed == 1
    quitall
  endif
endfu
noremap <C-Q> :call ConfirmQuit()<CR>

" vmap / y/<C-R>"<CR>

" }}}

" DIFF mode {{{ 

if &diff
  " Mappings {{{
  " unfold
  " noremap <F12> <c-W>hzRgg<c-W>lzRgg<c-W>hgg
  " go right
  " noremap <F11> <c-W>l
  " go left
  " noremap <F10> <c-W>h
  " get from right to left (must be on left!!)
  nnoremap <silent> ,> :diffget<cr>
  " get from left to right (must be on left!!)
  nnoremap <silent> ,< :diffput<cr>
  " next match
  nnoremap <tab> ]czz
  nnoremap ,] ]czz
  " previous match
  nnoremap <s-tab> [czz
  nnoremap ,[ [czz
  " iwhite
  noremap <silent> ,. :set diffopt^=iwhite<cr>
  " update the diff
  noremap <silent> ,, :diffup<cr>
  " }}}

"   set co=165
  exe "normal \<c-w>="
  set diffopt=filler,foldcolumn:0,context:5
  set nonumber
  set winwidth=80
endif

" }}}

" Tokmux {{{
" XXX move to a separate plugin (in Project)

" Utils {{{

function! Tokmux(tok)
  if (strpart(a:tok, 0, 3) ==? "RFC")
    let rfc_num = (strpart(a:tok, 3))
    let cmd="curl -s -L --post301 http://www.ietf.org/rfc/rfc" . rfc_num .".txt"
    call Disp(cmd)
    set filetype=rfc
    return
  endif
  " Assume 40 chars from {0-9a-f} to be linux kernel commit
  if match(a:tok, "^[a-fA-F0-9]*$") == 0 && strlen(a:tok) == 40
    " Check whether there is a local git repo.
    " If there is not, assume it's a Linux kernel commit.
    " XXX Linux kernel is hard-coded to lie in ~/src/linux-2.6
    let cmd="{ git status >/dev/null 2>&1 || cd ~/src/linux-2.6; } && git show " . a:tok
    call Disp(cmd)
    set filetype=git
    return
  endif
endfunction

function! Disp(cmd)
  let sout=system(a:cmd)
  :split
  :enew
  silent 0put=sout
  set buftype=nofile
  :wincmd _
  :1
endfunction
" }}}

" Mappings {{{

nnoremap <Leader><Leader> :call Tokmux(expand("<cword>"))<CR>
nnoremap <Leader>rf :call RFC(strpart(expand("<cword>"), 3))<CR>
nnoremap <Leader>w :silent exec ":!x-www-browser http://en.wikipedia.org/wiki/<cWORD>"<CR>

" }}}

" }}}

" PLUGIN: tpope/commentary {{{

nnoremap <C-C> gcc
vnoremap <C-C> gc
inoremap <C-C> <Esc>gcc

" }}}

" XXX Move to Project vim settings {{{

au BufRead,BufNewFile * let curr_dir=expand("%:p")
nnoremap <F10> :wa<CR>:set makeprg=.\ ~/.bashrc;\ jqmake\ %<CR>:make<CR>
inoremap <F10> <Esc>:wa<CR>:set makeprg=make\ $(echo\ %\\\|grep\ -o\ 'pkg/[^/]*')\ &&\ make\ -C\ pkg/main\ &&\ make\ ramdisk\ &&\ make\ -C\ os<CR>:make<CR>
vnoremap <F10> <Esc>:wa<CR>:set makeprg=make\ $(echo\ %\\\|grep\ -o\ 'pkg/[^/]*')\ &&\ make\ -C\ pkg/main\ &&\ make\ ramdisk\ &&\ make\ -C\ os<CR>:make<CR>

nmap ;; :sil exe ":!git difftool % &"<CR>

" }}}

" Replace all occurences of the word under the cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" When you don't have write permissions for the changed file:
" command Wsudo set buftype=nowrite | silent execute ':%w !sudo tee %' | set buftype= | e! %

" PLUGIN: vim-plug {{{

" Loaded from ~/.vim/autoload/plug.vim

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/vim-plug')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'vim-scripts/matchit.zip'
Plug 'easymotion/vim-easymotion'

" fzf does not work well in gvim and mvim
" Plug '/usr/local/opt/fzf'
" Plug 'junegunn/fzf.vim'
Plug 'kien/ctrlp.vim'

Plug 'terryma/vim-multiple-cursors'
Plug 'godlygeek/tabular'
Plug 'Valloric/ListToggle'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'editorconfig/editorconfig-vim'
Plug 'vim-syntastic/syntastic'
" Plug 'w0rp/ale'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py  --clang-completer --gocode-completer --tern-completer --go-completer --js-completer --rust-completer' }

Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'stephpy/vim-yaml', { 'for': 'yaml' }
Plug 'cespare/vim-toml', { 'for': 'toml' }
Plug 'Matt-Deacalion/vim-systemd-syntax', { 'for': 'systemd' }
Plug 'elubow/cql-vim', { 'for': 'cql' }
Plug 'exu/pgsql.vim', { 'for': ['pgsql', 'sql'] }

Plug 'shawncplus/phpcomplete.vim', { 'for': 'php' }
Plug 'hynek/vim-python-pep8-indent', { 'for': 'python' }
" Plug 'JuliaLang/julia-vim', { 'for': 'julia' }
Plug 'JuliaLang/julia-vim'

Plug 'othree/html5.vim', { 'for': ['html', 'hbs'] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': 'javascript' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'MaxMEllon/vim-jsx-pretty', { 'for': 'javascript' }
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'Quramy/tsuquyomi', { 'for': 'typescript', }

Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoInstallBinaries' }

Plug 'rust-lang/rust.vim', { 'for': 'rust' }

call plug#end()

" }}}


" XXX replaced with vim-plug
" 
" PLUGIN: dein {{{
" 
" if &compatible
"   set nocompatible
" endif
" 
" " Required:
" set runtimepath^=~/.vim/dein/repos/github.com/Shougo/dein.vim
" 
" " Required:
" call dein#begin(expand('~/.vim/dein/'))
" 
" " Load plugins from TOML file
" call dein#load_toml("~/.vim/dein/plugins.toml", {})
" 
" " Required:
" call dein#end()
" 
" " Required: (neovim sets it by default):
" filetype plugin indent on
" 
" }}}

" PLUGIN: vim-pathogen settings {{{

" To disable a plugin, add it's bundle name to the following list
" let g:pathogen_disabled = []
" call add(g:pathogen_disabled, 'vim-pathogen')

" exec pathogen#infect()

" fun! s:loadBundlesFromRoot(path)
  " Visit parent directory, if we did not reach the root
"   if a:path != "/" && !filereadable(a:path . "/.vim/.root")
"     call s:loadBundlesFromRoot(fnamemodify(a:path, ":h"))
"   endif

"   let vimSubDir = a:path . '/.vim'
"   if isdirectory(vimSubDir)
"     let bundleDir = vimSubDir . '/bundle'
    " Add the local bundles
"     if isdirectory(bundleDir)
"       exec pathogen#infect(bundleDir . '/{}')
"     endif

    " Now we can add the vimdir
"     call pathogen#surround(vimSubDir)
"   endif
" endfun
" call s:loadBundlesFromRoot(getcwd())

"}}}

colorscheme solarized
set background=dark

" Pathogen dependent commong settings {{{

" }}}

" PLUGIN: ctrl-p {{{

set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = 'find %s -type f'        " MacOSX/Linux

" let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" Open file menu
nnoremap <Leader>o :CtrlP<CR>
" Open buffer menu
nnoremap <Leader>b :CtrlPBuffer<CR>
" Open most recently used files
nnoremap <Leader>f :CtrlPMRUFiles<CR>

" }}}

" PLUGIN: airline {{{

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_left_sep = '⮀'
let g:airline_right_sep = '⮂'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.branch = '⭠'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.readonly = '⭤'
" let g:airline_powerline_fonts = 1

"}}}

" PLUGIN: haskellmode-vim settings {{{

let g:haddock_browser="/usr/bin/x-www-browser"

"}}}

" PLUGIN: vimwiki settings {{{

let g:vimwiki_list = [{'path': '~/rg/wiki/src', 'path_html': '~/rg/wiki/html'}]
" }}}

" PLUGIN: pangloss/vim-javascript {{{
let g:javascript_simple_indent = 0
" }}}

" PLUGIN: javascript-libraries-syntax {{{
let g:used_javascript_libs = 'underscore,angularjs,angularui,angularuirouter'
" }}}

" PLUGIN: fatih/vim-go {{{
let g:go_highlight_types = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_structs = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_variable_declarations = 0
let g:go_highlight_variable_assignments = 0
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

let g:go_template_autocreate = 0
let g:go_fmt_command = "goimports"
let g:go_info_mode = "guru"

" Sometimes when using both `vim-go` and `syntastic` Vim will start lagging
" while saving and opening files. The following fixes this:
let g:syntastic_go_checkers = ['golint', 'govet']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

" Another issue with `vim-go` and `syntastic` is that the location list window
" that contains the output of commands such as `:GoBuild` and `:GoTest` might
" not appear.  To resolve this:
let g:go_list_type = "quickfix"

"}}}

" PLUGIN: w0rp/ale {{{

let g:ale_sign_column_always = 1

"}}}

" PLUGIN: Syntastic {{{

" Recommended settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" JS settings

let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute " ,"trimming empty \<", "inserting implicit ", "unescaped \&" , "lacks \"action", "lacks value", "lacks \"src", "is not recognized!", "discarding unexpected", "replacing obsolete "]

function! JSCScfg(where)
    let cfg = findfile('.jscsrc', escape(a:where, ' ') . ';')
    return cfg !=# '' ? '-c ' . cfg : ''
endfunction
autocmd FileType javascript let b:syntastic_javascript_jscs_args = JSCScfg(expand('<amatch>:p:h', 1))

function! TSconfig(where)
    let cfg = findfile('tsconfig.json', escape(a:where, ' ') . ';')
    return cfg !=# '' ? '-p ' . cfg : ''
endfunction
autocmd FileType typescript let b:syntastic_typescript_tsc_args = TSconfig(expand('<amatch>:p:h', 1))
let g:syntastic_typescript_tsc_fname = ''
" }}}

" PLUGIN: YCM {{{
if !exists("g:ycm_semantic_triggers")
   let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

nnoremap <leader>rf :YcmCompleter RefactorRename 
nnoremap <leader>gs :YcmCompleter GoToReferences<CR>
nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gt :YcmCompleter GoTo<CR>

nnoremap <c-]> :YcmCompleter GoTo<CR>
nnoremap <c-w><c-]> <c-w>:YcmCompleter GoTo<CR>
nnoremap <c-t> <c-o>

" }}}

" PLUGIN: EditorConfig {{{
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" }}}

" PLUGIN: Julia {{{

let g:latex_to_unicode_auto = 0
let g:latex_to_unicode_tab = 0
let g:latex_to_unicode_eager = 0
let g:latex_to_unicode_file_types = ["julia", "tex", "plaintex"]

" }}}

" PLUGIN: fzf {{{

" XXX: assuming MacOS
if has('mac')
  let g:fzf_launcher = '"$HOME/.vim/plugin/fzf/fzf-MacVim.sh" "%s"'
endif

" }}}

" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=80

" Turn on the syntax after the plugins are configured
syntax on
