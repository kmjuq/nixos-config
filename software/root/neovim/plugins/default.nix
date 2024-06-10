{
  imports = [
  ];

  programs.nixvim = {
    plugins = {
      gitsigns.enable = true;
      nvim-autopairs.enable = true;
      nvim-colorizer.enable = true;
      treesitter.enable = true;
      lualine.enable = true;
    };
  };
}
