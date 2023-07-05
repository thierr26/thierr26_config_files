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
set listchars=tab:>-,trail:-,eol:$,extends:+,precedes:+
set list

" Toggle list mode.
nnoremap <C-L> :set list!<CR>

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

" Use base16 (see https://ddrscott.github.io/blog/2017/base16-shell).
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif

" Remap ESC to "kj" in insert mode.
inoremap kj <ESC>

" Make "," the "leader" key (instead of the backslash).
let mapleader = ","

" Map <Leader>b to buffer number printing.
nnoremap <Leader>b :echo bufnr('%')<CR>

" Map <Leader>a to the search of non ASCII characters.
nnoremap <Leader>a /[^\x00-\x7F]<CR>

" Map <Leader>c to comments hidding and <Leader>C to comments showing.
nnoremap <Leader>c :hi! link Comment Ignore<CR>
nnoremap <Leader>C :hi! link Comment Comment<CR>

" Always display cursor position.
set ruler

" -----------------------------------------------------------------------------

" Right pad current line with character under the cursor, so that line width
" reaches the desired width.
"
" The desired width is the value provided as argument. If no argument is
" provided, then the desired width is '&textwidth' if '&textwidth' is not zero.
" Otherwise it is 79.
"
" Arguments:
"
" #1 (optional) - Desired width.

function AutoFill(...)

    if a:0 > 0
        " Width argument provided.

        " Use argument as desired auto-filled line width.
        let l:width = a:1

    else
        " Width argument not provided.

        " Use '&textwidth' as desired auto-filled line width (or 79 if
        " '&textwidth' is 0).
        let l:width = &textwidth == 0 ? 79 : &textwidth

    endif

    " Get current line.
    let l:l = getline('.')

    " Get character under cursor.
    let l:cur_char = matchstr(l:l, '\%' . col('.') . 'c.')

    " Number of characters needed to reach desired width.
    let l:n = l:width - strwidth(l:l)

    " Update current line, right padding it with the character under the cursor
    " up to the desired width.
    call setline(line('.'), l:l . repeat(l:cur_char, l:n))

endfunction

" -----------------------------------------------------------------------------

" Save current buffer to file if modified, then edit file with name
" 'b:alt_name'.
"
" Particular case: If file with name 'b:alt_name' is already edited in the same
" tab page, then buffers are just exchanged in the windows.

function EditAltNameFile()

    if !exists("b:alt_name") || empty(b:alt_name)

        echohl ErrorMsg
        echomsg "Don't know what to do"
        echohl None

    elseif filereadable(b:alt_name)

        let l:nbuf = bufnr(b:alt_name)
        if l:nbuf != -1
            " There is already a buffer for file with name 'b:alt_name'.

            " Get the buffer list for the current tab page.
            let l:buf = tabpagebuflist()

            if index(l:buf, l:nbuf) != -1
                " File with name 'b:alt_name' is edited in the current tab
                " page.

                " Number of the window containing the buffer for file with name
                " 'b:alt_name'.
                let l:nwin = bufwinnr(b:alt_name)

                " Number of the current window.
                let l:cwin = winnr()

                " Number of the current buffer.
                let l:cbuf = bufnr('%')

                " Exchange buffers in the windows.
                execute l:nwin . "wincmd w"
                execute l:cbuf . "buffer!"
                execute l:cwin . "wincmd w"
                execute l:nbuf . "buffer!"

            else
                " File with name 'b:alt_name' is edited but not in the current
                " tab page.

                " Write buffer to file if modified.
                if &mod
                    w
                endif

                " Edit buffer for file with name 'b:alt_name'.
                execute "buffer " . b:alt_name

            endif

        else
            " There is no buffer for file with name 'b:alt_name'.

            " Write buffer to file if modified.
            if &mod
                w
            endif

            " Edit file with name 'b:alt_name'.
            execute "edit " . b:alt_name

        endif

    else

        echohl ErrorMsg
        echomsg b:alt_name . " does not exist or is not readable"
        echohl None

    endif

endfunction

" -----------------------------------------------------------------------------
"
" Execute ':make' and open the quickfix window if there are errors.

function Make()

    execute "normal! :make\<bar>cwin\<cr>"

endfunction

" -----------------------------------------------------------------------------

" If the following conditions are all true:
"
" - Variable 'g:last_quick_fix_cmd_edited_file_name' exists.
"
" - Variable 'g:last_quick_fix_cmd_buffer_number' exists.
"
" - There is a buffer with number 'g:last_quick_fix_cmd_buffer_number'.
"
" - The buffer with number 'g:last_quick_fix_cmd_buffer_number' is associated with
"   file with name 'g:last_quick_fix_cmd_edited_file_name'.
"
" then function 'Make' is called.
"
" Before calling 'Make', a move to a window associated with buffer with number
" 'g:last_quick_fix_cmd_buffer_number' is done if such window exists or
" quickfix window is closed (if opened) and buffer with number
" 'g:last_quick_fix_cmd_buffer_number' is edited.

function RepeatMake()

    let l:err = exists("g:last_quick_fix_cmd_edited_file_name") == 0
                \ || exists("g:last_quick_fix_cmd_buffer_number") == 0

    if !l:err

        let l:nbuf = bufnr(g:last_quick_fix_cmd_edited_file_name)
        let l:err = l:nbuf == -1

    endif

    if l:err

        echohl ErrorMsg
        echomsg "Cannot repeat :make"
        echohl None
        return

    endif

    " Get the buffer list for the current tab page.
    let l:buf = tabpagebuflist()

    if index(l:buf, l:nbuf) != -1
        " File with name 'g:last_quick_fix_cmd_edited_file_name' is edited in
        " the current tab page.

        " Number of the window containing the buffer for file with name
        " 'g:last_quick_fix_cmd_edited_file_name'.
        let l:nwin = bufwinnr(g:last_quick_fix_cmd_edited_file_name)

        " Move to that window.
        execute l:nwin . "wincmd w"

    else

        " Close the quickfix window.
        execute "cclose"

        " Edit buffer for file with name
        " 'g:last_quick_fix_cmd_edited_file_name'.
        execute "buffer " . g:last_quick_fix_cmd_edited_file_name

    endif

    call Make()

