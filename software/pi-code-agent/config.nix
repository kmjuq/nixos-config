{
  config,
  extraArgs,
  ...
}: let
  keys = extraArgs.keys;
  _builtins = extraArgs.selfLib._builtins;
  jsonText = _builtins.substituteFromAttr ./models.json keys;

  current_extensions_path = "${extraArgs.selfVar.flakeHome}/software/pi-code-agent/extensions/";
  current_settings_path = "${extraArgs.selfVar.flakeHome}/software/pi-code-agent/settings.json";
  current_agents_path = "${extraArgs.selfVar.flakeHome}/software/pi-code-agent/AGENTS.md";
in {
  home.file.".pi/agent/models.json" = {
    text = jsonText;
  };

  home.file.".pi/agent/extensions/" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_extensions_path}";
  };

  home.file.".pi/agent/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_settings_path}";
  };

  home.file.".pi/agent/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_agents_path}";
  };
}
