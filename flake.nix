{
  description = "The real nix file";

  inputs = {
    nix-darwin = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:nix-darwin/nix-darwin";
    };
    nixos-hardware = {url = "github:NixOS/nixos-hardware/master";};
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-unstable";};
    nixpkgs-stable = {url = "github:nixos/nixpkgs/nixos-24.11";};
    nixpkgs-unstable = {url = "github:nixos/nixpkgs/nixos-unstable";};
  };

  outputs = inputs: import ./flake/outputs.nix inputs;
}
