{...}: let
  inputs = import ../../flake/inputs;
in {
  inputs = {
    inherit (inputs) hyprland disko;
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
