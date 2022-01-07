let g:polyglot_disabled = ['sh', 'rust']

let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1
let g:ale_rust_cargo_use_clippy = 1
let g:ale_sign_warning = "}}"
let g:ale_linters = { 'rust': ['cargo'] }

" Loading plugins {{{
call plug#begin()
Plug 'nvim-lua/plenary.nvim'         " Async library
Plug 'lewis6991/gitsigns.nvim'       " Git Diff Signs
Plug 'nvim-telescope/telescope.nvim' " Fuzzy Tool

Plug 'mattn/emmet-vim', { 'for': ['markdown', 'html', 'xml'] } " HTML go brrrr

Plug 'rstacruz/vim-closer' " Bracket Closer (when enter is pressed)
Plug 'tpope/vim-endwise'   " Keyword Closing (like closing 'if' with 'end' in Lua)

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'andymass/vim-matchup'        " Better % Matching
Plug 'dense-analysis/ale'          " Better Syntastic
Plug 'alexmozaidze/vim-easy-align' " EZ Aligning
Plug 'svermeulen/vim-cutlass'      " Separate cut from delete
Plug 'tpope/vim-fugitive'          " Git Wrapper
Plug 'AndrewRadev/sideways.vim'    " Moving Function Arguments _Sideways_

Plug 'tpope/vim-surround'   " Operations on Parentheses (like 'cs(}')
Plug 'tpope/vim-obsession'  " Vim Session Manager
Plug 'tpope/vim-unimpaired' " Handy Bracket Mappings (like ']b')
Plug 'tpope/vim-eunuch'     " UNIX Shell Commands Syntax Sugar
Plug 'tpope/vim-repeat'     " Allow More Things To Repeat with .

Plug 'matveyt/vim-modest'            " Colorscheme that works on _any_ terminal
Plug 'rafi/awesome-vim-colorschemes' " Awesome Colorschemes

Plug 'sheerun/vim-polyglot'         " Multi-Language Support
Plug 'ron-rs/ron.vim'               " Ron Language Support
Plug 'alexmozaidze/rust.vim'        " Rust syntax highlighting (my own fork)
Plug 'rubixninja314/vim-mcfunction' " Minecraft Datapacks Support
call plug#end()
" }}}

lua require('gitsigns').setup()
lua << EOF
require('gitsigns').setup {
    signs = {
        add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
        change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
        delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
        },
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
        interval = 1000,
        follow_files = true
        },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        },
    current_line_blame_formatter_opts = {
        relative_time = false
        },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
        },
    yadm = {
    enable = false
    },
}
EOF

