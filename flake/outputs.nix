{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  self_lib = import ../lib {inherit lib;};
  self_var = import ../self.nix;
  device_flake = self_lib._builtins.deviceFlake self_var.device ../hosts "flake.nix";
  device_output_flake = device_flake.outputs;
in {
  "${device_output_flake.system-configuration}"."${self_var.device}" = with device_output_flake; system-build-func inputs self_var.user.name;
  formatter.${device_output_flake.system} = nixpkgs.legacyPackages.${device_output_flake.system}.alejandra;
  # inherit device_flake;
}
