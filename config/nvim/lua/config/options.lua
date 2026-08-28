vim.opt.termguicolors = true
vim.g.have_nerd_font = true

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Converts inserted <Tab> characters into spaces
vim.opt.expandtab = true

-- Number of spaces used for auto-indentation (e.g., when using '>>' or '<<')
vim.opt.shiftwidth = 2

-- Number of spaces a <Tab> counts for when editing (e.g., inserting or backspacing)
vim.opt.softtabstop = 2

-- Number of visual spaces a physical <Tab> character in a file counts for
vim.opt.tabstop = 2

-- Highlights search matches dynamically as you type them
vim.opt.incsearch = true

-- Keeps all search matches highlighted after you press enter
vim.opt.hlsearch = true

-- Displays absolute line numbers on the left side of the screen
vim.opt.number = true

-- Overrides 'ignorecase' to make search case-sensitive ONLY IF your search contains uppercase letters
vim.opt.smartcase = true

-- Ignores uppercase/lowercase differences when searching (works alongside smartcase)
vim.opt.ignorecase = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.opt.clipboard = ""

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Show signs in the number column overwriting the number instead of taking up a full column.
vim.o.signcolumn = 'number'

-- Decrease update time
vim.o.updatetime = 300

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 600

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ',  nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Hide created files in Explore
-- Note: Backslashes in Lua strings need to be escaped, or you can use [[ ]] for raw strings
vim.g.netrw_list_hide = '.*\\.swp$,.*\\.swo$'

vim.cmd([[
" Don't show cursor line in insert mode
" https://github.com/mhinz/vim-galore#smarter-cursorline
  autocmd InsertLeave,WinEnter * set cursorline
  autocmd InsertEnter,WinLeave * set nocursorline

" https://github.com/mhinz/vim-galore#faster-keyword-completion
set complete-=i   " disable scanning included files
set complete-=t   " disable searching tags

" https://github.com/mhinz/vim-galore#disable-audible-and-visual-bells
set noerrorbells
set novisualbell
set t_vb=
]])

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
-- vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#ADD8E6", fg = "#0000FF" })
-- on_yank({ higroup = "YankHighlight", timeout = 300 })
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Autocomplete setup
vim.o.pumborder = "rounded"
vim.opt.completeopt = { "menuone", "noinsert", "noselect", "fuzzy", "popup" }

vim.opt.wildoptions = { "pum", "fuzzy" }
vim.opt.wildmode = { "longest:full", "full" }
vim.o.wildignorecase = true

-- vim.cmd([[
-- cnoremap <expr> <Up> wildmenumode() ? "\<C-p>" : "\<Up>"
-- cnoremap <expr> <Down> wildmenumode() ? "\<C-n>" : "\<Down>"
-- ]])
--
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "gitcommit",
--   callback = function()
--     vim.opt_local.textwidth = 0          -- Removes the hard wrap limit
--     vim.opt_local.colorcolumn = ""       -- Clears any visual length columns
--     vim.opt_local.formatoptions:remove({"t", "l"}) -- Stops auto-wrapping text
--   end,
-- })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "jjdescription", "jj" },
  callback = function()
    -- Disable hard wrapping
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove({ "t", "a" })

    -- Disable visual soft wrapping (optional, remove if you want visual wrapping)
    vim.opt_local.wrap = false
  end,
})

