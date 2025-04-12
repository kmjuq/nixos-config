{
  lib,
  inputs,
  specialArgs,
  systemModules ? [],
  homeModules ? [],
  ...
}: let
  inherit (inputs) home-manager nix-darwin;
in
  nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    inherit specialArgs;

    modules =
      systemModules
      ++ [
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users.kemengjian.imports = homeModules;
          };
        }
      ];
  }
