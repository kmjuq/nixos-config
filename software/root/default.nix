{
  pkgs,
  ...
}:{
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
    ];
  };
}
