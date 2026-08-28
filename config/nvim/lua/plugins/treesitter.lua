local function select(mapping, name, type)
  vim.keymap.set({ 'x', 'o' }, mapping, function()
    require('nvim-treesitter-textobjects.select').select_textobject(name, type or 'textobjects')
  end)
end

local function goto_next_start(mapping, name, type)
  vim.keymap.set({ "n", "x", "o" }, mapping, function()
    require("nvim-treesitter-textobjects.move").goto_next_start(name, type or "textobjects")
  end, { desc = string.format("Go to next %s start", name) } )
end

local function goto_prev_start(mapping, name, type)
  vim.keymap.set({ "n", "x", "o" }, mapping, function()
    require("nvim-treesitter-textobjects.move").goto_previous_start(name, type or "textobjects")
  end, { desc = string.format("Go to previous %s start", name) } )
end

local function goto_next(mapping, name, type)
  vim.keymap.set({ "n", "x", "o" }, mapping, function()
    require("nvim-treesitter-textobjects.move").goto_next(name, type or "textobjects")
  end, { desc = string.format("Go to next %s", name) } )
end

local function goto_prev(mapping, name, type)
  vim.keymap.set({ "n", "x", "o" }, mapping, function()
    require("nvim-treesitter-textobjects.move").goto_previous(name, type or "textobjects")
  end, { desc = string.format("Go to prev %s", name) } )
end

local function select_both(mapping, name, type)
  select("i" .. mapping, name .. ".inner", type)
  select("a" .. mapping, name .. ".outer", type)
end

local function map_textobjects()
  --select
  select_both("m", "@function")
  select_both("c", "@class")
  select("is", "@local.scope", "locals")
  -- select("aa", "@parameter.outer")
  -- select("ia", "@parameter.inner")
  -- select_both("l", "@loop")
  -- select_both("f", "@call")
  --
  goto_next("sj", "@function.outer")
  goto_prev("sk", "@function.outer")
  -- goto_next_start("sj", "@function.outer")
  -- goto_prev_start("sk", "@function.outer")
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        init = function()
          -- Disable entire built-in ftplugin mappings to avoid conflicts.
          -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
          vim.g.no_plugin_maps = true

          -- Or, disable per filetype (add as you like)
          -- vim.g.no_python_maps = true
          -- vim.g.no_ruby_maps = true
          -- vim.g.no_rust_maps = true
          -- vim.g.no_go_maps = true
        end,
        config = function()
          require('nvim-treesitter-textobjects').setup {
            select = {
              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,
            },
          }
          map_textobjects()
        end,
      },
    },
    config = function()
      require('nvim-treesitter').install { 'html', 'javascript', 'c', 'java', 'lua', 'vim', 'cpp' }
    end,
  },
}
