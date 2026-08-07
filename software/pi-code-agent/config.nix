{
  self,
  config,
  extraArgs,
  ...
}: let
  keys = extraArgs.keys;
  _builtins = extraArgs.selfLib._builtins;
  jsonText = _builtins.substituteFromAttr ./models.json keys;
in {
  home.file.".pi/agent/models.json" = {
    text = jsonText;
  };
}
