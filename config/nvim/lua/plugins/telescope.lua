
return {
  {
    'nvim-telescope/telescope.nvim', version = '*',
    priority = 500,
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- optional but recommended
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local utils = require('telescope.utils')
      require('telescope').setup {
        defaults = {
          path_display = function(opts, path)
            local custom_path = string.gsub(path, "java/com/google", "jcg")
            custom_path = string.gsub(custom_path, "javatests/com/google", "jcgt")

            return utils.transform_path({ path_display = { "filename_first" } }, custom_path)
          -- Alternatively, use "shorten" or { "filename_first" } or truncate
          end
        }
      }

      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>tg', builtin.live_grep, { desc = 'Telescope live grep' })
      -- vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<localleader>b', function() builtin.buffers({ sort_mru = true }) end, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>to', builtin.oldfiles, { desc = 'Telescope oldfiles' })

      -- Search files in current directory
      vim.keymap.set(
        'n', '<leader>td',
        function() builtin.find_files({ cwd = utils.buffer_dir() }) end,
        { desc = "Telescope find files in current buffer's dir" })

      -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
      -- If you later switch picker plugins, this is where to update these mappings.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf

          -- Find references for the word under your cursor.
          vim.keymap.set('n', '<leader>rr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types without an actual implementation.
          vim.keymap.set('n', '<leader>ri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where a function is defined, etc.
          -- To jump back, press <C-t>.
          vim.keymap.set('n', '<leader>rd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

          -- Fuzzy find all the symbols in your current document.
          -- Symbols are things like variables, functions, types, etc.
          vim.keymap.set('n', '<leader>ro', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

          -- Fuzzy find all the symbols in your current workspace.
          -- Similar to document symbols, except searches over your entire project.
          vim.keymap.set('n', '<leader>rw', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

          -- Jump to the type of the word under your cursor.
          -- Useful when you're not sure what type a variable is and you want to see
          -- the definition of its *type*, not where it was *defined*.
          vim.keymap.set('n', '<leader>rt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })
    end
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    -- install the latest stable version
    version = "*",
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require("telescope").load_extension "frecency"
      vim.keymap.set('n', '<leader>tr', "<cmd>Telescope frecency<CR>", { silent = true, desc = 'Telescope frecency' })
    end,
  },
}
