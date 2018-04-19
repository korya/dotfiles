" OmniCppComplete initialization
" call omni#cpp#complete#Init()

set autoindent
set smartindent
set cindent

" Better indentation rules for C
" :0 - case labels at the same level as switch in switch statement
" l1 - align with a case label instead of the statement
" g0 - C++ "private:", "protected:" and "public:" are not indented
" t0 - function return type is not indented
" set cino=:0,l1,g0,t0,(0,u0

" Highlighting over 80 chars
" set textwidth=80
" au! BufNewFile,BufRead *.c,*.cpp,*.h,*.hpp,*.erl,*.hrl exec 'match Todo /\%>' . &textwidth . 'v.\+/'
" Taking the dynamic highlighting one step further
set textwidth=80
au BufNewFile,BufRead *.c,*.h,*.cpp exec 'match Todo /\%>' . &textwidth . 'v.\+\|.,[^ ]\|while(\| ,\| )\|( \|[|&]  \|  [|&]\|\n\n\n\|;* \n\|[^ ][!=]=[^ ]\|=[^ =]\|[^ !=<>|&^+]=\|for(\| ;\n/'
