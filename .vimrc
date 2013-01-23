"necessary for lots of cool vim things
set nocompatible
" ==================================================
" CURRENT MAPPINGS
" ==================================================
" ,l => toggles set list, i.e. shows invisible characters like tab eol etc,
" space => Toggles folds
" ,h => Converts selected html to haml
" ,s => Computes the numeric sum of selected lines

" ==================================================
" SETTINGS
" ==================================================
set grepprg=grep\ -nH\ $*
set lazyredraw                  " don't redraw while in macros
set shortmess=atI               " shorten messages and don
set listchars=tab:➟\ ,eol:¬,trail:·
set noautoread
set wildignore+=*.gif,*.fla,*.png,*.swf,*.jpg,tmp/*,public/assets/*,*.ogv,*.ico,*.pdf
" This shows what you are typing as a command
set showcmd
" vimdiff stuff
set diffopt+=iwhite
" Folding Stuffs
set foldmethod=syntax
set foldlevel=3
set autoindent
" Spaces instead of tab characters
set expandtab
set smarttab
" 2 character tab
set shiftwidth=2
set tabstop=2
set softtabstop=2
" tab completion stuff
set wildmenu
set wildmode=list:longest,full
set backspace=2
" Line Numbers
set number
" Incremental search
set incsearch
" Highlight things
set hlsearch
set modeline
set wildchar=9 " tab as completion character
set virtualedit=block
set clipboard=unnamedplus " Yanks go on clipboard
set showmatch " Show matching braces
set fillchars= " unset pipe as the vertical seperator
set ruler " show line and col number at the bottom
" ignores case while searching
set ignorecase
" ignores case while using lower case chars, searches in a case sensitive
" fashion when an upper case char is used
set smartcase
set cursorline
set selectmode=key
" default to UTF-8 encoding
set encoding=utf8
set fileencoding=utf8
" Needed for Syntax Highlighting and stuff
syntax on " syntax hilight on
syntax sync fromstart
set background=dark

" plugin settings
" Command T settings
let g:CommandTMaxFiles=5000
let g:CommandTMaxHeight=10

" ack
let g:ackprg="ack-grep -H --nocolor --nogroup --column"
let g:Powerline_symbols = 'fancy'
" disable warnings from NERDCommenter:
let g:NERDShutUp = 1

" invoke pathogen
filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on
colorscheme vividchalk

"NERDTree
let NERDTreeChDirMode=2 " Change the NERDTree directory to the root node
" Syntax coloring lines that are too long just slows down the world
set synmaxcol=200
" don't automatically highlight the matching parens
let loaded_matchparen = 1
set matchtime=0 " to stop automatic moving of cursor to matched paren
" XPTemplate config stuff
let g:xptemplate_vars="author=Khaja Minhajuddin&email=minhajuddin.k@gmail.com"
let g:xptemplate_brace_complete = ''
let g:xptemplate_key = '<Tab>'
let g:xptemplate_key_pum_only = '<S-Tab>'
"supertab config
let g:SuperTabMappingForward = '<c-space>'
let g:SuperTabMappingBackward = '<s-c-space>'

" from another vimrc
" Make sure that unsaved buffers that are to be put in the background are
" allowed to go in there (ie. the "must save first" error doesn't come up)
set hidden
" tell VIM to always put a status line in, even if there is only one window
set laststatus=2
" Make command line two lines high
set cmdheight=2
" Show the current mode
set showmode

" Hide the mouse pointer while typing
set mousehide

" Set up the gui cursor to look nice
set guicursor=n-v-c:block-Cursor-blinkon0
set guicursor+=ve:ver35-Cursor
set guicursor+=o:hor50-Cursor
set guicursor+=i-ci:ver25-Cursor
set guicursor+=r-cr:hor20-Cursor
set guicursor+=sm:block-Cursor-blinkwait175-blinkoff150-blinkon175
set wrap!

" set the gui options
set guioptions=aci
" This is the timeout used while waiting for user input on a multi-keyed macro
" or while just sitting and waiting for another key to be pressed measured
" in milliseconds.
"
" i.e. for the ",d" command, there is a "timeoutlen" wait period between the
"      "," key and the "d" key.  If the "d" key isn't pressed before the
"      timeout expires, one of two things happens: The "," command is executed
"      if there is one (which there isn't) or the command aborts.
set timeoutlen=500

" Keep some stuff in the history
set history=100

" These commands open folds
set foldopen=block,insert,jump,mark,percent,quickfix,search,tag,undo

" When the page starts to scroll, keep the cursor 8 lines from the top and 8
" lines from the bottom
set scrolloff=8

" Same as default except that I remove the 'u' option
set complete=.,w,b,t

" When completing by tag, show the whole tag, not just the function name
set showfulltag
" Syntastic settings
let g:syntastic_ruby_exec="ruby-1.9.2-p290"
"let g:syntastic_check_on_open=1
let g:syntastic_error_symbol='✱✱'
let g:syntastic_style_error_symbol='✱✱'
let g:syntastic_warning_symbol='❯❯'
let g:syntastic_style_warning_symbol='❯❯'
"let g:syntastic_auto_loc_list=1
" Settings specific to gvim
if has("gui_running")
  " maximizes the gvim window
  set guifont=Bitstream\ Vera\ Sans\ Mono\ for\ Powerline\ 10
  set lines=999 columns=999
  " No menus and no toolbar
  set guioptions-=m
  set guioptions-=T
else
  set t_Co=256
endif

" ==================================================
" MAPPINGS
" ==================================================
"mapleader this is what is used for the special <leader>
let mapleader=","
" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>
"space to toggle folds
nnoremap <Space> za
vnoremap <Space> za
" NERDTree stuff
map <leader>nt :execute 'NERDTreeToggle'<cr>
map <leader>nc :execute 'NERDTreeClose'<cr>
map <leader>nn :execute 'NERDTree'<cr>
map <leader>bo :execute '!gnome-open %'<cr>

"FuzzyFinder stuff
map <leader>ff :execute 'FufFile'<cr>
map <leader>fd :execute 'FufDir'<cr>
map <leader>fb :execute 'FufBuf'<cr>

" Navigation settings
" TODO redo them
" tab navigation like firefox
nmap <C-S-tab> :bprevious<cr>
nmap <C-tab> :bnext<cr>
map <C-S-tab> :bprevious<cr>
map <C-tab> :bnext<cr>
imap <C-S-tab> <ESC>:bprevious<cr>i
imap <C-tab> <ESC>:bnext<cr>i
"nmap <C-n> :tabnew<cr>
" remove search highlight
map <C-l> :nohls<cr>
" change current directory to the directory of the current buffer
nmap <silent> <leader>cd :lcd %:h<CR>
" Underline the current line with '='
nmap <silent> ,ul :t.\|s/./=/g\|set nohls<cr>
" Delete all buffers
nmap <silent> ,da :exec "1," . bufnr('$') . "bd"<cr>
" set text wrapping toggles
nmap <silent> <leader>wt :set invwrap<CR>:set wrap?<CR>
"Window wrangling
noremap <silent> <leader>ml <C-W>l
noremap <silent> <leader>mk <C-W>k
noremap <silent> <leader>mh <C-W>h
noremap <silent> <leader>mj <C-W>j
noremap <silent> <leader>mL <C-W>L
noremap <silent> <leader>mK <C-W>K
noremap <silent> <leader>mH <C-W>H
noremap <silent> <leader>mJ <C-W>J
noremap <silent> <leader>cw :close<CR>
" Buffer commands
noremap <silent> <leader>bd :bd<CR>
map <leader>a :execute 'Ack'<cr>

" ==================================================
" TEXT TRANSFORMATION
" NOTE: should these be functions?
" ==================================================
" html2haml
:vmap <leader>h :!/home/minhajuddin/.rvm/bin/r_html2haml -e<cr>
" computes the sum of numbers
:vmap <leader>s :!/home/minhajuddin/.scripts/msum<cr>


" ==================================================
" AUTOMATIC COMMANDS
" ==================================================
" ruby TODO: find out more about these settings
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
" mutt
autocmd BufRead /tmp/mutt-* set tw=72
autocmd BufRead /tmp/mutt-* setlocal spell!
"C specific settings
autocmd FileType c,cpp setlocal expandtab!
autocmd FileType c,cpp setlocal  softtabstop=0
"Go golang specific settings
autocmd Filetype go set makeprg=go\ build
autocmd BufNewFile,BufRead *.go setlocal expandtab!
autocmd BufNewFile,BufRead *.go setlocal softtabstop=0
autocmd BufWritePre *.go :silent Fmt
" set custom file types I've configured
autocmd BufNewFile,BufRead *.taskr  setf taskr
autocmd BufNewFile,BufRead nginx.conf  setf nginx
autocmd BufNewFile,BufRead /etc/nginx/*  setf nginx
autocmd BufNewFile,BufRead Gemfile  setf ruby
autocmd BufNewFile,BufRead Guardfile  setf ruby
autocmd BufNewFile,BufRead *.json  setf javascript
autocmd BufNewFile,BufRead *.crontab  setf crontab
autocmd BufNewFile,BufRead *.ru  setf ruby
autocmd BufNewFile,BufRead *.ps1  setf ps1
autocmd BufNewFile,BufRead *.boo  setf boo
autocmd BufNewFile,BufRead *.config  setf xml
autocmd BufNewFile,BufRead *.xaml  setf xml
autocmd BufNewFile,BufRead *.xoml  setf xml
autocmd BufNewFile,BufRead *.blogTemplate  setf xhtml
autocmd BufNewFile,BufRead *.brail  setf xhtml
autocmd BufNewFile,BufRead *.rst  setf xml
autocmd BufNewFile,BufRead *.rsb  setf xml
autocmd BufNewFile,BufRead *.io  setf io
autocmd BufNewFile,BufRead *.notes setf notes
autocmd BufNewFile,BufRead *.mg setf mg
autocmd BufNewFile,BufRead *.spark setf html

" ==================================================
" CUSTOM VIM FUNCTIONS AND THEIR MAPPINGS
" ==================================================
function! ExtractMethod() range
  let name = inputdialog("Name of new method:")
  '<
  exe "normal! O\<BS>def" . name ."\<CR>\<Esc>"
  '>
  exe "normal! o\<CR>}\<Esc>k"
  s/return/\/\/ return/ge
  normal! j%
  normal! kf(
  exe "normal! yyPi// = \<Esc>wdwA;\<Esc>"
  normal! ==
  normal! j0w
endfunction
vmap <leader>em :call ExtractMethod()<CR>

"automatically remove trailing whitespace for these files
" Removes trailing spaces
function TrimWhiteSpace()
  %s/\s\+$//e
endfunction

" The following beast is something i didn't write... it will return the
" syntax highlighting group that the current "thing" under the cursor
" belongs to -- very useful for figuring out what to change as far as
" syntax highlighting goes.
nmap <silent> <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
      \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name")
      \ . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
      \ . ">"<CR>

" TODO: Make this use a tmp file and the backgrounding
" process
let s:SCRATCH_BUFFER_NAME="RunCommandRun"
if !exists('s:buffer_number') " Supports reloading.
  let s:buffer_number = -1
endif

function! RunCommandShowBuffer()
  if(s:buffer_number == -1 || bufexists(s:buffer_number) == 0)
    exec "sp ". s:SCRATCH_BUFFER_NAME
    let s:buffer_number = bufnr('%')
  else
    let buffer_win=bufwinnr(s:buffer_number)
    if(buffer_win == -1)
      exec 'sb '. s:buffer_number
    endif
  endif
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  execute 'normal  ggdG'
endfunction
function! RunCommandOnCurrentBuffer(cmd)
  let original_bufnr = bufnr('%')
  let shellcommand = a:cmd . " " . bufname("%") . " 2>&1"
  call RunCommandShowBuffer()
  call setline(1, '#OUTPUT for ' . shellcommand)
  execute "$read ! " . shellcommand
  let original_winnr = winbufnr(original_bufnr)
  exec original_winnr.'wincmd w'
  1
endfunction

function! RunHandler()
  " to save the cursor position
  let l:winview = winsaveview()
  let currentfilename = expand('%:t')
  if &ft == "go"
    call RunCommandOnCurrentBuffer('go run')
    echo "triggered go run " . currentfilename
  elseif &ft == "ruby"
    if match(currentfilename, 'spec') > 0
      :silent!!b bundle exec rspec %
      redraw!
      echo "triggered rspec for" expand("%")
    else
      call RunCommandOnCurrentBuffer('ruby')
      redraw!
      echo 'execd current file'
    endif
  endif
  call winrestview(l:winview)
endfunction
nnoremap <C-d> :call RunHandler()<cr>

" reformat the file
function! ReformatCode()
  " to save the cursor position
  let l:winview = winsaveview()
  if &ft == "go"
    :execute 'Fmt'
    echo "go fmted!"
  elseif &ft == "javascript"
    :call g:Jsbeautify()
    echo "js beautified!"
  else
    :exe 'normal gg=G'
  endif
  call winrestview(l:winview)
endfunction
nnoremap <leader>rf :call ReformatCode()<cr>

" Import package under cursor name
function! ImportPackageUnderCursor()
  let word = expand('<cword>')
  exec 'Import '.word
endfunction
nnoremap <c-i> :call ImportPackageUnderCursor()<cr>



" ==================================================
"TODO
" ==================================================
"build a bunch of mappings like below to insert common things
"insert a hashrocket when <Control+L> is hit in insert mode
"imap <c-l> <space>=><space>
"make this a function
"remove command t
"nnoremap <leader>rct :execute 'map <leader>t :FufFile'<CR>
"nnoremap <leader>ct "=strftime("%Y%m%d%H%M%S")<CR>P
