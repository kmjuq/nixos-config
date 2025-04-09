{
  inputs,
  pkgs,
  ...
}: let
  user = "kmj";
in {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  time.timeZone = "Asia/Shanghai";

  networking = {
    hostName = user;
    extraHosts = ''
      127.0.0.1 localhost
    '';
    firewall = {
      enable = false;
      allowPing = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
      };
    };
  };

  users = {
    users = {
      ${user} = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        # password is 123
        hashedPassword = "$6$w9ELjs/WT9MLb0cu$y5NV2Ch1hYscVjIV4Zx/bihdU3aJF2uqTHHGvIvYVQBOFyxGF6cvTlHE6mBhTH5hH5MPhSHXI855tE.0JMV0k1";
        home = "/home/${user}";
      };
    };
  };
}
