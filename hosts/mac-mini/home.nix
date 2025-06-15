{pkgs, ...} @ inputs: {
  imports = [
    ../../software/kitty
    ../../software/neovim
    ../../software/starship
  ];

  # 注意修改这里的用户名与用户目录
  home.username = "kemengjian";
  home.homeDirectory = "/Users/kemengjian";

  programs = {
    home-manager = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    hugo
    lazygit
    wget
    tree
    htop

    uv
    pnpm
  ];

  home.stateVersion = "24.11";
}
