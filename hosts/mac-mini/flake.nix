{...}: let
  inputsFlake = import ../../flake/inputs.nix {};
in {
  inputs = {
    inherit (inputsFlake) nix-darwin;
  };

  outputs = {
    system-build-func = import ../../lib/darwinSystem.nix;
    system-modules = [
      ./configuration.nix
    ];
    home-modules = [
      ./home.nix
    ];
  };
}
