{
  inputs,
  username,
  system,
  systemModules,
  homeModules,
  ...
}: let
  inherit (inputs) home-manager nix-darwin;
  specialArgs = {
    inherit inputs;
    self=inputs.self;
  };
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
            backupFileExtension = "home-manager.backup";
            users."${username}".imports = homeModules;
          };
        }
      ];
  }
