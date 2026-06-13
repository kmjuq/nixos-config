{
  config,
  extraArgs,
  ...
}: let
  current_claude_path = "${extraArgs.selfVar.flakeHome}/software/claude-code/settings.json";
in {
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_claude_path}";
  };
}
