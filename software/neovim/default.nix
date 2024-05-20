{ config, pkgs, ... }:

{
  home.file.".config/nvim" = {
    source = ../neovim;
    recursive = true;
    executable = true;
  };
}
