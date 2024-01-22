{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      "mac-vm-kmj" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix
	  
	  home-manager.nixosModules.home-manager
	  {
	    home-manager = {
	      useGlobalPkgs = true;
	      useUserPackages = true;
	      users.kmj = import ./home.nix;
	    };
	  }
        ];
      };
    };
  };
}
