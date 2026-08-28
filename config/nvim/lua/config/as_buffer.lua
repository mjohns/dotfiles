local M = {}

local function make_buffer_name(short_name)
  return "as-buffer://" .. short_name
end

local function create_buffer(short_name)
  local buf_name = make_buffer_name(short_name)

  -- Close existing buffer it exists and reopen
  local existing_buf = vim.fn.bufnr(buf_name)
  if existing_buf ~= -1 then
    pcall(vim.api.nvim_buf_delete, existing_buf, { force = true })
  end

  local buf = vim.api.nvim_create_buf(false, false)

  vim.api.nvim_buf_set_name(buf, buf_name);
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  return buf
end

local function map_select_files_to_enter(buf)
  vim.keymap.set('n', '<CR>', 'gf', {buffer = buf})

  -- VISUAL MODE: Press <CR> to load all selected files into buffers
  vim.keymap.set('v', '<CR>', function()
    -- Get start and end lines of the visual selection
    local v_start = vim.fn.line('v')
    local v_end = vim.fn.line('.')

    -- Ensure v_start is always the top of the selection
    if v_start > v_end then
      v_start, v_end = v_end, v_start
    end

    local lines = vim.api.nvim_buf_get_lines(buf, v_start - 1, v_end, false)

    local loaded_count = 0
    for _, line in ipairs(lines) do
      if line and line ~= "" then
        local escaped_file = vim.fn.fnameescape(line)

        if loaded_count == 0 then
          -- Switch to the first selected file
          vim.cmd('edit ' .. escaped_file)
        else
          -- Add subsequent files to the buffer list in the background
          vim.cmd('badd ' .. escaped_file)
        end

        loaded_count = loaded_count + 1
      end
    end
  end, { buffer = buf, silent = true, desc = "Open selected files in buffers" })
end

function make_path_relative_if_possible(name)
  return vim.fn.fnamemodify(name, ":.")
end

--
-- oldfiles
--

function M.oldfiles()
  local buf = create_buffer("oldfiles");

  -- Populate the buffer with current oldfiles
  local oldfiles = vim.v.oldfiles
  local lines = {}
  for _, line in ipairs(oldfiles) do
    table.insert(lines, make_path_relative_if_possible(line))
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modified', false, { buf = buf })

  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  vim.keymap.set('n', 'q', '<C-^>', {buffer = buf})
  map_select_files_to_enter(buf);

  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("AsBufferOldfiles", M.oldfiles, { desc = "Open oldfiles as buffer" })

--
-- buffers
--

local function get_listed_buffers()
  local buffers = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if info.name ~= "" and info.name ~= make_buffer_name("buffers") then
      table.insert(buffers, { bufnr = info.bufnr, name = info.name, lnum = info.lnum })
    end
  end
  return buffers
end


local function update_buffers(buf)
  local kept = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if vim.trim(line) ~= "" then
      path = vim.fs.normalize(line)
      kept[path] = true
    end
  end

  for _, buf in ipairs(get_listed_buffers()) do
    if not kept[vim.fs.normalize(buf.name)] then
      vim.api.nvim_buf_delete(buf.bufnr, { force = true })
    end
  end

  -- auto close?
end

function M.buffers()
  local buf = create_buffer("buffers");

  -- Populate the buffer with current oldfiles
  local buffers = get_listed_buffers()
  local lines = {}
  for _, buffer_item in ipairs(buffers) do
    table.insert(lines, make_path_relative_if_possible(buffer_item.name))
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modified', false, { buf = buf })

  vim.keymap.set('n', 'q', '<C-^>', { buffer = buf })
  map_select_files_to_enter(buf);

   vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      update_buffers(buf)
      -- auto close on save. Go to alternate buffer which auto closes this
      vim.api.nvim_set_option_value('modified', false, { buf = buf })
      local keys = vim.api.nvim_replace_termcodes("<C-^>", true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    end,
  })

  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("AsBufferBuffers", M.buffers, { desc = "Open buffres as buffer" })

--
-- messages
--

function M.messages()
  local buf = create_buffer("messages");

  -- Populate the buffer with messages
  local exec_result = vim.api.nvim_exec2('messages', { output = true })
  local message_list = vim.split(exec_result.output, '\n', { trimempty = true })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, message_list)
  vim.api.nvim_set_option_value('modified', false, { buf = buf })

  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  vim.keymap.set('n', 'q', '<C-^>', { buffer = buf })

  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("AsBufferMessages", M.messages, { desc = "Open messages as buffer" })

--
-- registers
--

-- List of standard registers to include
local REGISTER_KEYS = {
  '"', "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
  "-", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
  "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
  "v", "w", "x", "y", "z", "*", "+", "/", "=",
}

local function update_registers(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for _, line in ipairs(lines) do
    -- Match pattern: optional leading space, double quote, register char, colon, space, then content
    local reg, content = line:match('^%s*"([^%s]):%s?(.*)$')
    if reg then
      -- Unescape literal newlines if any were preserved as '\n'
      content = content:gsub("\\n", "\n")
      vim.fn.setreg(reg, content)
    end
  end
end

function M.registers()
  local buf = create_buffer("registers")

  local lines = {}
  for _, reg in ipairs(REGISTER_KEYS) do
    local content = vim.fn.getreg(reg)
    if content and content ~= "" then
      -- Flatten multi-line register contents onto a single line for clear editing
      local single_line_content = content:gsub("\n", "\\n")
      table.insert(lines, string.format('"%s: %s', reg, single_line_content))
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modified", false, { buf = buf })

  vim.keymap.set("n", "q", "<C-^>", { buffer = buf, silent = true })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      update_registers(buf)
      vim.api.nvim_set_option_value("modified", false, { buf = buf })
      local keys = vim.api.nvim_replace_termcodes("<C-^>", true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    end,
  })

  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("AsBufferRegisters", M.registers, { desc = "Open registers as buffer" })

return M
