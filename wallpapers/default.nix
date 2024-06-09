{pkgs, ...}: {
  home.file."Wallpapers" = {
    source = ../wallpapers;
    recursive = true;
  };
}
