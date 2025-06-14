{
  inputs,
  system,
  user,
  systemModules ? [],
  homeModules ? [],
  ...
}: let
  inherit (inputs) home-manager nixpkgs;
in
  nixpkgs.lib.nixosSystem {
    specialArgs = {inherit system inputs;};

    modules =
      systemModules
      ++ [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user}.imports = homeModules;
          };
        }
      ];
  }
