" ┌──────────────────────────────┐
" │ Mark's _  fairly decent      │
" │ __   _(_)_ __ ___  _ __ ___  │
" │ \ \ / / | '_ ` _ \| '__/ __| │
" │  \ V /| | | | | | | | | (__  │
" │   \_/ |_|_| |_| |_|_|  \___| │
" │                              │
" └──────────────────────────────┘
"
" Section: Basic Configuration {{{1

set runtimepath+=~/.vim

set title
set history=700
set background=dark

filetype plugin on
filetype indent on

syntax enable

let mapleader = " "
let maplocalleader = " "

set autoread                        " Carry over indenting from previous line
set wildmenu                        " Handy auto completion menu

set list
"set listchars=tab:→\ ,trail:←,extends:»,precedes:«
set listchars=tab:∙\ ,trail:←,extends:»,precedes:«
set infercase                       " Completion recognizes capitalisation
set smartcase                       " Derp
set ignorecase                      " Case insensitivity
set incsearch                       " Search as you type
set hidden                          " Sometimes I don't want to save a buffer
                                    " before switching buffers

set backupdir=~/tmp
set modelines=5
set matchtime=1
set modeline
set tabstop=4
set softtabstop=4
set shiftwidth=4
set completeopt-=preview
set scrolloff=8

set spell
" Attempt to put backup files in /run/user/$UID/vim
function! s:DetermineBackupDirectory()
    let l:dirpath=expand("/run/user/$UID")
    if isdirectory(l:dirpath)
        if !isdirectory(l:dirpath . 'vim')
            call mkdir(l:dirpath . 'vim')
        endif
        let &backupdir=l:dirpath . 'vim'
    endif
endfunction

call s:DetermineBackupDirectory()

let s:cache_dir = &backupdir . '/cache'
function! s:get_cache_dir(suffix)
    return resolve(expand(s:cache_dir . '/' . a:suffix))
endfunction

" Quick vim config edits
nnoremap <leader>ve :split $MYVIMRC<CR>
"}}}

" Section: VIM-PLUG Installation {{{1
"
" Install VIM-PLUG
if !filereadable(expand('~/.vim/autoload/plug.vim'))
    silent !echo "Installing VIM Plug"
    silent !mkdir -p ~/.vim/autoload
    silent !curl -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif


" Here come the plugins...
call plug#begin('~/.vim/plugged')

"-----------------------------------------
" Syntax
"-----------------------------------------
Plug 'ap/vim-css-color',                    { 'for': ['css', 'less', 'sass'] }
Plug 'groenewege/vim-less',                 { 'for': ['less'] }
Plug 'nono/vim-handlebars',                 { 'for': ['handlebars'] }
Plug 'othree/html5.vim',                    { 'for': ['html'] }
Plug 'jelera/vim-javascript-syntax',        { 'for': ['javascript'] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript'] }
Plug 'leshill/vim-json',                    { 'for': ['javascript', 'json'] }
Plug 'tpope/vim-markdown',                  { 'for': ['markdown'] }
Plug 'briancollins/vim-jst',                { 'for': ['ejs', 'jst']}
Plug 'evanmiller/nginx-vim-syntax',         { 'for': ['nginx']}
Plug 'evidens/vim-twig',                    { 'for': ['twig']}
Plug 'StanAngeloff/php.vim',                { 'for': ['php']}
if executable('node')
    Plug 'marijnh/tern_for_vim',  { 'for': 'javascript', 'do': 'npm install' }
endif
Plug 'lunaru/vim-twig',                     { 'for': ['twig'] }
Plug 'digitaltoad/vim-jade',                { 'for': ['jade'] }
Plug 'ekalinin/Dockerfile.vim',             { 'for': ['docker'] }
Plug 'sheerun/vim-polyglot'
Plug 'rhysd/vim-clang-format',              { 'for': ['cpp', 'c'] } "{{{
    nmap <Leader>C :ClangFormatAutoToggle<CR>
    let g:clang_format#detect_style_file = 1
"}}}
Plug 'posva/vim-vue'

"-----------------------------------------
" Color Schemes
"-----------------------------------------
Plug 'fatih/molokai'

"-----------------------------------------
" Functionality
"-----------------------------------------
Plug 'Lokaltog/vim-easymotion'
Plug 'Shougo/vimproc.vim',                  { 'do': 'make' }
Plug 'airblade/vim-gitgutter'
Plug 'gregsexton/gitv'
Plug 'guns/xterm-color-table.vim',          { 'on': 'XtermColorTable' }
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-sensible'
Plug 'roryokane/detectindent' "{{{
    let g:detectindent_preferred_expandtab=1
    let g:detectindent_preferred_indent=4
    augroup DetectIndent
        autocmd!
        autocmd BufReadPost * DetectIndent
    augroup END
"}}}
Plug 'tpope/vim-surround'
Plug 'Shougo/unite.vim' "{{{
    autocmd FileType unite call s:unite_my_settings()
    function! s:unite_my_settings()
        call unite#filters#matcher_default#use(['matcher_fuzzy'])
        call unite#filters#sorter_default#use(['sorter_rank'])
        call unite#custom#profile('files', 'context.smartcase', 1)
        call unite#custom#source('line,outline', 'matchers', 'matcher_fuzzy')

        call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
            \ 'ignore_pattern', join([
            \ '\.git',
            \ 'google/obj/',
            \ 'dist/',
            \ 'node_modules/',
            \ 'tmp/'
            \ ], '\|'))

        imap <silent><buffer> <C-j> <Plug>(unite_select_next_line)
        imap <silent><buffer> <C-k> <Plug>(unite_select_previous_line)
        imap <silent><buffer> <Esc> <Plug>(unite_exit)
    endfunction

    Plug 'Shougo/neomru.vim'           " Required for file_mru
    Plug 'Shougo/unite-session'        " Provides session (project) support
    Plug 'Shougo/unite-outline'

    let g:unite_data_directory=&backupdir . '/unite'
    let g:unite_source_history_yank_enable = 1
    let g:unite_source_rec_max_cache_files=5000

    "nmap ; [unite]
    "nnoremap [unite] <nop>

    "nnoremap <silent> [unite] :Unite -toggle -no-split -buffer-name=files -start-insert buffer file_rec/async:!<CR>
    "nnoremap <silent> [unite]r :Unite -buffer-name=recent -start-insert file_mru<CR>

    "nnoremap <leader>/ :Unite grep:.<CR>
    "nmap <C-y> [unite]y

    "nnoremap <silent> ; :Unite -toggle -buffer-name=files -start-insert buffer file_rec/async:!<CR>
    "nnoremap <silent> <tab> :Unite -toggle -buffer-name=files -start-insert buffer <CR>

    " Use silver searcher if available
    if executable('ag')
        " Use instead of grep
        let g:unite_source_grep_command = 'ag'
        let g:unite_source_grep_default_opts =
                    \ '-i --line-numbers --nocolor --nogroup --hidden --ignore ' .
                    \ '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
        let g:unite_source_grep_recursive_opt = ''
        " Use instead of `find`
        let g:unite_source_rec_async_command= 'ag --nocolor --nogroup --hidden -g ""'
    elseif executable('awk')
        let g:unite_source_grep_command = 'ack'
        let g:unite_source_grep_default_opts = '--no-heading --no-color -C4'
        let g:unite_source_grep_recursive_opt = ''
        echom "Silver Searcher is unavailable, unite results will probably be irritating"
    endif

    Plug 'Shougo/unite-outline' "{{{
        nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<CR>
    "}}}
