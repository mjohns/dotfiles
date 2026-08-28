local function configure_dap()
  local dap = require("dap")
  local dapui = require("dapui")

  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" }
  }

  dap.configurations.cpp = {
    {
      name = "Launch executable (GDB)",
      type = "gdb",
      request = "launch",
      -- This will prompt you for the binary path when you start debugging
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopAtBeginningOfMainSubprogram = false,
    },
  }

  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp

  vim.keymap.set('n', '<leader>dd', function() dap.step_over() end, {
    desc = "Step over",
  })
  vim.keymap.set('n', '<leader>di', function() dap.step_into() end, {
    desc = "Step into",
  })
  vim.keymap.set('n', '<leader>dc', function() dap.continue() end, {
    desc = "Continue",
  })
  vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, {
    desc = "Toggle breakpoint",
  })
  vim.keymap.set('n', '<leader>dr', function() dap.toggle_repl() end, {
    desc = "Toggle repl",
  })

  dapui.setup()

  -- Automatically open/close UI layout on debug sessions
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end

end

return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = configure_dap,
  }
}
