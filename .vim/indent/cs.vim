" Vim indent file
" Language:	C#
" Maintainer:	Johannes Zellner <johannes@zellner.org>
" Last Change:	Fri, 15 Mar 2002 07:53:54 CET

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" C# is like indenting C
setlocal cindent
" change cinkeys so that #regions don't end up in 1st column
setlocal cinkeys=0{,0},0),*#,:,!^F,o,O,e

let b:undo_indent = "setl cin<"

