{
  pkgs,
  lib,
  ...
}: {
  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };
  };
}
