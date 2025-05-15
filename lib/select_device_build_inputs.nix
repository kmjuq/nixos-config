let
  self_builtins = import ./self_builtins.nix;
  self = import ../self.nix;
  device_import_attr = self_builtins.importNixAttr (
    self_builtins.getFilePathAttr ../hosts "flake.nix"
  );
  device_flake = device_import_attr.${self.device};
in
  device_flake.inputs
  // {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  }
