require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = 'both' -- to enable cursorline!
o.swapfile = false
o.wrap = true
o.linebreak = true
o.breakindent = true
o.expandtab = false
o.clipboard = ""
o.showbreak = "=== "

-- lsp
vim.lsp.set_log_level("off")
vim.diagnostic.enable(false)
