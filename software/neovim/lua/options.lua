local opt = vim.opt

-- 行号
opt.number = true

-- 缩进
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- 自动换行
opt.wrap = false

opt.cursorline = true

-- opt.mouse:append("a")

opt.clipboard:append("unnamedplus")

opt.termguicolors = true
-- opt.signcolumn = "yes"

opt.list = true
opt.listchars = { space = "·" }
