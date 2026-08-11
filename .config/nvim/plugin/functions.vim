" Expands a window to be full screen if not expanded. Otherwise
" returns windows to previous sizes.
function! ExpandWindow()
  let all_windows=range(1,winnr('$'))
  let curr_win=winnr()

  if exists("w:MjohnsWindowIsExpanded") && w:MjohnsWindowIsExpanded
    for i in all_windows
      exe i . " wincmd w"
      exe "vertical resize " . w:MjohnsWidthToRestore
      exe "resize " . w:MjohnsHeightToRestore
      let w:MjohnsWindowIsExpanded=0
    endfor
    exe curr_win . " wincmd w"
  else
    for i in all_windows
      exe i . " wincmd w"
      let w:MjohnsWidthToRestore=winwidth(0)
      let w:MjohnsHeightToRestore=winheight(0)
      let w:MjohnsWindowIsExpanded=0
    endfor
    exe curr_win . " wincmd w"
    exe "vertical resize " . 8000
    exe "resize " . 8000
    let w:MjohnsWindowIsExpanded=1
  endif
endfunction

" from tpope/unimpaired-vim
" Used to enter paste mode and restore after leaving insert mode.
" This allows pasting in text without vim formatting it.
function! SetupPaste() abort
  let s:paste = &paste
  let s:mouse = &mouse
  set paste
  set mouse=
  augroup unimpaired_paste
    autocmd!
    autocmd InsertLeave *
          \ if exists('s:paste') |
          \   let &paste = s:paste |
          \   let &mouse = s:mouse |
          \   unlet s:paste |
          \   unlet s:mouse |
          \ endif |
          \ autocmd! unimpaired_paste
  augroup END
endfunction

function! CountSearchMatches()
  exe "%s///gn"
endfunction

function! YankCurrentPath()
  exe 'let @" = expand("%")'
endfunction
