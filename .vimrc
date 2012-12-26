"necessary for lots of cool vim things
set nocompatible

set lazyredraw                  " don't redraw while in macros
"set list                        " show invisible characters
"set listchars=trail:·    " but only show tabs and trailing whitespace
"set listchars=tab:>·,trail:·    " but only show tabs and trailing whitespace
set shortmess=atI               " shorten messages and don

let g:Powerline_symbols = 'fancy'

"insert a hashrocket when <Control+L> is hit in insert mode
imap <c-l> <space>=><space>

"mapleader this is what is used for the special <leader>
let mapleader=","

"Settings specific to Windows and Linux
if has("win32") || has("win64")
  let Tlist_Ctags_Cmd='c:\Users\minhajuddin\.vim\tools\ctags\ctags.exe' "TODO: make sure this works
  set directory=$TMP
  set runtimepath=~\.vim,$VIMRUNTIME,~\.vim\after
  if !has("gui_running")
    "settings specific to windows console vim < cannot display rich colors
    colorscheme slate
  endif
else
  "Linux specific settings
  "setting the runtime path
  set runtimepath=~/.vim,$VIMRUNTIME,~/.vim/after
  "set directory=/tmp
  set grepprg=grep\ -nH\ $*
endif

" html2haml
:vmap <leader>h :!/home/minhajuddin/.rvm/bin/r_html2haml -e<cr>
:vmap <leader>s :!/home/minhajuddin/.scripts/msum<cr>

" If the current buffer has never been saved, it will have no name,
" call the file browser to save it, otherwise just save it.
nnoremap <silent> <C-S> :if expand("%") == ""<CR>browse confirm w<CR>else<CR>confirm w<CR>endif<CR>
imap <c-s> <Esc><c-s>

"nnoremap <C-e> :call MaximizeToggle ()<CR>

"function! MaximizeToggle()
  "if exists("s:maximize_session")
    "exec "source " . s:maximize_session
    "call delete(s:maximize_session)
    "unlet s:maximize_session
    "let &hidden=s:maximize_hidden_save
    "unlet s:maximize_hidden_save
  "else
    "let s:maximize_hidden_save = &hidden
    "let s:maximize_session = tempname()
    "set hidden
    "exec "mksession! " . s:maximize_session
    "only
  "endif
"endfunction


