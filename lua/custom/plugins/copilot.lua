if true then
  return {}
end

return {
  'zbirenbaum/copilot.lua',
  lazy = true,
  requires = {
    'copilotlsp-nvim/copilot-lsp',
    init = function()
      vim.g.copilot_nes_debounce = 500
    end,
  },
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      nes = {
        enabled = false,
        keymap = {
          accept_and_goto = '<leader>p',
          accept = false,
          dismiss = '<Esc>',
        },
      },
      -- copilot_model = 'gpt-4.1-copilot',
    }
  end,
}
