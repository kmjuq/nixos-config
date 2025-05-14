{
  inputs,
  system,
  specialArgs,
  systemModules ? [],
  homeModules ? [],
  ...
}: let
  inherit (inputs) home-manager nix-darwin;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;

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
