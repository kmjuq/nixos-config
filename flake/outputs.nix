{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.self-key) keys;
  # 把所有第三方函数合并到 lib 里
  extlib = {
    # 合并 nix-base64 的函数
    base64 = inputs.nix-base64.lib;
  };

  selfLib = import ../lib {inherit lib extlib;};
  selfVar = import ../self.nix;
  extraArgs = {inherit lib selfLib selfVar keys;};

  device_flake = selfLib._builtins.deviceFlake selfVar.device ../hosts "flake.nix";
  device_output_flake = device_flake.outputs;
in {
  "${device_output_flake.system-configuration}"."${selfVar.device}" = with device_output_flake; system-build-func inputs extraArgs;
  formatter.${device_output_flake.system} = nixpkgs.legacyPackages.${device_output_flake.system}.alejandra;
}
