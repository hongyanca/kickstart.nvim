vim.pack.add {
  'https://github.com/MeanderingProgrammer/treesitter-modules.nvim',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
}

require('treesitter-modules').setup {
  ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python' },
  -- Autoinstall languages that are not installed.
  auto_install = true,
  highlight = {
    enable = true,
    -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
    -- If you are experiencing weird indenting issues, add the language to
    -- the list of additional_vim_regex_highlighting and disabled languages for indent.
    additional_vim_regex_highlighting = { 'ruby' },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<Leader>ss',
      node_incremental = '<Leader>si',
      scope_incremental = '<Leader>sc',
      node_decremental = '<Leader>sd',
    },
  },
  indent = { enable = true, disable = { 'ruby' } },
}
