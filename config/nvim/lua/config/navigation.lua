local M = {}

-- Store the active target key (defaults to 'd' for diagnostics)
M.current_forward_target = "d"
M.current_backward_target = "d"

--- Set the target navigation key and trigger an immediate forward jump
---@param key string
function M.set_target(forward, back)
  M.current_forward_target = forward
  M.current_backward_target = back
  vim.notify("Navigation target set to: " .. forward, vim.log.levels.INFO)
end

function M.jump_forward()
  local keys = string.format("]%s", M.current_forward_target)
  local feedable_keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(feedable_keys, "m", false)
end

function M.jump_backward()
  local keys = string.format("[%s", M.current_backward_target)
  local feedable_keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(feedable_keys, "m", false)
end

--- Set up keymaps
function M.setup()
  vim.keymap.set("n", "<leader>dd", function() M.set_target("d", "d") end, { desc = "Navigate diagnostics" })
  vim.keymap.set("n", "<leader>dq", function() M.set_target("q", "q") end, { desc = "Navigate quickfix" })
  vim.keymap.set("n", "<leader>dm", function() M.set_target("m", "m") end, { desc = "Navigate methods" })
  vim.keymap.set("n", "<leader>dt", function() M.set_target("t", "t") end, { desc = "Navigate treesitter" })
  vim.keymap.set("n", "<leader>dx", function() M.set_target("x", "x") end, { desc = "Navigate conflicts" })

  -- Navigate forward with 'f'
  vim.keymap.set({ "n", "x", "o" }, "f", function()
    M.jump_forward()
  end, { desc = "Jump forward to active target" })

  -- Navigate backward with 'F'
  vim.keymap.set({ "n", "x", "o" }, "F", function()
    M.jump_backward()
  end, { desc = "Jump backward to active target" })
end

return M
