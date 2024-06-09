{lib, ...}: {
  readFiles = list: (builtins.foldl' (x: y: x + y) "" (builtins.map (x: builtins.readFile x) list));
}
