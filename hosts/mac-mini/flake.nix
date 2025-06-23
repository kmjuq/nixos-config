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
    user = rec {
      name = "kemengjian";
      dir = "/Users/${name}";
    };
  in {
    # outputs 的 formatter 要使用
    inherit system;
    system-configuration = "darwinConfigurations";
    system-build-func = inputs: extraArgs_: 
      let
        extraArgs = extraArgs_ // { inherit user;};
      in darwinSystem {
        inherit inputs extraArgs system systemModules homeModules;
      };
  };
}
