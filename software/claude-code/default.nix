{
  self,
  config,
  extraArgs,
  ...
}: let
  current_claude_path = "${self}/software/claude-code/settings.json";
  keys = extraArgs.keys;
  _builtins = extraArgs.selfLib._builtins;
  jsonText = _builtins.substituteFromAttr current_claude_path keys;
in {
  home.file.".claude/settings.json" = {
    text = jsonText;
    #source = config.lib.file.mkOutOfStoreSymlink "${current_claude_path}";
  };
}
