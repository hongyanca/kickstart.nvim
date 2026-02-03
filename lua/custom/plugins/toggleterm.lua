return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      direction = 'horizontal', -- horizontal | vertical | float
      open_mapping = [[<C-_>]], -- Ctrl-/
      -- '<Esc><Esc>' or '<C-\\><C-n>' exits Terminal mode and enters Normal mode.
      size = 15,
      hide_numbers = true,
      shade_terminals = true,
      config = function()
        require('toggleterm').setup {}
      end,
    },
  },
}
