{
  lib,
  extlib,
  ...
}: {
  # darwin系统构建函数
  darwinSystem = import ./darwinSystem.nix;
  # nixos系统构建函数
  nixosSystem = import ./nixosSystem.nix;

  _builtins = import ./self_builtins.nix;

  _lib = import ./self_lib.nix {inherit lib;};

  _extlib = import ./self_extlib.nix {inherit extlib;};
}
