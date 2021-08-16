" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
" Force the cursor onto a new line after 80 characters
set textwidth=80
" However, in Git commit messages, limit lines to 72 chars
" :set filetype? shows you the current file type that is loaded
" :set ft? also shows you the current file type that is loaded
" :verbose set tw shows you the current textwidth setting and what file set it
autocmd FileType gitcommit set textwidth=72
" Color the 81st (or 73rd) column so that we don't type over the limit
set colorcolumn=+1
" In Git commit messages, also color the 51st column (for subject)
autocmd FileType gitcommit set colorcolumn+=51
