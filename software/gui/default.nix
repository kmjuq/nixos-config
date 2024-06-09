{pkgs, ...}: {
  imports = [
    ./hyprland
    ./waybar
    ./hyprpaper
  ];

  home.packages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    wayland
    wayland-protocols
    wayland-utils
    wlroots
    wl-clipboard
    # input
    fcitx5-rime
    # clipboard manager
    cliphist
    # app launcher
    anyrun
    # terminal
    zellij
    kitty
    # notification
    mako
    # wallpaper
    hyprpaper
    # multimedia
    pipewire
    wireplumber
    # other
    qt6.qtwayland
  ];
}
