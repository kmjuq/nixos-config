{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
