local function configure_hydras()
  local Hydra = require("hydra")
  Hydra({
    name = 'Window management',
    hint = window_hint,
    config = {
      invoke_on_body = true,
    },
    mode = 'n',
    body = '<leader>tw',

    heads = {
      { 'h', '2<C-w><', { desc = 'narrower' } },
      { 'l', '2<C-w>>', { desc = 'wider' } },
      { 'k', '2<C-w>+', { desc = 'taller' } },
      { 'j', '2<C-w>-', { desc = 'shorter' } },
      { '=', '<C-w>=', { desc = 'equalize' } },
      { 'r', '<C-w>r', { desc = 'rotate' } },
      { 'w', '<C-w>w', { desc = 'next' } },

      -- Exit keys
      { '<Esc>', nil, { exit = true, desc = 'exit' } }
    }
  })

  -- Create a hydra for a [ movement like [d or [(
  -- j/k next/prev and h/l for first/last
  local function bracket_hydra(name, mapping, key, upper_key)
    Hydra({
      name = 'Navigate ' .. name,
      hint = window_hint,
      config = {
        invoke_on_body = true,
      },
      mode = 'n',
      body = mapping,

      heads = {
        { 'P', '[' .. upper_key, { remap = true, desc = 'first' } },
        { 'N', ']' .. upper_key, { remap = true, desc = 'last' } },
        { 'p', '[' .. key, { remap = true, desc = 'prev' } },
        { 'n', ']' .. key, { remap = true, desc = 'next' } },

        -- Exit keys
        { '<Esc>', nil, { exit = true, desc = 'exit' } }
      }
    })
  end

  bracket_hydra("diagnostics", "<leader>dd", "d", "D")
  bracket_hydra("quickfix", "<leader>dq", "q", "Q")
  bracket_hydra("files", "<leader>df", "f", "F")
  bracket_hydra("oldfiles", "<leader>do", "o", "O")
  bracket_hydra("buffers", "<leader>db", "b", "B")
  bracket_hydra("methods", "<leader>dm", "m", "M")
  bracket_hydra("treesitter", "<leader>dt", "t", "T")
  bracket_hydra("undo", "<leader>du", "u", "U")
  bracket_hydra("conflicts", "<leader>dx", "x", "X")
  bracket_hydra("yank", "<leader>dy", "y", "Y")
  bracket_hydra("hunks", "<leader>dh", "h", "H")

end

local loaded, _ = pcall(require, "hydra")
if loaded then
  configure_hydras()
end

return {
  {
    "nvimtools/hydra.nvim",
    config = function()
      configure_hydras()
    end
  },
}
