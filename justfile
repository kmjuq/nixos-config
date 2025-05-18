# 设置 justfile 配置
set shell := ["bash", "-uc"]
# 所有变量导出到环境变量env中，调用时需要通过 env. 的方式
set export
# 别名配置
alias bmm := b-mac-mini
alias bmv := b-mac-vm

# nixos 构建命令选择
nixos-rebuild := \
if arch() == "aarch64" {
  if os() == "macos" {
    "darwin-rebuild"
  } else {
    "nixos-rebuild"
  }
} else {
  "nixos-rebuild"
}

# 默认行为
default:
  just --list --unsorted

device:
  @echo "This is an {{arch()}} {{os()}} {{os_family()}} machine"


# nix-config-tools 更新，会有本地缓存
nct-u:
  nix flake update --flake github:kmjuq/nix-config-tools

# 执行 nix-config-tools 命令
nct-fi:
  nix run github:kmjuq/nix-config-tools#default -- flake-inputs
  nix fmt

# 第一次执行构建时得用 nix run，后续命令安装后可以用 darwin-rebuild
# nix run nix-darwin/master#darwin-rebuild -- switch --flake .#mac-mini --show-trace
# 构建 mac-mini
b-mac-mini:
  {{ nixos-rebuild }} switch --flake .#mac-mini --show-trace

# 构建 mac-vm
b-mac-vm:
  nixos-rebuild switch --flake .#mac-vm --show-trace

kmjname := "kmj"
# 单个变量导出到环境变量
export kmjage := "31"
filePath := `ls | cut -f 1 | sort | head -n 1`
foo := if "hello" =~ 'hel+o' { "match" } else { "mismatch" }

# 配方 echo
echo param:
  #!/usr/bin/env bash 
  #不用时，以下每行命令都是由不同shell执行，会有变量传递问题，工作目录切换问题。所以使用时，尽量使用shebang
  # 错误忽略，命令执行错误继续执行
  -cat foo
  # 环境变量调用方式
  echo $kmjname $kmjage
  # justfile 脚本的变量调用方式
  echo {{ kmjage }}
  # 变量存储命令结果
  cat {{ filePath }} | head
  # 正则表达式匹配
  echo foo
  # 配方参数
  echo {{ param }}


# [windows] this config is only for windows os
[windows]
l:
  dir ./

# 配方依赖
[private]
a:
  echo 'A!'

b: a && d
  echo 'B!'

[private]
c:
  echo 'C!'

[private]
d:
  just c
  echo 'D!'
