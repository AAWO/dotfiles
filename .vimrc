set encoding=utf-8
scriptencoding utf-8

" Enable syntax highlighting
syntax on

" Show line number and relative line number
set relativenumber number

" Enable statusline
set laststatus=2

" Tab settings
set tabstop=8     " number of visual spaces per TAB
set softtabstop=3 " number of spaces in tab when editing
set shiftwidth=3  " number of spaces to use for autoindent
set smarttab      " 'shiftwidth' at line start, 'softtabstop'/'tabstop' otherwise
set expandtab     " expand tab to spaces

" Show line at the cursor position
set cursorline

" Minimum lines to keep above and below cursor when scrolling
set scrolloff=3

autocmd BufNewFile,BufRead *.vhdm set syntax=vhdl

" statusline appearance - based on https://sidneyliebrand.io/blog/creating-my-own-vim-statusline
let g:mode_colors = {
     \ 'n':      'StatusLineSection',
     \ 'v':      'StatusLineSectionV',
     \ '^V':     'StatusLineSectionV',
     \ "\<C-V>": 'StatusLineSectionV',
     \ 'i':      'StatusLineSectionI',
     \ 'c':      'StatusLineSectionC',
     \ 'r':      'StatusLineSectionR'
     \ }


fun! StatusLineRenderer()
 let hl = '%#' . get(g:mode_colors, tolower(mode()), g:mode_colors.n) . '#'

 return hl
       \ . (&modified ? ' + │' : '')
       \ . ' %{StatusLineFilename()} %#StatusLine#%='
       \ . hl
       \ . ' '. (&filetype!=#''?&filetype:'none') . ' | '
       \ . (&modifiable?(&expandtab?'et ':'noet ').&shiftwidth:'') . ' | '
       \ . '%c | %p%% '
endfun


fun! StatusLineFilename()
 if (&ft ==? 'netrw') | return '*' | endif
 return substitute(expand('%'), '^' . getcwd() . '/\?', '', 'i')
endfun


fun! <SID>StatusLineHighlights()
 hi StatusLine         ctermbg=8   guibg=#313131 ctermfg=15 guifg=#cccccc
 hi StatusLineNC       ctermbg=0   guibg=#313131 ctermfg=8  guifg=#999999
 hi StatusLineSection  ctermbg=74  guibg=#55b5db ctermfg=0  guifg=#333333   " normal  mode - light blue
 hi StatusLineSectionV ctermbg=140 guibg=#a074c4 ctermfg=0  guifg=#000000   " visual  mode - purple
 hi StatusLineSectionI ctermbg=10  guibg=#9fca56 ctermfg=0  guifg=#000000   " insert  mode - green
 hi StatusLineSectionC ctermbg=11  guibg=#e5c07b ctermfg=0  guifg=#000000   " command mode - yellow
 hi StatusLineSectionR ctermbg=196 guibg=#ed3f45 ctermfg=0  guifg=#000000   " replace mode - red
endfun


call <SID>StatusLineHighlights()

" only set default statusline once on initial startup.
" ignored on subsequent 'so $MYVIMRC' calls to prevent
" active buffer statusline from being 'blurred'.
if has('vim_starting')
 let &statusline = ' %{StatusLineFilename()}%= %c | %p%% '
endif


augroup vimrc
 au!
 " show focussed buffer statusline
 au FocusGained,VimEnter,WinEnter,BufWinEnter *
   \ setlocal statusline=%!StatusLineRenderer()

 " show blurred buffer statusline
 au FocusLost,VimLeave,WinLeave,BufWinLeave *
   \ setlocal statusline&

 " restore statusline highlights on colorscheme update
 au Colorscheme * call <SID>StatusLineHighlights()
augroup END
