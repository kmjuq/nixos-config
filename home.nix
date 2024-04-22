{ inputs, config, pkgs, ... }:

{
  # 注意修改这里的用户名与用户目录
  home.username = "kmj";
  home.homeDirectory = "/home/kmj";

  programs = {
    home-manager = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "kemengjian";
      userEmail = "kemengjian@126.com";
    };
    bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
        export XDG_CURRENT_DESKTOP=Hyprland;
        export XDG_SESSION_DESKTOP=Hyprland;
        export XDG_SESSION_TYPE=wayland;
      '';
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  home.packages = with pkgs;[
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
    wayland
    wayland-protocols
    wayland-utils
    xwayland
    wlroots
    dbus
    # 如下是我常用的一些命令行工具，你可以根据自己的需要进行增删
    foot
    kitty
    firefox
    gnumake
    gcc
    rustc
    cargo
    go
    neofetch
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # misc
    cowsay
    file
    which
    tree
    gawk

    # nix related
    # it provides the command `nom` works just like `nix`
    # with more details log output

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
  ];

  home.stateVersion = "24.05";

}
