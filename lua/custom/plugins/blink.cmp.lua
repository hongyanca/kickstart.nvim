vim.pack.add {
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' },
}

local sources = { 'lsp', 'path', 'snippets', 'buffer' }
local providers = {}

if pcall(require, 'copilot') then
  vim.pack.add { 'https://github.com/fang2hou/blink-copilot' }
  table.insert(sources, 'copilot')
  providers.copilot = {
    name = 'copilot',
    module = 'blink-copilot',
    score_offset = 100,
    async = true,
  }
end

require('blink.cmp').setup {
  keymap = {
    preset = 'default',
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    default = sources,
    providers = providers,
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { enabled = true },
}
