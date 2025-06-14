let
  self_builtins = import ./self_builtins.nix;
  self = import ../self.nix;
  device_flake = self_builtins.deviceFlake self.device ../hosts "flake.nix";
in
  device_flake.inputs
  // {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:nix-community/home-manager/release-25.05";
    };
  }
