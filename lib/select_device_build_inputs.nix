let
  self_builtins = import ./self_builtins.nix;
  self = import ../self.nix;
  device_flake = self_builtins.deviceFlake self.device ../hosts "flake.nix";
in
  device_flake.inputs
  // {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-base64.url = "github:3nol/nix-base64";
  }
  // (
    if self.needKeys or false
    then {
      self-key = {url = "git+ssh://git@github.com/kmjuq/KEY.git";};
    }
    else {}
  )
