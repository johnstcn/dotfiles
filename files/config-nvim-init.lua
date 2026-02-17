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
Plug('neovim/nvim-lspconfig')
Plug('leafgarland/typescript-vim')
Plug('brianaung/compl.nvim')
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
-- Recommendations from https://github.com/brianaung/compl.nvim
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess:append "c"

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
  settings = {
    gopls = {
      gofumpt = true,
    },
  },
})

-- Format Go files on save with gofumpt
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    lsp_format(vim.api.nvim_get_current_buf())
  end,
})

-- Go test helpers
local function go_test_at_cursor()
  -- Find the test function name at cursor
  local line = vim.fn.line('.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, line, false)

  local test_name = nil
  for i = #lines, 1, -1 do
    local match = string.match(lines[i], '^func%s+(Test%w+)')
    if match then
      test_name = match
      break
    end
  end

  if test_name then
    local dir = vim.fn.expand('%:p:h')
    vim.cmd('botright split | terminal cd ' .. vim.fn.shellescape(dir) .. ' && go test -v -run ^' .. test_name .. '$')
  else
    vim.notify('No test function found at cursor', vim.log.levels.WARN)
  end
end

local function go_test_file()
  local dir = vim.fn.expand('%:p:h')
  local file = vim.fn.expand('%:t:r') -- Get filename without extension
  vim.cmd('botright split | terminal cd ' .. vim.fn.shellescape(dir) .. ' && go test -v -run ' .. file)
end

local function go_test_package()
  local dir = vim.fn.expand('%:p:h')
  vim.cmd('botright split | terminal cd ' .. vim.fn.shellescape(dir) .. ' && go test -v ./...')
end

-- Go test commands
vim.api.nvim_create_user_command('GoTestAtCursor', go_test_at_cursor, {})
vim.api.nvim_create_user_command('GoTestFile', go_test_file, {})
vim.api.nvim_create_user_command('GoTestPackage', go_test_package, {})

-- Go test keybindings (only in Go files)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    local opts = { silent = true, buffer = true }
    vim.keymap.set('n', '<leader>tc', go_test_at_cursor, opts)
    vim.keymap.set('n', '<leader>tf', go_test_file, opts)
    vim.keymap.set('n', '<leader>tp', go_test_package, opts)
  end,
})
