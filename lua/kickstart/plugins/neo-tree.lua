-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

if vim.g.have_nerd_font then
  vim.pack.add { 'https://github.com/nvim-tree/nvim-web-devicons' } -- not strictly required, but recommended
end

local function open_with_system(path)
  if vim.ui and vim.ui.open then
    vim.ui.open(path)
    return
  end

  local opener
  if vim.fn.has 'macunix' == 1 then
    opener = 'open'
  elseif vim.fn.has 'win32' == 1 then
    opener = 'start'
  elseif vim.fn.executable 'xdg-open' == 1 then
    opener = 'xdg-open'
  end

  if opener then vim.fn.jobstart({ opener, path }, { detach = true }) end
end

vim.keymap.set('n', '<leader>fe', function()
  require('neo-tree.command').execute { toggle = true, dir = vim.uv.cwd() }
end, { desc = 'Explorer NeoTree (cwd)' })

vim.keymap.set('n', '<leader>e', '<leader>fe', { desc = 'Explorer NeoTree (cwd)', remap = true })

vim.keymap.set('n', '<leader>ge', function()
  require('neo-tree.command').execute { source = 'git_status', toggle = true }
end, { desc = 'Git Explorer' })

vim.keymap.set('n', '<leader>be', function()
  require('neo-tree.command').execute { source = 'buffers', toggle = true }
end, { desc = 'Buffer Explorer' })

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('Neotree_start_directory', { clear = true }),
  desc = 'Start Neo-tree with directory',
  once = true,
  callback = function()
    if package.loaded['neo-tree'] then return end

    local stats = vim.uv.fs_stat(vim.fn.argv(0))
    if stats and stats.type == 'directory' then require 'neo-tree' end
  end,
})

---@type neotree.Config
local opts = {
  sources = { 'filesystem', 'buffers', 'git_status' },
  open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = true,
      show_hidden_count = true,
      hide_dotfiles = false,
      hide_gitignored = true,
      hide_by_name = {},
      never_show = {
        '.git',
        '.DS_Store',
        'thumbs.db',
      },
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
  window = {
    mappings = {
      ['l'] = 'open',
      ['h'] = 'close_node',
      ['<space>'] = 'none',
      ['Y'] = {
        function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          vim.fn.setreg('+', path, 'c')
        end,
        desc = 'Copy Path to Clipboard',
      },
      ['O'] = {
        function(state) open_with_system(state.tree:get_node().path) end,
        desc = 'Open with System Application',
      },
      ['P'] = { 'toggle_preview', config = { use_float = false } },
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
    git_status = {
      symbols = {
        unstaged = '󰄱',
        staged = '󰱒',
      },
    },
  },
}

local function on_move(data)
  local ok, snacks = pcall(require, 'snacks')
  if ok and snacks.rename then snacks.rename.on_rename_file(data.source, data.destination) end
end

local events = require 'neo-tree.events'
local function can_create_autocmd(event)
  local group = vim.api.nvim_create_augroup('kickstart-neotree-event-check', { clear = true })
  local ok, id = pcall(vim.api.nvim_create_autocmd, event, {
    group = group,
    callback = function() end,
  })
  vim.api.nvim_del_augroup_by_id(group)
  return ok and type(id) == 'number'
end

if not can_create_autocmd 'BufModifiedSet' then
  local define_autocmd_event = events.define_autocmd_event
  events.define_autocmd_event = function(event_name, autocmds, ...)
    if event_name == events.VIM_BUFFER_MODIFIED_SET then
      autocmds = { 'TextChanged', 'TextChangedI', 'BufWritePost' }
    end

    return define_autocmd_event(event_name, autocmds, ...)
  end
end

opts.event_handlers = opts.event_handlers or {}
vim.list_extend(opts.event_handlers, {
  { event = events.FILE_MOVED, handler = on_move },
  { event = events.FILE_RENAMED, handler = on_move },
})

require('neo-tree').setup(opts)

vim.api.nvim_create_autocmd('TermClose', {
  pattern = '*lazygit',
  callback = function()
    if package.loaded['neo-tree.sources.git_status'] then
      require('neo-tree.sources.git_status').refresh()
    end
  end,
})
