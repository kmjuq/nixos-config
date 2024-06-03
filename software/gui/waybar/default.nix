{pkgs, ...}: {
  home.packages = with pkgs; [
    waybar
  ];

  #programs.waybar = {
  #  enable = true;
  #  settings = builtins.fromJSON (builtins.readFile ./waybar.json);
  #  style = builtins.readFile ./waybar.css;
  #};

  home.file.".config/waybar/config".source = ./waybar.json;
  home.file.".config/waybar/style.css".source = ./waybar.css;
}
