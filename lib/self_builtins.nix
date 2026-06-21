rec {
  # 读取多个文件内容
  readFiles = list:
    builtins.foldl'
    (x: y: x + y)
    ""
    (
      builtins.map
      (x: builtins.readFile x)
      list
    );

  # 过滤集合中不需要的value的属性
  filterAttrs = pred: set:
    builtins.foldl'
    (
      acc: name:
        if pred name set.${name}
        then acc // {${name} = set.${name};}
        else acc
    )
    {}
    (builtins.attrNames set);

  # 获取指定路径下的所有子目录完整路径列表
  getDirPath = dir:
    builtins.map
    (entry: dir + "/${entry}")
    (
      builtins.attrNames
      (
        filterAttrs
        (name: type: type == "directory")
        (builtins.readDir dir)
      )
    );

  # 获取指定路径下的所有子目录完整路径列表，是Attr格式
  getDirPathAttr = dir: filename:
    builtins.mapAttrs
    (name: value: builtins.toPath (dir + "/${name}/${filename}"))
    (
      filterAttrs
      (name: type: type == "directory")
      (builtins.readDir dir)
    );

  # 获取指定目录下的文件的全路径
  getFilePathAttr = dir: filename: getDirPathAttr dir filename;

  # 加载nix文件
  importNixAttr = attr: builtins.mapAttrs (name: value: import value {}) attr;

  # 加载flake.nix文件
  deviceFlake = attr: dir: filename:
    builtins.getAttr
    attr
    (importNixAttr (getFilePathAttr dir filename));

  # 获取指定目录下的文件名和文件内容并形成attr,文件名不能重复
  dirFilesToAttr = dir: let
    # 读取目录内容，得到 { filename = "regular"|"directory"|... }
    contents = builtins.readDir dir;
    # 只保留常规文件
    isRegular = name: type: type == "regular";
    fileNames = builtins.attrNames contents;
    regularFiles = builtins.filter (name: isRegular name contents.${name}) fileNames;
    # 生成 name/value 列表
    toEntry = name: {
      inherit name;
      value = builtins.readFile (dir + "/${name}");
    };
  in
    builtins.listToAttrs (map toEntry regularFiles);

  # 用于根据密钥替换文件内容
  substituteFromAttr = file: attrs: let
    content = builtins.readFile file;
    keys = builtins.attrNames attrs;
    patterns = map (k: "<${k}>") keys;
    replacements = map (k: builtins.toString attrs.${k}) keys;
  in
    builtins.replaceStrings patterns replacements content;

  # 根据环境变量名列表，获取环境变量名和环境变量内容的attr对象
  getEnvVars = envNames:
    builtins.listToAttrs (
      builtins.map
      (name: {
        inherit name;
        value = builtins.getEnv name;
      })
      envNames
    );

  # 从环境变量获取 JSON 字符串并转换为 attrset
  getEnvJson = envName: let
    jsonStr = builtins.getEnv envName;
  in
    if jsonStr != ""
    then builtins.fromJSON jsonStr
    else {};

  # 安全导入 nix 文件，路径不存在时返回空对象（可自定义默认值）
  safeImport = path: default:
    if builtins.pathExists path
    then import path
    else default;
}
