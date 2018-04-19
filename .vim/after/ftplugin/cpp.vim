" OmniCppComplete initialization
" call omni#cpp#complete#Init()

set autoindent
set smartindent
set cindent

set textwidth=120
au BufNewFile,BufRead *.c,*.h,*.cpp exec 'match Todo /\%>' . &textwidth . 'v.\+\|.,[^ ]\|while(\| ,\| )\|( \|[|&]  \|  [|&]\|\n\n\n\|;* \n\|[^ ][!=]=[^ ]\|=[^ =]\|[^ !=<>|&^+]=\|for(\| ;\n/'
