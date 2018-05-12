let s:plugin = maktaba#plugin#Get('codefmt')


""
" @private
" Formatter: prettier
function! codefmt#prettier#GetFormatter() abort
  let l:formatter = {
      \ 'name': 'prettier',
      \ 'setup_instructions': 'Install prettier' .
          \ '(https://prettier.io/).'}

  function l:formatter.IsAvailable() abort
    return executable(s:plugin.Flag('prettier_executable'))
  endfunction

  function l:formatter.AppliesToBuffer() abort
    return &filetype is# 'css' || &filetype is# 'scss' || &filetype is# 'less' ||
        \ &filetype is# 'html' || &filetype is# 'json' ||
        \ &filetype is# 'javascript' || &filetype is# 'typescript' ||
        \ &filetype is# 'jsx' || &filetype is# 'javascript.jsx'
  endfunction

  ""
  " Reformat the current buffer with prettier or the binary named in
  " @flag(prettier_executable), only targeting the range between {startline} and
  " {endline}.
  " @throws ShellError
  function l:formatter.FormatRange(startline, endline) abort
    let l:cmd = [s:plugin.Flag('prettier_executable'), '--stdin']

    if &filetype == 'css' || &filetype == 'scss' || &filetype is# 'less' ||
          \ &filetype == 'json' ||
          \ &filetype == 'typescript'
      let l:cmd = l:cmd + ['--parser', &filetype]
    endif

    call maktaba#ensure#IsNumber(a:startline)
    call maktaba#ensure#IsNumber(a:endline)

    let l:lines = getline(1, line('$'))
    " Hack range formatting by formatting range individually, ignoring context.
    let l:input = join(l:lines[a:startline - 1 : a:endline - 1], "\n")

    let l:result = maktaba#syscall#Create(l:cmd).WithStdin(l:input).Call()
    let l:formatted = split(l:result.stdout, "\n")
    " Special case empty slice: neither l:lines[:0] nor l:lines[:-1] is right.
    let l:before = a:startline > 1 ? l:lines[ : a:startline - 2] : []
    let l:full_formatted = l:before + l:formatted + l:lines[a:endline :]

    call maktaba#buffer#Overwrite(1, line('$'), l:full_formatted)
  endfunction

  return l:formatter
endfunction
