{lib, ...}: rec {
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

  # darwin系统构建函数
  darwinSystem = import ./darwinSystem.nix;
  # nixos系统构建函数
  nixosSystem = import ./nixosSystem.nix;

  # 过滤集合中不需要的value的属性
  filterAttrs =
    pred: set:
      builtins.foldl'
      (
        acc: name:
          if pred name set.${name} # 判断条件
          then acc // {${name} = set.${name};} # 符合条件则保留
          else acc
      )
      {} # 初始累加器为空集
      
      (builtins.attrNames set)
    # 遍历所有属性名
    ;
  # 获取指定路径下的所有子目录完整路径列表
  getDirPath = dir:
    builtins.map
    (entry: dir + "/${entry}") # 拼接完整路径
    
    (
      builtins.attrNames # 提取目录名列表
      
      (
        filterAttrs # 过滤目录类型
        
        (name: type: type == "directory")
        (builtins.readDir dir) # 读取原始目录内容
      )
    );
  # 获取指定路径下的所有子目录完整路径列表，是Attr格式
  getDirPathAttr = dir: filename:
    builtins.mapAttrs
    (name: value: builtins.toPath (dir + "/${name}/${filename}"))
    (
      filterAttrs # 过滤目录类型
      
      (name: type: type == "directory")
      (builtins.readDir dir) # 读取原始目录内容
    );
  # 获取指定目录下的文件的全路径
  getFilePathAttr = dir: filename: getDirPathAttr dir filename;

  # 加载nix文件
  importNixAttr = attr: builtins.mapAttrs (name: value: import value {}) attr;
}
