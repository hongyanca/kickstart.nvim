vim.pack.add {
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
  'https://github.com/nvim-lua/plenary.nvim',
}

local harpoon = require 'harpoon'

harpoon:setup()

vim.keymap.set('n', '<leader>a', function()
  harpoon:list():add()
end, { desc = 'Add current file to 󱡀 ' })

vim.keymap.set('n', '<C-e>', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set('n', '<leader>r', function()
  harpoon:list():remove()
end, { desc = 'Remove current file from 󱡀 ' })

vim.keymap.set('n', '<leader>1', function()
  harpoon:list():select(1)
end, { desc = '󱡀 1' })

vim.keymap.set('n', '<leader>2', function()
  harpoon:list():select(2)
end, { desc = '󱡀 2' })

vim.keymap.set('n', '<leader>3', function()
  harpoon:list():select(3)
end, { desc = '󱡀 3' })

vim.keymap.set('n', '<leader>4', function()
  harpoon:list():select(4)
end, { desc = '󱡀 4' })
