{
  inputs,
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "hyprpaper"
      ];
      general = {
        "$mainMod" = "SUPER";
      };
      bind = [
        "$mainMod,T,exec,foot"
      ];
      source = [
        "~/.config/hypr/mocha.conf"
      ];
      env = [
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        # misc
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
      ];
    };
  };

  home.file.".config/hypr/mocha.conf".source = ./mocha.conf;

  home.packages = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal
    qt6.qtwayland
  ];
}
