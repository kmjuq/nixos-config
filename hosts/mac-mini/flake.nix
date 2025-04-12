{...}: let
  inputs = import ../../flake/inputs;
in {
  inputs = {
    inherit (inputs) nix-darwin;
  };

  outputs = {
    system-modules = [
      ./configuration.nix
    ];
    home-modules = [
      ./home.nix
    ];
  };
}
