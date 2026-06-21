{extlib, ...}: rec {
  # base64
  toBase64 = str: extlib.base64.toBase64 str;
  fromBase64 = str: extlib.base64.fromBase64 str;

  # 将环境变量中base64编码的json字符串转换为属性集
  jsonBase64ToAttr = envName: let
    jsonStr = fromBase64 (builtins.getEnv envName);
  in
    if jsonStr != ""
    then builtins.fromJSON jsonStr
    else {};
}
