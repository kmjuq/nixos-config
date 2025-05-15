{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  self_lib = import ../lib {inherit lib;};
  self_var = import ../self.nix {inherit lib;};
  system = "aarch64-darwin";
in {
  formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
}
