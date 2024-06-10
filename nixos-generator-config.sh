parted /dev/sda -- mklabel gpt
sleep 1;
parted /dev/sda -- mkpart ESP fat32 1 MB 1024 MB
sleep 1;
parted /dev/sda -- mkpart swap linux-swap 1024 MB 4096 MB
sleep 1;
parted /dev/sda -- mkpart root ext4 4096 MB 100%
sleep 1;
parted /dev/sda -- set 1 esp on
sleep 1;

mkfs.fat -F 32 -n boot /dev/sda1        # (for UEFI systems only)
sleep 1;
mkswap -L swap /dev/sda2
sleep 1;
swapon /dev/sda2
sleep 1;
mkfs.ext4 -L nixos /dev/sda3
sleep 1;

mount /dev/disk/by-label/nixos /mnt
sleep 1;
mkdir -p /mnt/boot                      # (for UEFI systems only)
sleep 1;
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot # (for UEFI systems only)
sleep 1;
nixos-generate-config --root /mnt

sleep 1;

nixos-install

echo "please add hardware configuration to git"
