{pkgs, ...}: {
  imports = [
    ./neovim
  ];

  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      # command line
      # nix format
      alejandra
      curl
      lazygit
      git
      gh
      parted
      nix-output-monitor
      busybox
      jq
      yq-go
      coreutils-full

      # shell
      nushell
      just
      fzf

      man-pages
      man-pages-posix
    ];
  };

  documentation = {
    enable = true;
    dev = {
      enable = true;
    };
    man = {
      enable = true;
    };
    info = {
      enable = true;
    };
    nixos = {
      enable = true;
    };
  };
}
