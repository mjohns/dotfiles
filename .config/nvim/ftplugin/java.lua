local function find_imports()
  local buf = vim.api.nvim_get_current_buf()
  local current_word = vim.fn.expand('<cword>')
  local lines = vim.fn.systemlist('find_imports ' .. current_word)

  if #lines == 0 then
    vim.notify("No import found for " .. current_word, vim.log.levels.ERROR)
    return
  end

  local function add_import(value)
    vim.api.nvim_buf_set_lines(buf, 1, 1, false, { value })
    -- vim.notify("Added import" .. current_word, vim.log.levels.INFO)
  end

  if #lines == 1 then
    add_import(lines[1])
    return
  end

  vim.cmd(":RunCmd find_imports " .. current_word)
  vim.cmd([[
  if !&modifiable
    map <buffer> <Enter> yyqggjpsh
  endif
  ]])
end
vim.keymap.set("n", "<localleader>i", function() find_imports() end, { desc = "Find import for current word" })

vim.cmd([[
" for java constructors: myField -> this.myField = myField;
map <localleader>m ciwthis.<esc>pa = <esc>pa;<esc>
]])
