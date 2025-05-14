{
  inputs,
  system,
  specialArgs,
  systemModules ? [],
  homeModules ? [],
  ...
}: let
  inherit (inputs) home-manager nixpkgs;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;

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
