{ inputs, config, pkgs, lib, ... }:
let
  pass = "";
in
{
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  programs = {
    nixvim = {
      enable = true;
      enableMan = true;
      viAlias = true;
      vimAlias = true;
      extraConfigLua = (
        builtins.readFile ./neovim/lua/options.lua
        +
        builtins.readFile ./neovim/lua/keymaps.lua
      );
    };
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      git
      gh
      parted
      nix-output-monitor
      busybox
      jq
      yq-go
      coreutils-full
    ];
  };
}
