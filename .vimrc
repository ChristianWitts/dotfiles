" A few preferences to get vim feeling better

" Set wrapping on, syntax highlighting, and the cursor position
set wrap
syntax on
set ruler

" Set the wrap limit to 72 characters, for GH messages
set textwidth=72
set colorcolumn=+1

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

