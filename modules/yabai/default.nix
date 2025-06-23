{
  config,
  extraArgs,
  ...
}: let
  current_skhdrc_path = "${extraArgs.selfVar.flakeHome}/modules/yabai/skhdrc";
  current_yabairc_path = "${extraArgs.selfVar.flakeHome}/modules/yabai/yabairc";
  current_sketchybar_path = "${extraArgs.selfVar.flakeHome}/modules/yabai/sketchybar";
in {
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
