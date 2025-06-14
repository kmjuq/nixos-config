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
}
