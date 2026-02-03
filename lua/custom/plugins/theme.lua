-- Theme configuration
-- Change the name of the colorscheme plugin below, and then
-- change the command in the config to whatever the name of that colorscheme is.
--
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.

return {
  {
    'Shatur/neovim-ayu',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function() vim.cmd.colorscheme 'ayu-dark' end,

    -- 'webhooked/kanso.nvim',
    -- priority = 1000, -- Make sure to load this before all the other start plugins.
    -- config = function()
    --   -- vim.cmd.colorscheme 'kanso'
    -- end,
  },
}
