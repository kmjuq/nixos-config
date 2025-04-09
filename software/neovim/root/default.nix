{
  inputs,
  pkgs,
  system,
  ...
}: let
  nixvimModules =
    if system == "aarch64-darwin"
    then [inputs.nixvim.nixDarwinModules]
    else [inputs.nixvim.nixosModules];
in {
  imports =
    [
      ./keymappings.nix
      ./options.nix
      ./plugins
      ./colorschemes
    ]
    ++ nixvimModules;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;

    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
      vim-just
    ];
  };
}
