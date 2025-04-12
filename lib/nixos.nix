{
  lib,
  inputs,
  specialArgs,
  systemModules ? [],
  homeModules ? [],
  ...
}: let
  inherit (inputs) home-manager nixpkgs;
in
  nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    inherit specialArgs;

    modules =
      systemModules
      ++ [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.kmj.imports = homeModules;
          };
        }
      ];
  }
