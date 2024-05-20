local opt = vim.opt

-- 行号
opt.number = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 自动换行
opt.wrap = false

opt.cursorline = true

opt.mouse:append("a")

opt.clipboard:append("unnamedplus")

opt.termguicolors = true
opt.signcolumn = "yes"
