{...} @ args: {
  inherit args;

  # nix-darwin
  nix-darwin = {
    url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # 平铺窗口管理器
  hyprland = {
    url = "github:hyprwm/Hyprland";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # 分区工具
  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
