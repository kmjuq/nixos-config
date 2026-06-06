{
  config,
  extraArgs,
  ...
}: let
  current_claude_path = "${extraArgs.selfVar.flakeHome}/software/claude-code/claude.json";
in {
  home.file.".calude.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_claude_path}";
  };
}
