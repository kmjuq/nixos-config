{
  inputs,
  config,
  pkgs,
  lib,
  system,
  ...
}: let
  pass = "";
in {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  programs = {
    nixvim = {
      enable = true;
      enableMan = true;
      viAlias = true;
      vimAlias = true;
      #extraConfigLua = (
      #  builtins.readFile ./neovim/lua/options.lua
      #  + builtins.readFile ./neovim/lua/keymaps.lua
      #);
      extraPlugins = with pkgs.vimPlugins; [
        vim-just
        LazyVim
      ];
    };
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
    ];
  };
}