" appearance options
" settings
set noautoread
set wildignore+=*.gif,*.fla,*.png,*.swf,*.jpg,tmp/*,public/assets/*,*.ogv,*.ico

map <leader>rle :execute '%s///g'<cr>
"match ErrorMsg '\s\+$'
nnoremap <leader>rt :%s/\s\+$//e<CR>
"remove command t
nnoremap <leader>rct :execute 'map <leader>t :FufFile'<CR>
"settings specific to gvim
if has("gui_running")
  " maximizes the gvim window
  set guifont=Bitstream\ Vera\ Sans\ Mono\ for\ Powerline\ 10
  "set guifont=Bitstream\ Vera\ Sans\ Mono\ 10
  set lines=999 columns=999
  " No menus and no toolbar
  set guioptions-=m
  set guioptions-=T
  "let g:obviousModeInsertHi = "guibg=Black guifg=White"
else
  "let g:obviousModeInsertHi = "ctermfg=253 ctermbg=16"
  set t_Co=256
endif

" This shows what you are typing as a command. I love this!
set showcmd

" make vim load the .bashrc in vim commandline
"set shellcmdflag=-ic

" vimdiff stuff
set diffopt+=iwhite

" Folding Stuffs ==> TODO:Need to set it to a more meaningful value
set foldmethod=marker

" Who doesn't like autoindent?
set autoindent

" haddock browser
let g:haddock_browser="/usr/bin/google-chrome"
" Spaces are better than a tab character
set expandtab
set smarttab

" Who wants an 8 character tab? Not me!
set shiftwidth=2
set tabstop=2
set softtabstop=2

" Cool tab completion stuff
set wildmenu
set wildmode=list:longest,full

" Got backspace?
set backspace=2

" Line Numbers PWN!
set number
" Incremental searching is sexy
set incsearch

" Highlight things that we find with the search
set hlsearch

set modeline
set wildchar=9 " tab as completion character

set virtualedit=block
set clipboard=unnamedplus " Yanks go on clipboard instead.
set showmatch " Show matching braces.
set fillchars= " unset pipe as the vertical seperator

set number ruler " show line numbers
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

" Make sure taglist doesn't change the window size
let g:Tlist_Inc_Winwidth = 0

" ack
let g:ackprg="ack-grep -H --nocolor --nogroup --column"
" automatic commands
"ruby
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
"mutt
au BufRead /tmp/mutt-* set tw=72
au BufRead /tmp/mutt-* setlocal spell!
"Go specific settings
au BufNewFile,BufRead *.go setlocal expandtab!
au BufNewFile,BufRead *.go setlocal softtabstop=0
" set custom file types I've configured
au BufNewFile,BufRead *.taskr  setf taskr
au BufNewFile,BufRead nginx.conf  setf nginx
au BufNewFile,BufRead /etc/nginx/*  setf nginx
au BufNewFile,BufRead Gemfile  setf ruby
au BufNewFile,BufRead Guardfile  setf ruby
au BufNewFile,BufRead *.json  setf javascript
au BufNewFile,BufRead *.crontab  setf crontab
au BufNewFile,BufRead *.ru  setf ruby
au BufNewFile,BufRead *.ps1  setf ps1
au BufNewFile,BufRead *.boo  setf boo
au BufNewFile,BufRead *.config  setf xml
au BufNewFile,BufRead *.xaml  setf xml
au BufNewFile,BufRead *.xoml  setf xml
au BufNewFile,BufRead *.blogTemplate  setf xhtml
au BufNewFile,BufRead *.brail  setf xhtml
au BufNewFile,BufRead *.rst  setf xml
au BufNewFile,BufRead *.rsb  setf xml
au BufNewFile,BufRead *.io  setf io
au BufNewFile,BufRead *.notes setf notes
au BufNewFile,BufRead *.mg setf mg
au BufNewFile,BufRead *.spark setf html
" Needed for Syntax Highlighting and stuff
syntax on " syntax hilight on
syntax sync fromstart

" pathogen stuff
filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

if !exists(":JSLintToggle")
  command JSLintToggle :let b:jslint_disabled = exists('b:jslint_disabled') ? b:jslint_disabled ? 0 : 1 : 1
endif

set background=dark
"colorscheme zenburn
"colorscheme desert
colorscheme vividchalk
"colorscheme moria
"colorscheme solarized

" coffee script
let coffee_compile_on_save = 0

"xmlpretty
runtime xmlpretty.vim
command! -range=% Xmlpretty :call XmlPretty(<line1>, <line2>)
" disable warnings from NERDCommenter:
let g:NERDShutUp = 1

let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_autoshowtag = 1

"autocmd VimEnter * nested :call tagbar#autoopen(1)
"autocmd FileType * nested :call tagbar#autoopen(0)


vmap <leader>em :call ExtractMethod()<CR>
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

" ==================
" Custom mappings
" ==================


nnoremap <leader>ct "=strftime("%Y%m%d%H%M%S")<CR>P

" NERDTree stuff
map <leader>nt :execute 'NERDTreeToggle'<cr>
map <leader>nc :execute 'NERDTreeClose'<cr>
map <leader>nn :execute 'NERDTree'<cr>
"let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=2 " Change the NERDTree directory to the root node


map <leader>bo :execute '!gnome-open %'<cr>

"cmap w!! w !sudo tee % > /dev/null
"cmap trim call TrimWhiteSpace()
nmap <leader>fn File<tab>

"automatically remove trailing whitespace for these files
" Removes trailing spaces
function TrimWhiteSpace()
  %s/\s\+$//e
  :endfunction
  autocmd FileType html,ruby,python,java autocmd FileWritePre    * :call TrimWhiteSpace()
  autocmd FileType html,ruby,python,java autocmd FileAppendPre   * :call TrimWhiteSpace()
  autocmd FileType html,ruby,python,java autocmd FilterWritePre  * :call TrimWhiteSpace()
  autocmd FileType html,ruby,python,java autocmd BufWritePre     * :call TrimWhiteSpace()

  " js beautify
  nnoremap <silent> <leader>rj :call g:Jsbeautify()<cr>

  "FuzzyFinder stuff
  map <leader>ff :execute 'FufFile'<cr>
  map <leader>fd :execute 'FufDir'<cr>
  map <leader>fb :execute 'FufBuf'<cr>

  " tab navigation like firefox
  nmap <C-S-tab> :bprevious<cr>
  nmap <C-tab> :bnext<cr>
  map <C-S-tab> :bprevious<cr>
  map <C-tab> :bnext<cr>
  imap <C-S-tab> <ESC>:bprevious<cr>i
  imap <C-tab> <ESC>:bnext<cr>i
  "nmap <C-n> :tabnew<cr>


  " Haskell stuff
  map <leader>rh :execute '!runghc %'<cr>

  " miscellaneous
  " rewrite this command when you know how to get the current line info => map <leader>rl :execute '!ruby -e \'\''<cr>
  "execute ruby code in the current buffer
  map <leader>rc :execute '!ruby %'<cr>
  map <C-K><C-F> :Xmlpretty<CR>
  nnoremap <silent> <F8> :TlistToggle<CR>

  " reformat the file
  map <leader>rf gg=G<cr>

  " remove search highlight
  map <C-l> :nohls<cr>
  " =====================================================================
  " end of custom mappings
  " =====================================================================



  " change current directory to the directory of the current buffer
  nmap <silent> <leader>cd :lcd %:h<CR>

  " Underline the current line with '='
  nmap <silent> ,ul :t.\|s/./=/g\|set nohls<cr>

  " Delete all buffers
  nmap <silent> ,da :exec "1," . bufnr('$') . "bd"<cr>

  " Syntax coloring lines that are too long just slows down the world
  set synmaxcol=2048

  " I don't like it when the matching parens are automatically highlighted
  let loaded_matchparen = 1

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

  " Set the status line the way i like it
  set stl=%f\ %m\ %r\ Line:%l/%L[%p%%]\ Col:%c\ Buf:%n\ [%b][0x%B]
  "set stl=%f\ %m\ %r\ Line:%l/%L[%p%%]\ Col:%c\ Buf:%n\ [%b][0x%B] %<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P


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

  " set the gui options the way I like
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

  " The following beast is something i didn't write... it will return the
  " syntax highlighting group that the current "thing" under the cursor
  " belongs to -- very useful for figuring out what to change as far as
  " syntax highlighting goes.
  nmap <silent> <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
        \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name")
        \ . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
        \ . ">"<CR>

  " set text wrapping toggles
  nmap <silent> <leader>wt :set invwrap<CR>:set wrap?<CR>

  " Run the command that was just yanked
  nmap <silent> <leader>ry :@"<cr>

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

  set wrap!

  " Command T settings
  map <leader>t :CtrlP<cr>
  map <leader>cf :CtrlPClearCache<cr>


  " Buffer commands
  noremap <silent> <leader>bd :bd<CR>

  " TODO ============== Get this working in the right way ==========
  " set any autocmds (make sure they are only set once)
  "if !exists("autocommands_loaded")
  "let autocommands_loaded = 1

  " setup C# building
  "autocmd BufNewFile,BufRead *.cs compiler devenv

  " setup folding
  "autocmd BufNewFile,BufRead *.cs set foldmethod=syntax
  "endif
  " setup integrated help
  "function! OnlineDoc()
  "let s:wordUnderCursor = expand("<cword>")

  "if &ft =~ "cs"
  "let s:url = "http://social.msdn.microsoft.com/Search/en-US/?Refinement=26&Query=" . s:wordUnderCursor
  "else
  "execute "help " . s:wordUnderCursor
  "return
  "endif

  "let s:browser = "\"C:\Users\kberridge\AppData\Local\Google\Chrome\Application\chrome.exe\""
  "let s:cmd = "silent !start " . s:browser . " " . s:url

  "execute s:cmd
  "endfunction

  "map <silent> <F1> :call OnlineDoc()<CR>
  "imap <silent> <F1> <ESC>:call OnlineDoc()<CR>

  " TODO ============== Get this working in the right way ==========
  "

  " Custom functions
  "
  "

"au FocusLost * :set number
"au FocusGained * :set relativenumber
"

let g:slime_target = "tmux"
nnoremap <C-o> :tabedit %<CR>
nnoremap <C-d> :tabclose<CR>
let g:syntastic_ruby_exec="ruby-1.9.2-p290"
