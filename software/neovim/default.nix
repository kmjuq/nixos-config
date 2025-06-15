{
  config,
  pkgs,
  ...
}: let
  current_neovim_path = builtins.toPath ./.;
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