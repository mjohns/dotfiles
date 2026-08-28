-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- lazy has issues on newer versions of git with reftable
vim.env.GIT_DEFAULT_REF_FORMAT = "files"

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("vim._core.ui2").enable({})
require("config.options")
require("config.colors")

require("config.lazy")
