" Enable syntax highlighting.
syntax enable

" Activate file type plugins.
filetype plugin indent on

" -----------------------------------------------------------------------------

" Returns a truthy value if the argument is the path to a writable directory.
" If the directory does not exist, then the function attempts to create it,
" with permission 0700 (rwx------: readable and writable only for the owner).
" Directory creation is not attempted if function mkdir is not available.
"
" Arguments:
"
" #1 - path_to_dir
" Path to a directory.
"
" Return value:
" Non-zero if the argument is the path to a writable directory (created by the
" function if it did not exist), zero otherwise.
function s:CanWriteToDir(path_to_dir)

    if !isdirectory(a:path_to_dir) && exists("*mkdir")
        silent! call mkdir(a:path_to_dir, "p", 0700)
    endif
    return (filewritable(a:path_to_dir) == 2)

endfunction

" -----------------------------------------------------------------------------

" Get the path to the Vim home directory (~/.vim on Unix / Linux systems).
let s:DotVimPath = split(&runtimepath,",")[0]

let s:BackupDir = s:DotVimPath . "/backup"
if s:CanWriteToDir(s:BackupDir)
    set backup

    " Write backup files preferably in "~/.vim/backup".
    let &backupdir = s:BackupDir . "," . &backupdir
endif

let s:SwapDir = s:DotVimPath . "/swap"
if s:CanWriteToDir(s:SwapDir)

    " Write swap files preferably in "~/.vim/swap". The "//" causes Vim to name
    " the swap files based on the full path name of the edited files.
    let &directory = s:SwapDir . "//" . "," . &directory
endif

" Enable the use of the mouse.
set mouse=a

" Disable double space insertion on join command.
set nojoinspaces

" Don't wrap lines.
set nowrap

" Prevent the Ruby file type plugin from setting shiftwidth and softtabstop.
let g:ruby_recommended_style=0

" Set maximum text width.
set textwidth=79

" Set width of a tabulation character.
set tabstop=4

" Use spaces (not tabulation characters) when tabulation key is hit in insert
" mode.
set expandtab

" Set the number of columns the text is shifted on reindent operations (<<,
" >>).
set shiftwidth=4

" Set the number of columns used when hitting tabulation in insert mode.
set softtabstop=4

" Highlight search.
set hlsearch

" Do case insensitive search...
set ignorecase
" ... except when the search pattern contains at least one uppercase character.
" '\c' or '\C' can still be used in the search pattern to force case
" insensitive or case sensitive search.
set smartcase

" Set showcmd option (makes the number of selected characters or lines appear
" in visual mode).
set showcmd

" Disable temporarily the search highlighting when the user presses Ctrl-H.
nnoremap <C-H> :nohlsearch<CR>

" Toggle spell checking when the user presses Ctrl-S.
nnoremap <C-S> :set spell!<CR>

" Do incremental search.
set incsearch

" Make tabs, trailing spaces and end of lines show up and make a '+' show up
" in the last column of the screen if the line is longer than the window width.
set listchars=tab:>-,trail:-,eol:$,extends:+
set list

if !has("win16") && !has("win32") && !has("win64") && !has("win32unix")
            \ && $LANG =~# "\.UTF-8$"
    " Make the split separator appear like a thin line.
    set fillchars+=vert:│
endif

" Don't show the tool bar.
set guioptions-=T

" Don't show the scroll bars.
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=b

" Do not use automatic folding.
set foldmethod=manual

" Invert foldenable when the user presses the space bar.
nnoremap <space> zi

" On Windows, try to use the Consolas font.
" On Unix / Linux, try to use the Inconsolata font. On a Debian GNU/Linux
" system, you can install it with the command:
" apt-get install fonts-inconsolata
if has("unix")
    silent! set guifont=inconsolata\ 12
elseif has("win32")
    silent! set guifont=Consolas:h10
endif

" Do auto-indentation.
set autoindent

" Source .vimrc in the current directory.
set exrc

" Use base16 (see https://ddrscott.github.io/blog/2017/base16-shell).
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif

" Remap ESC to "kj" in insert mode.
inoremap kj <ESC>

" Make "," the "leader" key (instead of the backslash).
let mapleader = ","

" Map <Leader>a to the search of non ASCII characters.
nnoremap <Leader>a /[^\x00-\x7F]<CR>

" Map <Leader>c to comments hidding and <Leader>C to comments showing.
nnoremap <Leader>c :hi! link Comment Ignore<CR>
nnoremap <Leader>C :hi! link Comment Comment<CR>

" Always display cursor position.
set ruler

" Set options for Diapp plugin.
let g:diapp_gprbuild_comm_msg = 0
