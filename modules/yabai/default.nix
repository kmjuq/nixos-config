{
  config,
  ...
}: let
  current_skhdrc_path = builtins.toPath ./skhdrc;
  current_yabairc_path = builtins.toPath ./yabairc;
  current_sketchybar_path = builtins.toPath ./sketchybar;
in {

  imports = [
    ../../software/starship
  ];

  home.file.".skhdrc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_skhdrc_path}";
  };

  home.file.".yabairc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_yabairc_path}";
  };

  home.file.".config/sketchybar" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_sketchybar_path}";
  };

}