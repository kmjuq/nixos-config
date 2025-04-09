{
  inputs,
  config,
  pkgs,
  ...
}: {
  # 注意修改这里的用户名与用户目录
  home.username = "kemengjian";
  home.homeDirectory = "/Users/kemengjian";

  programs = {
    home-manager = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    # productivity
    hugo # static site generator
    just
    lazygit
  ];

  home.stateVersion = "24.11";
}
