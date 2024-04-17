{ inputs, config, pkgs, lib, ... }:

let
  user = "kmj";
in
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

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
    extraHosts = 
      ''
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

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  users = {
    users = {
      ${user} = {
        isNormalUser = true;
        extraGroups = ["wheel"];
	hashedPassword = "$6$w9ELjs/WT9MLb0cu$y5NV2Ch1hYscVjIV4Zx/bihdU3aJF2uqTHHGvIvYVQBOFyxGF6cvTlHE6mBhTH5hH5MPhSHXI855tE.0JMV0k1";
	home = "/home/${user}";
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      wget
      curl
      git
      gh
      parted
      nix-output-monitor
      open-vm-tools
      mesa-demos
      mesa
      busybox
      toybox
    ];
  };
  virtualisation.vmware.guest.enable = true;
  nix = {
    settings = {
      substituters = lib.mkForce ["https://mirror.sjtu.edu.cn/nix-channels/store"];
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };
  system.stateVersion = "24.05"; 
}

