-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Iterate over all Lua files in the plugins directory and load them
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' then dofile(vim.fs.joinpath(plugins_dir, file_name)) end
end

-- No line wrap
vim.o.wrap = false

-- Hide tilde ~ characters
vim.opt.fillchars = { eob = ' ' }

-- :W to save a file that was opened without sufficient permissions.
vim.api.nvim_create_user_command('W', function()
  vim.cmd 'write !sudo tee % >/dev/null'
  vim.cmd 'edit!'
end, {})

-- Tab settings
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.tabstop = 4 -- Set the number of spaces representing a tab
vim.opt.shiftwidth = 4 -- Set the number of spaces used for indentation (>> or <<)
vim.opt.softtabstop = 4 -- Set the number of spaces inserted when pressing Tab

-- Quit all without saving
vim.keymap.set('n', '<leader>qq', ':qa!<CR>', { desc = 'Quit all without saving' })

-- Use 'jj' for <Esc>
vim.keymap.set('i', 'jj', '<Esc>', { silent = true })

-- Practical Vim 2ed, Tip 62 - Replace a Visual Selection with a Register
-- The visual selection swaps places with the text in the register.
-- To mitigate this side effect
-- ThePrimeagen's remap: it puts the visual selection in the black hole register
vim.keymap.set('v', '<leader>P', '"_dP', { noremap = true, silent = true })

return {}
