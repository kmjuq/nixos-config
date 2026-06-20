{
  config,
  pkgs,
  extraArgs,
  self,
  ...
}: let
  current_neovim_path = "${self}/software/neovim/";
in {
  home.packages = with pkgs; [
    neovim
    fd
    ripgrep
    fzf
  ];

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_neovim_path}";
  };
}
