vim.pack.add {
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
}

require('nvim-treesitter-textobjects').setup {
  select = {
    enable = true,
    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
    selection_modes = {
      ['@parameter.outer'] = 'v', -- charwise
      ['@function.outer'] = 'V', -- linewise
      -- ['@class.outer'] = '<c-v>', -- blockwise
    },
    include_surrounding_whitespace = false,
  },
}

local select = require('nvim-treesitter-textobjects.select').select_textobject

vim.keymap.set({ 'x', 'o' }, 'af', function() select('@function.outer', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'if', function() select('@function.inner', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'ac', function() select('@class.outer', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'ic', function() select('@class.inner', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'as', function() select('@local.scope', 'locals') end)
