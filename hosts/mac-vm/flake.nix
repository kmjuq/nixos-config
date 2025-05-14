{...}: let
  inputsFlake = import ../../flake/inputs.nix {};
in {
  inputs = {
    inherit (inputsFlake) hyprland disko;
  };

  outputs = {
    system-modules = [
      ./configuration.nix
    ];
    home-modules = [
      ./modules/user/mac-mini.nix
    ];
  };
}
