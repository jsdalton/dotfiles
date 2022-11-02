call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdcommenter'
Plug 'neovim/nvim-lspconfig'

" Completion stuff
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'

" fuzzy find
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 

" asterisk search
Plug 'junegunn/vim-slash'

" Snippet engine
Plug 'hrsh7th/vim-vsnip'

" Color scheme
Plug 'arcticicestudio/nord-vim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

" move_selection_previous
Plug 'tpope/vim-surround'

" parens matching etc
Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'

" React
Plug 'neoclide/vim-jsx-improve'
call plug#end()

" general nvim
set nowrap                        " don't wrap lines
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set expandtab                     " use spaces, not tabs
set list                          " Show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode
set number
set switchbuf+=usetab,newtab
set showtabline=2

" prevent out of memory errors
set maxmempattern=20000

"" fzf settings
set rtp+=/usr/local/opt/fzf
nnoremap <C-p> :Telescope find_files<Cr>

" color scheme settings
set termguicolors
colorscheme tokyonight
let g:lightline = { 'colorscheme': 'tokyonight', 'active': { 'left': [ [ 'mode', 'paste' ], [ 'readonly', 'absolutepath', 'modified' ] ] } }

" quickfix
autocmd FileType qf nnoremap <buffer> t <CR>
autocmd FileType qf nnoremap <buffer><silent> <esc> :quit<cr>

lua << EOF
local nvim_lsp = require 'lspconfig'
local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>tab split | lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ff', '<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>', opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-l>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- rename doesn't work
  --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>d', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>qd', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Enable the following language servers
local servers = { 'tsserver', 'solargraph' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- eslint stuff
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

local rubocop = {
  lintCommand = "rubocop --format emacs --force-exclusion --stdin ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  linkIgnoreExitCode = true,
  formatCommand = "c rubocop -A -f quiet --stderr -s ${INPUT}",
  formatStdin = true
}

require 'lspconfig'.efm.setup {
  init_options = {documentFormatting = true},
  settings = {
    rootMarkers = {".git/", "Gemfile", ".rubocop.yml"},
    languages = {
      lua = { {formatCommand = "lua-format -i", formatStdin = true} },
      javascript = {eslint},
      javascriptreact = {eslint},
      ["javascript.jsx"] = {eslint},
      typescript = {eslint},
      ["typescript.tsx"] = {eslint},
      typescriptreact = {eslint},
      ruby = {rubocop},
      rspec = {rubocop}
    }
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact",
    "ruby",
    "rspec"
  }
}
EOF

" telescope stuff
nnoremap <Leader>tp :lua require'telescope.builtin'.builtin{}<CR>
nnoremap <Leader>tg :lua require'telescope.builtin'.grep_string{}<CR>
nnoremap <Leader>ts :lua require'telescope.builtin'.live_grep{}<CR>

lua << EOF
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    layout_strategy = 'vertical',
    layout_config = {
      horizontal = {
        width = 0.9
        },
      vertical = {
        width = 0.9
        }
      },
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-k>"] = "move_selection_previous",
        ["<C-j>"] = "move_selection_next",
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
EOF

" Setup Completion
" See https://github.com/hrsh7th/nvim-cmp#basic-configuration
lua << EOF
local cmp = require 'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<S-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-Space>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
})

-- nvim-autopairs with cmp stuff
local npairs = require('nvim-autopairs')
npairs.setup()
npairs.add_rules(require('nvim-autopairs.rules.endwise-ruby'))
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
EOF

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  autotag = {
    enable = true,
  },
  hightlight = { enable = true },
  indent = { enable = true }
}
EOF

" move lines up and down
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" make a friendly ag alias that does not overrite current buffer automatically
ca ag Ag!

" source vimrc (reload init.vm)
nnoremap <leader>sv :source $MYVIMRC<CR>

" nerdtre 
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" ruby stuf
au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,Procfile,Guardfile,config.ru,*.rake} set ft=ruby

" nerd commenter enable 
let NERDSpaceDelims=1
