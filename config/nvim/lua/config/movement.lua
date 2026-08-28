local M = {}

-- Like gM but ignores leading whitespace for the line when calculating middle
M.goto_middle_of_text = function()
  local line = vim.api.nvim_get_current_line()

  local first_non_ws = line:find("%S")
  if not first_non_ws then
    return
  end

  local line_len = #line
  local target_col = math.floor((first_non_ws + line_len) / 2)

  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, { row, target_col - 1 })
end

return M
