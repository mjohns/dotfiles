local M = {}

-- Function to simplify the boilerplate of adding a new parameter to a guice constructor.
-- Add the new item to the constructor (ideally as first parameter) and this function will
-- add the member definition and the assignment.
M.add_guice_param = function()
  local buf = vim.api.nvim_get_current_buf()
  local function get_line(line_number)
    local val = vim.api.nvim_buf_get_lines(buf, line_number, line_number + 1, false)[1]
    return val == nill and "" or val
  end

  local function get_indent(indent_line_number, default_indent)
    local line = get_line(indent_line_number)
    return string.match(line, "^%s*") or default_indent
  end

  local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local type_name, var_name = string.match(line, "(%S+)%s+([%w_]+)%s*,?%s*$")
  if not type_name or not var_name then
    -- now check if it is a single param constructor.
    type_name, var_name = string.match(line, "([^%s%(]+)%s+([%w_]+)%s*%)%s*{")
  end
  if not type_name or not var_name then
    vim.notify("Could not parse parameter type and name from line", vim.log.levels.ERROR)
    return
  end

  local total_lines = vim.api.nvim_buf_line_count(buf)

  -- Search upwards for the @Inject annotation
  local inject_row = -1
  for i = r, 1, -1 do
    local l = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    if string.match(l, "@Inject") then
      inject_row = i - 1
      break
    end
  end

  if inject_row == -1 then
    vim.notify("Could not find @Inject above cursor", vim.log.levels.ERROR)
    return
  end

  local param_position = (r - inject_row)  - 3
  if param_position < 0 then
    param_poisiton = 0
  end

  local start_brace_row = -1
  for i = r, total_lines do
    local l = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    if string.match(l, "{") then
      start_brace_row = i - 1
      break
    end
  end

  if start_brace_row == -1 then
    vim.notify("Could not find opening brace for constructor", vim.log.levels.ERROR)
    return
  end

  -- Find the top line of private final variables above @Inject
  local top_private_final_row = -1
  for i = inject_row - 2, 1, -1 do
    local l = get_line(i)
    if l:find("private final", 1, true) then
      top_private_final_row = i
    else
      break
    end
  end

  local top_insert_row = top_private_final_row
  if top_insert_row ~= -1 then
    -- Try to adjust down where we insert to match the parameter position in the private final block
    top_insert_row = top_private_final_row + param_position
    if top_insert_row >= inject_row then
      top_insert_row = top_private_final_row
    end
  end

  if top_insert_row == -1 then
    -- Just insert directly above the constructor
    local line_above_constructor = vim.api.nvim_buf_get_lines(buf, inject_row -1, inject_row, false)[1]
    local is_blank = line_above_constructor:match("^%s*$")
    top_insert_row = is_blank and inject_row - 1 or inject_row - 2
  end

  local bottom_insert_row = start_brace_row + 1 + param_position

  local top_indent = get_indent(top_insert_row, "  ")
  local bottom_indent = get_indent(bottom_insert_row, "    ")

  local field_line = string.format("%sprivate final %s %s;", top_indent, type_name, var_name)
  local assign_line = string.format("%sthis.%s = %s;", bottom_indent, var_name, var_name)

  -- insert bottom row first so row numbers don't shift
  vim.api.nvim_buf_set_lines(buf, bottom_insert_row, bottom_insert_row, false, { assign_line })
  vim.api.nvim_buf_set_lines(buf, top_insert_row, top_insert_row, false, { field_line })
end


M.sort_guice_constructor = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- 1. Find @Inject constructor location
  local inject_line_idx = nil
  for i, line in ipairs(lines) do
    if line:find("@Inject") then
      inject_line_idx = i
      break
    end
  end

  if not inject_line_idx then
    vim.notify("No @Inject annotation found in the current file.", vim.log.levels.WARN)
    return
  end

  -- 2. Extract constructor parameter order and param-to-type mapping
  local param_order = {}
  local param_to_type = {}
  local param_indent = "  "
  local constructor_start = nil
  local constructor_end = nil

  for i = inject_line_idx + 1, #lines do
    local line = lines[i]
    if line:find("%(") then
      constructor_start = i
    end

    -- Match parameter line: Type name, or Type name)
    local type_name, param_name = line:match("%s*([%w_<>%?%.,%s]+)%s+([%w_]+)%s*[,%)]")
    if type_name and param_name then
      -- Trim whitespace/qualifiers from type
      type_name = type_name:match("^%s*(.-)%s*$")
      table.insert(param_order, param_name)
      param_to_type[param_name] = type_name
    end

    if line:find("%)%s*{" ) then
      constructor_end = i
      break
    end
  end

  if #param_order == 0 then
    vim.notify("Could not parse constructor parameters.", vim.log.levels.ERROR)
    return
  end

  -- Map lookup for fast index matching
  local param_rank = {}
  for rank, name in ipairs(param_order) do
    param_rank[name] = rank
  end

  -- 3. Collect and replace private final field declarations
  local field_lines = {}
  local field_indices = {}
  local field_indent = "  "

  for i, line in ipairs(lines) do
    local field_type, field_name = line:match("%s*private%s+final%s+([%w_<>%?%.,%s]+)%s+([%w_]+)%s*;")
    if field_name and param_rank[field_name] then
      field_indent = line:match("^(%s*)") or "  "
      table.insert(field_indices, i)
      table.insert(field_lines, {
        name = field_name,
        type = field_type:match("^%s*(.-)%s*$"),
        line = line
      })
    end
  end

  -- Reorder field declarations matching constructor params
  if #field_lines > 0 then
    table.sort(field_lines, function(a, b)
      return param_rank[a.name] < param_rank[b.name]
    end)

    for idx, orig_line_idx in ipairs(field_indices) do
      local item = field_lines[idx]
      lines[orig_line_idx] = string.format("%sprivate final %s %s;", field_indent, item.type, item.name)
    end
  end

  -- 4. Collect and replace constructor assignment statements (this.x = x;)
  local assign_lines = {}
  local assign_indices = {}
  local assign_indent = "    "

  for i = (constructor_end or 1) + 1, #lines do
    local line = lines[i]
    if line:find("%}") then
      break
    end

    local assign_var = line:match("%s*this%.([%w_]+)%s*=%s*[%w_]+%s*;")
    if assign_var and param_rank[assign_var] then
      assign_indent = line:match("^(%s*)") or "    "
      table.insert(assign_indices, i)
      table.insert(assign_lines, assign_var)
    end
  end

  if #assign_lines > 0 then
    table.sort(assign_lines, function(a, b)
      return param_rank[a] < param_rank[b]
    end)

    for idx, orig_line_idx in ipairs(assign_indices) do
      local var_name = assign_lines[idx]
      lines[orig_line_idx] = string.format("%sthis.%s = %s;", assign_indent, var_name, var_name)
    end
  end

  -- Apply buffer update in a single atomic transaction
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.notify("Sorted Guice fields & assignments matching @Inject constructor!", vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>ac', M.sort_guice_constructor, { desc = "Sort guice constructor members and assignments", })

return M
