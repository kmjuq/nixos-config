{
  pkgs,
  lib,
  ...
}: {
  networking.proxy.default = "http://127.0.0.1:7890";
}
