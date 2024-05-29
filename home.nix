{ inputs, config, pkgs, ... }:

{

  imports = [
    ./software
    ./wallpapers
  ];
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
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
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
    foot = {
      enable = true;
      server = {
        enable = true;
      };
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        format = "$all";
        palette = "catppuccin_mocha";
      } // builtins.fromTOML (
        builtins.readFile (
          pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "starship";
              rev = "5629d23";
              sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
            } + /palettes/mocha.toml
        )
      );
    };
  };

  home.packages = with pkgs;[
    xdg-desktop-portal
    wayland
    wayland-protocols
    wayland-utils
    wlroots
    dbus
    wl-clipboard
    # display manager

    # file manager
    yazi
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
    # 如下是我常用的一些命令行工具，你可以根据自己的需要进行增删
    devenv
    gnumake
    gcc
    neofetch
    nnn # terminal file manager

    # archives
    xz

    # utils
    ripgrep # recursively searches directories for a regex pattern
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # misc
    cowsay
    file
    which
    gawk

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring

    # system tools
    sysstat
    elinks
    
    exercism
  ];

  home.stateVersion = "24.05";

}
