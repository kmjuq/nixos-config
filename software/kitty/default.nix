{
  config,
  pkgs,
  ...
}: let
  current_kitty_path = builtins.toPath ./.;
in {

  home.packages = with pkgs; [
    kitty
  ];

  home.file.".config/kitty" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_kitty_path}";
  };

}