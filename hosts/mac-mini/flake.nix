{...}: let
  inputsFlake = import ../../flake/inputs.nix {};
  darwinSystem = import ../../lib/darwinSystem.nix;
in {
  inputs = {
    inherit (inputsFlake) nix-darwin;
  };

  outputs = let
    systemModules = [
      ./configuration.nix
      # homebrew 配置
      ../../modules/homebrew
    ];
    homeModules = [
      ./home.nix
      ../../modules/yabai
    ];
    system = "aarch64-darwin";
  in {
    inherit system;
    system-configuration = "darwinConfigurations";
    system-build-func = inputs: username:
      darwinSystem {
        inherit inputs username system systemModules homeModules;
      };
  };
}
