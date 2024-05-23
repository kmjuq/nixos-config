{ inputs, config, pkgs, ... }:

{

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
    settings = {
      source = [
        "~/.config/hypr/mocha.conf"
      ];
    };
  };

  home.file.".config/hypr/mocha.conf".source = ./mocha.conf;

}
