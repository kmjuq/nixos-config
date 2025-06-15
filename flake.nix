{
  description = "The real nix file";

  inputs = { home-manager = { inputs = { nixpkgs = { follows = "nixpkgs"; }; }; url = "github:nix-community/home-manager/release-25.05"; }; nix-darwin = { inputs = { nixpkgs = { follows = "nixpkgs"; }; }; url = "github:nix-darwin/nix-darwin/nix-darwin-25.05"; }; nixos-hardware = { url = "github:NixOS/nixos-hardware/master"; }; nixpkgs = { url = "github:nixos/nixpkgs/nixos-25.05"; }; nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-25.05"; }; nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; }; }



;

  outputs = inputs: import ./flake/outputs.nix inputs;
}