endfunction

" -----------------------------------------------------------------------------

" If the variable 'b:clear_build_env_cmd' command does not exists, then issues
" an error message. Otherwise, executes the command stored in
" 'b:clear_build_env_cmd' with the shell.

function CleanBuildEnv()

    let l:var_name = "b:clear_build_env_cmd"

    if exists(l:var_name) == 0

        echohl ErrorMsg
        echomsg "Variable " . l:var_name . " does not exist, can't do anything"
        echohl None
        return

    endif

    :call system(eval(l:var_name))

endfunction

" -----------------------------------------------------------------------------

" Autocommands for Ada source files
augroup ada

    au!

    " Set autowrite.
    au BufNewFile,BufReadPost,BufFilePost *.ad[abs] {
        setlocal autowrite
    }

    " Set tabulation parameters.
    au BufNewFile,BufReadPost,BufFilePost *.ad[abs] {
        setlocal tabstop=3 expandtab shiftwidth=3 softtabstop=3
    }

    " Compute the name of the body file for a specification and conversely.
    au BufNewFile,BufReadPost,BufFilePost *.ads {
        b:alt_name = substitute(expand('%'), "...$", "adb", "")
    }
    au BufNewFile,BufReadPost,BufFilePost *.adb {
        b:alt_name = substitute(expand('%'), "...$", "ads", "")
    }
    au BufNewFile,BufReadPost,BufFilePost *_.ada {
        b:alt_name = substitute(expand('%'), ".....$", ".ada", "")
    }
    au BufNewFile,BufReadPost,BufFilePost *[^_].ada {
        b:alt_name = substitute(expand('%'), "....$", "_.ada", "")
    }

    " Set makeprg.
    au BufNewFile,BufReadPost,BufFilePost *.ads {
        setlocal makeprg=gprbuild\ -n\ -q\ -c\ -gnatc\ -p
                    \\ -P\ default.gpr\ -u\ %
    }
    au BufNewFile,BufReadPost,BufFilePost *.adb {
        setlocal makeprg=gprbuild\ -n\ -q\ -p\ -P\ default.gpr\ -u\ %
    }

    " Store edited file name and buffer number to global variables on :make
    " command invocation. Variables used by RepeatMake().
    au QuickFixCmdPre make {
        g:last_quick_fix_cmd_edited_file_name = expand('%:p')
        g:last_quick_fix_cmd_buffer_number    = bufnr('%')
    }

    " Store the compiler generated files removing command.
    au BufNewFile,BufReadPost,BufFilePost *.ad[abs] {
        b:clear_build_env_cmd = "gprclean -q -r -P default.gpr"
    }

augroup END

" Autocommands for GNAT project files
augroup gpr

    au!

    " Set autowrite.
    au BufNewFile,BufReadPost,BufFilePost *.gpr {
        setlocal autowrite
    }

    " Set tabulation parameters.
    au BufNewFile,BufReadPost,BufFilePost *.gpr {
        setlocal tabstop=3 expandtab shiftwidth=3 softtabstop=3
    }

    " Set makeprg.
    au BufNewFile,BufReadPost,BufFilePost *.gpr {
        setlocal makeprg=gprbuild\ -n\ -q\ -k\ -p\ -P\ %
    }

    " Store edited file name and buffer number to global variables on :make
    " command invocation. Variables used by RepeatMake().
    au QuickFixCmdPre make {
        g:last_quick_fix_cmd_edited_file_name = expand('%:p')
        g:last_quick_fix_cmd_buffer_number = bufnr('%')
    }

    " Store the compiler generated files removing command.
    au BufNewFile,BufReadPost,BufFilePost *.gpr {
        b:clear_build_env_cmd = "gprclean -q -r -P default.gpr"
    }

augroup END

" Autocommands for the quickfix window
augroup quickfixwindow

    au!

    au BufWinEnter quickfix {
        setlocal wrap nolist
    }

augroup END

" Associate function 'AutoFill' to command ':AF'.
command -nargs=? AF :call AutoFill(<f-args>)

" Associate function 'EditAltNameFile' to command ':A'.
command -nargs=0 A :call EditAltNameFile()

" Map <F10> to ':make', in normal and insert modes.
nnoremap <F10> :call Make()<CR>
inoremap <F10> <ESC>:call Make()<CR>

" Map <F11> to function 'RepeatMake', in normal and insert modes.
nnoremap <F11> :call RepeatMake()<CR>
inoremap <F11> <ESC>:call RepeatMake()<CR>

" Map <F3> to function 'CleanBuildEnv', in normal and insert modes.
nnoremap <F3> :call CleanBuildEnv()<CR>
inoremap <F3> <ESC>:call CleanBuildEnv()<CR>

" Useful to make some highlight groups visible when using Vim through SSH in
" Windows 10 cmd.
function Fix_Highlighting()
    hi StatusLine ctermfg=lightblue
    hi StatusLineNC ctermfg=darkgray
    hi Boolean ctermfg=darkred
    hi Constant ctermfg=darkred
    hi Number ctermfg=darkred
    hi Float ctermfg=darkred
    hi SpecialChar ctermfg=lightblue
    hi Delimiter ctermfg=lightblue

endfunction
nnoremap <Leader>w :call Fix_Highlighting()<CR>
