{ config, pkgs, lib, ... }:

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

  users = {
    users = {
      ${user} = {
        isNormalUser = true;
        extraGroups = ["wheel"];
	hashedPassword = "$6$w9ELjs/WT9MLb0cu$y5NV2Ch1hYscVjIV4Zx/bihdU3aJF2uqTHHGvIvYVQBOFyxGF6cvTlHE6mBhTH5hH5MPhSHXI855tE.0JMV0k1";
	home = "/home/${user}";
	packages = with pkgs; [
 	  tree
	];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim 
    wget
    curl
    git
  ];

  nix = {
    settings = {
      substituters = lib.mkForce ["https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"];
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };
  system.stateVersion = "23.11"; 
}

