" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  "autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Added By Jason
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" style: 'linux' linux mode, tab is 8 and not replaced by spaces
"      : 'google' tab is 2 spaces
"      : 'mcu' tab is 4 spaces
let s:style= "linux"

au FileType c call Style_C_Func(s:style)
au FileType cpp call Style_C_Func(s:style)
au FileType python call Style_Py_Func()

function! Style_C_Func(style)
  if a:style == "linux"
    " 1 tab == 8 spaces
    set shiftwidth=8
    set tabstop=8
  elseif a:style == "google"
    " Use spaces instead of tabs
    set expandtab
    " 1 tab == 2 spaces
    set shiftwidth=2
    set tabstop=2
  elseif a:style == "mcu"
    " Use spaces instead of tabs
    set expandtab
    " 1 tab == 4 spaces
    set shiftwidth=4
    set tabstop=4
  endif
  set tw=80
  set cc=+1
  hi ColorColumn ctermbg=blue guibg=blue
  nmap <F2> :call Style_C_Func("linux")<CR>
  nmap <F3> :call Style_C_Func("mcu")<CR>
  nmap <F4> :call Style_C_Func("google")<CR>
endfunction

function! Style_Py_Func()
" 1 tab == 4 spaces
  set tabstop=4
  set shiftwidth=4

" Use spaces instead of tabs
  set expandtab
endfunction

let Tlist_Ctags_Cmd='ctags'
nmap <F6> :TlistToggle<CR>
nmap <F5> :set invnumber<CR>
nmap ,h <C-W>h
nmap ,j <C-W>j
nmap ,k <C-W>k
nmap ,l <C-W>l
nmap ,H <C-W>H
nmap ,J <C-W>J
nmap ,K <C-W>K
nmap ,L <C-W>L
nmap ,o <C-W>o
nmap ,, <C-W><C-W>

set efm=%m
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
