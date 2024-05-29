{ pkgs, ... }:

{
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/wallpapers/summer-night.png
    wallpaper = ,~/wallpapers/summer-night.png
  '';
}
