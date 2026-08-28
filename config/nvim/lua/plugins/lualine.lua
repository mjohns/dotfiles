function macro_recording()
  local reg = vim.fn.reg_recording()
  if reg == "" then return "" end -- not recording
  return "recording to " .. reg
end


return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      theme = "solarized_light",
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        -- lualine_c = {'filename', {'filename', path = 1}},
        lualine_c = {'filename', macro_recording},
        lualine_x = {'searchcount', 'diagnostics', 'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
    },
  },
}
