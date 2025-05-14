{
  description = "The real nix file";

  inputs = let
    self_lib = import ./lib/default.nix {lib = {};};
    self = import ./self.nix;
    device_import_attr = self_lib.importNixAttr (
      self_lib.getFilePathAttr ./hosts "flake.nix"
    );
    device_flake = device_import_attr.${self.device};
  in
    device_flake.inputs
    // {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "aarch64-darwin";
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
