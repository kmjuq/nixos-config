{
  inputs,
  config,
  pkgs,
  ...
}: {
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
      settings =
        {
          format = "$all";
          palette = "catppuccin_mocha";
        }
        // builtins.fromTOML (
          builtins.readFile (
            pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "starship";
              rev = "5629d23";
              sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
            }
            + /palettes/mocha.toml
          )
        );
    };
  };

  home.packages = with pkgs; [
    neofetch
    nnn # terminal file manager

    # utils
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    yazi

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
    onedrive
    # development
    devenv
    direnv
  ];

  home.stateVersion = "24.11";
}
