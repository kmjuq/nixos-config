{
  self,
  config,
  extraArgs,
  ...
}: let
  keys = extraArgs.keys;
  _builtins = extraArgs.selfLib._builtins;
  jsonText = _builtins.substituteFromAttr ./models.json keys;

  current_extensions_path = "${self}/software/pi-code-agent/extensions/";

in {
  home.file.".pi/agent/models.json" = {
    text = jsonText;
  };

  home.file.".pi/agent/extensions/" = {
    source = config.lib.file.mkOutOfStoreSymlink "${current_extensions_path}";
  };

}
