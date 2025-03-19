{pkgs, ...}: {
  imports = [
    ./hyprland
    ./hyprpaper
  ];

  home.packages = with pkgs; [
    wayland
    wayland-protocols
    wayland-utils
    wl-clipboard
    # input
    fcitx5-rime
    # clipboard manager
    cliphist
    # app launcher
    # anyrun
    # terminal
    zellij
    foot
    alacritty
    # notification
    mako
    # wallpaper
    hyprpaper
    # multimedia
    pipewire
    wireplumber
  ];
}
