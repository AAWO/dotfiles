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

" Use ctrl-[hjkl] to select the active split!
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

autocmd BufNewFile,BufRead *.vhdm set syntax=vhdl

" statusline appearance - based on https://sidneyliebrand.io/blog/creating-my-own-vim-statusline
let g:mode_colors = {
     \ 'n'      : 'StatusLineSection',
     \ 'v'      : 'StatusLineSectionV',
     \ '^V'     : 'StatusLineSectionV',
     \ "\<C-V>" : 'StatusLineSectionV',
     \ 'i'      : 'StatusLineSectionI',
     \ 'c'      : 'StatusLineSectionC',
     \ 'r'      : 'StatusLineSectionR'
     \ }

let g:currentmode={
       \ 'n'      : 'NORMAL ',
       \ 'v'      : 'VISUAL ',
       \ 'V'      : 'V·Line ',
       \ "\<C-V>" : 'V·Block ',
       \ 'i'      : 'INSERT ',
       \ 'R'      : 'REPLACE ',
       \ 'Rv'     : 'V·Replace ',
       \ 'c'      : 'COMMAND ',
       \ 't'      : 'TERMINAL '
       \}

fun! StatusLineRenderer()
 let hl = '%#' . get(g:mode_colors, tolower(mode()), g:mode_colors.n) . '#'

 return hl
       \  . ' ' . get(g:currentmode, mode())
       \ . '%#StatusLine#'
       \ . ' %{StatusLineFilename()}%#StatusLine#'
       \ . (&modified ? ' [+]'  : '')
       \ . (&readonly ? ' [RO]' : '')
       \ . '%='
       \ . ' '. (&filetype!=#''?&filetype:'none') . ' [' . (&fileencoding.'|') . &fileformat.'] '
       \ . hl
       \ . '[%l/%L] col: %2c'
endfun


fun! StatusLineFilename()
 if (&ft ==? 'netrw') | return '*' | endif
 return substitute(expand('%'), '^' . getcwd() . '/\?', '', 'i')
endfun


fun! <SID>StatusLineHighlights()
 hi StatusLine         ctermbg=8   guibg=#313131 ctermfg=15 guifg=#cccccc
 hi StatusLineNC       ctermbg=0   guibg=#313131 ctermfg=8  guifg=#999999
 hi StatusLineSection  ctermbg=114 guibg=#8dd68f ctermfg=0  guifg=#000000   " normal  mode - green
 hi StatusLineSectionV ctermbg=137 guibg=#a074c4 ctermfg=0  guifg=#000000   " visual  mode - orange-brown
 hi StatusLineSectionI ctermbg=109 guibg=#55b5db ctermfg=0  guifg=#333333   " insert  mode - light blue
 hi StatusLineSectionC ctermbg=229 guibg=#e5c07b ctermfg=0  guifg=#000000   " command mode - yellow
 hi StatusLineSectionR ctermbg=107 guibg=#ed3f45 ctermfg=0  guifg=#000000   " replace mode - olive
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

" force statusline redrawing when entering command mode
augroup redrawStatusLine
  au!
  autocmd CmdlineEnter : redrawstatus
augroup END
