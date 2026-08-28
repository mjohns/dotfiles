
vim.keymap.set('n', '-', '<CMD>Oil<CR>')

return {
  'stevearc/oil.nvim',
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git'
        end,
      },
      win_options = {
        wrap = true,
        winbar = "%{v:lua.require('oil').get_current_dir()}",
      }
    })
  end,
}
