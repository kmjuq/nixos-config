{
  config,
  pkgs,
  extraArgs,
  ...
}: let
  current_kitty_path = "${extraArgs.selfVar.flakeHome}/software/kitty/";
in {
  home.packages = with pkgs; [
    kitty
  ];

  home.file.".config/kitty" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_kitty_path}";
  };
}
