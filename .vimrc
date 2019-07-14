" Activates the Pathogen plugin (package vim-pathogen on Debian).
silent! call pathogen#infect()
silent! call pathogen#helptags()

" Enable syntax highlighting.
syntax enable

" Activate file type plugins.
filetype plugin indent on

" -----------------------------------------------------------------------------

" Returns a truthy value if the argument is the path to a writable directory.
" If the directory does not exist, then the function attempts to create it,
" with permission 0700 (rwx------: readable and writable only for the owner).
"
" Arguments:
"
" #1 - path_to_dir
" Path to a directory.
"
" Return value:
" Non-zero if the argument is the path to a writable directory, zero otherwise.
function s:CanWriteToDir(path_to_dir)

    let l:Ret = (filewritable(a:path_to_dir) == 2)
    if !l:Ret
        if exists("*mkdir")
            silent! call mkdir(a:path_to_dir, "p", 0700)
        endif
        let l:Ret = (filewritable(a:path_to_dir) == 2)
    endif
    return l:Ret

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

" Highlight search.
set hlsearch

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

" Don't show the menu.
set guioptions-=m

" Don't show the scroll bars.
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=b

" Use the whole window height.
set guiheadroom=0

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

" Make "," the "leader" key (instead of the backslash).
let mapleader = ","

" Map <Leader>a to the search of non ASCII characters.
nnoremap <Leader>a /[^\x00-\x7F]<CR>

" Map <Leader>c to comments hidding and <Leader>C to comments showing.
nnoremap <Leader>c :hi! link Comment Ignore<CR>
nnoremap <Leader>C :hi! link Comment Comment<CR>

if !has("win16") && !has("win32") && !has("win64") && !has("win32unix")
            \ && $LANG =~# "\.UTF-8$"
    " Make guides displayed by the plugin indentLine appear like
    " thin lines (https://github.com/Yggdroot/indentLine).
    let g:indentLine_char = '│'
endif

" Make regular expression mode the default search mode in the Ctrl-P plugin
" (https://github.com/kien/ctrlp.vim).
let g:ctrlp_regexp = 1

" Have Ctrl-P plugin scan hidden files and directories.
let g:ctrlp_show_hidden = 1

if !has("win16") && !has("win32") && !has("win64")
    " Have Ctrl-P use custom file scanning commands.
    let g:ctrlp_user_command = {
    \ 'types': {
        \ 1: ['default.gpr',
            \ 'cd %s && find . -type f | grep -v "\.\/\(obj\)\|\(bin\)\|'
            \ . '\(lcov\)\|\([^\/]*doc[^\/]*\)\|\(.git\)\/"'],
        \ 2: ['build',
            \ 'find %s -type f | grep -v "\/\(build\)\|\(.git\)\/"'],
        \ 3: ['.git',
            \ 'find %s -type f | grep -v "\/\.git\/"'],
        \ },
    \ 'fallback': 'find %s -type f'}
endif

" Use single leader key instead of double leader key in the EasyMotion plugin
" (https://github.com/Lokaltog/vim-easymotion).
let g:EasyMotion_leader_key = '<Leader>'

" Remap <Leader>w to the bidirectional word search function of the EasyMotion
" plugin.
map <Leader>w <Plug>(easymotion-bd-w)

" Make the BufExplorer plugin (https://github.com/jlanzarotta/bufexplorer)
" show relative paths by default.
let g:bufExplorerShowRelativePath = 1

" Make tcomment work with octave file type.
call tcomment#type#Define('octave', '# %s')

let s:specific_settings_required = 0
if s:specific_settings_required
    set background=light
    silent! color moria
    set ruler
    set backupcopy=yes
    set lines=57
endif
