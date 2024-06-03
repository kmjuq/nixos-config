set shell := ["nu","-c"]

alias b := build-mac-vm-kmj

defaut:
  just --list --unsorted

# build mac vmware
build-mac-vm-kmj:
  nixos-rebuild switch --flake .#mac-vm-kmj
