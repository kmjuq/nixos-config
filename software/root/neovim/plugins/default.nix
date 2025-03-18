{
  imports = [
  ];

  programs.nixvim = {
    plugins = {
      gitsigns.enable = true;
      nvim-autopairs.enable = true;
      colorizer.enable = true;
      treesitter.enable = true;
      lualine.enable = true;
    };
  };
}