"}}}
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline', "{{{
    let g:airline_left_sep = '⮀'
    let g:airline_left_alt_sep = '⮁'
    let g:airline_right_sep = '⮂'
    let g:airline_right_alt_sep = '⮃'
    let g:airline_symbols = {}
    let g:airline_symbols.branch = '⭠'
    let g:airline_symbols.readonly = '⭤'
    let g:airline_symbols.linenr = '⭡'
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#fnamemod = ':t'
    let g:airline_theme = 'luna'
"}}}
Plug 'tpope/vim-fugitive', "{{{
    map \b :Gblame<CR>
    map \l :Glog<CR>
    map \gs :Gstatus<CR>
"}}}
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' } "{{{
    let g:NERDTreeQuitOnOpen = 0
    let g:NERDTreeShowLineNumbers = 0
    let g:NERDTreeWinPos = "right"
    let g:NERDTreeIgnore = ['\.pyc$']
    nmap \e :NERDTreeToggle<CR>
"}}}
Plug 'godlygeek/tabular',                   { 'on': 'Tabularize' } "{{{
    nmap <Leader>a& :Tabularize /^<CR>
    vmap <Leader>a& :Tabularize /^<CR>
    nmap <Leader>a= :Tabularize /=<CR>
    vmap <Leader>a= :Tabularize /=<CR>
    nmap <Leader>a: :Tabularize /:\zs<CR>
    vmap <Leader>a: :Tabularize /:\zs<CR>
    nmap <Leader>a, :Tabularize /,<CR>
    vmap <Leader>a, :Tabularize /,<CR>
    nmap <Leader>a# :Tabularize /#<CR>
    vmap <Leader>a# :Tabularize /#<CR>
    nmap <Leader>a> :Tabularize /=><CR>
    vmap <Leader>a> :Tabularize /=><CR>

"}}}
Plug 'fatih/vim-go', {'for': 'go'}
"Plug 'garyburd/go-explorer', {'for': 'go', 'do': 'go get -u github.com/garyburd/go-explorer/src/getool'}
Plug 'scrooloose/syntastic' "{{{
    let g:syntastic_enable_signs = 1
    let g:syntastic_auto_jump = 0
    let g:syntastic_javascript_jslint_conf = "--nomen"
    let g:syntastic_javascript_checkers = ['jshint', 'jscs']
    let g:syntastic_python_checkers =['python', 'flake8']
    "let g:syntastic_c_checkers = ['clang_check']
    "let g:syntastic_c_lang_check_post_args = ""
    "let g:syntastic_c_check_header = 1
    "let g:syntastic_c_compiler = 'clang'
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_error_symbol = '✗'
    let g:syntastic_style_error_symbol = '◼'
    let g:syntastic_warning_symbol = '▲'
    let g:syntastic_style_warning_symbol = '≈'
    let g:syntastic_check_on_wq = 0
