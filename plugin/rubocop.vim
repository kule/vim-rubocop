let s:error = 0

function! Rubocop(args)
  if &filetype == "ruby"
    call s:RunRubocop(@%, 1, a:args)
  else
    echo "Cannot run rubocop on non-ruby file"
  endif
endfunction

function! RubocopFix()
  if &filetype == "ruby"
    call s:RunRubocop(@%, 0, "--auto-correct --safe")
  else
    echo "Cannot run rubocop on non-ruby file"
  endif
endfunction

function! RubocopAll(args)
  call s:RunRubocop("", 1, a:args)
endfunction

function! s:RunRubocop(path, async, args)
  let l:rubocop_args = a:args . join(a:000, " ")

  if !empty(a:path)
    let l:rubocop_args = l:rubocop_args . " " . a:path
  endif

  let l:rubocop_command = s:RubocopCmd(). " " . l:rubocop_args

  if s:error
    return
  endif

  if a:async
    call s:executeCmdAsync(l:rubocop_command)
  else
    call s:executeCmd(l:rubocop_command)
  endif
endfunction

function! s:RubocopCmd()
  if exists('g:rubocop_cmd')
    if g:rubocop_cmd =~ "emacs"
      let l:rubocop_command = g:rubocop_cmd
    else
      let l:rubocop_command = g:rubocop_cmd . " --format emacs"
    endif
  else
    if !executable('rubocop')
      let s:error = 1
      echom s:error
      echoerr "Rubocop: rubocop binary not found. Please install it first"
      return
    endif

    let l:rubocop_command = 'rubocop --format emacs'
    let l:root = getcwd()
    let l:gemfile_path = root . "/Gemfile"
    if filereadable(l:gemfile_path)
      let l:body = join(readfile(l:gemfile_path), "\n")
      let l:bundle_path = matchstr(l:body, "standard")
      if empty(l:bundle_path)
        let l:rubocop_command = 'rubocop --format emacs'
      else
        let l:rubocop_command = 'bundle exec rubocop --format emacs'
      endif
    endif
  endif

  return l:rubocop_command
endfunction

function! BackgroundCmdFinish(...)
  echom "Complete"
  execute "cfile! " . g:backgroundCommandOutput

  let l:match_count = len(getqflist())

  if l:match_count
    copen
  else
    cclose
    echom "No errors! bravo!"
  endif

  unlet g:backgroundCommandOutput
endfunction

function! s:executeCmdAsync(cmd)
  echom "Running Rubocop"

  let g:backgroundCommandOutput = tempname()
  if has('nvim')
    call jobstart(a:cmd . ' > ' . g:backgroundCommandOutput, {'on_exit': 'BackgroundCmdFinish'})
  else
    call job_start(a:cmd, {'close_cb': 'BackgroundCmdFinish', 'out_io': 'file', 'out_name': g:backgroundCommandOutput})
  endif
endfunction

function! s:executeCmd(cmd)
  echom a:cmd
  let oldautoread=&autoread
  set autoread
  silent !clear
  execute "!" . a:cmd
  redraw
  let &autoread=oldautoread
endfunction

command! -nargs=* Rubocop call Rubocop(<q-args>)
command! -nargs=* RubocopAll call RubocopAll(<q-args>)
command! -nargs=0 RubocopFix call RubocopFix()
