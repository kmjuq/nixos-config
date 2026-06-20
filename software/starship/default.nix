{
  self,
  config,
  pkgs,
  extraArgs,
  ...
}: let
  current_starship_path = "${self}/software/starship/starship.toml";
in {
  home.packages = with pkgs; [
    starship
  ];

  home.file.".config/starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_starship_path}";
  };
}
