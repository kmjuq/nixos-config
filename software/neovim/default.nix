{
  config,
  pkgs,
  extraArgs,
  ...
}: let
  current_neovim_path = "${extraArgs.selfVar.flakeHome}/software/neovim/";
in {
  home.packages = with pkgs; [
    neovim
    fd
    ripgrep
  ];

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_neovim_path}";
  };
}
