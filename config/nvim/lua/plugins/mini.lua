function configure_clue()
  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      -- Leader triggers
      { mode = { 'n', 'x' }, keys = '<leader>' },
      { mode = { 'n', 'x' }, keys = '<localleader>' },

      -- `[` and `]` keys
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- `g` key
      { mode = { 'n', 'x' }, keys = 'g' },
      { mode = { 'n', 'x' }, keys = 's' },

      -- Marks
      { mode = { 'n', 'x' }, keys = "'" },
      { mode = { 'n', 'x' }, keys = '`' },

      -- Registers
      { mode = { 'n', 'x' }, keys = '"' },
      { mode = { 'i', 'c' }, keys = '<C-r>' },

      -- Window commands
      { mode = 'n', keys = '<C-w>' },

      -- `z` key
      { mode = { 'n', 'x' }, keys = 'z' },

      { mode = 'n', keys = '<C-w>' },
    },

    window = {
      config = {
        width = 60
      },
    },

    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end

return {
  'nvim-mini/mini.nvim',
  version = '*',
  priority = 900,
  config = function()
    require('mini.comment').setup()
    -- require('mini.icons').setup()
    require('mini.ai').setup()
    require('mini.surround').setup({
      mappings = {
        highlight = "sH",
      },
    })
    require('mini.operators').setup()
    require('mini.bracketed').setup()
    require('mini.misc').setup_termbg_sync()
    require('mini.trailspace').setup()
    -- require('mini.bufremove').setup()


    configure_clue()

    -- require('mini.jump2d').setup()
    -- require('mini.starter').setup()
  end,
}
