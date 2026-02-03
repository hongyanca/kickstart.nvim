return {
  'saghen/blink.cmp',
  optional = true,
  dependencies = { 'fang2hou/blink-copilot', opts = { max_completions = 1 } },
  opts = {
    appearance = {
      nerd_font_variant = 'mono',
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
      },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
}
