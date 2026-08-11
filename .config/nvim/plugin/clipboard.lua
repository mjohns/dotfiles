local opt = vim.opt

-- Make sure .tmux.conf has 'set -s set-clipboard on'
-- Maybe also 'set -g allow-passthrough on'
-- Test escape sequences with: printf $'\e]52;c;%s\a' "$(base64 <<<'hello world')"

opt.clipboard = "unnamedplus"

if vim.env.SSH_CONNECTION then
  local function vim_paste()
    local content = vim.fn.getreg '"'
    return vim.split(content, "\n")
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy "+",
      ["*"] = require("vim.ui.clipboard.osc52").copy "*",
    },
    paste = {
      ["+"] = vim_paste,
      ["*"] = vim_paste,
    },
  }
end
