" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
compiler/ghc.vim	[[[1
536

" Vim Compiler File
" Compiler:	GHC
" Maintainer:	Claus Reinke <claus.reinke@talk21.com>
" Last Change:	22/06/2010
"
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim

" ------------------------------ paths & quickfix settings first
"

if exists("current_compiler") && current_compiler == "ghc"
  finish
endif
let current_compiler = "ghc"

let s:scriptname = "ghc.vim"

if !haskellmode#GHC() | finish | endif
if (!exists("b:ghc_staticoptions"))
  let b:ghc_staticoptions = ''
endif

" set makeprg (for quickfix mode) 
execute 'setlocal makeprg=' . g:ghc . '\ ' . escape(b:ghc_staticoptions,' ') .'\ -e\ :q\ %'
"execute 'setlocal makeprg=' . g:ghc .'\ -e\ :q\ %'
"execute 'setlocal makeprg=' . g:ghc .'\ --make\ %'

" quickfix mode: 
" fetch file/line-info from error message
" TODO: how to distinguish multiline errors from warnings?
"       (both have the same header, and errors have no common id-tag)
"       how to get rid of first empty message in result list?
setlocal errorformat=
                    \%-Z\ %#,
                    \%W%f:%l:%c:\ Warning:\ %m,
                    \%E%f:%l:%c:\ %m,
                    \%E%>%f:%l:%c:,
                    \%+C\ \ %#%m,
                    \%W%>%f:%l:%c:,
                    \%+C\ \ %#%tarning:\ %m,

" oh, wouldn't you guess it - ghc reports (partially) to stderr..
setlocal shellpipe=2>

" ------------------------- but ghc can do a lot more for us..
"

" allow map leader override
if !exists("maplocalleader")
  let maplocalleader='_'
endif

" initialize map of identifiers to their types
" associate type map updates to changedtick
if !exists("b:ghc_types")
  let b:ghc_types = {}
  let b:my_changedtick = b:changedtick
endif

if exists("g:haskell_functions")
  finish
endif
let g:haskell_functions = "ghc"

" avoid hit-enter prompts
set cmdheight=3

" edit static GHC options
" TODO: add completion for options/packages?
command! GHCStaticOptions call GHC_StaticOptions()
function! GHC_StaticOptions()
  let b:ghc_staticoptions = input('GHC static options: ',b:ghc_staticoptions)
  execute 'setlocal makeprg=' . g:ghc . '\ ' . escape(b:ghc_staticoptions,' ') .'\ -e\ :q\ %'
  let b:my_changedtick -=1
endfunction

map <LocalLeader>T :call GHC_ShowType(1)<cr>
map <LocalLeader>t :call GHC_ShowType(0)<cr>
function! GHC_ShowType(addTypeDecl)
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [_,symb,qual,unqual] = namsym
  let name  = qual=='' ? unqual : qual.'.'.unqual
  let pname = ( symb ? '('.name.')' : name ) 
  call GHC_HaveTypes()
  if !has_key(b:ghc_types,name)
    redraw
    echo pname "type not known"
  else
    redraw
    for type in split(b:ghc_types[name],' -- ')
      echo pname "::" type
      if a:addTypeDecl
        call append( line(".")-1, pname . " :: " . type )
      endif
    endfor
  endif
endfunction

" show type of identifier under mouse pointer in balloon
" TODO: it isn't a good idea to tie potentially time-consuming tasks
"       (querying GHCi for the types) to cursor movements (#14). Currently,
"       we ask the user to call :GHCReload explicitly. Should there be an
"       option to reenable the old implicit querying?
if has("balloon_eval")
  set ballooneval
  set balloondelay=600
  set balloonexpr=GHC_TypeBalloon()
  function! GHC_TypeBalloon()
    if exists("b:current_compiler") && b:current_compiler=="ghc" 
      let [line] = getbufline(v:beval_bufnr,v:beval_lnum)
      let namsym = haskellmode#GetNameSymbol(line,v:beval_col,0)
      if namsym==[]
        return ''
      endif
      let [start,symb,qual,unqual] = namsym
      let name  = qual=='' ? unqual : qual.'.'.unqual
      let pname = name " ( symb ? '('.name.')' : name )
      if b:ghc_types == {} 
        redraw
        echo "no type information (try :GHGReload)"
      elseif (b:my_changedtick != b:changedtick)
        redraw
        echo "type information may be out of date (try :GHGReload)"
      endif
      " silent call GHC_HaveTypes()
      if b:ghc_types!={}
        if has("balloon_multiline")
          return (has_key(b:ghc_types,pname) ? split(b:ghc_types[pname],' -- ') : '') 
        else
          return (has_key(b:ghc_types,pname) ? b:ghc_types[pname] : '') 
        endif
      else
        return ''
      endif
    else
      return ''
    endif
  endfunction
endif

map <LocalLeader>si :call GHC_ShowInfo()<cr>
function! GHC_ShowInfo()
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [_,symb,qual,unqual] = namsym
  let name = qual=='' ? unqual : (qual.'.'.unqual)
  let output = GHC_Info(name)
  pclose | new 
  setlocal previewwindow
  setlocal buftype=nofile
  setlocal noswapfile
  put =output
  wincmd w
  "redraw
  "echo output
endfunction

" fill the type map, unless nothing has changed since the last attempt
function! GHC_HaveTypes()
  if b:ghc_types == {} && (b:my_changedtick != b:changedtick)
    let b:my_changedtick = b:changedtick
    return GHC_BrowseAll()
  endif
endfunction

" update b:ghc_types after successful make
au QuickFixCmdPost make if GHC_CountErrors()==0 | silent call GHC_BrowseAll() | endif

" count only error entries in quickfix list, ignoring warnings
function! GHC_CountErrors()
  let c=0
  for e in getqflist() | if e.type=='E' && e.text !~ "^[ \n]*Warning:" | let c+=1 | endif | endfor
  return c
endfunction

command! GHCReload call GHC_BrowseAll()
function! GHC_BrowseAll()
  " let imports = haskellmode#GatherImports()
  " let modules = keys(imports[0]) + keys(imports[1])
  let b:my_changedtick = b:changedtick
  let imports = {} " no need for them at the moment
  let current = GHC_NameCurrent()
  let module = current==[] ? 'Main' : current[0]
  if haskellmode#GHC_VersionGE([6,8,1])
    return GHC_BrowseBangStar(module)
  else
    return GHC_BrowseMultiple(imports,['*'.module])
  endif
endfunction

function! GHC_NameCurrent()
  let last = line("$")
  let l = 1
  while l<last
    let ml = matchlist( getline(l), '^module\s*\([^ (]*\)')
    if ml != []
      let [_,module;x] = ml
      return [module]
    endif
    let l += 1
  endwhile
  redraw
  echo "cannot find module header for file " . expand("%")
  return []
endfunction

function! GHC_BrowseBangStar(module)
  redraw
  echo "browsing module " a:module
  let command = ":browse! *" . a:module
  let orig_shellredir = &shellredir
  let &shellredir = ">" " ignore error/warning messages, only output or lack of it
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -v0 --interactive ' . expand("%") , command )
  let &shellredir = orig_shellredir
  return GHC_ProcessBang(a:module,output)
endfunction

function! GHC_BrowseMultiple(imports,modules)
  redraw
  echo "browsing modules " a:modules
  let command = ":browse " . join( a:modules, " \n :browse ") 
  let command = substitute(command,'\(:browse \(\S*\)\)','putStrLn "-- \2" \n \1','g')
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -v0 --interactive ' . expand("%") , command )
  return GHC_Process(a:imports,output)
endfunction

function! GHC_Info(what)
  " call GHC_HaveTypes()
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -v0 --interactive ' . expand("%"), ":info ". a:what)
  return output
endfunction

function! GHC_ProcessBang(module,output)
  let module      = a:module
  let b           = a:output
  let linePat     = '^\(.\{-}\)\n\(.*\)'
  let contPat     = '\s\+\(.\{-}\)\n\(.*\)'
  let typePat     = '^\(\)\(\S*\)\s*::\(.*\)'
  let commentPat  = '^-- \(\S*\)'
  let definedPat  = '^-- defined locally'
  let importedPat = '^-- imported via \(.*\)'
  if !(b=~commentPat)
    echo s:scriptname.": GHCi reports errors (try :make?)"
    return 0
  endif
  let b:ghc_types = {}
  let ml = matchlist( b , linePat )
  while ml != []
    let [_,l,rest;x] = ml
    let mlDecl = matchlist( l, typePat )
    if mlDecl != []
      let [_,indent,id,type;x] = mlDecl
      let ml2 = matchlist( rest , '^'.indent.contPat )
      while ml2 != []
        let [_,c,rest;x] = ml2
        let type .= c
        let ml2 = matchlist( rest , '^'.indent.contPat )
      endwhile
      let id   = substitute( id, '^(\(.*\))$', '\1', '')
      let type = substitute( type, '\s\+', " ", "g" )
      " using :browse! *<current>, we get both unqualified and qualified ids
      let qualified = (id =~ '\.') && (id =~ '[A-Z]')
      let b:ghc_types[id] = type
      if !qualified
        for qual in qualifiers
          let b:ghc_types[qual.'.'.id] = type
        endfor
      endif
    else
      let mlImported = matchlist( l, importedPat )
      let mlDefined  = matchlist( l, definedPat )
      if mlImported != []
        let [_,modules;x] = mlImported
        let qualifiers = split( modules, ', ' )
      elseif mlDefined != []
        let qualifiers = [module]
      endif
    endif
    let ml = matchlist( rest , linePat )
  endwhile
  return 1
endfunction

function! GHC_Process(imports,output)
  let b       = a:output
  let imports = a:imports
  let linePat = '^\(.\{-}\)\n\(.*\)'
  let contPat = '\s\+\(.\{-}\)\n\(.*\)'
  let typePat = '^\(\s*\)\(\S*\)\s*::\(.*\)'
  let modPat  = '^-- \(\S*\)'
  " add '-- defined locally' and '-- imported via ..'
  if !(b=~modPat)
    echo s:scriptname.": GHCi reports errors (try :make?)"
    return 0
  endif
  let b:ghc_types = {}
  let ml = matchlist( b , linePat )
  while ml != []
    let [_,l,rest;x] = ml
    let mlDecl = matchlist( l, typePat )
    if mlDecl != []
      let [_,indent,id,type;x] = mlDecl
      let ml2 = matchlist( rest , '^'.indent.contPat )
      while ml2 != []
        let [_,c,rest;x] = ml2
        let type .= c
        let ml2 = matchlist( rest , '^'.indent.contPat )
      endwhile
      let id   = substitute(id, '^(\(.*\))$', '\1', '')
      let type = substitute( type, '\s\+', " ", "g" )
      " using :browse *<current>, we get both unqualified and qualified ids
      if current_module " || has_key(imports[0],module) 
        if has_key(b:ghc_types,id) && !(matchstr(b:ghc_types[id],escape(type,'[].'))==type)
          let b:ghc_types[id] .= ' -- '.type
        else
          let b:ghc_types[id] = type
        endif
      endif
      if 0 " has_key(imports[1],module) 
        let qualid = module.'.'.id
        let b:ghc_types[qualid] = type
      endif
    else
      let mlMod = matchlist( l, modPat )
      if mlMod != []
        let [_,module;x] = mlMod
        let current_module = module[0]=='*'
        let module = current_module ? module[1:] : module
      endif
    endif
    let ml = matchlist( rest , linePat )
  endwhile
  return 1
endfunction

let s:ghc_templates = ["module _ () where","class _ where","class _ => _ where","instance _ where","instance _ => _ where","type family _","type instance _ = ","data _ = ","newtype _ = ","type _ = "]

" use ghci :browse index for insert mode omnicompletion (CTRL-X CTRL-O)
function! GHC_CompleteImports(findstart, base)
  if a:findstart 
    let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),-1) " insert-mode: we're 1 beyond the text
    if namsym==[]
      redraw
      echo 'no name/symbol under cursor!'
      return -1
    endif
    let [start,symb,qual,unqual] = namsym
    return (start-1)
  else " find keys matching with "a:base"
    let res = []
    let l   = len(a:base)-1
    call GHC_HaveTypes()
    for key in keys(b:ghc_types) 
      if key[0 : l]==a:base
        let res += [{"word":key,"menu":":: ".b:ghc_types[key],"dup":1}]
      endif
    endfor
    return res
  endif
endfunction
set omnifunc=GHC_CompleteImports
"
" Vim's default completeopt is menu,preview
" you probably want at least menu, or you won't see alternatives listed
" setlocal completeopt+=menu

" menuone is useful, but other haskellmode menus will try to follow your choice here in future
" setlocal completeopt+=menuone

" longest sounds useful, but doesn't seem to do what it says, and interferes with CTRL-E
" setlocal completeopt-=longest

map <LocalLeader>ct :call GHC_CreateTagfile()<cr>
function! GHC_CreateTagfile()
  redraw
  echo "creating tags file" 
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -e ":ctags" ' . expand("%"))
  " for ghcs older than 6.6, you would need to call another program 
  " here, such as hasktags
  echo output
endfunction

command! -nargs=1 GHCi redraw | echo system(g:ghc. ' ' . b:ghc_staticoptions .' '.expand("%").' -e "'.escape(<f-args>,'"').'"')

" use :make 'not in scope' errors to explicitly list imported ids
" cursor needs to be on import line, in correctly loadable module
map <LocalLeader>ie :call GHC_MkImportsExplicit()<cr>
function! GHC_MkImportsExplicit()
  let save_cursor = getpos(".")
  let line   = getline('.')
  let lineno = line('.')
  let ml     = matchlist(line,'^import\(\s*qualified\)\?\s*\([^( ]\+\)')
  if ml!=[]
    let [_,q,mod;x] = ml
    silent make
    if getqflist()==[]
      if line=~"import[^(]*Prelude"
        call setline(lineno,substitute(line,"(.*","","").'()')
      else
        call setline(lineno,'-- '.line)
      endif
      silent write
      silent make
      let qflist = getqflist()
      call setline(lineno,line)
      silent write
      let ids = {}
      for d in qflist
        let ml = matchlist(d.text,'Not in scope: \([^`]*\)`\([^'']*\)''')
        if ml!=[]
          let [_,what,qid;x] = ml
          let id  = ( qid =~ "^[A-Z]" ? substitute(qid,'.*\.\([^.]*\)$','\1','') : qid )
          let pid = ( id =~ "[a-zA-Z0-9_']\\+" ? id : '('.id.')' )
          if what =~ "data"
            call GHC_HaveTypes()
            if has_key(b:ghc_types,id)
              let pid = substitute(b:ghc_types[id],'^.*->\s*\(\S*\).*$','\1','').'('.pid.')'
            else
              let pid = '???('.pid.')'
            endif
          endif
          let ids[pid] = 1
        endif
      endfor
      call setline(lineno,'import'.q.' '.mod.'('.join(keys(ids),',').')')
    else
      copen
    endif
  endif
  call setpos('.', save_cursor)
endfunction

" no need to ask GHC about its supported languages and
" options with every editing session. cache the info in
" ~/.vim/haskellmode.config 
" TODO: should we store more info (see haskell_doc.vim)?
"       move to autoload?
"       should we keep a history of GHC versions encountered?
function! GHC_SaveConfig()
  let vimdir = expand('~').'/'.'.vim'
  let config = vimdir.'/haskellmode.config'
  if !isdirectory(vimdir)
    call mkdir(vimdir)
  endif
  let entries = ['-- '.g:ghc_version]
  for l in s:ghc_supported_languages
    let entries += [l]
  endfor
  let entries += ['--']
  for l in s:opts
    let entries += [l]
  endfor
  call writefile(entries,config)
endfunction

" reuse cached GHC configuration info, if using the same
" GHC version.
function! GHC_LoadConfig()
  let vimdir = expand('~').'/'.'.vim'
  let config = vimdir.'/haskellmode.config'
  if filereadable(config)
    let lines = readfile(config)
    if lines[0]=='-- '.g:ghc_version
      let i=1
      let s:ghc_supported_languages = []
      while i<len(lines) && lines[i]!='--'
        let s:ghc_supported_languages += [lines[i]]
        let i+=1
      endwhile
      let i+=1
      let s:opts = []
      while i<len(lines)
        let s:opts += [lines[i]]
        let i+=1
      endwhile
      return 1
    else
      return 0
    endif
  else
    return 0
  endif
endfunction

let s:GHC_CachedConfig = haskellmode#GHC_VersionGE([6,8]) && GHC_LoadConfig()

if haskellmode#GHC_VersionGE([6,8,2])
  if !s:GHC_CachedConfig
    let s:opts = filter(split(substitute(system(g:ghc . ' -v0 --interactive', ':set'), '  ', '','g'), '\n'), 'v:val =~ "-f"')
  endif
else
  let s:opts = ["-fglasgow-exts","-fallow-undecidable-instances","-fallow-overlapping-instances","-fno-monomorphism-restriction","-fno-mono-pat-binds","-fno-cse","-fbang-patterns","-funbox-strict-fields"]
endif
let s:opts = sort(s:opts)

amenu ]OPTIONS_GHC.- :echo '-'<cr>
aunmenu ]OPTIONS_GHC
for o in s:opts
  exe 'amenu ]OPTIONS_GHC.'.o.' :call append(0,"{-# OPTIONS_GHC '.o.' #-}")<cr>'
