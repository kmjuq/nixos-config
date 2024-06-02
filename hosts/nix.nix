{ pkgs, lib,... }:
{
  nix = {
    settings = {
      substituters = lib.mkForce [ "https://mirrors.cernet.edu.cn/nix-channels/store" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };
  system.stateVersion = "24.05";
}
