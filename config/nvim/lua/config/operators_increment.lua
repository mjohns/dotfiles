-- local function duplicate_and_increment()
--   -- Capture the count (defaults to 1 if no number key was pressed)
--   local count = vim.v.count1
--
--   -- Exit visual mode to populate '< and '> marks
--   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
--
--   -- Get the start and end line numbers of the visual selection
--   local start_line = vim.fn.getpos("'<")[2]
--   local end_line = vim.fn.getpos("'>")[2]
--
--   -- Retrieve lines from the buffer (0-indexed API)
--   local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
--
--   local new_lines = {}
--
--   -- For each count iteration (1..N), increment numbers in each line
--   for step = 1, count do
--     for _, line in ipairs(lines) do
--       local incremented_line = line:gsub("%d+", function(num)
--         return tostring(tonumber(num) + step)
--       end)
--       table.insert(new_lines, incremented_line)
--     end
--   end
--
--   -- Insert all generated lines directly below the visual selection
--   vim.api.nvim_buf_set_lines(0, end_line, end_line, false, new_lines)
-- end
--
-- -- Map 'ga' in Visual Mode
-- vim.keymap.set('v', 'ga', duplicate_and_increment, {
--   desc = "Duplicate selection below and increment numbers",
--   silent = true,
-- })

-- Core function to duplicate and increment lines
local function duplicate_and_increment_lines(start_line, end_line)
  local count = vim.v.count1

  -- Retrieve selected lines from the buffer (0-indexed API)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local new_lines = {}

  -- For each count iteration (1..N), increment numbers in each line
  for step = 1, count do
    for _, line in ipairs(lines) do
      local incremented_line = line:gsub("%d+", function(num)
        return tostring(tonumber(num) + step)
      end)
      table.insert(new_lines, incremented_line)
    end
  end

  -- Insert generated lines directly below the target line(s)
  vim.api.nvim_buf_set_lines(0, end_line, end_line, false, new_lines)
end

-- Operator function executed by g@
_G.duplicate_and_increment_op = function(type)
  local count = vim.v.count1
  local start_line, end_line

  if type == "line" or type == "char" or type == "block" then
    -- Motions or visual selection
    start_line = vim.fn.getpos("'[")[2]
    end_line = vim.fn.getpos("']")[2]
  else
    -- Direct line call (gaa)
    start_line = vim.api.nvim_win_get_cursor(0)[1]
    end_line = start_line
  end

  -- Retrieve lines from the buffer (0-indexed API)
  duplicate_and_increment_lines(start_line, end_line)
end

-- Setup mappings using g@ to enable dot-repeatability
local function set_opfunc_and_run(motion)
  vim.go.operatorfunc = "v:lua.duplicate_and_increment_op"
  return "g@" .. motion
end

-- Normal Mode: 'gaa' operates on current line (dot-repeatable)
vim.keymap.set('n', 'gaa', function()
  return set_opfunc_and_run("_")
end, { expr = true, desc = "Duplicate line below and increment numbers", silent = true })


-- Visual Mode: Map 'ga' to run over visual selection
vim.keymap.set('v', 'ga', function()
  -- Exit visual mode to populate '< and '> marks
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]

  duplicate_and_increment_lines(start_line, end_line)
end, { desc = "Duplicate visual selection below and increment numbers", silent = true })

-- -- Normal Mode: Map 'gaa' to run on the current line
-- vim.keymap.set('n', 'gaa', function()
--   local current_line = vim.api.nvim_win_get_cursor(0)[1]
--
--   duplicate_and_increment_lines(current_line, current_line)
-- end, { desc = "Duplicate current line below and increment numbers", silent = true })
--
