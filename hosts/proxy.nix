{
  pkgs,
  lib,
  ...
}: {
  networking.proxy.default="http://192.168.31.199:7890";
}
