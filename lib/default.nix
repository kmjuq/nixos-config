{lib, ...}: {
  # darwin系统构建函数
  darwinSystem = import ./darwinSystem.nix;
  # nixos系统构建函数
  nixosSystem = import ./nixosSystem.nix;

  self_builtins = import ./self_builtins.nix;

  self_nixpkgs = import ./self_nixpkgs.nix {inherit lib;};
}
