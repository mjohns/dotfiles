function! s:RunCmdInternal(name, autoOpen) abort
  " Run the shell command and capture output as a list of lines
  let l:lines = systemlist(a:name)
  "let l:cmd_output=system("ls")
  "let l:lines=split(l:cmd_output, "\n", 1) " the 1 is to keep empty lines

  " Check if output is empty
  if empty(l:lines) || (len(l:lines) == 1 && l:lines[0] ==# '')
    echohl ErrorMsg
    echomsg 'No output'
    echohl None
    return
  endif

  " Auto-open if exactly 1 line and autoOpen is true
  if len(l:lines) == 1 && a:autoOpen
    execute 'edit ' . fnameescape(l:lines[0])
    return
  endif

  " Otherwise, create a unique temporary buffer
  " We use localtime() and getpid() to ensure a unique name (emulating the UUID)
  let l:bufname = 'temporary_buffer_' . localtime() . '_' . getpid()
  execute 'edit ' . fnameescape(l:bufname)

  " Set buffer options to behave as a disposable scratchpad
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap

  " Apply buffer-local mappings
  " Note: 'nnoremap' is used instead of 'map' to prevent recursive mapping issues
  nnoremap <buffer> <CR> gF
  nnoremap <buffer> q <C-^>
  nnoremap <buffer> m <cmd>set ma<CR>

  " Populate the buffer with the command output
  call setline(1, l:lines)

  " Lock the buffer and go to the first line
  setlocal nomodifiable
  normal! gg
endfunction

function! RunCmd(name) abort
  call s:RunCmdInternal(a:name, 0)
endfunction

function! RunCmdAutoOpen(name) abort
  call s:RunCmdInternal(a:name, 1)
endfunction

function! RunCmdWithHistory(c) abort
  call histadd('cmd', 'RunCmd ' . a:c)
  call RunCmd(a:c)
endfunction

command! -nargs=1 Find :call RunCmdAutoOpen("fa <args>")
command! -nargs=1 RunCmd :call RunCmd("<args>")
