return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    lazy = false,
    config = function()
      require('bufferline').setup {
        options = {
          themable = true,
          numbers = 'none',
          close_command = 'bdelete! %d', -- can be a string | function, | false see "Mouse actions"
          right_mouse_command = 'bdelete! %d', -- can be a string | function | false, see "Mouse actions"
          left_mouse_command = 'buffer %d', -- can be a string | function, | false see "Mouse actions"
          middle_mouse_command = nil, -- can be a string | function, | false see "Mouse actions"
          indicator = {
            icon = '󰞘 ', -- this should be omitted if indicator style is not 'icon'
            style = 'icon',
          },
          buffer_close_icon = '󰅖',
          modified_icon = '● ',
          close_icon = ' ',
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'File Explorer',
              highlight = 'Directory',
              text_align = 'left',
            },
          },
        },
      }
    end,
    keys = {
      {
        'L',
        function()
          vim.cmd('bnext ' .. vim.v.count1)
        end,
        desc = 'Next buffer',
      },
      {
        'H',
        function()
          vim.cmd('bprev ' .. vim.v.count1)
        end,
        desc = 'Previous buffer',
      },
      {
        'gb',
        function()
          vim.cmd 'BufferLinePick'
        end,
        desc = 'Goto buffer',
      },
    },
  },
}
