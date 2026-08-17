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
  current_ext_default_path = "${extraArgs.selfVar.flakeHome}/software/pi-code-agent/pi-extensions.default.json";
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

  # 扩展统一配置的【只读默认值】（Nix 声明式管理）。
  # 运行时可写文件 ~/.pi/agent/pi-extensions.json 由 /cfg 命令生成，不受本链接影响。
  home.file.".pi/agent/pi-extensions.default.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_ext_default_path}";
  };
}
