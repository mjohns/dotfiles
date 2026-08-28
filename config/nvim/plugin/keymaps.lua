local set = vim.keymap.set

-- make j/k act on visual lines
set('', 'j', 'gj')
set('', 'k', 'gk')

-- Basic movement and jumping
set('', 'gl', '$', { desc = "Go to line end" })
set('', 'gh', '^', { desc = "Go to line start" })
set('', 'gk', '[{', { desc = "Go to previous unmatched {" })
set('', 'gj', ']}', { desc = "Go to next unmatched }" })

-- -- [( has weird behavior for when it works or not. Just do a directional search for (
-- set('n', '(', '?(<CR><Esc>', { remap = true, silent = true, desc = "Go to previous (" })
-- set('n', ')', '/)<CR><Esc>', { remap = true, silent = true, desc = "Go to next (" })
set('n', '(', '[(', { silent = true, desc = "Go to previous unmatched (" })
set('n', ')', '])', { silent = true, desc = "Go to next unmatched (" })
-- set('n', '(', ':cprev<CR>', { silent = true, desc = "cprev" })
-- set('n', ')', ':cnext<CR>', { silent = true, desc = "cnext" })

-- Quickfix navigation
set('n', 'SJ', '<cmd>cnext<CR>')
set('n', 'SK', '<cmd>cprev<CR>')

-- -- Like o/O but not going into insert mode
-- set('n', 'SJ', 'o<ESC>')
-- set('n', 'SK', 'O<ESC>')

-- Make visual mode act on full lines by default (removed duplicate from your script)
set('n', 'v', 'V')
set('n', 'V', 'v')

-- In visual mode make J/K just j/k. In case we don't swap v and V like above.
-- set('v', 'J', 'j')
-- set('v', 'K', 'k')

-- Make it so x does not put the deleted char in the default buffer
set('n', 'x', '"_x')

-- Make it easier to enter command mode
set('', ';', ':')

-- Page scrolling. For keyboards where PageDown/Up and mapped to convenient keys.
set('', '<PageDown>', '<C-d>')
set('', '<PageUp>', '<C-u>')

vim.cmd([[
" %% will expand to the current directory relative to the base dir
" Example usage to create a new file in same directory as file in current buffer.
" :e %%/new_file.txt
cabbr <expr> %% expand('%:p:h')
]])

-- Window navigation
set('', '<C-k>', '<C-w>w', { desc = "Focus next window" })
-- set('', '<A-k>', '<C-w>w', { remap = true })

-- Jumping forward and back
set('', 'sh', '<C-o>', { desc = "Previous jump location" })
set('', 'sl', '<C-i>', { desc = "Next jump location" })

-- Switch back to the previously loaded file
-- set('', 'sb', '<C-^>', { remap = true })

-- Forward and back for edits
set('', 'SH', 'g;', { desc = "Previous edit location" })
set('', 'SL', 'g,', { desc = "Next edit location" })

-- Just use <C-w>r to rotate buffer
-- set('n', '<leader>m', '<cmd>call ShiftBuffer()<CR>', { silent = true, desc = "Move buffer to other window" })

set('', '<C-h>', '<cmd>call ExpandWindow()<CR>', {
  silent = true,
  desc = "Toggle full screen window",
})

-- Setup paste mappings
set('n', 'yo', ':call SetupPaste()<CR>o', { silent = true })
set('n', 'yO', ':call SetupPaste()<CR>O', { silent = true })

set('n', '<localleader>r', ':RunCmd ', { desc = "Run shell cmd and output into temp buffer" })
set('n', '<localleader>f', ':Find ', { desc = "Find files" })
set('n', '<localleader>a', ':call RunCmdWithHistory("all " . expand("<cword>"))<CR>', {
  silent = true,
  desc = "Grep current word using 'all'",
})
set('n', '<localleader>g', ':call RunCmdWithHistory("fa " . expand("<cword>"))<CR>', {
  silent = true,
  desc = "Find file matching current word",
})

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
set('n', '<Esc>', '<cmd>nohlsearch<CR>')

local function toggle_quickfix()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd('cclose')
      return
    end
  end
  vim.cmd('45copen')
end
set('n', '<leader>q', toggle_quickfix, { desc = "Toggle quickfix (copen)", silent = true })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

local function open_build_file()
  local current_dir = vim.fn.expand('%:h')
  vim.cmd.edit(current_dir .. '/BUILD')
end
set('n', '<localleader>e', open_build_file, { desc = "Open BUILD file" })

-- vim.cmd("packadd nvim.undotree")
-- set("n", "<leader>u", require("undotree").open, d("Undo tree"))

vim.keymap.set('n', '<leader>ai', require("config.guice").add_guice_param, {
  desc = "Add guice parameter boilerplate",
})


local function toggle_virtual_text()
  local current_config = vim.diagnostic.config()
  vim.diagnostic.config({ virtual_text = not current_config.virtual_text })
end
set('n', '<leader>tv', toggle_virtual_text, { desc = "Toggle diagnostic virtual text" })

-- Mappings for yanking to the clipbaord
set({'n', 'x'}, 'sy', '"+y', { desc = "Yank to system clipboard" })

-- Yank the function, paste it above, then move done to the bottom copy
local function duplicate_function()
  local keys = vim.api.nvim_replace_termcodes('gmami<CR><CR>', true, false, true)

  -- Feed the duplication keys. The 'm' flag acts like remap = true.
  vim.api.nvim_feedkeys(keys, 'm', false)

  -- Schedule the <ESC> to happen on the next tick of the event loop.
  vim.schedule(function()
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    -- 'n' means noremap for the escape key
    vim.api.nvim_feedkeys(esc, 'n', false)
  end)
end
set('n', 'sm', duplicate_function, { silent = true, desc = "Duplicate function" })

-- Notes on mapping cmd-hjkl to arrow keys in iterm
-- Iterm > Settings > Keys > “send text with vim special chars”
--   Up Arrow     \033[A
--   Down Arrow   \033[B
--   Right Arrow  \033[C
--   Left Arrow   \033[D


set("n", "<leader>tnp", ":e ~/.config/nvim/lua/plugins<CR>", {silent = true, desc = "Open lazy plugins dir"})
set("n", "<leader>tnk", ":e ~/.config/nvim/plugin/keymaps.lua<CR>", {silent = true, desc = "Open nvim keymaps.lua"})
set("n", "<leader>tno", ":e ~/.config/nvim/lua/config/options.lua<CR>", {silent = true, desc = "Open nvim options.lua"})
set("n", "<leader>tnc", ":e ~/.config/nvim/lua/config<CR>", {silent = true, desc = "Open nvim lua config dir"})
set("n", "<leader>tni", ":e ~/.config/nvim/init.lua<CR>", {silent = true, desc = "Open nvim init.lua"})

local function strip_trailing_whitespace()
  _G.MiniTrailspace.trim()
end
vim.api.nvim_create_user_command('StripTrailingWhitespace', strip_trailing_whitespace, { desc = "Strip trailing whitespace" })

set('n', '<localleader>s', require("config.related_files").switch_related_file, { desc = "Switch to related file" })
set('n', '<localleader>t', require("config.related_files").switch_test_file, { desc = "Switch to test file" })

local as_buffer = require("config.as_buffer")
set('n', '<leader>bo', as_buffer.oldfiles, { desc = "Open oldfiles as buffer" })
set('n', '<leader>bb', as_buffer.buffers, { desc = "Open buffers as buffer" })
set('n', '<leader>bm', as_buffer.messages, { desc = "Open messages as buffer" })
set('n', '<leader>br', as_buffer.registers, { desc = "Open registers as buffer" })

set("n", "gM", require("config.movement").goto_middle_of_text, { desc = "Go to middle of line" })

vim.keymap.set('n', '<C-f>', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format current buffer with LSP' })

local function add_iwyu()
  local keys = vim.api.nvim_replace_termcodes('A  // IWYU pragma: keep', true, false, true)
  vim.api.nvim_feedkeys(keys, 'm', false)

  -- Schedule the <ESC> to happen on the next tick of the event loop.
  vim.schedule(function()
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    -- 'n' means noremap for the escape key
    vim.api.nvim_feedkeys(esc, 'n', false)
  end)
end
set('n', '<leader>ak', add_iwyu, { desc = "Add IWYU keep" })

-- Autocomplete
vim.keymap.set("i", "<C-space>", "<C-x><C-o>");
vim.keymap.set("i", "<cr>", function() return (vim.fn.pumvisible() ~= 0) and '<C-y>' or '<cr>' end, { expr = true, desc = "Accept completion" })

-- Navigate wildmenu items vertically using Up/Down arrows
vim.keymap.set("c", "<Down>", function()
  return vim.fn.wildmenumode() == 1 and "<Right>" or "<Down>"
end, { expr = true, replace_keycodes = true })

vim.keymap.set("c", "<Up>", function()
  return vim.fn.wildmenumode() == 1 and "<Left>" or "<Up>"
end, { expr = true, replace_keycodes = true })
