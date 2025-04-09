{pkgs, ...}: {
  imports = [
    ../../software/neovim/root
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

      # command tools
      curl
      git
      gh
      jq
      yq-go
      coreutils-full
      busybox

      # parition disk
      parted

      just
      lazygit
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
