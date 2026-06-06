{pkgs, ...}: {
  home.file."wallpapers" = {
    source = ../wallpapers;
    recursive = true;
  };
}
