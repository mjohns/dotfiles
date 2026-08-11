local M = {}

M.switch_related_file = function()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.expand('%:p:h')
  local basename = vim.fn.expand('%:t:r')
  local ext = vim.fn.expand('%:e')

  local targets = {}

  -- Handle C/C++ Headers -> Source
  if ext == 'h' or ext == 'hpp' then
    targets = {
      basename .. '.cc',
      basename .. '.cpp',
      basename .. '.c',
      basename .. '.cxx'
    }

  -- Handle C/C++ Source -> Headers
  elseif ext == 'c' or ext == 'cc' or ext == 'cpp' or ext == 'cxx' then
    targets = {
       basename .. '.h',
       basename .. '.hpp'
    }

  -- Handle angular html/ts pairs
  elseif ext == 'html' then
    if basename:match(".ng$") then
      local base_html = basename:gsub(".ng$", "")
      targets = {
        base_html .. '.ts'
      }
    end

  elseif ext == 'ts' then
    targets = {
      basename .. '.ng.html'
    }

  -- Handle Java <-> Impl.java
  elseif ext == 'java' then
    if basename:match("Impl$") then
      -- Strip "Impl" off the end to get the base interface
      local base_interface = basename:gsub("Impl$", "")
      targets = { base_interface .. '.java' }
    else
      -- Add "Impl" to the end
      targets = { basename .. 'Impl.java' }
    end
  end

  if #targets == 0 then
    vim.notify("No related file logic defined for ." .. ext, vim.log.levels.INFO)
    return
  end

  for _, partial_target in ipairs(targets) do
    target = dir .. '/' .. partial_target
    if vim.fn.filereadable(target) == 1 then
      -- fnameescape ensures files with spaces in the name don't break the command
      vim.cmd('edit ' .. vim.fn.fnameescape(target))
      return
    end
  end

  vim.notify("Related file not found.", vim.log.levels.WARN)
end

local function switch_test_file()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.expand('%:p:h')
  local basename = vim.fn.expand('%:t:r')
  local ext = vim.fn.expand('%:e')

  local target_paths = {}

  if basename == 'BUILD' then
    if dir:match("/java/") then
      local target_dir = dir:gsub("/java/", "/javatests/", 1)
      -- The javatests BUILD may not exist. Just open it anyway. we can create it with :w++p
      vim.cmd('edit ' .. vim.fn.fnameescape(target_dir .. '/BUILD'))
      return
    elseif dir:match("/javatests/") then
      local target_dir = dir:gsub("/javatests/", "/java/", 1)
      table.insert(target_paths, target_dir .. '/BUILD')
    end

  -- Handle C/C++ Source <-> Test
  elseif ext == 'c' or ext == 'cc' or ext == 'cpp' or ext == 'cxx' or ext == 'h' or ext == 'hpp' then
    if basename:match("_test$") then
      -- We are in a test file, look for the source file
      local base_source = basename:gsub("_test$", "")
      local exts = { 'cc', 'cpp', 'c', 'cxx', 'h', 'hpp' }
      for _, e in ipairs(exts) do
        table.insert(target_paths, dir .. '/' .. base_source .. '.' .. e)
      end
    else
      -- We are in a source file, look for the test file
      table.insert(target_paths, dir .. '/' .. basename .. '_test.cc')
      table.insert(target_paths, dir .. '/' .. basename .. '_test.cpp')
    end

  -- Handle Java Source <-> Test
  elseif ext == 'java' then
    if basename:match("Test$") then
      -- We are in a test file, swap javatests for java
      local base_source = basename:gsub("Test$", "")
      local target_dir = dir:gsub("/javatests/", "/java/", 1)
      table.insert(target_paths, target_dir .. '/' .. base_source .. '.java')
      -- Fallback to just folder
      table.insert(target_paths, target_dir)
    else
      -- We are in a source file, swap java for javatests
      local target_dir = dir:gsub("/java/", "/javatests/", 1)
      table.insert(target_paths, target_dir .. '/' .. basename .. 'Test.java')
      -- Fallback to just folder
      table.insert(target_paths, target_dir)
    end
  end

  if #target_paths == 0 then
    vim.notify("No test file logic defined for ." .. ext, vim.log.levels.INFO)
    return
  end

  for _, target in ipairs(target_paths) do
    if vim.fn.filereadable(target) == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(target))
      return
    end
  end

  vim.notify("Test file not found.", vim.log.levels.WARN)
end

M.switch_test_file = switch_test_file

return M
