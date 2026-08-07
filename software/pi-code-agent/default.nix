{
  config,
  extraArgs,
  inputs,
  pkgs,
  ...
}: {
  # In your system packages:
  environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    pi
  ];
}
