"Attempt to detect filetype/contents so that vim can autoindent etc 
filetype indent plugin on
 
"Enable syntax highlighting 
syntax on
 
"Better command-line completion 
set wildmenu
 
"Show partial commands in the last line of the screen
set showcmd
 
" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start
 
"When opening a new line and no filetype-specific indenting is enabled, keep the same indent as the line you're currently on(Useful for READMEs, etc)
set autoindent

"fa in modo che i tab siano trasformati in spazi
set expandtab

"Display the cursor position on the last line of the screen or in the status line of a window
set ruler
 
"Always display the status line, even if only one window is displayed
set laststatus=2
 
"Instead of failing a command because of unsaved changes, instead raise a  dialogue asking if you wish to save changed files 
set confirm
 
"Use visual bell instead of beeping when doing something wrong 
set visualbell
 
"Display line numbers on the left
set number
 
"Quickly time out on keycodes, but never time out on mappings 
set notimeout ttimeout ttimeoutlen=200
 
"Highlight the current line
"set cursorline

"Set the color theme to be used 
colors ron

" bcclsn v0.2 " 
