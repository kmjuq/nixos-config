# 设置 justfile 配置
set shell := ["bash","-c"]
# 所有变量导出到环境变量env中，调用时需要通过 env. 的方式
set export
# 别名配置
alias bmvk := build-mac-vm-kmj
# 默认行为
defaut:
  just --list --unsorted

# build mac vmware
build-mac-vm-kmj:
  nixos-rebuild switch --flake .#mac-vm-kmj

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