"}}}
Plug 'mbbill/undotree',                     { 'on': 'UndotreeToggle' } "{{{
    let g:undotree_SplitLocation = 'botright'
    let g:undotree_FocusWhenToggle=1
    nnoremap \r :UndotreeToggle<CR>
"}}}
Plug 'embear/vim-localvimrc', "{{{
    let g:localvimrc_persistent=2
    let g:localvimrc_persistence_file=expand('$HOME/.config/localvimrc_persistent')
"}}}
Plug 'majutsushi/tagbar', "{{{
    nmap \t :TagbarToggle<CR>
"}}}
Plug 'vhdirk/vim-cmake'
"Plug 'jalcine/cmake.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim', "{{{
    nnoremap <silent> ; :Files<CR>
    nnoremap <leader>/ :Ag<CR>

"}}}
Plug 'jmcomets/vim-pony', { 'for': 'python' }
Plug 'mattn/webapi-vim'
Plug 'mattn/gist-vim'

"-----------------------------------------
" Autocomplete
"-----------------------------------------
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neosnippet.vim' "{{{
    let g:neosnippet#snippets_directory = '~/.vim/bundle/vim-snippets,~/.vim/snippets'
    let g:neosnippet#enable_snipmate_compatibility = 1

    imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ? "\<C-n>" : "\<TAB>")
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
    imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
    smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
"}}}

Plug 'Shougo/neocomplete.vim' "{{{
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#data_directory = s:get_cache_dir('neocomplete')
    "inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"
    "inoremap <expr><S-tab> pumvisible() ? "\<C-p>" : "<S-tab>"
"}}}

call plug#end()
"}}}

" Section: Color Schemes {{{1

function! ColorSchemeMolokai()
    set background=dark
    let g:molokai_original = 1
    let g:rehash256 = 1
    try
        colo molokai
    catch
    endtry
    highlight SpecialKey cterm=None ctermfg=237 ctermbg=None
    highlight Normal ctermbg=None
    highlight SignColumn ctermbg=232
    highlight LineNr ctermbg=232 ctermfg=236
    "highlight SyntasticError ctermfg=53 ctermbg=197
    "highlight SyntasticWarning ctermfg=58 ctermbg=226
    highlight Todo ctermbg=243 ctermbg=65

endfunction

function! ColorTermSolarized()
    set background=dark
    let g:solarized_termcolors = 256
    let g:solarized_contrast = "high"
    let g:solarized_termtrans = 1
    try
        colo solarized
    endtry
    highlight SpecialKey cterm=None ctermfg=234 ctermbg=None
endfunction
"}}}

" Section: Helpful Functions {{{1

" highlight trailing whitespace with garish color
function! HighlightExtraWhitespace()
    highlight ExtraWhitespace ctermfg=204 ctermbg=161
    match ExtraWhitespace /\s\+$/
    highlight SpecialKey ctermbg=None
endfunction

" trim all trailing whitespace
function! StripExtraWhitespace()
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction
"}}}

" Section: Key bindings {{{1

"" buffa flippin'
map <C-n> :bnext<CR>
map <C-p> :bprev<CR>

"" ctrl-o sort in visual mode
vmap <C-o> :sort<CR>

"" toggle folds with <Return>
nnoremap <CR> za

"" magically fix indentation
map <F7> mzgg=G`z<CR>

"" toggle line numbers
nmap <leader>n :set invnumber<CR>

"" don't exist visual mode when shifting
vnoremap < <gv
vnoremap > >gv

"" big jump up/down
noremap J 30j
noremap K 30k

"" Vim-Plug
nnoremap <leader>pu :PlugUpdate<CR>
nnoremap <leader>pi :PlugInstall<CR>
nnoremap <leader>pc :PlugClean<CR>

"" quickfix list nav with ctrl+j/k
nnoremap <C-j> :lnext<CR>
nnoremap <C-k> :lprev<CR>

"" show jump list
nnoremap <leader>o :jumps<CR>

nnoremap <leader>sw :call StripExtraWhitespace()<CR>

"" screen line scroll
nnoremap <silent> j gj
nnoremap <silent> k gk
"}}}

" Section: Visual tweaks {{{1

call ColorSchemeMolokai()
call HighlightExtraWhitespace()
"}}}

" GVim stuff
set guifont=Envy\ Code\ R\ 10

" Section: Spell check {{{1
"" spell check all git commit messages

"" underline misspellings
hi clear SpellBad
hi SpellBad cterm=underline

" more intuitive (for me at least) misspelling navigation
nnoremap zn ]s
nnoremap zp [s

" toggle spell check
nnoremap z! :setlocal spell!<CR>

" replace current misspelling with first suggestion
nnoremap zf <Esc>1z=
"}}}

" Section: Read .vimlocal if available {{{1
if filereadable(expand('~/.vimlocal'))
    source ~/.vimlocal
endif

" vim:fdm=marker:ts=4:sw=4:et:
