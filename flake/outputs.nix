{
  self,
  nixpkgs,
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit lib;};
  myvars = import ../self.nix {inherit lib;};
in {
}