" Standart NeoVim settings {{{
set path=.,,~/**,~/.local/**,~/.config/**,~/.xmonad/**,**
filetype plugin indent on
set noswapfile
set et ci pi sts=0 sw=4 ts=4
syntax enable
set modelines=0
set incsearch inccommand=nosplit
set background=dark
set nowrap
set undofile
set textwidth=0 wrapmargin=0 colorcolumn=100
set formatoptions=crqj
set scroll=0
set scrolloff=4
set sidescrolloff=4
set ignorecase
set shada=\'100,<9999,s100
set diffopt+=iwhite
set display=lastline
set shortmess=I
set clipboard=unnamedplus
set splitbelow splitright
set hidden
set termguicolors
if empty($DISPLAY)
    let g:colors_8bit = 0
    set notermguicolors
endif
set guicursor=o-cr-n-v-sm-r:block,c-i-ci-ve:ver25
set cursorcolumn
set list listchars=tab:│\ ,trail:･,nbsp:+,extends:,precedes:
if empty($DISPLAY)
    set listchars=tab:│\ ,nbsp:+,trail:~,extends:>,precedes:<
endif
set lazyredraw
set tm=86400000
set number relativenumber numberwidth=4
set showmode
set mouse=a
set nohlsearch
set cpo=adlABceF_
set nostartofline
set conceallevel=0
set concealcursor=
set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>
set laststatus=2
autocmd BufEnter *.vim,*.nvim setlocal formatoptions=crqj
autocmd BufEnter *.md,*.markdown,*.org setlocal formatoptions=tcrqn21jp
autocmd BufEnter *.porth setlocal filetype=porth
" }}}

" Statusbar settings {{{
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW:%dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction
set statusline=
set statusline+=\ %F\ %m\ %R
set statusline+=%=
set statusline+=\ %y\ \ %l:%c\ \ %p%%\ \ %{LinterStatus()}\ 
" }}}

" Onedark settings {{{
let g:onedark_terminal_italics = 1
let g:onedark_hide_endofbuffer = 1
" }}}
colorscheme onedark
if empty($DISPLAY)
    colorscheme modest
endif

" Removing visual tweaks when in Terminal-mode {{{
autocmd TermEnter * set nolist nonumber norelativenumber | NoMatchParen
autocmd TermLeave * set list number relativenumber | DoMatchParen
" }}}

" Mapping leader
let mapleader=" "

" Removing <Leader> key's default behaviour {{{
nmap <silent> <Leader> <Nop>
nmap <silent> <Leader><Leader> <Nop>
" }}}

" Remapping x and s to cut and cut-change respectivly {{{
nnoremap x d
xnoremap x d
nnoremap xx dd
nnoremap X D

nnoremap s c
xnoremap s c
nnoremap ss cc
nnoremap S C
" }}}

" Fixing Y map
nmap <silent> Y y$

" Moving through splits with <C-direction> {{{
tnoremap <silent> <C-h> <C-\><C-n><C-w>h
tnoremap <silent> <C-j> <C-\><C-n><C-w>j
tnoremap <silent> <C-k> <C-\><C-n><C-w>k
tnoremap <silent> <C-l> <C-\><C-n><C-w>l
inoremap <silent> <C-h> <C-\><C-n><C-w>h
inoremap <silent> <C-j> <C-\><C-n><C-w>j
inoremap <silent> <C-k> <C-\><C-n><C-w>k
inoremap <silent> <C-l> <C-\><C-n><C-w>l
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l
" }}}

" Quitting Terminal-mode with <Esc> {{{
tnoremap <silent> <Esc> <C-\><C-n>
" }}}

" Maps for saving {{{
nnoremap <silent> <Leader>w :confirm w<CR>
nnoremap <silent> <Leader>W :confirm wa<CR>
nnoremap <silent> <Leader>u :SudoWrite<CR>
" }}}

" Maps for quitting {{{
nnoremap <silent> <Leader>q :confirm q<CR>
nnoremap <silent> <Leader>Q :confirm qa<CR>
" }}}

" Maps for quitting&saving {{{
nnoremap <silent> <Leader>s :wq<CR>
nnoremap <silent> <Leader>S :wqa<CR>
" }}}

" Maps for killing buffer(s) {{{
nnoremap <silent> <Leader>k :bd!<CR>
nnoremap <silent> <Leader>K :bd!<CR>
" }}}

" Map scratch buffer
nnoremap <silent> <Leader>x :ene<CR>:setlocal buftype=nofile bufhidden=hide noswapfile<CR>

" Argument text object mappings {{{
omap <silent> aa <Plug>SidewaysArgumentTextobjA
xmap <silent> aa <Plug>SidewaysArgumentTextobjA
omap <silent> ia <Plug>SidewaysArgumentTextobjI
xmap <silent> ia <Plug>SidewaysArgumentTextobjI
nnoremap <silent> <Leader>h :SidewaysLeft<CR>
nnoremap <silent> <Leader>l :SidewaysRight<CR>
" }}}

" Easy-Align mapings {{{
xmap ga <Plug>(LiveEasyAlign)
nmap ga <Plug>(LiveEasyAlign)
" }}}

" Ale settings {{{
nnoremap <silent> ]l :ALENext<CR>
nnoremap <silent> [l :ALEPrevious<CR>
nnoremap <silent> <Leader>d :ALEDetail<CR>
" }}}

" Telescope settings {{{
" Find files using Telescope command-line sugar.
nnoremap <Leader>e <Cmd>Telescope find_files<CR>
nnoremap <Leader>g <Cmd>Telescope live_grep<CR>
nnoremap <Leader>b <Cmd>Telescope buffers<CR>
" }}}

" Matchup settings {{{
"let g:matchup_matchparen_offscreen = 0
let g:matchup_matchparen_offscreen = {'method': 'popup'}
" }}}

" Emmet settings {{{
let g:user_emmet_leader_key = '<F1>'
" }}}

autocmd BufEnter *.rs setlocal matchpairs-=<:>
