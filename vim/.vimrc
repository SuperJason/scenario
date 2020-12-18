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
" is_mcu_mode: 'yes' tab is 4 spaces
"            : 'no' linux mode, tab is 8 and not replaced by spaces
let s:is_mcu_mode = "no"

au FileType c call My_C_func()
au FileType cpp call My_C_func()
au FileType python call My_Py_func()

function! My_C_func()
" Be smart when using tabs ;)
"  set smarttab

  if s:is_mcu_mode == "yes" 
    " Use spaces instead of tabs
    set expandtab
    " 1 tab == 4 spaces
    set shiftwidth=4
    set tabstop=4
  else
    " 1 tab == 8 spaces
    set shiftwidth=8
    set tabstop=8
  endif
  set tw=80
  set cc=+1
  hi ColorColumn ctermbg=blue guibg=blue
endfunction

function! My_Py_func()
" 1 tab == 4 spaces
  set tabstop=4

" Use spaces instead of tabs
  set expandtab
" Be smart when using tabs ;)
  "set smarttab

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

if has("cscope")

    set cspc=8 " cscopepathcomp	-- how many components of the path to show

    cmap ;s cs find s 
    cmap ;g cs find g 
    cmap ;c cs find c 
    cmap ;t cs find t 
    cmap ;e cs find e 
    cmap ;f cs find f 
    cmap ;i cs find i 
    cmap ;d cs find d 

    cmap ;ws scs find s 
    cmap ;wg scs find g 
    cmap ;wc scs find c 
    cmap ;wt scs find t 
    cmap ;we scs find e 
    cmap ;wf scs find f 
    cmap ;wi scs find i 
    cmap ;wd scs find d 

    nmap ;s :cs find s <C-R>=expand("<cword>")<CR><CR>	
    nmap ;g :cs find g <C-R>=expand("<cword>")<CR><CR>	
    nmap ;c :cs find c <C-R>=expand("<cword>")<CR><CR>	
    nmap ;t :cs find t <C-R>=expand("<cword>")<CR><CR>	
    nmap ;e :cs find e <C-R>=expand("<cword>")<CR><CR>	
    nmap ;f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap ;i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap ;d :cs find d <C-R>=expand("<cword>")<CR><CR>	

    nmap ;ws :scs find s <C-R>=expand("<cword>")<CR><CR>	
    nmap ;wg :scs find g <C-R>=expand("<cword>")<CR><CR>	
    nmap ;wc :scs find c <C-R>=expand("<cword>")<CR><CR>	
    nmap ;wt :scs find t <C-R>=expand("<cword>")<CR><CR>	
    nmap ;we :scs find e <C-R>=expand("<cword>")<CR><CR>	
    nmap ;wf :scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap ;wi :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap ;wd :scs find d <C-R>=expand("<cword>")<CR><CR>	

    nmap ;vs :vert scs find s <C-R>=expand("<cword>")<CR><CR>	
    nmap ;vg :vert scs find g <C-R>=expand("<cword>")<CR><CR>	
    nmap ;vc :vert scs find c <C-R>=expand("<cword>")<CR><CR>	
    nmap ;vt :vert scs find t <C-R>=expand("<cword>")<CR><CR>	
    nmap ;ve :vert scs find e <C-R>=expand("<cword>")<CR><CR>	
    nmap ;vf :vert scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap ;vi :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap ;vd :vert scs find d <C-R>=expand("<cword>")<CR><CR>	

    command -nargs=* Csl :cs add $WACS/lepton/cscope.out
    command -nargs=* Csq :cs add $WACS/qpsw/cscope.out
    command -nargs=* Csp :cs add $WACS/penguin/cscope.out

    if has("quickfix")
        command -nargs=* Csqf :set cscopequickfix=s-,g-,c-,d-,i-,t-,e-,f-
        command -nargs=* Csqfs :set cscopequickfix=s-,g-,c-,d-,i-,t-,e-,f-
        command -nargs=* Csqfc :set cscopequickfix=s0,g0,c0,d0,i0,t0,e0,f0
        command -nargs=* Csqfa :set cscopequickfix=s+,g+,c+,d+,i+,t+,e+,f+
    endif

endif

set efm=%m
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
