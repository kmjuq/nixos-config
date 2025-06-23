{
  device = "mac-mini";
  networking = {
    proxy = "http://192.168.31.199:7890";
  };
  git = rec {
    username = "kemengjian";
    email = "${username}@126.com";
  };
  flakeHome = "/Users/kemengjian/workspace/git/nixos-config";
}
