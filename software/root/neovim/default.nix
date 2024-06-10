{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
    ./keymappings.nix
    ./options.nix
    ./plugins
  ];

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
