-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Self = require("self")

local map = LazyVim.safe_keymap_set

map("i", "jk", "<esc>", { desc = "exit insert mode", noremap = true, silent = true })

if Self.ismac() then
  -- save file
  map({ "i", "x", "n", "s" }, "<D-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
end
