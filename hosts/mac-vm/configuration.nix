{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../nix.nix
    ../fonts.nix
    ../proxy.nix
    ../basic.nix
  ];

  hardware.graphics = {
    package = pkgs.mesa;
    enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      open-vm-tools
      mesa
    ];
  };

  virtualisation.vmware.guest.enable = true;
}
