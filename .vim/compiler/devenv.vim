" Vim compiler file
" Compiler:	DevEnv

if exists("current_compiler")
  finish
endif
let current_compiler = "devenv"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

" default errorformat
CompilerSet errorformat=\ %#%f(%l\\\,%c):\ %m

" default make
CompilerSet makeprg=build.bat
