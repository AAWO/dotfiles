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

" Highlight all search matches
set hlsearch

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

let g:currentmode = {
      \ 'n'      : 'NORMAL ',
      \ 'v'      : 'VISUAL ',
      \ 'V'      : 'V·Line ',
      \ "\<C-V>" : 'V·Block ',
      \ 'i'      : 'INSERT ',
      \ 'R'      : 'REPLACE ',
      \ 'Rv'     : 'V·Replace ',
      \ 'c'      : 'COMMAND ',
      \ 't'      : 'TERMINAL '
      \ }

" Short mode labels for a narrow window
let g:mode_abbreviations = {
      \ 'n'      : ['NOR', 'N'],
      \ 'v'      : ['VIS', 'V'],
      \ 'V'      : ['V·L', 'VL'],
      \ "\<C-V>" : ['V·B', 'VB'],
      \ 'i'      : ['INS', 'I'],
      \ 'R'      : ['REP', 'R'],
      \ 'Rv'     : ['V·R', 'VR'],
      \ 'c'      : ['CMD', 'C'],
      \ 't'      : ['TER', 'T']
      \ }


" Calculate the width occupied by all segments except the filename
" Reserve exactly two columns for a space before and after the path
fun! <SID>StatusLinePathWidth(mode_name, flags, file_type, file_format, cursor_info) abort
   let l:mode_segment = empty(a:mode_name) ? '' : ' ' . a:mode_name . ' '
   let l:used = strdisplaywidth(l:mode_segment . a:flags
         \ . a:file_type . a:file_format . a:cursor_info)
   return winwidth(0) - l:used - 2
endfun

" Render a single filename and a mode-colored label
" Reduce the width if the window is too narrow
fun! StatusLineRenderer() abort
   let l:current_mode = mode()
   let hl = '%#' . get(g:mode_colors, tolower(l:current_mode), g:mode_colors.n) . '#'
   let l:mode_name = trim(get(g:currentmode, l:current_mode, l:current_mode))
   let l:mode_abbreviations = get(g:mode_abbreviations, l:current_mode,
         \ [strcharpart(l:mode_name, 0, 3), strcharpart(l:mode_name, 0, 1)])
   let l:flags = (&modified ? '[+]' : '')
         \ . (&readonly ? (&modified ? ' [RO]' : '[RO]') : '')
   let l:file_type = ' ' . (&filetype !=# '' ? &filetype : 'none')
   let l:file_format = ' [' . &fileencoding . '|' . &fileformat . '] '
   let l:cursor_format = ' [%l/%L] col: %2c'
   let l:cursor_info = ' [' . line('.') . '/' . line('$') . '] col: '
         \ . printf('%2d', col('.'))
   let l:path = StatusLinePath()
   let l:filename = l:path
   let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
         \ l:file_type, l:file_format, l:cursor_info)

   " 1. Hide encoding and file format
   if strdisplaywidth(l:filename) > l:available
      let l:file_format = ''
      let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
            \ l:file_type, l:file_format, l:cursor_info)
   endif

   " 2. Abbreviate the mode label to three characters
   if strdisplaywidth(l:filename) > l:available
      let l:mode_name = l:mode_abbreviations[0]
      let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
            \ l:file_type, l:file_format, l:cursor_info)
   endif

   " 3. Hide the file type
   if strdisplaywidth(l:filename) > l:available
      let l:file_type = ''
      let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
            \ l:file_type, l:file_format, l:cursor_info)
   endif

   " 4. Shorten each directory name to (at most) three characters
   if strdisplaywidth(l:filename) > l:available
      let l:filename = pathshorten(l:path, 3)
   endif

   " 5. Simplify the cursor position from [line/total] col: column to line:column.
   if strdisplaywidth(l:filename) > l:available
      let l:cursor_format = ' %l:%c'
      let l:cursor_info = ' ' . line('.') . ':' . col('.')
      let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
            \ l:file_type, l:file_format, l:cursor_info)
   endif

   " 6. Abbreviate the mode label to the minimum
   if strdisplaywidth(l:filename) > l:available
      let l:mode_name = l:mode_abbreviations[1]
      let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
            \ l:file_type, l:file_format, l:cursor_info)
   endif

   " 7. Shorten directory names to two or one character(s)
   if strdisplaywidth(l:filename) > l:available
      let l:filename = pathshorten(l:path, 2)
      " If two-character directory names still do not fit
      if strdisplaywidth(l:filename) > l:available
         let l:filename = pathshorten(l:path, 1)
      endif
   endif

   " 8. Hide the cursor position
   if strdisplaywidth(l:filename) > l:available
      let l:cursor_format = ''
      let l:cursor_info = ''
      let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
            \ l:file_type, l:file_format, l:cursor_info)
   endif

   " 9: Hide modified/read-only markers
   if strdisplaywidth(l:filename) > l:available
      let l:flags = ''
      let l:available = <SID>StatusLinePathWidth(l:mode_name, l:flags,
            \ l:file_type, l:file_format, l:cursor_info)
   endif

   " 10: replace the start of the path with "..."
   if strdisplaywidth(l:filename) > l:available
      let l:filename = StatusLineFilename(max([0, l:available]))
   endif

   " Escape percent signs so filenames cannot become statusline formats
   let l:filename = substitute(l:filename, '%', '%%', 'g')
   let l:mode_segment = empty(l:mode_name) ? '' : ' ' . l:mode_name . ' '

   return hl
      \ . l:mode_segment
      \ . '%#StatusLine#'
      \ . ' %<' . l:filename . ' '
      \ . l:flags
      \ . '%='
      \ . l:file_type . l:file_format
      \ . hl
      \ . l:cursor_format
endfun

" Select a full of relative path
fun! StatusLinePath() abort
   " Show a placeholder for netrw (file manager) directory listings
   if &filetype ==? 'netrw'
      return '*'
   endif

   " No filename
   if empty(expand('%'))
      return '[No Name]'
   endif

   let l:full = expand('%:p')
   let l:relative = fnamemodify(l:full, ':.')

   " Select the shorter representation from full and relative paths
   if l:relative !=# l:full
      let l:relative = './' . l:relative
      return strdisplaywidth(l:relative) <= strdisplaywidth(l:full)
            \ ? l:relative : l:full
   endif

   return l:full
endfun

" Shorten the displayed path to fit the active window
fun! StatusLineFilename(maxwidth) abort
   let l:path = StatusLinePath()
   let l:limit = max([0, a:maxwidth])

   " If the path fits - preserve all its directory names
   if strdisplaywidth(l:path) <= l:limit
      return l:path
   endif

   " Progressively shorten directories, keeping the full filename
   for l:keep in [3, 2, 1]
      let l:short = pathshorten(l:path, l:keep)

      " Stop when an abbreviated directory path fits
      if strdisplaywidth(l:short) <= l:limit
         return l:short
      endif
   endfor

   " Don't display a filename if the window has zero free columns
   if l:limit == 0
      return ''
   endif

   " Add prefix '...' to the path suffix
   " In windows narrower than 3 columns, display only '.' or '..'.
   let l:ellipsis = strpart('...', 0, min([3, l:limit]))
   let l:suffix_width = l:limit - strdisplaywidth(l:ellipsis)
   while strdisplaywidth(l:short) > l:suffix_width
      let l:short = strcharpart(l:short, 1)
   endwhile
   return l:ellipsis . l:short
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

" Only set the default statusline once on initial startup
" Inactive windows retain the original compact statusline layout.
if has('vim_starting')
   let &statusline = ' %<%{StatusLineFilename(max([0,winwidth(0)-12]))}%= %c | %p%% '
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
