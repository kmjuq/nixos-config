{pkgs,extraArgs, ...} @ inputs: {
  imports = [
    ../../software/kitty
    ../../software/neovim
    ../../software/starship
  ];

  # 注意修改这里的用户名与用户目录
  home.username = "${extraArgs.user.name}";
  home.homeDirectory = "${extraArgs.user.dir}";

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

  home.stateVersion = "25.05";
}
