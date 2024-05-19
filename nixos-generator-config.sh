parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MB 1024MB
parted /dev/sda -- mkpart swap linux-swap 1024MB 4096MB
parted /dev/sda -- mkpart root ext4 4096MB 100%
parted /dev/sda -- set 1 esp on

mkfs.fat -F 32 -n boot /dev/sda1        # (for UEFI systems only)
mkswap -L swap /dev/sda2
swapon /dev/sda2
mkfs.ext4 -L nixos /dev/sda3
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot                      # (for UEFI systems only)
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot # (for UEFI systems only)
nixos-generate-config --root /mnt
cp ./configuration.nix /mnt/etc/nixos/configuration.nix
nixos-install
