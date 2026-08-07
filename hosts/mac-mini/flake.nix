{...}: let
  inputsFlake = import ../../flake/inputs.nix {};
  darwinSystem = import ../../lib/darwinSystem.nix;
in {
  inputs = {
    inherit (inputsFlake) nix-darwin llm-agents;
  };

  outputs = let
    systemModules = [
      ./configuration.nix
      # homebrew 配置
      ../../modules/homebrew
      ../nix.nix
      ../../software/pi-code-agent
    ];
    homeModules = [
      ./home.nix
      ../../modules/yabai
      ../../software/kitty
      ../../software/neovim
      ../../software/starship
      ../../software/pi-code-agent/config.nix
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
    system-build-func = inputs: extraArgs_: let
      extraArgs = extraArgs_ // {inherit user;};
    in
      darwinSystem {
        inherit inputs extraArgs system systemModules homeModules;
      };
  };
}
