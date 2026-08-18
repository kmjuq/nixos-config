-- lazyvim 本身的配置
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
    init = function()
      vim.opt.spell = false
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit" },
        callback = function()
          vim.opt_local.spell = false
        end,
      })
    end,
  },
}
