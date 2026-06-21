{
  description = "The real nix file";

  inputs = {
    home-manager = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:nix-community/home-manager/release-26.05";
    };
    nix-base64 = {url = "github:3nol/nix-base64";};
    nix-darwin = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    };
    nixos-hardware = {url = "github:NixOS/nixos-hardware/master";};
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-26.05";};
    nixpkgs-stable = {url = "github:nixos/nixpkgs/nixos-26.05";};
    nixpkgs-unstable = {url = "github:nixos/nixpkgs/nixos-unstable";};
    self-key = {url = "git+ssh://git@github.com/kmjuq/KEY.git";};
  };

  outputs = inputs: import ./flake/outputs.nix inputs;
}
