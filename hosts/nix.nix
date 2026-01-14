{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    just
    git
    gh
  ];

  nix = {
    settings = {
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
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
