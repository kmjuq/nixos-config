{...}: let
  inputsFlake = import ../../flake/inputs.nix {};
in {
  inputs = {
    inherit (inputsFlake) nix-darwin;
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
