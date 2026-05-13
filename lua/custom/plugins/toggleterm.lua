vim.pack.add {
  { src = 'https://github.com/akinsho/toggleterm.nvim', version = vim.version.range '*' },
}

require('toggleterm').setup {
  direction = 'horizontal', -- horizontal | vertical | float
  open_mapping = [[<C-_>]], -- Ctrl-/
  -- '<Esc><Esc>' or '<C-\\><C-n>' exits Terminal mode and enters Normal mode.
  size = 15,
  hide_numbers = true,
  shade_terminals = true,
}
