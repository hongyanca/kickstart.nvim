-- Copilot is disabled. Remove this guard to enable the vim.pack setup below.
if true then return end

vim.g.copilot_nes_debounce = 500

vim.pack.add {
  'https://github.com/zbirenbaum/copilot.lua',
  'https://github.com/copilotlsp-nvim/copilot-lsp',
}

require('copilot').setup {
  nes = {
    enabled = false,
    keymap = {
      accept_and_goto = '<leader>p',
      accept = false,
      dismiss = '<Esc>',
    },
  },
}