endfor
if has("gui_running")
  map <LocalLeader>opt :popup ]OPTIONS_GHC<cr>
else
  map <LocalLeader>opt :emenu ]OPTIONS_GHC.
endif

amenu ]LANGUAGES_GHC.- :echo '-'<cr>
aunmenu ]LANGUAGES_GHC
if haskellmode#GHC_VersionGE([6,8])
  if !s:GHC_CachedConfig
    let s:ghc_supported_languages = sort(split(system(g:ghc . ' --supported-languages'),'\n'))
  endif
  for l in s:ghc_supported_languages
    exe 'amenu ]LANGUAGES_GHC.'.l.' :call append(0,"{-# LANGUAGE '.l.' #-}")<cr>'
  endfor
  if has("gui_running")
    map <LocalLeader>lang :popup ]LANGUAGES_GHC<cr>
  else
    map <LocalLeader>lang :emenu ]LANGUAGES_GHC.
  endif
endif

if !s:GHC_CachedConfig
  call GHC_SaveConfig()
endif

ftplugin/haskell.vim	[[[1
14
"
" general Haskell source settings
" (shared functions are in autoload/haskellmode.vim)
"
" (Claus Reinke, last modified: 28/04/2009)
"
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim
" please send patches to <claus.reinke@talk21.com>

" try gf on import line, or ctrl-x ctrl-i, or [I, [i, ..
setlocal include=^import\\s*\\(qualified\\)\\?\\s*
setlocal includeexpr=substitute(v:fname,'\\.','/','g').'.'
setlocal suffixesadd=hs,lhs,hsc

ftplugin/haskell_doc.vim	[[[1
881
"
" use haddock docs and index files
" show documentation, complete & qualify identifiers 
"
" (Claus Reinke; last modified: 17/06/2009)
" 
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim
" please send patches to <claus.reinke@talk21.com>

" :Doc <name> and :IDoc <name> open haddocks for <name> in opera
"
"   :Doc needs qualified name (default Prelude) and package (default base)
"   :IDoc needs unqualified name, looks up possible links in g:haddock_index
"
"   :DocIndex populates g:haddock_index from haddock's index files
"   :ExportDocIndex saves g:haddock_index to cache file
"   :ImportDocIndex reloads g:haddock_index from cache file
"
" all the following use the haddock index (g:haddock_index)
"
" _? opens haddocks for unqualified name under cursor, 
"    suggesting alternative full qualifications in popup menu
"
" _. fully qualifies unqualified name under cursor,
"    suggesting alternative full qualifications in popup menu
"
" _i  add import <module>(<name>) statement for unqualified <name> under cursor,
" _im add import <module>         statement for unqualified <name> under cursor,
"    suggesting alternative full qualifications in popup menu
"    (this currently adds one statement per call, instead of
"     merging into existing import statements, but it's a start;-)
"
" CTRL-X CTRL-U (user-defined insert mode completion) 
"   suggests completions of unqualified names in popup menu

let s:scriptname = "haskell_doc.vim"

" script parameters
"   g:haddock_browser            *mandatory* which browser to call
"   g:haddock_browser_callformat [optional] how to call browser
"   g:haddock_indexfiledir       [optional] where to put 'haddock_index.vim'
"   g:haddock_docdir             [optional] where to find html docs
"   g:ghc                        [optional] which ghc to call
"   g:ghc_pkg                    [optional] which ghc_pkg to call

" been here before?
if exists("g:haddock_index")
  finish
endif

" initialise nested dictionary, to be populated 
" - from haddock index files via :DocIndex
" - from previous cached version via :ImportDocIndex
let g:haddock_index = {}

" initialise dictionary, mapping modules with haddocks to their packages,
" populated via MkHaddockModuleIndex() or HaveModuleIndex()
let g:haddock_moduleindex = {}

" program to open urls, please set this in your vimrc
  "examples (for windows):
  "let g:haddock_browser = "C:/Program Files/Opera/Opera.exe"
  "let g:haddock_browser = "C:/Program Files/Mozilla Firefox/firefox.exe"
  "let g:haddock_browser = "C:/Program Files/Internet Explorer/IEXPLORE.exe"
if !exists("g:haddock_browser")
  echoerr s:scriptname." WARNING: please set g:haddock_browser!"
endif

if !haskellmode#GHC() | finish | endif

if (!exists("g:ghc_pkg") || !executable(g:ghc_pkg))
  let g:ghc_pkg = substitute(g:ghc,'\(.*\)ghc','\1ghc-pkg','')
endif

if exists("g:haddock_docdir") && isdirectory(g:haddock_docdir)
  let s:docdir = g:haddock_docdir
elseif executable(g:ghc_pkg)
" try to figure out location of html docs
" first choice: where the base docs are (from the first base listed)
  let [field;x] = split(system(g:ghc_pkg . ' field base haddock-html'),'\n')
  " path changes in ghc-6.12.*
  " let field = substitute(field,'haddock-html: \(.*\)libraries.base','\1','')
  let field = substitute(field,'haddock-html: \(.*\)lib\(raries\)\?.base.*$','\1','')
  let field = substitute(field,'\\','/','g')
  " let alternate = substitute(field,'html','doc/html','')
  " changes for ghc-6.12.*: check for doc/html/ first
  let alternate = field.'doc/html/'
  if isdirectory(alternate)
    let s:docdir = alternate
  elseif isdirectory(field)
    let s:docdir = field
  endif
else
  echoerr s:scriptname." can't find ghc-pkg (set g:ghc_pkg ?)."
endif

" second choice: try some known suspects for windows/unix
if !exists('s:docdir') || !isdirectory(s:docdir)
  let s:ghc_libdir = substitute(system(g:ghc . ' --print-libdir'),'\n','','')
  let location1a = s:ghc_libdir . '/doc/html/'
  let location1b = s:ghc_libdir . '/doc/'
  let location2 = '/usr/share/doc/ghc-' . haskellmode#GHC_Version() . '/html/' 
  if isdirectory(location1a)
    let s:docdir = location1a
  elseif isdirectory(location1b)
    let s:docdir = location1b
  elseif isdirectory(location2)
    let s:docdir = location2
  else " give up
    echoerr s:scriptname." can't find locaton of html documentation (set g:haddock_docdir)."
    finish
  endif
endif

" todo: can we turn s:docdir into a list of paths, and
" include docs for third-party libs as well?

let s:libraries         = s:docdir . 'libraries/'
let s:guide             = s:docdir . 'users_guide/'
let s:index             = 'index.html'
if exists("g:haddock_indexfiledir") && filewritable(g:haddock_indexfiledir)
  let s:haddock_indexfiledir = g:haddock_indexfiledir 
elseif filewritable(s:libraries)
  let s:haddock_indexfiledir = s:libraries
elseif filewritable($HOME)
  let s:haddock_indexfiledir = $HOME.'/'
else "give up
  echoerr s:scriptname." can't locate index file. please set g:haddock_indexfiledir"
  finish
endif
let s:haddock_indexfile = s:haddock_indexfiledir . 'haddock_index.vim'

" different browser setups require different call formats;
" you might want to call the browser synchronously or 
" asynchronously, and the latter is os-dependent;
"
" by default, the browser is started in the background when on 
" windows or if running in a gui, and in the foreground otherwise
" (eg, console-mode for remote sessions, with text-mode browsers).
"
" you can override these defaults in your vimrc, via a format 
" string including 2 %s parameters (the first being the browser 
" to call, the second being the url).
if !exists("g:haddock_browser_callformat")
  if has("win32") || has("win64")
    let g:haddock_browser_callformat = 'start %s "%s"'
  else
    if has("gui_running")
      let g:haddock_browser_callformat = '%s %s '.printf(&shellredir,'/dev/null').' &'
    else
      let g:haddock_browser_callformat = '%s %s'
    endif
  endif
endif

" allow map leader override
if !exists("maplocalleader")
  let maplocalleader='_'
endif

command! DocSettings call DocSettings()
function! DocSettings()
  for v in ["g:haddock_browser","g:haddock_browser_callformat","g:haddock_docdir","g:haddock_indexfiledir","s:ghc_libdir","g:ghc_version","s:docdir","s:libraries","s:guide","s:haddock_indexfile"]
    if exists(v)
      echo v '=' eval(v)
    else
      echo v '='
    endif
  endfor
endfunction

function! DocBrowser(url)
  "echomsg "DocBrowser(".url.")"
  if (!exists("g:haddock_browser") || !executable(g:haddock_browser))
    echoerr s:scriptname." can't find documentation browser. please set g:haddock_browser"
    return
  endif
  " start browser to open url, according to specified format
  let url = a:url=~'^\(file://\|http://\)' ? a:url : 'file://'.a:url
  silent exe '!'.printf(g:haddock_browser_callformat,g:haddock_browser,escape(url,'#%')) 
endfunction

"Doc/Doct are an old interface for documentation lookup
"(that is the reason they are not documented!-)
"
"These uses are still fine at the moment, and are the reason 
"that this command still exists at all
"
" :Doc -top
" :Doc -libs
" :Doc -guide
"
"These uses may or may not work, and shouldn't be relied on anymore
"(usually, you want _?/_?1/_?2 or :MDoc; there is also :IDoc)
"
" :Doc length
" :Doc Control.Monad.when
" :Doc Data.List.
" :Doc Control.Monad.State.runState mtl
command! -nargs=+ Doc  call Doc('v',<f-args>)
command! -nargs=+ Doct call Doc('t',<f-args>)

function! Doc(kind,qualname,...) 
  let suffix   = '.html'
  let relative = '#'.a:kind.'%3A'

  if a:qualname=="-top"
    call DocBrowser(s:docdir . s:index)
    return
  elseif a:qualname=="-libs"
    call DocBrowser(s:libraries . s:index)
    return
  elseif a:qualname=="-guide"
    call DocBrowser(s:guide . s:index)
    return
  endif

  if a:0==0 " no package specified
    let package = 'base/'
  else
    let package = a:1 . '/'
  endif

  if match(a:qualname,'\.')==-1 " unqualified name
    let [qual,name] = [['Prelude'],a:qualname]
    let file = join(qual,'-') . suffix . relative . name
  elseif a:qualname[-1:]=='.' " module qualifier only
    let parts = split(a:qualname,'\.')
    let quallen = len(parts)-1
    let [qual,name] = [parts[0:quallen],parts[-1]]
    let file = join(qual,'-') . suffix
  else " qualified name
    let parts = split(a:qualname,'\.')
    let quallen = len(parts)-2
    let [qual,name] = [parts[0:quallen],parts[-1]]
    let file = join(qual,'-') . suffix . relative . name
  endif

  let path = s:libraries . package . file
  call DocBrowser(path)
endfunction

" TODO: add commandline completion for :IDoc
"       switch to :emenu instead of inputlist?
" indexed variant of Doc, looking up links in g:haddock_index
" usage:
"  1. :IDoc length
"  2. click on one of the choices, or select by number (starting from 0)
command! -nargs=+ IDoc call IDoc(<f-args>)
function! IDoc(name,...) 
  let choices = HaddockIndexLookup(a:name)
  if choices=={} | return | endif
  if a:0==0
    let keylist = map(deepcopy(keys(choices)),'substitute(v:val,"\\[.\\]","","")')
    let choice = inputlist(keylist)
  else
    let choice = a:1
  endif
  let path = values(choices)[choice] " assumes same order for keys/values..
  call DocBrowser(path)
endfunction

let s:flagref = s:guide . 'flag-reference.html'
if filereadable(s:flagref)
  " extract the generated fragment ids for the 
  " flag reference sections 
  let s:headerPat     = '.\{-}<h3 class="title"><a name="\([^"]*\)"><\/a>\([^<]*\)<\/h3>\(.*\)'
  let s:flagheaders   = []
  let s:flagheaderids = {}
  let s:contents      = join(readfile(s:flagref))
  let s:ml = matchlist(s:contents,s:headerPat)
  while s:ml!=[]
    let [_,s:id,s:title,s:r;s:x] = s:ml
    let s:flagheaders            = add(s:flagheaders, s:title)
    let s:flagheaderids[s:title] = s:id
    let s:ml = matchlist(s:r,s:headerPat)
  endwhile
  command! -nargs=1 -complete=customlist,CompleteFlagHeaders FlagReference call FlagReference(<f-args>)
  function! FlagReference(section)
    let relativeUrl = a:section==""||!exists("s:flagheaderids['".a:section."']") ? 
                    \ "" : "#".s:flagheaderids[a:section]
    call DocBrowser(s:flagref.relativeUrl)
  endfunction
  function! CompleteFlagHeaders(al,cl,cp)
    let s:choices = s:flagheaders
    return CompleteAux(a:al,a:cl,a:cp)
  endfunction
endif

command! -nargs=1 -complete=customlist,CompleteHaddockModules MDoc call MDoc(<f-args>)
function! MDoc(module)
  let suffix   = '.html'
  call HaveModuleIndex()
  if !has_key(g:haddock_moduleindex,a:module)
    echoerr a:module 'not found in haddock module index'
    return
  endif
  let package = g:haddock_moduleindex[a:module]['package']
  let file    = substitute(a:module,'\.','-','g') . suffix
" let path    = s:libraries . package . '/' . file
  let path    = g:haddock_moduleindex[a:module]['html']
  call DocBrowser(path)
endfunction

function! CompleteHaddockModules(al,cl,cp)
  call HaveModuleIndex()
  let s:choices = keys(g:haddock_moduleindex)
  return CompleteAux(a:al,a:cl,a:cp)
endfunction

" create a dictionary g:haddock_index, containing the haddoc index
command! DocIndex call DocIndex()
function! DocIndex()
  let files   = split(globpath(s:libraries,'doc-index*.html'),'\n')
  let g:haddock_index = {}
  if haskellmode#GHC_VersionGE([7,0,0])
    call ProcessHaddockIndexes3(s:libraries,files)
  else
    call ProcessHaddockIndexes2(s:libraries,files)
  endif
  if haskellmode#GHC_VersionGE([6,8,2])
    if &shell =~ 'sh' " unix-type shell
      let s:addon_libraries = split(system(g:ghc_pkg . ' field \* haddock-html'),'\n')
    else " windows cmd.exe and the like
      let s:addon_libraries = split(system(g:ghc_pkg . ' field * haddock-html'),'\n')
    endif
    for addon in s:addon_libraries
      let ml = matchlist(addon,'haddock-html: \("\)\?\(file:///\)\?\([^"]*\)\("\)\?')
      if ml!=[]
        let [_,quote,file,addon_path;x] = ml
        let addon_path = substitute(addon_path,'\(\\\\\|\\\)','/','g')
        let addon_files = split(globpath(addon_path,'doc-index*.html'),'\n')
        if haskellmode#GHC_VersionGE([7,0,0])
          call ProcessHaddockIndexes3(addon_path,addon_files)
        else
          call ProcessHaddockIndexes2(addon_path,addon_files)
        endif
      endif
    endfor
  endif
  return 1
endfunction

function! ProcessHaddockIndexes(location,files)
  let entryPat= '.\{-}"indexentry"[^>]*>\([^<]*\)<\(\%([^=]\{-}TD CLASS="\%(indexentry\)\@!.\{-}</TD\)*\)[^=]\{-}\(\%(="indexentry\|TABLE\).*\)'
  let linkPat = '.\{-}HREF="\([^"]*\)".>\([^<]*\)<\(.*\)'

  redraw
  echo 'populating g:haddock_index from haddock index files in ' a:location
  for f in a:files  
    echo f[len(a:location):]
    let contents = join(readfile(f))
    let ml = matchlist(contents,entryPat)
    while ml!=[]
      let [_,entry,links,r;x] = ml
      "echo entry links
      let ml2 = matchlist(links,linkPat)
      let link = {}
      while ml2!=[]
        let [_,l,m,links;x] = ml2
        "echo l m
        let link[m] = a:location . '/' . l
        let ml2 = matchlist(links,linkPat)
      endwhile
      let g:haddock_index[DeHTML(entry)] = deepcopy(link)
      "echo entry g:haddock_index[entry]
      let ml = matchlist(r,entryPat)
    endwhile
  endfor
endfunction

" concatenating all lines is too slow for a big file, process lines directly
function! ProcessHaddockIndexes2(location,files)
  let entryPat= '^>\([^<]*\)</'
  let linkPat = '.\{-}A HREF="\([^"]*\)"'
  let kindPat = '#\(.\)'

  " redraw
  echo 'populating g:haddock_index from haddock index files in ' a:location
  for f in a:files  
    echo f[len(a:location):]
    let isEntry = 0
    let isLink  = ''
    let link    = {}
    let entry   = ''
    for line in readfile(f)
      if line=~'CLASS="indexentry' 
        if (link!={}) && (entry!='')
          if has_key(g:haddock_index,DeHTML(entry))
            let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
          else
            let dict = deepcopy(link)
          endif
          let g:haddock_index[DeHTML(entry)] = dict
          let link  = {}
          let entry = ''
        endif
        let isEntry=1 
        continue 
      endif
      if isEntry==1
        let ml = matchlist(line,entryPat)
        if ml!=[] | let [_,entry;x] = ml | let isEntry=0 | continue | endif
      endif
      if entry!=''
        let ml = matchlist(line,linkPat)
        if ml!=[] | let [_,isLink;x]=ml | continue | endif
      endif
      if isLink!=''
        let ml = matchlist(line,entryPat)
        if ml!=[] 
          let [_,module;x] = ml 
          let [_,kind;x]   = matchlist(isLink,kindPat)
          let last         = a:location[strlen(a:location)-1]
          let link[module."[".kind."]"] = a:location . (last=='/'?'':'/') . isLink
          let isLink='' 
          continue 
        endif
      endif
    endfor
    if link!={} 
      if has_key(g:haddock_index,DeHTML(entry))
        let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
      else
        let dict = deepcopy(link)
      endif
      let g:haddock_index[DeHTML(entry)] = dict
    endif
  endfor
endfunction

function! ProcessHaddockIndexes3(location,files)
  let entryPat= '>\(.*\)$'
  let linkPat = '<a href="\([^"]*\)"'
  let kindPat = '#\(.\)'

  " redraw
  echo 'populating g:haddock_index from haddock index files in ' a:location
  for f in a:files  
    echo f[len(a:location):]
    let isLink  = ''
    let link    = {}
    let entry   = ''
    let lines   = split(join(readfile(f,'b')),'\ze<')
    for line in lines
      if (line=~'class="src') || (line=~'/table')
        if (link!={}) && (entry!='')
          if has_key(g:haddock_index,DeHTML(entry))
            let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
          else
            let dict = deepcopy(link)
          endif
          let g:haddock_index[DeHTML(entry)] = dict
          let link  = {}
          let entry = ''
        endif
        let ml = matchlist(line,entryPat)
        if ml!=[] | let [_,entry;x] = ml | continue | endif
        continue 
      endif
      if entry!=''
        let ml = matchlist(line,linkPat)
        if ml!=[] 
          let [_,isLink;x]=ml
          let ml = matchlist(line,entryPat)
          if ml!=[] 
            let [_,module;x] = ml 
            let [_,kind;x]   = matchlist(isLink,kindPat)
            let last         = a:location[strlen(a:location)-1]
            let link[module."[".kind."]"] = a:location . (last=='/'?'':'/') . isLink
            let isLink='' 
          endif
          continue
        endif
      endif
    endfor
    if link!={} 
      if has_key(g:haddock_index,DeHTML(entry))
        let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
      else
        let dict = deepcopy(link)
      endif
      let g:haddock_index[DeHTML(entry)] = dict
    endif
  endfor
endfunction


command! ExportDocIndex call ExportDocIndex()
function! ExportDocIndex()
  call HaveIndex()
  let entries = []
  for key in keys(g:haddock_index)
    let entries += [key,string(g:haddock_index[key])]
  endfor
  call writefile(entries,s:haddock_indexfile)
  redir end
endfunction

command! ImportDocIndex call ImportDocIndex()
function! ImportDocIndex()
  if filereadable(s:haddock_indexfile)
    let lines = readfile(s:haddock_indexfile)
    let i=0
    while i<len(lines)
      let [key,dict] = [lines[i],lines[i+1]]
      sandbox let g:haddock_index[key] = eval(dict) 
      let i+=2
    endwhile
    return 1
  else
    return 0
  endif
endfunction

function! HaveIndex()
  return (g:haddock_index!={} || ImportDocIndex() || DocIndex() )
endfunction

function! MkHaddockModuleIndex()
  let g:haddock_moduleindex = {}
  call HaveIndex()
  for key in keys(g:haddock_index)
    let dict = g:haddock_index[key]
    for module in keys(dict)
      let html = dict[module]
      let html   = substitute(html  ,'#.*$','','')
      let module = substitute(module,'\[.\]','','')
      let ml = matchlist(html,'libraries/\([^\/]*\)[\/]')
      if ml!=[]
        let [_,package;x] = ml
        let g:haddock_moduleindex[module] = {'package':package,'html':html}
      endif
      let ml = matchlist(html,'/\([^\/]*\)\/html/[A-Z]')
      if ml!=[]
        let [_,package;x] = ml
        let g:haddock_moduleindex[module] = {'package':package,'html':html}
      endif
    endfor
  endfor
endfunction

function! HaveModuleIndex()
  return (g:haddock_moduleindex!={} || MkHaddockModuleIndex() )
endfunction

" decode HTML symbol encodings (are these all we need?)
function! DeHTML(entry)
  let res = a:entry
  let decode = { '&lt;': '<', '&gt;': '>', '&amp;': '\\&' }
  for enc in keys(decode)
    exe 'let res = substitute(res,"'.enc.'","'.decode[enc].'","g")'
  endfor
  return res
endfunction

" find haddocks for word under cursor
" also lists possible definition sites
" - needs to work for both qualified and unqualified items
" - for 'import qualified M as A', consider M.item as source of A.item
" - offer sources from both type [t] and value [v] namespaces
" - for unqualified items, list all possible sites
" - for qualified items, list imported sites only
" keep track of keys with and without namespace tags:
" the former are needed for lookup, the latter for matching against source
map <LocalLeader>? :call Haddock()<cr>
function! Haddock()
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  let imports = haskellmode#GatherImports()
  let asm  = has_key(imports[1],qual) ? imports[1][qual]['modules'] : []
  let name = unqual
  let dict = HaddockIndexLookup(name)
  if dict=={} | return | endif
  " for qualified items, narrow results to possible imports that provide qualifier
  let filteredKeys = filter(copy(keys(dict))
                         \ ,'match(asm,substitute(v:val,''\[.\]'','''',''''))!=-1') 
  let keys = (qual!='') ?  filteredKeys : keys(dict)
  if (keys==[]) && (qual!='')
    echoerr qual.'.'.unqual.' not found in imports'
    return 0
  endif
  " use 'setlocal completeopt+=menuone' if you always want to see menus before
  " anything happens (I do, but many users don't..)
  if len(keys)==1 && (&completeopt!~'menuone')
        call DocBrowser(dict[keys[0]])
  elseif has("gui_running")
    for key in keys
      exe 'amenu ]Popup.'.escape(key,'\.').' :call DocBrowser('''.dict[key].''')<cr>'
    endfor
    popup ]Popup
  else
    let s:choices = keys
    let key = input('browse docs for '.name.' in: ','','customlist,CompleteAux')
    if key!=''
      call DocBrowser(dict[key])
    endif
  endif
endfunction

if !exists("g:haskell_search_engines")
  let g:haskell_search_engines = 
    \ {'hoogle':'http://www.haskell.org/hoogle/?hoogle=%s'
    \ ,'hayoo!':'http://holumbus.fh-wedel.de/hayoo/hayoo.html?query=%s'
    \ }
endif

map <LocalLeader>?? :let es=g:haskell_search_engines
                 \ \|echo "g:haskell_search_engines"
                 \ \|for e in keys(es)
                 \ \|echo e.' : '.es[e]
                 \ \|endfor<cr>
map <LocalLeader>?1 :call HaskellSearchEngine('hoogle')<cr>
map <LocalLeader>?2 :call HaskellSearchEngine('hayoo!')<cr>

" query one of the Haskell search engines for the thing under cursor
" - unqualified symbols need to be url-escaped
" - qualified ids need to be fed as separate qualifier and id for
"   both hoogle (doesn't handle qualified symbols) and hayoo! (no qualified
"   ids at all)
" - qualified ids referring to import-qualified-as qualifiers need to be
"   translated to the multi-module searches over the list of original modules
function! HaskellSearchEngine(engine)
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  let imports = haskellmode#GatherImports()
  let asm  = has_key(imports[1],qual) ? imports[1][qual]['modules'] : []
  let unqual = haskellmode#UrlEncode(unqual)
  if a:engine=='hoogle'
    let name = asm!=[] ? unqual.'+'.join(map(copy(asm),'"%2B".v:val'),'+')
           \ : qual!='' ? unqual.'+'.haskellmode#UrlEncode('+').qual
           \ : unqual
  elseif a:engine=='hayoo!'
    let name = asm!=[] ? unqual.'+module:('.join(copy(asm),' OR ').')'
           \ : qual!='' ? unqual.'+module:'.qual
           \ : unqual
  else
    let name = qual=="" ? unqual : qual.".".unqual
  endif
  if has_key(g:haskell_search_engines,a:engine)
    call DocBrowser(printf(g:haskell_search_engines[a:engine],name))
  else
    echoerr "unknown search engine: ".a:engine
  endif
endfunction

" used to pass on choices to CompleteAux
let s:choices=[]

" if there's no gui, use commandline completion instead of :popup
" completion function CompleteAux suggests completions for a:al, wrt to s:choices
function! CompleteAux(al,cl,cp)
  "echomsg '|'.a:al.'|'.a:cl.'|'.a:cp.'|'
  let res = []
  let l = len(a:al)-1
  for r in s:choices
    if l==-1 || r[0 : l]==a:al
      let res += [r]
    endif
  endfor
  return res
endfunction

" CamelCase shorthand matching: 
" favour upper-case letters and module qualifier separators (.) for disambiguation
function! CamelCase(shorthand,string)
  let s1 = a:shorthand
  let s2 = a:string
  let notFirst = 0 " don't elide before first pattern letter
  while ((s1!="")&&(s2!="")) 
    let head1 = s1[0]
    let head2 = s2[0]
    let elide = notFirst && ( ((head1=~'[A-Z]') && (head2!~'[A-Z.]')) 
              \             ||((head1=='.') && (head2!='.')) ) 
    if elide
      let s2=s2[1:]
    elseif (head1==head2) 
      let s1=s1[1:]
      let s2=s2[1:]
    else
      return 0
    endif
    let notFirst = (head1!='.')||(head2!='.') " treat separators as new beginnings
  endwhile
  return (s1=="")
endfunction

" use haddock name index for insert mode completion (CTRL-X CTRL-U)
function! CompleteHaddock(findstart, base)
  if a:findstart 
    let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),-1) " insert-mode: we're 1 beyond the text
    if namsym==[]
      redraw
      echo 'no name/symbol under cursor!'
      return -1
    endif
    let [start,symb,qual,unqual] = namsym
    return (start-1)
  else " find keys matching with "a:base"
    let res  = []
    let l    = len(a:base)-1
    let qual = a:base =~ '^[A-Z][a-zA-Z0-9_'']*\(\.[A-Z][a-zA-Z0-9_'']*\)*\(\.[a-zA-Z0-9_'']*\)\?$'
    call HaveIndex() 
    for key in keys(g:haddock_index)
      let keylist = map(deepcopy(keys(g:haddock_index[key])),'substitute(v:val,"\\[.\\]","","")')
      if (key[0 : l]==a:base)
        for m in keylist
          let res += [{"word":key,"menu":m,"dup":1}]
        endfor
      elseif qual " this tends to be slower
        for m in keylist
          let word = m . '.' . key
          if word[0 : l]==a:base
            let res += [{"word":word,"menu":m,"dup":1}]
          endif
        endfor
      endif
    endfor
    if res==[] " no prefix matches, try CamelCase shortcuts
      for key in keys(g:haddock_index)
        let keylist = map(deepcopy(keys(g:haddock_index[key])),'substitute(v:val,"\\[.\\]","","")')
        if CamelCase(a:base,key)
          for m in keylist
            let res += [{"word":key,"menu":m,"dup":1}]
          endfor
        elseif qual " this tends to be slower
          for m in keylist
            let word = m . '.' . key
            if CamelCase(a:base,word)
              let res += [{"word":word,"menu":m,"dup":1}]
            endif
          endfor
        endif
      endfor
    endif
    return res
  endif
endfunction
setlocal completefunc=CompleteHaddock
"
" Vim's default completeopt is menu,preview
" you probably want at least menu, or you won't see alternatives listed
" setlocal completeopt+=menu

" menuone is useful, but other haskellmode menus will try to follow your choice here in future
" setlocal completeopt+=menuone

" longest sounds useful, but doesn't seem to do what it says, and interferes with CTRL-E
" setlocal completeopt-=longest

" fully qualify an unqualified name
" TODO: - standardise commandline versions of menus
map <LocalLeader>. :call Qualify()<cr>
function! Qualify()
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  if qual!=''  " TODO: should we support re-qualification?
    redraw
    echo 'already qualified'
    return 0
  endif
  let name = unqual
  let line         = line('.')
  let prefix       = (start<=1 ? '' : getline(line)[0:start-2] )
  let dict   = HaddockIndexLookup(name)
  if dict=={} | return | endif
  let keylist = map(deepcopy(keys(dict)),'substitute(v:val,"\\[.\\]","","")')
  let imports = haskellmode#GatherImports()
  let qualifiedImports = []
  for qualifiedImport in keys(imports[1])
    let c=0
    for module in imports[1][qualifiedImport]['modules']
      if haskellmode#ListElem(keylist,module) | let c+=1 | endif
    endfor
    if c>0 | let qualifiedImports=[qualifiedImport]+qualifiedImports | endif
  endfor
  "let asm  = has_key(imports[1],qual) ? imports[1][qual]['modules'] : []
  let keylist = filter(copy(keylist),'index(qualifiedImports,v:val)==-1')
  if has("gui_running")
    " amenu ]Popup.-imported- :
    for key in qualifiedImports
      let lhs=escape(prefix.name,'/.|\')
      let rhs=escape(prefix.key.'.'.name,'/&|\')
      exe 'amenu ]Popup.'.escape(key,'\.').' :'.line.'s/'.lhs.'/'.rhs.'/<cr>:noh<cr>'
    endfor
    amenu ]Popup.-not\ imported- :
    for key in keylist
      let lhs=escape(prefix.name,'/.|\')
      let rhs=escape(prefix.key.'.'.name,'/&|\')
      exe 'amenu ]Popup.'.escape(key,'\.').' :'.line.'s/'.lhs.'/'.rhs.'/<cr>:noh<cr>'
    endfor
    popup ]Popup
  else
    let s:choices = qualifiedImports+keylist
    let key = input('qualify '.name.' with: ','','customlist,CompleteAux')
    if key!=''
      let lhs=escape(prefix.name,'/.\')
      let rhs=escape(prefix.key.'.'.name,'/&\')
      exe line.'s/'.lhs.'/'.rhs.'/'
      noh
    endif
  endif
endfunction

" create (qualified) import for a (qualified) name
" TODO: refine search patterns, to avoid misinterpretation of
"       oddities like import'Neither or not'module
map <LocalLeader>i :call Import(0,0)<cr>
map <LocalLeader>im :call Import(1,0)<cr>
map <LocalLeader>iq :call Import(0,1)<cr>
map <LocalLeader>iqm :call Import(1,1)<cr>
function! Import(module,qualified)
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  let name       = unqual
  let pname      = ( symb ? '('.name.')' : name )
  let importlist = a:module ? '' : '('.pname.')'
  let qualified  = a:qualified ? 'qualified ' : ''

  if qual!=''
    exe 'call append(search(''\%1c\(\<import\>\|\<module\>\|{-# OPTIONS\|{-# LANGUAGE\)'',''nb''),''import '.qualified.qual.importlist.''')'
    return
  endif

  let line   = line('.')
  let prefix = getline(line)[0:start-1]
  let dict   = HaddockIndexLookup(name)
  if dict=={} | return | endif
  let keylist = map(deepcopy(keys(dict)),'substitute(v:val,"\\[.\\]","","")')
  if has("gui_running")
    for key in keylist
      " exe 'amenu ]Popup.'.escape(key,'\.').' :call append(search("\\%1c\\(import\\\\|module\\\\|{-# OPTIONS\\)","nb"),"import '.key.importlist.'")<cr>'
      exe 'amenu ]Popup.'.escape(key,'\.').' :call append(search(''\%1c\(\<import\>\\|\<module\>\\|{-# OPTIONS\\|{-# LANGUAGE\)'',''nb''),''import '.qualified.key.escape(importlist,'|').''')<cr>'
    endfor
    popup ]Popup
  else
    let s:choices = keylist
    let key = input('import '.name.' from: ','','customlist,CompleteAux')
    if key!=''
      exe 'call append(search(''\%1c\(\<import\>\|\<module\>\|{-# OPTIONS\|{-# LANGUAGE\)'',''nb''),''import '.qualified.key.importlist.''')'
    endif
  endif
endfunction

function! HaddockIndexLookup(name)
  call HaveIndex()
  if !has_key(g:haddock_index,a:name)
    echoerr a:name 'not found in haddock index'
    return {}
  endif
  return g:haddock_index[a:name]
endfunction

ftplugin/haskell_hpaste.vim	[[[1
79
" rudimentary hpaste support for vim
" (using netrw for reading, wget for posting/annotating)
"
" claus reinke, last modified: 07/04/2009
"
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim

" unless wget is in your PATH, you need to set g:wget
" before loading this script. windows users are out of 
" luck, unless they have wget installed (such as the 
" cygwin one looked for here), or adapt this script to 
" whatever alternative they have at hand (perhaps using 
" vim's perl/python bindings?)
if !exists("g:wget")
  if executable("wget")
    let g:wget = "!wget -q"
  else
    let g:wget = "!c:\\cygwin\\bin\\wget -q"
  endif
endif

" read (recent) hpaste files
" show index in new buffer, where ,r will open current entry
" and ,p will annotate current entry with current buffer
command! HpasteIndex call HpasteIndex()
function! HpasteIndex()
  new
  read http://hpaste.org
  %s/\_$\_.//g
  %s/<tr[^>]*>//g
  %s/<\/tr>//g
  g/<\/table>/d
  g/DOCTYPE/d
  %s/<td>\([^<]*\)<\/td><td><a href="\/fastcgi\/hpaste\.fcgi\/view?id=\([0-9]*\)">\([^<]*\)<\/a><\/td><td>\([^<]*\)<\/td><td>\([^<]*\)<\/td><td>\([^<]*\)<\/td>/\2 [\1] "\3" \4 \5 \6/
  map <buffer> ,r 0yE:noh<cr>:call HpasteEditEntry('"')<cr>
endfunction

" load an existing entry for editing
command! -nargs=1 HpasteEditEntry call HpasteEditEntry(<f-args>)
function! HpasteEditEntry(entry)
  new
  exe 'Nread http://hpaste.org/fastcgi/hpaste.fcgi/raw?id='.a:entry
  "exe 'map <buffer> ,p :call HpasteAnnotate('''.a:entry.''')<cr>'
endfunction

" " posting temporarily disabled -- needs someone to look into new
" " hpaste.org structure

" " annotate existing entry (only to be called via ,p in HpasteIndex)
" function! HpasteAnnotate(entry)
"   let nick  = input("nick? ")
"   let title = input("title? ")
"   if nick=='' || title==''
"     echo "nick or title missing. aborting annotation"
"     return
"   endif
"   call HpastePost('annotate/'.a:entry,nick,title)
" endfunction
" 
" " post new hpaste entry
" " using 'wget --post-data' and url-encoded content
" command! HpastePostNew  call HpastePost('new',<args>)
" function! HpastePost(mode,nick,title,...)
"   let lines = getbufline("%",1,"$") 
"   let pat   = '\([^[:alnum:]]\)'
"   let code  = '\=printf("%%%02X",char2nr(submatch(1)))'
"   let lines = map(lines,'substitute(v:val."\r\n",'''.pat.''','''.code.''',''g'')')
" 
"   let url   = 'http://hpaste.org/' . a:mode 
"   let nick  = substitute(a:nick,pat,code,'g')
"   let title = substitute(a:title,pat,code,'g')
"   if a:0==0
"     let announce = 'false'
"   else
"     let announce = a:1
"   endif
"   let cmd = g:wget.' --post-data="content='.join(lines,'').'&nick='.nick.'&title='.title.'&announce='.announce.'" '.url
"   exe escape(cmd,'%')
" endfunction
autoload/haskellmode.vim	[[[1
191
"
" utility functions for haskellmode plugins
"
" (Claus Reinke; last modified: 22/06/2010)
" 
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim
" please send patches to <claus.reinke@talk21.com>



" find start/extent of name/symbol under cursor;
" return start, symbolic flag, qualifier, unqualified id
" (this is used in both haskell_doc.vim and in GHC.vim)
function! haskellmode#GetNameSymbol(line,col,off)
  let name    = "[a-zA-Z0-9_']"
  let symbol  = "[-!#$%&\*\+/<=>\?@\\^|~:.]"
  "let [line]  = getbufline(a:buf,a:lnum)
  let line    = a:line

  " find the beginning of unqualified id or qualified id component 
  let start   = (a:col - 1) + a:off
  if line[start] =~ name
    let pattern = name
  elseif line[start] =~ symbol
    let pattern = symbol
  else
    return []
  endif
  while start > 0 && line[start - 1] =~ pattern
    let start -= 1
  endwhile
  let id    = matchstr(line[start :],pattern.'*')
  " call confirm(id)

  " expand id to left and right, to get full id
  let idPos = id[0] == '.' ? start+2 : start+1
  let posA  = match(line,'\<\(\([A-Z]'.name.'*\.\)\+\)\%'.idPos.'c')
  let start = posA>-1 ? posA+1 : idPos
  let posB  = matchend(line,'\%'.idPos.'c\(\([A-Z]'.name.'*\.\)*\)\('.name.'\+\|'.symbol.'\+\)')
  let end   = posB>-1 ? posB : idPos

  " special case: symbolic ids starting with .
  if id[0]=='.' && posA==-1 
    let start = idPos-1
    let end   = posB==-1 ? start : end
  endif

  " classify full id and split into qualifier and unqualified id
  let fullid   = line[ (start>1 ? start-1 : 0) : (end-1) ]
  let symbolic = fullid[-1:-1] =~ symbol  " might also be incomplete qualified id ending in .
  let qualPos  = matchend(fullid, '\([A-Z]'.name.'*\.\)\+')
  let qualifier = qualPos>-1 ? fullid[ 0 : (qualPos-2) ] : ''
  let unqualId  = qualPos>-1 ? fullid[ qualPos : -1 ] : fullid
  " call confirm(start.'/'.end.'['.symbolic.']:'.qualifier.' '.unqualId)

  return [start,symbolic,qualifier,unqualId]
endfunction

function! haskellmode#GatherImports()
  let imports={0:{},1:{}}
  let i=1
  while i<=line('$')
    let res = haskellmode#GatherImport(i)
    if !empty(res)
      let [i,import] = res
      let prefixPat = '^import\s*\%({-#\s*SOURCE\s*#-}\)\?\(qualified\)\?\s\+'
      let modulePat = '\([A-Z][a-zA-Z0-9_''.]*\)'
      let asPat     = '\(\s\+as\s\+'.modulePat.'\)\?'
      let hidingPat = '\(\s\+hiding\s*\((.*)\)\)\?'
      let listPat   = '\(\s*\((.*)\)\)\?'
      let importPat = prefixPat.modulePat.asPat.hidingPat.listPat ".'\s*$'

      let ml = matchlist(import,importPat)
      if ml!=[]
        let [_,qualified,module,_,as,_,hiding,_,explicit;x] = ml
        let what = as=='' ? module : as
        let hidings   = split(hiding[1:-2],',')
        let explicits = split(explicit[1:-2],',')
        let empty = {'lines':[],'hiding':hidings,'explicit':[],'modules':[]}
        let entry = has_key(imports[1],what) ? imports[1][what] : deepcopy(empty)
        let imports[1][what] = haskellmode#MergeImport(deepcopy(entry),i,hidings,explicits,module)
        if !(qualified=='qualified')
          let imports[0][what] = haskellmode#MergeImport(deepcopy(entry),i,hidings,explicits,module)
        endif
      else
        echoerr "haskellmode#GatherImports doesn't understand: ".import
      endif
    endif
    let i+=1
  endwhile
  if !has_key(imports[1],'Prelude') 
    let imports[0]['Prelude'] = {'lines':[],'hiding':[],'explicit':[],'modules':[]}
    let imports[1]['Prelude'] = {'lines':[],'hiding':[],'explicit':[],'modules':[]}
  endif
  return imports
endfunction

function! haskellmode#ListElem(list,elem)
  for e in a:list | if e==a:elem | return 1 | endif | endfor
  return 0
endfunction

function! haskellmode#ListIntersect(list1,list2)
  let l = []
  for e in a:list1 | if index(a:list2,e)!=-1 | let l += [e] | endif | endfor
  return l
endfunction

function! haskellmode#ListUnion(list1,list2)
  let l = []
  for e in a:list2 | if index(a:list1,e)==-1 | let l += [e] | endif | endfor
  return a:list1 + l
endfunction

function! haskellmode#ListWithout(list1,list2)
  let l = []
  for e in a:list1 | if index(a:list2,e)==-1 | let l += [e] | endif | endfor
  return l
endfunction

function! haskellmode#MergeImport(entry,line,hiding,explicit,module)
  let lines    = a:entry['lines'] + [ a:line ]
  let hiding   = a:explicit==[] ? haskellmode#ListIntersect(a:entry['hiding'], a:hiding) 
                              \ : haskellmode#ListWithout(a:entry['hiding'],a:explicit)
  let explicit = haskellmode#ListUnion(a:entry['explicit'], a:explicit)
  let modules  = haskellmode#ListUnion(a:entry['modules'], [ a:module ])
  return {'lines':lines,'hiding':hiding,'explicit':explicit,'modules':modules}
endfunction

" collect lines belonging to a single import statement;
" return number of last line and collected import statement
" (assume opening parenthesis, if any, is on the first line)
function! haskellmode#GatherImport(lineno)
  let lineno = a:lineno
  let import = getline(lineno)
  if !(import=~'^import\s') | return [] | endif
  let open  = strlen(substitute(import,'[^(]','','g'))
  let close = strlen(substitute(import,'[^)]','','g'))
  while open!=close
    let lineno += 1
    let linecont = getline(lineno)
    let open  += strlen(substitute(linecont,'[^(]','','g'))
    let close += strlen(substitute(linecont,'[^)]','','g'))
    let import .= linecont
  endwhile
  return [lineno,import]
endfunction

function! haskellmode#UrlEncode(string)
  let pat  = '\([^[:alnum:]]\)'
  let code = '\=printf("%%%02X",char2nr(submatch(1)))'
  let url  = substitute(a:string,pat,code,'g')
  return url
endfunction

" TODO: we could have buffer-local settings, at the expense of
"       reconfiguring for every new buffer.. do we want to?
function! haskellmode#GHC()
  if (!exists("g:ghc") || !executable(g:ghc)) 
    if !executable('ghc') 
      echoerr s:scriptname.": can't find ghc. please set g:ghc, or extend $PATH"
      return 0
    else
      let g:ghc = 'ghc'
    endif
  endif    
  return 1
endfunction

function! haskellmode#GHC_Version()
  if !exists("g:ghc_version")
    let g:ghc_version = substitute(system(g:ghc . ' --numeric-version'),'\n','','')
  endif
  return g:ghc_version
endfunction

function! haskellmode#GHC_VersionGE(target)
  let current = split(haskellmode#GHC_Version(), '\.' )
  let target  = a:target
  for i in current
    if ((target==[]) || (i>target[0]))
      return 1
    elseif (i==target[0])
      let target = target[1:]
    else
      return 0
    endif
  endfor
  return 1
endfunction

doc/haskellmode.txt	[[[1
465
*haskellmode.txt*	Haskell Mode Plugins	02/05/2009

Authors:
    Claus Reinke <claus.reinke@talk21.com> ~

Homepage:
    http://projects.haskell.org/haskellmode-vim

CONTENTS                                                         *haskellmode*

    1. Overview                                     |haskellmode-overview|
        1.1 Runtime Requirements                    |haskellmode-requirements|
        1.2 Quick Reference                         |haskellmode-quickref|
    2. Settings                                     |haskellmode-settings|
      2.1 GHC and web browser                       |haskellmode-settings-main|
      2.2 Fine tuning - more configuration options  |haskellmode-settings-fine|
    3. GHC Compiler Integration                     |haskellmode-compiler|
    4. Haddock Integration                          |haskellmode-haddock|
        4.1 Indexing                                |haskellmode-indexing|
        4.2 Lookup                                  |haskellmode-lookup|
        4.3 Editing                                 |haskellmode-editing|
    5. Hpaste Integration                           |haskellmode-hpaste|
    6. Additional Resources                         |haskellmode-resources|

==============================================================================
                                                        *haskellmode-overview*
1. Overview ~

    The Haskell mode plugins provide advanced support for Haskell development
    using GHC/GHCi on Windows and Unix-like systems. The functionality is
    based on Haddock-generated library indices, on GHCi's interactive
    commands, or on simply activating (some of) Vim's built-in program editing
    support in Haskell-relevant fashion. These plugins live side-by-side with
    the pre-defined |syntax-highlighting| support for |haskell| sources, and
    any other Haskell-related plugins you might want to install (see
    |haskellmode-resources|).

    The Haskell mode plugins consist of three filetype plugins (haskell.vim,
    haskell_doc.vim, haskell_hpaste.vim), which by Vim's |filetype| detection
    mechanism will be auto-loaded whenever files with the extension '.hs' are
    opened, and one compiler plugin (ghc.vim) which you will need to load from
    your vimrc file (see |haskellmode-settings|).


                                                    *haskellmode-requirements*
1.1 Runtime Requirements ~

    The plugins require a recent installation of GHC/GHCi. The functionality
    derived from Haddock-generated library indices also requires a local
    installation of the Haddock documentation for GHC's libraries (if there is
    no documentation package for your system, you can download a tar-ball from
    haskell.org), as well as an HTML browser (see |haddock_browser|). If you 
    want to use the experimental hpaste interface, you will also need Wget.

    * GHC/GHCi ~
      Provides core functionality. http://www.haskell.org/ghc

    * HTML library documentation files and indices generated by Haddock ~
      These usually come with your GHC installation, possibly as a separate
      package. If you cannot get them this way, you can download a tar-ball
      matching your GHC version from  http://www.haskell.org/ghc/docs/

    * HTML browser with basic CSS support ~
      For browsing Haddock docs.

    * Wget ~
      For interfacing with http://hpaste.org.

      Wget is widely available for modern Unix-like operating systems. Several
      ports also exist for Windows, including:

      - Official GNU Wget (natively compiled for Win32)
        http://www.gnu.org/software/wget/#downloading

      - UnxUtils Wget (natively compiled for Win32, bundled with other ported
        Unix utilities)
        http://sourceforge.net/projects/unxutils/

      - Cygwin Wget (emulated POSIX in Win32, must be run under Cygwin)
        http://cygwin.com/packages/wget/

                                                    *haskellmode-quickref*
1.2 Quick Reference ~

|:make|               load into GHCi, show errors (|quickfix| |:copen|)
|_ct|                 create |tags| file 
|_si|                 show info for id under cursor
|_t|                  show type for id under cursor
|_T|                  insert type declaration for id under cursor
|balloon|             show type for id under mouse pointer
|_?|                  browse Haddock entry for id under cursor
|_?1|                 search Hoogle for id under cursor
|_?2|                 search Hayoo! for id under cursor
|:IDoc| {identifier}  browse Haddock entry for unqualified {identifier}
|:MDoc| {module}      browse Haddock entry for {module}
|:FlagReference| {s}  browse Users Guide Flag Reference for section {s}
|_.|                  qualify unqualified id under cursor
|_i|                  add 'import <module>(<identifier>)' for id under cursor
|_im|                 add 'import <module>' for id under cursor
|_iq|                 add 'import qualified <module>(<identifier>)' for id under cursor
|_iqm|                add 'import qualified <module>' for id under cursor
|_ie|                 make imports explit for import statement under cursor
|_opt|                add OPTIONS_GHC pragma
|_lang|               add LANGUAGE pragma
|i_CTRL-X_CTRL-O|     insert-mode completion based on imported ids (|haskellmode-XO|)
|i_CTRL-X_CTRL-U|     insert-mode completion based on documented ids (|haskellmode-XU|)
|i_CTRL-N|            insert-mode completion based on imported sources
|:GHCi|{command/expr} run GHCi command/expr in current module

|:GHCStaticOptions|   edit static GHC options for this buffer
|:DocSettings|        show current Haddock-files-related plugin settings
|:DocIndex|           populate Haddock index 
|:ExportDocIndex|     cache current Haddock index to a file
|:HpasteIndex|        Read index of most recent entries from hpaste.org
|:HpastePostNew|      Submit current buffer as a new hpaste 


==============================================================================
                                                        *haskellmode-settings*
2. Settings ~

    The plugins try to find their dependencies in standard locations, so if
    you're lucky, you will only need to set |compiler| to ghc, and configure
    the location of your favourite web browser. You will also want to make
    sure that |filetype| detection and |syntax| highlighting are on. Given the
    variety of things to guess, however, some dependencies might not be found
    correctly, or the defaults might not be to your liking, in which case you
    can do some more fine tuning. All of this configuration should happen in
    your |vimrc|.
>
        " enable syntax highlighting
        syntax on
 
        " enable filetype detection and plugin loading
        filetype plugin on
<

                                                   *haskellmode-settings-main*
2.1 GHC and web browser ~

                                                 *compiler-ghc* *ghc-compiler*
    To use the features provided by the GHC |compiler| plugin, use the
    following |autocommand| in your vimrc:
>
        au BufEnter *.hs compiler ghc
<
                                                                       *g:ghc*
    If the compiler plugin can't locate your GHC binary, or if you have
    several versions of GHC installed and have a preference as to which binary
    is used, set |g:ghc|:
>
        :let g:ghc="/usr/bin/ghc-6.6.1"
<
                                                           *g:haddock_browser*
    The preferred HTML browser for viewing Haddock documentation can be set as
    follows:
>
        :let g:haddock_browser="/usr/bin/firefox"
<

                                                   *haskellmode-settings-fine*
2.2 Fine tuning - more configuration options ~

    Most of the fine tuning is likely to happen for the haskellmode_doc.vim
    plugin, so you can check the current settings for this plugin via the
    command |:DocSettings|. If all the settings reported there are to your
    liking, you probably won't need to do any fine tuning.

                                                *g:haddock_browser_callformat*
    By default, the web browser|g:haddock_browser| will be started
    asynchronously (in the background) on Windows or when vim is running in a
    GUI, and synchronously (in the foreground) otherwise. These settings seem
    to work fine if you are using a console mode browser (eg, when editing in
    a remote session), or if you are starting a GUI browser that will launch
    itself in the background. But if these settings do not work for you, you
    can change the default browser launching behavior.

    This is controlled by |g:haddock_browser_callformat|. It specifies a
    format string which uses two '%s' parameters, the first representing the
    path of the browser to launch, and the second is the documentation URL
    (minus the protocol specifier, i.e. file://) passed to it by the Haddock
    plugin.  For instance, to launch a GUI browser on Unix-like systems and
    force it to the background (see also |shellredir|):
>
        :let g:haddock_browser_callformat = '%s file://%s '.printf(&shellredir,'/dev/null').' &'
<
                                                            *g:haddock_docdir*
    Your system's installed Haddock documentation for GHC and its libraries
    should be automatically detected. If the plugin can't locate them, you
    must point |g:haddock_docdir| to the path containing the master index.html
    file for the subdirectories 'libraries', 'Cabal', 'users_guide', etc.:
>
        :let g:haddock_docdir="/usr/local/share/doc/ghc/html/"
<
                                                      *g:haddock_indexfiledir*
    The information gathered from Haddock's index files will be stored in a
    file called 'haddock_index.vim' in a directory derived from the Haddock
    location, or in $HOME. To configure another directory for the index file,
    use: 
>
        :let g:haddock_indexfiledir="~/.vim/"
<
                                                                      *g:wget*
    If you also want to try the experimental hpaste functionality, you might
    you need to set |g:wget| before the |hpaste| plugin is loaded (unless wget
    is in your PATH):
>
        :let g:wget="C:\Program Files\wget\wget.exe"
<

    Finally, the mappings actually use|<LocalLeader>|behind the scenes, so if
    you have to, you can redefine|maplocalleader|to something other than '_'.
    Just remember that the docs still refer to mappings starting with '_', to
    avoid confusing the majority of users!-)

==============================================================================
                                                  *haskellmode-compiler* *ghc*
3. GHC Compiler Integration ~

    The GHC |compiler| plugin sets the basic |errorformat| and |makeprg| to
    enable |quickfix| mode using GHCi, and provides functionality for show
    info (|_si|), show type (|_t| or mouse |balloon|), add type declaration
    (|_T|), create tag file (|_ct|), and insert-mode completion
    (|i_CTRL-X_CTRL-O|) based on GHCi browsing of the current and imported
    modules. 

    To avoid frequent calls to GHCi, type information is cached in Vim. The
    cache will be populated the first time a command depends on it, and will
    be refreshed every time a |:make| goes through without generating errors
    (if the |:make| does not succeed, the old types will remain available in
    Vim).  You can also unconditionally force reloading of type info using
    |:GHCReload| (if GHCi cannot load your file, the type info will be empty).


    In addition to the standard|quickfix| commands, the GHC compiler plugin
    provides:

                                                                  *:GHCReload*
:GHCReload              Reload modules and unconditionally refresh cache of
                        type info. Usually, |:make| is prefered, as that will
                        refresh the cache only if GHCi reports no errors, and
                        show the errors otherwise.

                                                           *:GHCStaticOptions*
:GHCStaticOptions       Edit the static GHC options (more generally, options
                        that cannot be set by in-file OPTIONS_GHC pragmas)
                        for the current buffer. Useful for adding hidden 
                        packages (-package ghc), or additional import paths
                        (-isrc; you will then also want to augment |path|).
                        If you have static options you want to set as
                        defaults, you could use b:ghc_staticoptions, eg:
>
                        au FileType haskell let b:ghc_staticoptions = '-isrc'
                        au FileType haskell setlocal path += src
<

                                                                       *:GHCi*
:GHCi {command/expr}    Run GHCi commands/expressions in the current module.                  

                                                                         *_ct*
_ct                     Create |tags| file for the current Haskell source
                        file. This uses GHCi's :ctags command, so it will work
                        recursively, but will only list tags for exported
                        entities.

                                                                        *_opt*
_opt                    Shows a menu of frequently used GHC compiler options 
                        (selecting an entry adds the option as a pragma to the
                        start of the file). Uses popup menu (GUI) or :emenu
                        and command-line completion (CLI).

                                                                       *_lang*
_lang                   Shows a menu of the LANGUAGE options supported by GHC
                        (selecting an entry adds the language as a pragma to 
                        the start of the file). Uses popup menu (GUI) or
                        :emenu and command-line completion (CLI).

                                                                         *_si*
_si                     Show extended information for the name under the
                        cursor. Uses GHCi's :info command. Output appears in
                        |preview-window| (when done, close with |:pclose|).

                                                                          *_t*
_t                      Show type for the name under the cursor. Uses cached
                        info from GHCi's :browse command.

                                                                          *_T*
_T                      Insert type declaration for the name under the cursor.
                        Uses cached info from GHCi's :browse command.

                                *haskellmode-XO* *haskellmode-omni-completion*
CTRL-X CTRL-O           Standard insert-mode omni-completion based on the
                        cached type info from GHCi browsing current and
                        imported modules. Only names from the current and from
                        imported modules are included (the completion menu
                        also show the type of each identifier).

==============================================================================
                                               *haskellmode-haddock* *haddock*
4. Haddock Integration ~

    Haskell mode integrates with Haddock-generated HTML documentation,
    providing features such as navigating to the Haddock entry for the
    identifier under the cursor (|_?|), completion for the identifier under
    the cursor (|i_CTRL-X_CTRL-U|), and adding import statements (|_i| |_im|
    |_iq| |_iqm|) or module qualifier (|_.|) for the identifier under the
    cursor.

    These commands operate on an internal Haddock index built from the
    platform's installed Haddock documentation for GHC's libraries. Since
    populating this index takes several seconds, it should be stored as a 
    file called 'haddock_index.vim' in the directory specified by
    |g:haddock_indexfiledir|.

    Some commands present a different interface (popup menu or command-line
    completion) according to whether the current Vim instance is graphical or
    console-based (actually: whether or not the GUI is running). Such
    differences are marked below with the annotations (GUI) and (CLI),
    respectively.

    |:DocSettings| shows the settings for this plugin. If you are happy with
    them, you can call |:ExportDocIndex| to populate and write out the
    documentation index (should be called once for every new version of GHC).

                                                                *:DocSettings*
:DocSettings            Show current Haddock-files-related plugin settings.


                                                        *haskellmode-indexing*
4.1 Indexing ~

                                                                   *:DocIndex*
:DocIndex               Populate the Haddock index from the GHC library
                        documentation.

                                                             *:ExportDocIndex*
:ExportDocIndex         Cache the current Haddock index to a file (populate
                        index first, if empty).


                                                          *haskellmode-lookup*
4.2 Lookup ~

                                                                          *_?*
_?                      Open the Haddock entry (in |haddock_browser|) for an
                        identifier under the cursor, selecting full
                        qualifications from a popup menu (GUI) or via
                        command-line completion (CLI), if the identifier is
                        not qualified.

                                                                         *_?1*
_?1                     Search Hoogle (using |haddock_browser|) for an
                        identifier under the cursor.


                                                                         *_?2*
_?2                     Search Hayoo! (using |haddock_browser|) for an
                        identifier under the cursor.

                                                                       *:IDoc*
:IDoc {identifier}      Open the Haddock entry for the unqualified
                        {identifier} in |haddock_browser|, suggesting possible
                        full qualifications.

                                                                       *:MDoc*
:MDoc {module}          Open the Haddock entry for {module} in
                        |haddock_browser| (with command-line completion for
                        the fully qualified module name).

                                                              *:FlagReference*
:FlagReference {s}      Browse Users Guide Flag Reference for section {s}
                        (with command-line completion for section headers).


                                                         *haskellmode-editing*
4.3 Editing ~

                                                                          *_.*
_.                      Fully qualify the unqualified name under the cursor
                        selecting full qualifications from a popup menu (GUI)
                        or via command-line completion (CLI).

                                                                    *_iq* *_i*
_i _iq                  Add 'import [qualified] <module>(<identifier>)'
                        statement for the identifier under the cursor,
                        selecting fully qualified modules from a popup menu
                        (GUI) or via command-line completion (CLI), if the
                        identifier is not qualified.  This currently adds one
                        import statement per call instead of merging into
                        existing import statements.

                                                                  *_iqm* *_im*
_im                     Add 'import [qualified] <module>' statement for the
                        identifier under the cursor, selecting fully qualified
                        modules from a popup menu (GUI) or via command-line
                        completion (CLI), if the identifier is not qualified.
                        This currently adds one import statement per call
                        instead of merging into existing import statements.

                                                                         *_ie*
_ie                     On an 'import <module>' line, in a correctly loadable
                        module, temporarily comment out import and use :make
                        'not in scope' errors to explicitly list imported
                        identifiers.

                                *haskellmode-XU* *haskellmode-user-completion*
CTRL-X CTRL-U           User-defined insert mode name completion based on all
                        names known to the Haddock index, including package
                        names. Completions are presented in a popup menu which
                        also displays the fully qualified module from which
                        each entry may be imported. 

                        CamelCode shortcuts are supported, meaning that
                        lower-case letters can be elided, using only
                        upper-case letters and module qualifier separators (.)
                        for disambiguation:

                          pSL    -> putStrLn
                          C.E.t  -> Control.Exception.t
                          C.M.MP -> Control.Monad.MonadPlus

                        To reduce unwanted matches, the first letter of such
                        shortcuts and the first letter after each '.' have to
                        match directly.

==============================================================================
                                                 *haskellmode-hpaste* *hpaste*
5. Hpaste Integration ~

    This experimental feature allows browsing and posting to
    http://hpaste.org, a Web-based pastebin tailored for Haskell code.


                                                                *:HpasteIndex*
:HpasteIndex            Read the most recent entries from hpaste.org. Show an
                        index of the entries in a new buffer, where ',r' will
                        open the current highlighted entry [and ',p' will
                        annotate it with the current buffer].

                                                              *:HpastePostNew*
:HpastePostNew          Submit current buffer as a new hpaste entry.
                        [This, and ',p' above, are temporarily disabled, 
                         needs update to new hpaste.org layout]

==============================================================================
                                                       *haskellmode-resources*
6. Additional Resources ~

    An quick screencast tour through of these plugins is available at:

    http://projects.haskell.org/haskellmode-vim/screencasts.html

    Other Haskell-related Vim plugins can be found here:

    http://www.haskell.org/haskellwiki/Libraries_and_tools/Program_development#Vim

    Make sure to read about Vim's other program-editing features in its online
    |user-manual|. Also have a look at Vim tips and plugins at www.vim.org -
    two other plugins I tend to use when editing Haskell are AlignPlugin.vim
    (to line up regexps for definitions, keywords, comments, etc. in
    consecutive lines) and surround.vim (to surround text with quotes,
    brackets, parentheses, comments, etc.).

==============================================================================
 vim:tw=78:ts=8:ft=help:
