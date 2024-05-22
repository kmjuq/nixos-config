{ inputs, config, pkgs, ... }:

{

  imports = [
    ./software
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
	  pkgs.fetchFromGitHub {
	    owner = "catppuccin";
	    repo = "starship";
	    rev = "5629d23";
	    sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
	  } + /palettes/mocha.toml
	)
      );
    };
  };

  home.shellAliases = {
    reboot = "systemctl reboot";
    poweroff = "systemctl poweroff";
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
    starship
    kitty
    # notification
    mako
    # status bar
    waybar
    # widgets
    eww
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
