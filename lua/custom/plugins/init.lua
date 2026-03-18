-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec

-- No line wrap
vim.o.wrap = false

-- Hide tilde ~ characters
vim.opt.fillchars = { eob = ' ' }

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
