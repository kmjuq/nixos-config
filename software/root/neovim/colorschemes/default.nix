{
  pkgs,
  ...
}:
{
  
  imports = [
    ./catppuccin.nix
  ];

  programs.nixvim = {
    
    colorschemes = {
      catppuccin.enable = true;
    };

  };

}
