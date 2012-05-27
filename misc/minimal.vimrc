set nocompatible

"mapleader this is what is used for the special <leader>
let mapleader=","

" This shows what you are typing as a command. I love this!
set showcmd

" Folding Stuffs ==> TODO:Need to set it to a more meaningful value
set foldmethod=marker

" Who doesn't like autoindent?
set autoindent

" Spaces are better than a tab character
set expandtab
set smarttab

" Who wants an 8 character tab? Not me!
set shiftwidth=2
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
set showmatch " Show matching braces.

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


" set custom file types I've configured
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
au BufNewFile,BufRead *.rb colorscheme vividchalk
au BufNewFile,BufRead *.erb colorscheme vividchalk
" Needed for Syntax Highlighting and stuff
syntax on " syntax hilight on
syntax sync fromstart 
filetype plugin indent on

" ==================
" Custom mappings
" ==================

" shortcut for alt-tabbing buffers
map <leader>bn :bn<cr>
map <leader>bp :bp<cr>

" reformat the file
map <leader>rf gg=G<cr> 

" remove search highlight
map <leader>rh :nohls<cr>
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

" Make sure that unsaved buffers that are to be put in the background are
" allowed to go in there (ie. the "must save first" error doesn't come up)
set hidden

" Set the status line the way i like it
set stl=%f\ %m\ %r\ Line:%l/%L[%p%%]\ Col:%c\ Buf:%n\ [%b][0x%B]

" tell VIM to always put a status line in, even if there is only one window
set laststatus=2
" Make command line two lines high
set ch=2
" Show the current mode
set showmode

" Hide the mouse pointer while typing
set mousehide

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

" set text wrapping toggles
nmap <silent> <leader>tw :set invwrap<CR>:set wrap?<CR>

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

" Buffer commands
noremap <silent> <leader>bd :bd<CR>
