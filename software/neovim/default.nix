{
  self,
  config,
  ...
}: let
  current_neovim_path = "${self.outPath}/software/neovim";
in {
  home.packages = with pkgs; [
    neovim
  ];

  # home.file.".config/nvim" = {
  #   source = ../neovim;
  #   recursive = true;
  # };
  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_neovim_path}";
  };
}
