-- Python LSP servers configuration (Pyright + Ruff)
-- These are extracted from init.lua for better modularity

return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- https://docs.astral.sh/ruff/editors/setup/#neovim
      -- Use Ruff exclusively for linting, formatting, and organizing imports,
      -- disable those capabilities for Pyright
      vim.lsp.config('pyright', {
        settings = {
          pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              -- Ignore all files for analysis to exclusively use Ruff for linting
              ignore = { '*' },
            },
          },
        },
      })
      vim.lsp.enable('pyright')

      -- Ruff language server configuration
      -- https://docs.astral.sh/ruff/editors/setup/#neovim
      vim.lsp.config('ruff', {
        init_options = {
          settings = {
            -- General Settings
            lineLength = 88, -- Standard Black/Ruff default
            logLevel = 'error', -- Options: 'error', 'warn', 'info', 'debug'

            -- Preference for configuration files
            -- 'filesystemFirst' prioritizes pyproject.toml/ruff.toml over these settings
            configurationPreference = 'filesystemFirst',

            -- Linter Settings
            lint = {
              enable = true,
              preview = false, -- Enable to use unstable/experimental rules
              -- Select rules to enable (e.g., ["E4", "E7", "F"])
              -- If null, uses defaults or workspace config files
              select = nil,
              extendSelect = {},
              ignore = {},
            },

            -- Formatter Settings
            format = {
              preview = false,
            },

            -- Code Actions
            showSyntaxErrors = true,
            fixAll = true, -- Register as capable of 'source.fixAll'
            organizeImports = true, -- Register as capable of 'source.organizeImports'
          },
        },
      })
      vim.lsp.enable('ruff')
    end,
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      -- Add Python formatters to conform.nvim
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { 'ruff_format', 'ruff_organize_imports' }
      return opts
    end,
  },
}
