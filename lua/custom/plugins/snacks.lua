vim.pack.add { 'https://github.com/folke/snacks.nvim' }

require('snacks').setup {}

-- Credit for this section goes to exsesx
-- https://github.com/LazyVim/LazyVim/discussions/4232#discussioncomment-11191278
local snacks = require 'snacks'

-- Check whether Copilot is installed
if pcall(require, 'copilot') then
  -- Workaround to keep track of state.
  vim.g.snacks_copilot_enabled = true
  snacks
    .toggle({
      name = 'Toggle (Copilot Completion)',
      color = {
        enabled = 'azure',
        disabled = 'orange',
      },
      get = function()
        return vim.g.snacks_copilot_enabled
      end,
      set = function(state)
        if state then
          vim.g.snacks_copilot_enabled = true
          require('copilot.command').enable()
        else
          vim.g.snacks_copilot_enabled = false
          require('copilot.command').disable()
        end
      end,
    })
    :map '<leader>tc'
end
