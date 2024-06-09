{pkgs, ...}: {
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/Wallpapers/summer-night.png
    wallpaper = ,~/Wallpapers/summer-night.png
  '';
}
