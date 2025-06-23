{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  selfLib = import ../lib {inherit lib;};
  selfVar = import ../self.nix;
  extraArgs = { inherit selfLib selfVar; };

  device_flake = selfLib._builtins.deviceFlake selfVar.device ../hosts "flake.nix";
  device_output_flake = device_flake.outputs;
in {
  "${device_output_flake.system-configuration}"."${selfVar.device}" = with device_output_flake; system-build-func inputs extraArgs;
  formatter.${device_output_flake.system} = nixpkgs.legacyPackages.${device_output_flake.system}.alejandra;
}
