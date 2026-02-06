local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('junegunn/seoul256.vim')
Plug('vim-airline/vim-airline')
Plug('tpope/vim-sensible')
Plug('tpope/vim-fugitive')
Plug('mkitt/tabline.vim')
Plug('airblade/vim-gitgutter')
vim.cmd([[
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
]])
Plug('junegunn/fzf.vim')
Plug('leafgarland/typescript-vim')
vim.call('plug#end')

vim.cmd('silent! colorscheme seoul256')
vim.cmd('silent! set background=dark')
vim.cmd('silent! set cursorcolumn cursorline')
vim.cmd('silent! set number relativenumber')
vim.cmd('silent! set mouse=a')

vim.keymap.set('n', '<C-p>', ':Files<CR>', { silent = true})
vim.keymap.set('n', '<C-f>', ':Rg<CR>', { silent = true})

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { silent = true })
-- Exit terminal mode with ESC
vim.api.nvim_set_keymap('t', '<ESC><ESC>', '<C-\\><C-n>', {noremap = true, silent = true })

local function lsp_format(bufnr)
  if vim.lsp.buf.format then
    vim.lsp.buf.format({ bufnr = bufnr })
  else
    vim.lsp.buf.formatting_sync(nil, 2000)
  end
end

local function on_attach(_, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  local opts = { silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>f', function()
    lsp_format(bufnr)
  end, opts)
end

local lspconfig = require('lspconfig')
lspconfig.gopls.setup({
  on_attach = on_attach,
})
